//
//  Copyright (c) 2024 gematik GmbH
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
    var environment: IntegrationTestsEnvironment!

    override func setUp() {
        super.setUp()

        if let integrationTestsEnvironmentString = ProcessInfo.processInfo.environment["APP_CONF"],
           let integrationTestsEnvironment = integrationTestsAppConfigurations[integrationTestsEnvironmentString] {
            environment = integrationTestsEnvironment
        } else {
            environment = integrationTestsEnvironmentDummy // change me for manual testing
        }
    }

    func testCompleteFlow() throws {
        guard let signer = environment.brainpool256r1Signer else {
            throw XCTSkip("Skip test because no signing entity available")
        }

        let storage = MemStorage()
        let configuration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURI: environment.appConfiguration.redirectUri,
            extAuthRedirectURI: environment.appConfiguration.extAuthRedirectUri,
            discoveryURL: environment.appConfiguration.idp,
            scopes: environment.appConfiguration.idpDefaultScopes
        )
        let httpClient = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: [
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.idpAdditionalHeader),
                LoggingInterceptor(log: .body),
            ]
        )

        let trustStoreSession = MockTrustStoreSession()
        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())
        let session = DefaultIDPSession(
            config: configuration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: PersistentExtAuthRequestStorage()
        )
        var success = false
        var token: IDPToken!
        session.requestChallenge()
            .flatMap { challenge in
                challenge.sign(with: signer, using: signer.certificates)
                    .mapError { $0.asIDPError() }
            }
            .flatMap { signedChallenge in
                session.verifyAndExchange(signedChallenge: signedChallenge,
                                          idTokenValidator: { _ in .success(true) })
            }
            .first()
            .test(
                timeout: 10,
                expectations: { idpToken in
                    success = true
                    Swift.print("token access", idpToken.accessToken)
                    Swift.print("token id", idpToken.idToken)
                    Swift.print("token sso: '\(idpToken.ssoToken ?? "<empty>")'")
                    token = idpToken
                }, subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(success) == true

        guard token != nil else {
            fail("token must not be nil")
            return
        }
        expect(token).toNot(beNil())

        // sso refresh
        success = false
        session.refresh(token: token)
            .first()
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
            tokenType: token.tokenType,
            redirect: configuration.redirectURI.absoluteString
        )

        success = false
        session.refresh(token: token)
            .first()
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

        guard let signer = environment.brainpool256r1Signer else {
            throw XCTSkip("Skip test because no signing entity available")
        }

        let storage = MemStorage()
        let pairingIDPSessionConfiguration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURI: environment.appConfiguration.redirectUri,
            extAuthRedirectURI: environment.appConfiguration.extAuthRedirectUri,
            discoveryURL: environment.appConfiguration.idp,
            scopes: ["pairing", "openid"]
        )
        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())
        let httpClient = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: [
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.idpAdditionalHeader),
                LoggingInterceptor(log: .body),
            ]
        )
        let trustStoreSession = MockTrustStoreSession()

        let pairingIDPSession = DefaultIDPSession(
            config: pairingIDPSessionConfiguration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: DummyExtAuthRequestStorage()
        )
        var success = false
        var token: IDPToken!
        pairingIDPSession.requestChallenge()
            .flatMap { challenge in
                challenge.sign(with: signer, using: signer.certificates)
                    .mapError { $0.asIDPError() }
            }
            .flatMap { signedChallenge in
                pairingIDPSession.verifyAndExchange(signedChallenge: signedChallenge,
                                                    idTokenValidator: { _ in .success(true) })
            }
            .first()
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
            redirectURI: environment.appConfiguration.redirectUri,
            extAuthRedirectURI: environment.appConfiguration.extAuthRedirectUri,
            discoveryURL: environment.appConfiguration.idp,
            scopes: environment.appConfiguration.idpDefaultScopes
        )
        let altVerifyIDPSession = DefaultIDPSession(
            config: altVerifyIDPSessionConfiguration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: PersistentExtAuthRequestStorage()
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

        let pairingSession = try! secureEnclaveSignatureProvider.createPairingSession()

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
                            challengeSession: signedAuthenticationData.originalChallenge,
                            idTokenValidator: { _ in .success(true) }
                        )
                    }
            }
            .first()
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

    func testGetPairedDevices() throws {
        guard let signer = environment.brainpool256r1Signer else {
            throw XCTSkip("Skip test because no signing entity available")
        }

        let storage = MemStorage()
        let pairingIDPSessionConfiguration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURI: environment.appConfiguration.redirectUri,
            extAuthRedirectURI: environment.appConfiguration.extAuthRedirectUri,
            discoveryURL: environment.appConfiguration.idp,
            scopes: ["pairing", "openid"]
        )
        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())
        let httpClient = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: [
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.idpAdditionalHeader),
                LoggingInterceptor(log: .body),
            ]
        )
        let trustStoreSession = MockTrustStoreSession()

        let pairingIDPSession = DefaultIDPSession(
            config: pairingIDPSessionConfiguration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: DummyExtAuthRequestStorage()
        )
        var success = false
        var token: IDPToken!
        pairingIDPSession.requestChallenge()
            .flatMap { challenge in
                challenge.sign(with: signer, using: signer.certificates)
                    .mapError { $0.asIDPError() }
            }
            .flatMap { signedChallenge in
                pairingIDPSession.verifyAndExchange(signedChallenge: signedChallenge,
                                                    idTokenValidator: { _ in .success(true) })
            }
            .first()
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

        success = false
        // Get registered Devices
        pairingIDPSession.listDevices(token: token)
            .first()
            .test(failure: { error in
                      fail("\(error)")
                  },
                  expectations: { devices in
                      success = true

                      Swift.print("DEVICES: ")
                      devices.pairingEntries.forEach { entry in
                          Swift.print("Device: ", entry.name, entry.pairingEntryVersion)
                      }
                  },
                  subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(success) == true
    }

    func testExternalAuthenticationLoginGid() throws {
        guard let idpsekServer = environment.idpsekURLServer else {
            throw XCTSkip("Skip test because no IDP Server was provided")
        }

        let storage = MemStorage()
        let configuration = DefaultIDPSession.Configuration(
            clientId: "eRezeptApp",
            redirectURI: environment.appConfiguration.redirectUri,
            extAuthRedirectURI: environment.appConfiguration.extAuthRedirectUri,
            discoveryURL: environment.appConfiguration.idp,
            scopes: environment.appConfiguration.idpDefaultScopes
        )
        let httpClient = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            interceptors: [
                AdditionalHeaderInterceptor(additionalHeader: environment.appConfiguration.idpAdditionalHeader),
                LoggingInterceptor(log: .body),
            ]
        )

        let trustStoreSession = MockTrustStoreSession()
        let schedulers = TestSchedulers(compute: DispatchQueue(label: "serial-test").eraseToAnyScheduler())
        let session = DefaultIDPSession(
            config: configuration,
            storage: storage,
            schedulers: schedulers,
            httpClient: httpClient,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: PersistentExtAuthRequestStorage()
        )

        // Step: Download available KKs for external authentication (a.k.a. fasttrack), select the first named
        // "*Gematik*"

        var success = false
        var selectedEntry: KKAppDirectory.Entry?

        session.loadDirectoryKKApps()
            .test(
                timeout: 10,
                failure: { error in
                    fail("\(error)")
                },
                expectations: { list in
                    success = true
                    print("##########")
                    print("\(list)")
                    selectedEntry = list.apps.first { entry in
                        print(entry.name)
                        return entry.name.localizedCaseInsensitiveContains("gematik")
                    }
                }, subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )

        expect(success) == true
        expect(selectedEntry).toNot(beNil())

        guard let selectedEntry = selectedEntry else {
            return
        }

        // MARK: - Step 1: Authentication Request

        var redirectURL: URL?
        success = false

        session
            .startExtAuth(entry: selectedEntry)
            .test(
                timeout: 100,
                failure: { error in
                    fail("\(error)")
                },
                expectations: { list in

                    // MARK: - Step 2: Authentication Request Response

                    success = true
                    redirectURL = list
                },
                subscribeScheduler: DispatchQueue.global()
                    .eraseToAnyScheduler()
            )

        expect(selectedEntry).toNot(beNil())
        expect(selectedEntry.gId).to(beTrue())

        // MARK: - Step 3: Universal Link - mocked by calling Step 4 - 7 within this test

        guard let redirectURL2 = redirectURL,
              var components = URLComponents(url: redirectURL2, resolvingAgainstBaseURL: true) else {
            return
        }

        let idpsekURL = idpsekServer.url
        components.scheme = idpsekURL.scheme
        components.host = idpsekURL.host
        components.port = idpsekURL.port
        components.path = idpsekURL.path
        components.queryItems?.append(.init(name: "user_id", value: "12345678"))

        // MARK: - STEP 4 - 7

        expect(components.url).toNot(beNil())
        guard let urlStep4 = components.url else {
            fail("Step 4 URL Creation failed")
            return
        }
        let request = URLRequest(url: urlStep4)

        var urlStep7RedirectVal: URL?
        httpClient
            .send(
                request: request,
                interceptors: [
                    LoggingInterceptor(log: .url),
                    AdditionalHeaderInterceptor(additionalHeader: idpsekServer.header),
                ]
            ) { _, redirect in
                urlStep7RedirectVal = redirect.url
                return nil
            }
            .test(
                timeout: 10,
                failure: { error in
                    fail("\(error)")
                },
                expectations: { result in
                    print(result)
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )

        expect(urlStep7RedirectVal).toNot(beNil())
        guard let urlStep7Redirect = urlStep7RedirectVal else {
            return
        }

        // MARK: - STEP 8

        let universalLink = urlStep7Redirect

        // MARK: - STEP 9

        var token: IDPToken?
        session.extAuthVerifyAndExchange(universalLink, idTokenValidator: { _ in .success(true) })
            .test(
                failure: { error in
                    fail("\(error)")
                },
                expectations: { response in
                    token = response
                },
                subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler()
            )
        expect(token).toNot(beNil())
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
