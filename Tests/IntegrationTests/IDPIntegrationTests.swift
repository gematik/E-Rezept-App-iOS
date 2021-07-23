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

import ASN1Kit
import Combine
@testable import eRpApp
import Foundation
import HTTPClient
@testable import IDP
import Nimble
import OpenSSL
import Security
import TestUtils
import TrustStore
import XCTest

/// Runs IDP Integration Tests.
/// Set `IDP_URL` in runtime environment to setup idp server url.
final class IDPIntegrationTests: XCTestCase {
    func testCompleteFlow() {
        let signer = try! Brainpool256r1Signer(
            x5c: Bundle(for: Self.self)
                .path(forResource: "x509-ec-bp256r1", ofType: "cer", inDirectory: "Certificates.bundle")!,
            key: Bundle(for: Self.self)
                .path(forResource: "x509-ec-key-bp256r1", ofType: "bin", inDirectory: "Certificates.bundle")!
        )

        let idpURLString = ProcessInfo.processInfo
            .environment["IDP_URL"] ??
            "https://idp-test.zentral.idp.splitdns.ti-dienste.de/.well-known/openid-configuration"
//             "https://idp.dev.gematik.solutions/discoveryDocument"

        let storage = MemStorage()
        let configuration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURL: URL(string: "https://redirect.gematik.de/erezept")!,
            discoveryURL: URL(string: idpURLString)!,
            scopes: ["e-rezept", "openid"]
        )
        let httpClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral,
                                           interceptors: [
                                               AdditionalHeaderInterceptor(additionalHeader: [
                                               ]),
                                               LoggingInterceptor(log: .body),
                                           ])

        let trustStoreSession = MockTrustStoreSession()
        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())
        let session = DefaultIDPSession(
            config: configuration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession
        )
        var success = false
        var token: IDPToken!
        session.requestChallenge()
            .flatMap { challenge in
                challenge.sign(with: signer, using: signer.certificates)
                    .mapError { $0.asIDPError() }
            }
            .flatMap { signedChallenge in
                session.verifyAndExchange(signedChallenge: signedChallenge)
            }
            .test(expectations: { idpToken in
                    success = true
                    Swift.print("token access", idpToken.accessToken)
                    Swift.print("token id", idpToken.idToken)
                    Swift.print("token sso: '\(idpToken.ssoToken ?? "<empty>")'")
                    token = idpToken
                  }, subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(success) == true

        guard token != nil else {
            fail("token must not be nil")
            return
        }
        expect(token).toNot(beNil())

        // sso refresh
        success = false
        session.refresh(token: token)
            .test(expectations: { idpToken in
                success = true
                Swift.print("token access", idpToken.accessToken)
                Swift.print("token id", idpToken.idToken)
                Swift.print("token sso: '\(idpToken.ssoToken ?? "<empty>")'")
            }, subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler())

        expect(success) == true

        // invalid sso refresh

        var elements = token.ssoToken!.split(separator: Character("."), omittingEmptySubsequences: false)
        elements[0] = "eyJlbmMiOiJBMjU2R0NNIiwiY3R5IjoiTkpXVCIsImV4cCI6MTYxODQ5MjE0MSwiYWxnIjoiZGlyIiwia2lkIjoiMDAwMSJ9"

        let newSSOToken: String = elements.joined(separator: ".")

        token = IDPToken(
            accessToken: token.accessToken,
            expires: token.expires,
            idToken: token.idToken,
            ssoToken: newSSOToken,
            tokenType: token.tokenType
        )

        success = false
        session.refresh(token: token)
            .test(failure: { _ in
                success = true
            }, expectations: { _ in
                fail("token should not be valid")
            },
                  subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler())

        expect(storage.tokenState.value).to(beNil())

        expect(success) == true
    }

    class BiometricsSHA256Signer: JWTSigner {
        let privateKeyContainer: PrivateKeyContainer

        init(privateKeyContainer: PrivateKeyContainer) throws {
            self.privateKeyContainer = privateKeyContainer
        }

        var certificates: [Data] {
            [Data()]
        }

        enum Error: Swift.Error {
            case sessionClosed
            case signatureFailed
        }

        func sign(message: Data) -> AnyPublisher<Data, Swift.Error> {
            Future { [weak self] promise in
                promise(Result {
                    guard let result = try self?.privateKeyContainer.sign(data: message) else {
                        throw Error.signatureFailed
                    }
                    return result
                })
            }
            .eraseToAnyPublisher()
        }
    }

    func testBiometrieFlow() throws {
        let keyIdentifier = try! generateSecureRandom(length: 32)
        let keyTag = keyIdentifier.encodeBase64urlsafe().utf8string!
        let privateKeyContainer: PrivateKeyContainer

        do {
            privateKeyContainer = try PrivateKeyContainer.createFromKeyChain(with: keyTag)
        }
        defer {
            _ = try? PrivateKeyContainer.deleteExistingKey(for: keyTag)
        }

        let signer = try! Brainpool256r1Signer(
            x5c: Bundle(for: Self.self)
                .path(forResource: "x509-ec-bp256r1", ofType: "cer", inDirectory: "Certificates.bundle")!,
            key: Bundle(for: Self.self)
                .path(forResource: "x509-ec-key-bp256r1", ofType: "bin", inDirectory: "Certificates.bundle")!
        )

        let idpURLString = ProcessInfo.processInfo
            .environment["IDP_URL"] ??
//                "http://localhost:8080/discoveryDocument"
            "https://idp-test.zentral.idp.splitdns.ti-dienste.de/.well-known/openid-configuration"
        let redirectURLString = "https://redirect.gematik.de/erezept"

        let storage = MemStorage()
        let pairingIDPSessionConfiguration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURL: URL(string: redirectURLString)!,
            discoveryURL: URL(string: idpURLString)!,
            scopes: ["pairing", "openid"]
        )
        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())
        let httpClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral,
                                           interceptors: [
                                               AdditionalHeaderInterceptor(additionalHeader: [
                                               ]),
                                               LoggingInterceptor(log: .body),
                                           ])
        let trustStoreSession = MockTrustStoreSession()

        let pairingIDPSession = DefaultIDPSession(
            config: pairingIDPSessionConfiguration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession
        )
        var success = false
        var token: IDPToken!
        pairingIDPSession.requestChallenge()
            .flatMap { challenge in
                challenge.sign(with: signer, using: signer.certificates)
                    .mapError { $0.asIDPError() }
            }
            .flatMap { signedChallenge in
                pairingIDPSession.verifyAndExchange(signedChallenge: signedChallenge)
            }
            .test(timeout: 10,
                  failure: { error in
                      fail("\(error)")
                  },
                  expectations: { idpToken in
                    success = true
                    Swift.print("token access", idpToken.accessToken)
                    Swift.print("token id", idpToken.idToken)
                    Swift.print("token sso: '\(idpToken.ssoToken ?? "<empty>")'")
                    token = idpToken
                  }, subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(success) == true

        guard token != nil else {
            fail("token must not be nil")
            return
        }
        expect(token).toNot(beNil())

        // Biometrie Registration
        let altVerifyIDPSessionConfiguration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURL: URL(string: redirectURLString)!,
            discoveryURL: URL(string: idpURLString)!,
            scopes: ["e-rezept", "openid"]
        )
        let altVerifyIDPSession = DefaultIDPSession(
            config: altVerifyIDPSessionConfiguration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession
        )

        let cert = signer.x5c

        let secureEnclaveSignatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: storage,
            keyIdentifierGenerator: { () -> Data in
                keyIdentifier
            }
        ) { _ -> PrivateKeyContainer in
            privateKeyContainer
        }

        let pairingSession = try! secureEnclaveSignatureProvider.registerData()

        secureEnclaveSignatureProvider.signPairingSession(pairingSession, with: signer, certificate: cert)
            .mapError { $0.asIDPError() }
            .flatMap { registration -> AnyPublisher<PairingEntry, IDPError> in
                pairingIDPSession.pairDevice(with: registration, token: token)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
            .test(
                failure: { error in
                    fail("\(error)")
                },
                expectations: { pairingResponse in
                    expect(pairingResponse).toNot(beNil())
                }
            )

        success = false

        altVerifyIDPSession.requestChallenge()
            .flatMap { challenge -> AnyPublisher<SignedAuthenticationData, IDPError> in
                secureEnclaveSignatureProvider.authenticationData(for: challenge)
                    .mapError { $0.asIDPError() }
                    .eraseToAnyPublisher()
            }
            .flatMap { signedAuthenticationData in
                altVerifyIDPSession.altVerify(signedAuthenticationData)
                    .flatMap { exchangeToken in
                        altVerifyIDPSession.exchange(
                            token: exchangeToken,
                            challengeSession: signedAuthenticationData.originalChallenge
                        )
                    }
            }
            .test(failure: { error in
                      fail("\(error)")
                  },
                  expectations: { idpToken in
                    success = true
                    Swift.print("token access", idpToken.accessToken)
                    Swift.print("token id", idpToken.idToken)
                    Swift.print("token sso: '\(idpToken.ssoToken ?? "<empty>")'")
                    token = idpToken
                  }, subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(success) == true
    }
}

class Brainpool256r1Signer: JWTSigner {
    let x5c: X509
    let key: BrainpoolP256r1.Verify.PrivateKey

    init(x5c path: String, key filePath: String) throws {
        x5c = try X509(der: path.readFileContents())
        key = try BrainpoolP256r1.Verify.PrivateKey(raw: filePath.readFileContents())
    }

    var certificates: [Data] {
        [x5c.derBytes!]
    }

    func sign(message: Data) -> AnyPublisher<Data, Error> {
        Future { promise in
            promise(Result {
                try self.key.sign(message: message).rawRepresentation
            })
        }
        .eraseToAnyPublisher()
    }
}

class MockTrustStoreSession: TrustStoreSession {
    func reset() {}

    func validate(certificate _: X509) -> AnyPublisher<Bool, TrustStoreError> {
        Just(true).setFailureType(to: TrustStoreError.self).eraseToAnyPublisher()
    }

    func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        Just(try! X509(der: Data())).setFailureType(to: TrustStoreError.self).eraseToAnyPublisher()
    }
}
