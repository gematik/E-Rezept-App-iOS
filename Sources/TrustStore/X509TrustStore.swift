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
import OpenSSL

struct X509TrustStore {
    // [REQ:gemSpec_Krypt:A_21218]
    // [REQ:gemSpec_Krypt:A_24470]
    // [REQ:gemSpec_eRp_FdV:A_20032-01]
    // Category A: Cross root certificates
    let rootCa: X509
    let addRoots: [X509]

    // Category B: Certificate Authority certificates
    let caCerts: [X509]

    // Category C: The VAU certificate
    let vauCert: X509

    // Category D: IDP certificates
    let idpCerts: [X509]

    init(trustAnchor: X509, addRoots: [X509], caCerts: [X509], eeCerts: [X509]) throws {
        rootCa = trustAnchor

        // Category A:
        // Before adding an addRoot we check if it can be validated by the currently potential trust store.
        // We expect the incoming addRoots to be chronically ordered (i.e. ["RCA3->RCA4", "RCA4->RCA5", ...])
        //  so a simple forEach loop is already sufficient here. See also gemSpec_Krypt A_21216.
        var validatedAddRoots: [X509] = []
        try addRoots.forEach { addRoot in
            if try addRoot.validateWith(trustStore: [trustAnchor] + validatedAddRoots) {
                validatedAddRoots.append(addRoot)
            }
        }
        self.addRoots = validatedAddRoots

        // Category B:
        self.caCerts = Self.filter(caCerts: caCerts, trusting: [rootCa] + addRoots)

        // Category C and D:
        let vauAndIdpCerts = Self.filter(eeCerts: eeCerts, trusting: [rootCa] + addRoots + self.caCerts)
        guard let vauCert = vauAndIdpCerts.vauCerts.first, vauAndIdpCerts.vauCerts.count == 1 else {
            throw TrustStoreError.noCertificateFound
        }
        self.vauCert = vauCert
        idpCerts = vauAndIdpCerts.idpCerts
    }

    init(trustAnchor: TrustAnchor, certList: CertList) throws {
        // Expect certificates to be DER formatted
        let addRoots = certList.addRoots.compactMap { try? X509(der: $0) }
        let caCerts = certList.caCerts.compactMap { try? X509(der: $0) }
        let eeCerts = certList.eeCerts.compactMap { try? X509(der: $0) }

        try self.init(trustAnchor: trustAnchor.certificate, addRoots: addRoots, caCerts: caCerts, eeCerts: eeCerts)
    }

    init(trustAnchor: TrustAnchor, pkiCertificates: PKICertificates, vauCertData: Data) throws {
        // Expect certificates to be DER formatted
        let addRoots = pkiCertificates.addRoots.compactMap { try? X509(der: $0) }
        let caCerts = pkiCertificates.caCerts.compactMap { try? X509(der: $0) }
        guard let vauCert = try? X509(der: vauCertData)
        else {
            throw TrustStoreError.internal(error: .vauCertificateUnexpectedFormat)
        }
        try self.init(
            trustAnchor: trustAnchor.certificate,
            addRoots: addRoots,
            caCerts: caCerts,
            eeCerts: [vauCert]
        )
    }

    var certList: CertList {
        let addRoots = self.addRoots.compactMap(\.derBytes)
        let caCerts = self.caCerts.compactMap(\.derBytes)
        let eeCerts = ([vauCert] + idpCerts).compactMap(\.derBytes)
        return CertList(addRoots: addRoots, caCerts: caCerts, eeCerts: eeCerts)
    }

    var pkiCertificates: PKICertificates {
        let addRoots = self.addRoots.compactMap(\.derBytes)
        let caCerts = self.caCerts.compactMap(\.derBytes)
        return PKICertificates(addRoots: addRoots, caCerts: caCerts)
    }

    func validate(certificate: X509) -> Bool {
        guard let result = try? certificate.validateWith(trustStore: [rootCa] + addRoots + caCerts)
        else {
            return false
        }
        return result
    }
}

extension X509TrustStore {
    /// Match a collection of `OCSPResponse`s with the end entity certificates of this `X509TrustStore`.
    /// Checks response status, revocation status for each certificate and validates the signer certificates of
    ///   the responses itself.
    ///
    /// [REQ:gemSpec_Krypt:A_21218]
    /// [REQ:gemSpec_eRp_FdV:A_20032-01]
    ///
    /// - Note: This function assumes that up-to-dateness of the responses itself has already been checked.
    ///
    /// - Returns: true on successful matching/validation, false if not successful or error
    func checkEeCertificatesStatus(with ocspResponses: [OCSPResponse]) throws -> Bool {
        // [REQ:gemSpec_Krypt:A_21218] OCSP responder certificates must be verifiable by the TrustStore
        // [REQ:gemSpec_Krypt:A_25060#3] OCSP responder certificates must be verifiable by the TrustStore
        let verifiedOCSPResponses = basicVerifyFilter(ocspResponses: ocspResponses)
        guard
            !verifiedOCSPResponses.isEmpty,
            verifiedOCSPResponses.allSatisfy({ $0.status() == .successful })
        else { return false }

        let eeCertAndSignerTuple: [(X509, X509)] = try eeCerts.map { eeCertificate -> (X509, X509) in
            try (eeCertificate, retrieveSignerFromCaCertificates(eeCertificate: eeCertificate))
        }

        // [REQ:gemSpec_Krypt:A_21218] For every EE certificate there must be a matching OCSP response
        let matchedResponses = try eeCertAndSignerTuple.map { eeCertificate, signer in
            try verifiedOCSPResponses.first { response in
                try response.certificateStatus(for: eeCertificate, issuer: signer) == OCSPResponse.CertStatus.good
            }
        }
        guard matchedResponses.allSatisfy({ $0 != nil })
        else { return false }

        // [REQ:gemSpec_Krypt:A_21218] For every OCSP response there must be a matching EE certificate
        let matchedEeCerts = try ocspResponses.map { response in
            try eeCertAndSignerTuple.first { eeCertificate, signer in
                try response.certificateStatus(for: eeCertificate, issuer: signer) == OCSPResponse.CertStatus.good
            }
        }
        guard matchedEeCerts.allSatisfy({ $0 != nil }) else { return false }

        return true
    }

    // [REQ:gemSpec_Krypt:A_21218] OCSP responder certificates must be verifiable by the TrustStore
    // [REQ:gemSpec_Krypt:A_25060#4] OCSP responder certificates must be verifiable by the TrustStore
    private func basicVerifyFilter(ocspResponses: [OCSPResponse]) -> [OCSPResponse] {
        ocspResponses.filter { ocspResponse in
            if let ocspResponseSigner = try? ocspResponse.getSigner(),
               self.validate(certificate: ocspResponseSigner) {
                return true
            }
            return false
        }
    }

    private func retrieveSignerFromCaCertificates(eeCertificate: X509) throws -> X509 {
        guard let signer = caCerts.first(where: { $0.issued(eeCertificate) }) else {
            throw TrustStoreError.internal(error: .missingSignerForEECertificate)
        }
        return signer
    }
}

// Helping functions to filter proper certificates before adding them to the trust store
extension X509TrustStore {
    // [REQ:gemSpec_Krypt:A_21218:(3)] Check ca_certs against category A certificates
    private static let caCertRegex =
        try! NSRegularExpression(pattern: "CN=GEM\\.KOMP-CA\\d+") // swiftlint:disable:this force_try

    static func filter(caCerts: [X509], trusting trustStore: [X509]) -> [X509] {
        caCerts.filter { caCert in
            guard let chainCheck = try? caCert.validateWith(trustStore: trustStore),
                  let subjectOneLine = try? caCert.subjectOneLine()
            else {
                return false
            }

            let commonNameCheck = !Self.caCertRegex.matches(
                in: subjectOneLine,
                range: NSRange(location: 0, length: subjectOneLine.count)
            ).isEmpty
            return chainCheck && commonNameCheck
        }
    }

    // [REQ:gemSpec_Krypt:A_21218:(4)] Check ee_certs against category A+B certificates
    // [REQ:gemSpec_Krypt:A_A_25061] Check ee_certs against category A+B certificates
    typealias VauAndIpdCerts = (vauCerts: [X509], idpCerts: [X509])
    static func filter(eeCerts: [X509], trusting trustStore: [X509]) -> VauAndIpdCerts {
        eeCerts.reduce(([X509](), [X509]())) { vauAndIdpCerts, eeCert in
            guard
                let chainCheck = try? eeCert.validateWith(trustStore: trustStore),
                chainCheck == true
            else {
                return vauAndIdpCerts
            }

            let (vauCerts, idpCerts) = vauAndIdpCerts
            if eeCert.contains(oidBytes: .oidErpVau) {
                return (vauCerts + [eeCert], idpCerts)
            } else if eeCert.contains(oidBytes: .oidIdpd) { // [REQ:gemSpec_IDP_Frontend:A_20623,A_20625#4] oid check
                return (vauCerts, idpCerts + [eeCert])
            }

            return (vauCerts, idpCerts)
        }
    }
}

extension X509 {
    enum OidBytes {
        case oidErpVau // 1.2.276.0.76.4.258 == 0x06082A8214004C048202
        // [REQ:gemSpec_IDP_Frontend:A_20623] IDP oid
        case oidIdpd // 1.2.276.0.76.4.260 == 0x06082A8214004C048204
    }

    func contains(oidBytes: OidBytes) -> Bool {
        switch oidBytes {
        case .oidErpVau:
            let vauOidBytes = Data([0x06, 0x08, 0x2A, 0x82, 0x14, 0x00, 0x4C, 0x04, 0x82, 0x02])
            return derBytes?.range(of: vauOidBytes) != nil
        case .oidIdpd:
            let idpdOidBytes = Data([0x06, 0x08, 0x2A, 0x82, 0x14, 0x00, 0x4C, 0x04, 0x82, 0x04])
            return derBytes?.range(of: idpdOidBytes) != nil
        }
    }
}
