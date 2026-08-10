//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Foundation
import HTTPClient
import OpenSSL

/// Function that returns the current date/now
public typealias TrustStoreTimeProvider = () -> Date

/// TrustStoreSession acts as an interactor/mediator for the TrustStoreClient and TrustStoreStorage
public class DefaultTrustStoreSession {
    private let serverURL: URL
    private let trustStoreStorage: TrustStoreStorage
    private let trustStoreClient: TrustStoreClient
    private let time: TrustStoreTimeProvider
    private let trustAnchor: TrustAnchor

    static let ocspResponseExpiration: TimeInterval = 60 * 60 * 12

    /// Initialize a Truststore Session
    ///
    /// - Parameters:
    ///   - serverURL: the server URL
    ///   - trustAnchor: Trust Anchor (root certificate) for further certificate validation
    ///   - trustStoreStorage: the backing session storage
    ///   - httpClient: the HTTP client
    public convenience init(
        serverURL: URL,
        trustAnchor: TrustAnchor,
        trustStoreStorage: TrustStoreStorage,
        httpClient: HTTPClient
    ) {
        self.init(
            serverURL: serverURL,
            trustAnchor: trustAnchor,
            trustStoreStorage: trustStoreStorage,
            trustStoreClient: RealTrustStoreClient(serverURL: serverURL, httpClient: httpClient)
        )
    }

    /// Initialize a Truststore Session
    ///
    /// - Parameters:
    ///   - serverURL: the server URL
    ///   - trustAnchor: Trust Anchor (root certificate) for further certificate validation
    ///   - trustStoreStorage: the backing session storage
    ///   - trustStoreClient: TrustStore Client
    ///   - time: the time provider
    required init(
        serverURL: URL,
        trustAnchor: TrustAnchor,
        trustStoreStorage: TrustStoreStorage,
        trustStoreClient: TrustStoreClient,
        time: @escaping TrustStoreTimeProvider = Date.init
    ) {
        self.serverURL = serverURL
        self.trustAnchor = trustAnchor
        self.trustStoreStorage = trustStoreStorage
        self.trustStoreClient = trustStoreClient
        self.time = time
    }
}

// [REQ:gemSpec_Krypt:A_21218,A_21222#2] `DefaultTrustStoreSession` coordinates loading and validity checking
extension DefaultTrustStoreSession: TrustStoreSession {
    public func reset() {
        trustStoreStorage.set(pkiCertificates: nil)
        trustStoreStorage.set(vauCertificate: nil)
        trustStoreStorage.resetOcspResponses()
    }

    public func vauCertificate() async throws -> X509 {
        let trustStore = try await loadOcspCheckedTrustStore()
        return trustStore.vauCert
    }

    // [REQ:gemSpec_eRp_FdV:A_19739]
    public func validate(eeCertificate: X509) async throws -> Bool {
        let trustStore = try await loadOcspCheckedTrustStore()
        if !trustStore.validate(certificate: eeCertificate, validationTime: time()) {
            return false
        }
        // Check certificate against the locally stored OCSP response (if available)
        guard
            let issuerCN = try? eeCertificate.issuerCn(),
            let serialNr = try? eeCertificate.serialNumber()
        else {
            throw TrustStoreError.malformedCertificate
        }

        if let localOcspData = trustStoreStorage.getOcspResponse(issuerCn: issuerCN, serialNr: serialNr),
           let localOcspBase64 = String(data: localOcspData, encoding: .utf8),
           let localOcspDecoded = Data(base64Encoded: localOcspBase64),
           let localOcsp = try? OCSPResponse(der: localOcspDecoded),
           // Ensure grace-period freshness
           localOcsp.notProducedBefore(date: time().addingTimeInterval(-Self.ocspResponseExpiration)) {
            return try trustStore.checkEeCertificateStatus(
                eeCertificate: eeCertificate,
                ocspResponse: localOcsp,
                validationTime: time()
            )
        }

        // If not available or outdated, request the OCSP response from the server
        let remoteOcsp = try await loadGracePeriodCheckedOcspResponseFromServer(
            issuerCn: issuerCN,
            serialNr: serialNr
        )
        return try trustStore.checkEeCertificateStatus(
            eeCertificate: eeCertificate,
            ocspResponse: remoteOcsp,
            validationTime: time()
        )
    }
}

struct OCSPCheckedX509TrustStore {
    let trustStore: X509TrustStore

    var vauCert: X509 {
        trustStore.vauCert
    }

    func containsEECert(_ certificate: X509) -> Bool {
        trustStore.containsEECert(certificate)
    }

    static func from(trustStore: X509TrustStore) -> Self {
        OCSPCheckedX509TrustStore(trustStore: trustStore)
    }
}

extension DefaultTrustStoreSession {
    // swiftlint:disable:next function_body_length
    func loadOcspCheckedTrustStore() async throws -> X509TrustStore {
        // Case1: TrustStore certificate data is locally available (OSCPResponse may be requested from remote)
        //        and validates successfully
        if
            let localPkiCertificates = trustStoreStorage.getPKICertificates(),
            let localVauCertData = trustStoreStorage.getVauCertificate(),
            let vauCert = try? X509(der: localVauCertData),
            let vauCertIssuerCN = try? vauCert.issuerCn(),
            let vauCertSerialNr = try? vauCert.serialNumber(),
            let ocspUncheckedTrustStore = try? X509TrustStore(
                trustAnchor: trustAnchor,
                pkiCertificates: localPkiCertificates,
                vauCertData: localVauCertData,
                validationTime: time()
            ) {
            let vauCertOCSPResponse = try await loadCurrentVauCertificateOcspResponse(
                issuerCn: vauCertIssuerCN,
                serialNr: vauCertSerialNr
            )

            // [REQ:gemSpec_Krypt:A_25060#1] OCSPResponse must be validated by current TrustStore ("Kategorie (B)")
            // [REQ:gemSpec_Krypt:A_25061] Check VAU Certificate ("Kategorie (C)") with OCSPResponse
            if let ocspValid = try? ocspUncheckedTrustStore.checkEeCertificatesStatus(with: [vauCertOCSPResponse]),
               ocspValid {
                return ocspUncheckedTrustStore
            }
        }

        // Case2: TrustStore not locally available
        //      OR validation of VAU certificate has failed
        // --> load all data from remote and build a new TrustStore from it

        // [REQ:gemSpec_Krypt:A_25058] Initial TrustStore creation
        // [REQ:gemSpec_Krypt:A_25063] Re-init TrustStore if certificate validation has failed, then validate it again
        // Reset all locally saved data
        reset()

        let rootSubjectCn = try trustAnchor.certificate.subjectCN()
        let remotePkiCertificates = try await trustStoreClient
            .loadPKICertificatesFromServer(rootSubjectCn: rootSubjectCn)
        let remoteVauCertData = try await trustStoreClient.loadVauCertificateFromServer()

        guard
            let vauCert = try? X509(der: remoteVauCertData),
            let vauCertIssuerCN = try? vauCert.issuerCn(),
            let vauCertSerialNr = try? vauCert.serialNumber()
        else {
            throw TrustStoreError.internal(error: .vauCertificateUnexpectedFormat)
        }
        guard let ocspUncheckedTrustStore = try? X509TrustStore(
            trustAnchor: trustAnchor,
            pkiCertificates: remotePkiCertificates,
            vauCertData: remoteVauCertData,
            validationTime: time()
        )
        else {
            throw TrustStoreError.internal(error: .trustAnchorUnexpectedFormat)
        }
        let vauCertOCSPResponse = try await loadGracePeriodCheckedOcspResponseFromServer(
            issuerCn: vauCertIssuerCN,
            serialNr: vauCertSerialNr
        )

        // [REQ:gemSpec_Krypt:A_25060#2] OCSPResponse must be validated by current TrustStore ("Kategorie (B)")
        // [REQ:gemSpec_Krypt:A_25061] Check VAU Certificate ("Kategorie (C)") with OCSPResponse
        guard let ocspValid = try? ocspUncheckedTrustStore.checkEeCertificatesStatus(with: [vauCertOCSPResponse]),
              ocspValid
        else {
            throw TrustStoreError.noValidVauCertificateAvailable
        }
        trustStoreStorage.set(pkiCertificates: remotePkiCertificates)
        trustStoreStorage.set(vauCertificate: remoteVauCertData)

        return ocspUncheckedTrustStore
    }

    // [REQ:gemSpec_Krypt:A_21216#1] Obtain OCSPResponse for VAU certificate from Fachdienst
    /// Load the OCSP Response for the VAU encryption certificate
    ///
    /// - Parameters:
    ///  - issuerCn: Common name (CN) of the issuer of the certificate the OCSP response is requested for
    ///  - serialNr: Serial number (a positive integer) of the certificate the OCSP response is requested for
    /// - Note: Thrown errors are of type `TrustStoreError`
    /// - Returns: OCSPResponse
    func loadCurrentVauCertificateOcspResponse(
        issuerCn: String,
        serialNr: String
    ) async throws -> OCSPResponse {
        let localVauCertOcspResponse = trustStoreStorage.getOcspResponse(issuerCn: issuerCn, serialNr: serialNr)
        if
            let localVauCertOcspResponse,
            let localVauCertOcspResponseBase64 = String(data: localVauCertOcspResponse, encoding: .utf8),
            let localVauCertOcspResponseDecoded = Data(base64Encoded: localVauCertOcspResponseBase64),
            let ocspResponse = try? OCSPResponse(der: localVauCertOcspResponseDecoded),
            // [REQ:gemSpec_Krypt:A_21216#2] OCSPResponse not older than OCSP-Graceperiod=12h else request a new one
            ocspResponse.notProducedBefore(date: time().addingTimeInterval(-Self.ocspResponseExpiration)) {
            // Locally saved OCSP response is available and still valid
            return ocspResponse
        } else {
            return try await loadGracePeriodCheckedOcspResponseFromServer(
                issuerCn: issuerCn,
                serialNr: serialNr
            )
        }
    }

    func loadGracePeriodCheckedOcspResponseFromServer(
        issuerCn: String,
        serialNr: String
    ) async throws -> OCSPResponse {
        trustStoreStorage.setOcspResponse(issuerCn: issuerCn, serialNr: serialNr, ocspResponse: nil)
        let remoteVauCertOcspResponse = try await trustStoreClient.loadOcspResponseFromServer(
            issuerCn: issuerCn,
            serialNr: serialNr
        )
        guard
            let remoteVauCertOcspResponseBase64 = String(data: remoteVauCertOcspResponse, encoding: .utf8),
            let remoteVauCertOcspResponseDecoded = Data(base64Encoded: remoteVauCertOcspResponseBase64),
            let ocspResponse = try? OCSPResponse(der: remoteVauCertOcspResponseDecoded),
            // [REQ:gemSpec_Krypt:A_21216#3] OCSPResponse not older than OCSP-Graceperiod=12h else decline
            // [REQ:gemSpec_Krypt:A_25059] OCSPResponse not older than OCSP-Graceperiod=12h else decline
            ocspResponse.notProducedBefore(date: time().addingTimeInterval(-Self.ocspResponseExpiration))
        else {
            throw TrustStoreError.invalidOCSPResponse
        }
        trustStoreStorage.setOcspResponse(
            issuerCn: issuerCn,
            serialNr: serialNr,
            ocspResponse: remoteVauCertOcspResponse
        )
        return ocspResponse
    }
}

extension Collection<OCSPResponse> {
    // [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, we must request new ones
    func allSatisfyNotProducedBefore(date: Date) -> Bool {
        allSatisfy { ocspResponse in
            ocspResponse.notProducedBefore(date: date)
        }
    }
}

extension OCSPResponse {
    func notProducedBefore(date: Date) -> Bool {
        guard let producedAt = try? producedAt() else {
            return false
        }
        return producedAt.timeIntervalSince(date) > 0
    }
}

extension X509TrustStore {
    func containsEECert(_ certificate: X509) -> Bool {
        vauCert == certificate || idpCerts.contains { $0 == certificate }
    }

    var eeCerts: [X509] {
        [vauCert] + idpCerts
    }
}
