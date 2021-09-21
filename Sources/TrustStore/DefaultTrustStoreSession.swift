//
//  Copyright (c) 2021 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Combine
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
        httpClient: HTTPClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
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

// [REQ:gemSpec_Krypt:A_21218,A_21222]
extension DefaultTrustStoreSession: TrustStoreSession {
    public func reset() {
        trustStoreStorage.set(certList: nil)
        trustStoreStorage.set(ocspList: nil)
    }

    public func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        loadOCSPCheckedTrustStore()
            .map(\.vauCert)
            .eraseToAnyPublisher()
    }

    public func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError> {
        loadOCSPCheckedTrustStore()
            .map { trustStore in
                trustStore.containsEECert(certificate)
            }
            .eraseToAnyPublisher()
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
    func loadOCSPCheckedTrustStore() -> AnyPublisher<OCSPCheckedX509TrustStore, TrustStoreError> {
        loadOCSPResponses()
            .first()
            .flatMap { [weak self] (ocspResponses: [OCSPResponse])
                -> AnyPublisher<OCSPCheckedX509TrustStore, TrustStoreError> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.trustStoreStorage.certList
                    .first()
                    .setFailureType(to: TrustStoreError.self)
                    .flatMap { (certList: CertList?) -> AnyPublisher<OCSPCheckedX509TrustStore, TrustStoreError> in
                        // if match(ocsp, storage.truststore) -> return storage.truststore
                        if let certList = certList,
                           let trustStore = try? X509TrustStore(trustAnchor: self.trustAnchor, certList: certList),
                           let ocspValid = try? trustStore.checkEeCertificatesStatus(with: ocspResponses),
                           ocspValid == true {
                            return Just(OCSPCheckedX509TrustStore.from(trustStore: trustStore))
                                .setFailureType(to: TrustStoreError.self)
                                .eraseToAnyPublisher()
                        }
                        // else load trustStore from remote
                        else {
                            self.trustStoreStorage.set(certList: nil)
                            return self.trustStoreClient // swiftlint:disable:this trailing_closure
                                .loadCertListFromServer()
                                .first()
                                .tryMap { (certList: CertList)
                                    -> (trustStore: X509TrustStore, certList: CertList) in
                                    // if match(ocsp, network.truststore) -> return remote.truststore
                                    guard let trustStore = try? X509TrustStore(
                                        trustAnchor: self.trustAnchor,
                                        certList: certList
                                    ),
                                        let ocspValid = try? trustStore
                                        .checkEeCertificatesStatus(with: ocspResponses),
                                        ocspValid == true
                                    else {
                                        throw TrustStoreError.eeCertificateOCSPStatusVerification
                                    }
                                    return (trustStore: trustStore, certList: certList)
                                }
                                .handleEvents(receiveOutput: { [weak self] renewed in
                                    self?.trustStoreStorage.set(certList: renewed.certList)
                                })
                                .map { (trustStore: X509TrustStore, _: CertList) -> OCSPCheckedX509TrustStore in
                                    OCSPCheckedX509TrustStore.from(trustStore: trustStore)
                                }
                                .mapError { $0.asTrustStoreError() }
                                .eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // [REQ:gemSpec_Krypt:A_21218]
    func loadOCSPResponses() -> AnyPublisher<[OCSPResponse], TrustStoreError> {
        trustStoreStorage.ocspList
            .first()
            .setFailureType(to: TrustStoreError.self)
            .flatMap { [weak self] (ocspList: OCSPList?) -> AnyPublisher<[OCSPResponse], TrustStoreError> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                if let ocspList = ocspList,
                   let ocspResponses = try? ocspList.responses.map({ try OCSPResponse(der: $0) }),
                   // [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, we must request new ones
                   ocspResponses
                   .allSatisfyNotProducedBefore(date: self.time()
                       .addingTimeInterval(-Self.ocspResponseExpiration)) {
                    return Just(ocspResponses)
                        .setFailureType(to: TrustStoreError.self)
                        .eraseToAnyPublisher()
                } else {
                    self.trustStoreStorage.set(ocspList: nil)
                    return self.trustStoreClient // swiftlint:disable:this trailing_closure
                        .loadOCSPListFromServer()
                        .first()
                        .tryMap { (ocspList: OCSPList) -> (ocspResponses: [OCSPResponse], ocspList: OCSPList) in
                            guard let ocspResponses = try? ocspList.responses
                                .map({ try OCSPResponse(der: $0) }),
                                // [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, ...
                                ocspResponses
                                .allSatisfyNotProducedBefore(date: self.time()
                                    .addingTimeInterval(-Self.ocspResponseExpiration))
                            else {
                                throw TrustStoreError.invalidOCSPResponse
                            }
                            return (ocspResponses, ocspList)
                        }
                        .handleEvents(receiveOutput: { [weak self] renewed in
                            self?.trustStoreStorage.set(ocspList: renewed.ocspList)
                        })
                        .map { (ocspResponses: [OCSPResponse], _: OCSPList) -> [OCSPResponse] in
                            ocspResponses
                        }
                        .mapError { $0.asTrustStoreError() }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Collection where Element == OCSPResponse {
    // [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, we must request new ones
    func allSatisfyNotProducedBefore(date: Date) -> Bool {
        allSatisfy { ocspResponse in
            guard let producedAt = try? ocspResponse.producedAt() else {
                return false
            }
            return producedAt.timeIntervalSince(date) > 0
        }
    }
}

extension X509TrustStore {
    func containsEECert(_ certificate: X509) -> Bool {
        vauCert == certificate || idpCerts.contains { $0 == certificate }
    }

    var eeCerts: [X509] { [vauCert] + idpCerts }
}
