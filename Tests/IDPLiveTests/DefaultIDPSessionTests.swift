// swiftlint:disable file_length
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

import AsyncHelpers
import Combine
import CombineSchedulers
import CryptoKit
import Foundation
import IDP
@testable import IDPLive
import Nimble
import OpenSSL
import TestUtils
import TrustStore
import XCTest

final class DefaultIDPSessionTests: XCTestCase {
    var trustStoreSessionMock: TrustStoreSessionMock!

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    private func discoveryDocument(createdOn: Date) -> DiscoveryDocument {
        guard let documentData = try? Bundle.module
            .path(forResource: "discovery-doc", ofType: "jwt", inDirectory: "Resources/JWT.bundle")?
            .readFileContents(),
            let documentJWT = try? JWT(from: documentData),
            let jwkData = try? Bundle.module
            .path(forResource: "jwk", ofType: "json", inDirectory: "Resources/JWT.bundle")?
            .readFileContents(),
            let jwk = try? JSONDecoder().decode(JWK.self, from: jwkData),
            let document = try? DiscoveryDocument(
                jwt: documentJWT,
                encryptPuks: jwk,
                signingPuks: jwk,
                createdOn: createdOn
            )
        else {
            fatalError("Could not load test discovery document")
        }
        return document
    }

    private lazy var challengeDocument: IDPChallenge = {
        guard let challengeData = try? Bundle.module
            .path(forResource: "challenge-2", ofType: "json", inDirectory: "Resources/JWT.bundle")?
            .readFileContents(),
            let challenge = try? JSONDecoder().decode(IDPChallenge.self, from: challengeData) else {
            fatalError("Could not load test idp challenge")
        }
        return challenge
    }()

    private lazy var invalidChallenge: IDPChallenge = {
        guard let challengeData = try? Bundle.module
            .path(forResource: "challenge-invalid", ofType: "json", inDirectory: "Resources/JWT.bundle")?
            .readFileContents(),
            let challenge = try? JSONDecoder().decode(IDPChallenge.self, from: challengeData) else {
            fatalError("Could not load test idp challenge")
        }
        return challenge
    }()

    var idpClientMock: MockIDPClient!
    var schedulers: Schedulers!
    var storage: MemStorage!
    var sut: DefaultIDPSession!
    var extAuthRequestStorageMock: ExtAuthRequestStorageMock!

    var initialToken: IDPToken!
    var dateProvider: TimeProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()

        idpClientMock = MockIDPClient()

        // Date provider provides a date that should validate the DiscoveryDocument when reading from IDPStorage
        let issuedDate = dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000")!
        let discoveryDocument = discoveryDocument(createdOn: issuedDate.addingTimeInterval(TimeInterval(-10)))

        idpClientMock.discoveryDocument = discoveryDocument

        initialToken = IDPToken(
            // swiftlint:disable:next line_length
            accessToken: "eyJhbGciOiJCUDI1NlIxIiwidHlwIjoiYXQrSldUIiwia2lkIjoicHVrX2lkcF9zaWcifQ.eyJzdWIiOiJRWFkzUUx2dDhnX09BdVZkZldOM2xyVjBhNThISzRhMU1rSWJ2YlpkQm9BIiwicHJvZmVzc2lvbk9JRCI6IjEuMi4yNzYuMC43Ni40LjQ5Iiwib3JnYW5pemF0aW9uTmFtZSI6IlRlc3QgR0tWLVNWTk9ULVZBTElEIiwiaWROdW1tZXIiOiJYMTEwNDQzODc0IiwiYW1yIjpbIm1mYSIsInNjIiwicGluIl0sImlzcyI6Imh0dHBzOi8vaWRwLmRldi5nZW1hdGlrLnNvbHV0aW9ucyIsImdpdmVuX25hbWUiOiJIZWlueiBIaWxsYmVydCIsImNsaWVudF9pZCI6ImVSZXplcHRBcHAiLCJhY3IiOiJnZW1hdGlrLWVoZWFsdGgtbG9hLWhpZ2giLCJhdWQiOiJodHRwczovL2VycC10ZXN0LnplbnRyYWwuZXJwLnNwbGl0ZG5zLnRpLWRpZW5zdGUuZGUvIiwiYXpwIjoiZVJlemVwdEFwcCIsInNjb3BlIjoiZS1yZXplcHQgb3BlbmlkIiwiYXV0aF90aW1lIjoxNjE5NTE2OTk0LCJleHAiOjE2MTk1MTcyOTQsImZhbWlseV9uYW1lIjoiQ8O2cmRlcyIsImlhdCI6MTYxOTUxNjk5NCwianRpIjoiYjUzYTIwYzFmMzM1MTBlOCJ9.E9K6Wsjyxe-udXWgkk-pk6esZd2rw6UP5Ang_KV8-eBd0PvW663I-zcIcPVds2H939wBoRnPAzXmvipxxdnHPg",
            expires: issuedDate,
            idToken: decryptedTokenPayload.idToken,
            ssoToken: "sso-token",
            tokenType: "Bearer",
            redirect: "redirect"
        )

        storage = MemStorage()
        storage.set(discovery: discoveryDocument)

        schedulers = Schedulers.immediate

        trustStoreSessionMock = TrustStoreSessionMock()
        trustStoreSessionMock.validateEeCertificateX509BoolReturnValue = true

        extAuthRequestStorageMock = ExtAuthRequestStorageMock()

        // 1 second before token expiration
        let dateProviderDate = issuedDate.addingTimeInterval(TimeInterval(-1))
        dateProvider = {
            dateProviderDate
        }
    }

    // [REQ:gemSpec_IDP_Frontend:A_20617-01]
    // [REQ:gemSpec_IDP_Frontend:A_20623]
    // [REQ:gemSpec_IDP_Frontend:A_20512#10] Testing the implementation
    func testLoadDiscoveryDocumentFromStorageOnInitFailesWhenTrustStoreFailsValidation() async throws {
        let trustStoreSessionMock = TrustStoreSessionMock()
        trustStoreSessionMock.validateEeCertificateX509BoolReturnValue = false
        let idpClientMock = MockIDPClient()
        idpClientMock.discoveryDocument = nil
        let storage = MemStorage()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        storage.set(discovery: discoveryDocument(createdOn: issuedDate))

        let session = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        ) { issuedDate }

        await expect(storage.discoveryDocumentState).toEventually(beNil())
        expect(trustStoreSessionMock.validateEeCertificateX509BoolCallsCount).to(equal(1))

        _ = session
    }

    // [REQ:gemSpec_IDP_Frontend:A_20617-01]
    // [REQ:gemSpec_IDP_Frontend:A_20623]
    // [REQ:gemSpec_IDP_Frontend:A_20512#11] Testing the implementation
    func testLoadDiscoveryDocumentFromRemoteOnInitFailesWhenTrustStoreFailsValidation() throws {
        trustStoreSessionMock.validateEeCertificateX509BoolReturnValue = false
        let idpClientMock = MockIDPClient()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        idpClientMock.discoveryDocument = discoveryDocument(createdOn: issuedDate)
        let storage = MemStorage()
        storage.set(discovery: nil)

        // sut: IDPSession is not stored as we test its internals
        _ = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        ) { issuedDate }

        expect(storage.discoveryDocumentState).to(beNil())
        expect(self.trustStoreSessionMock.validateEeCertificateX509BoolCallsCount).toEventually(equal(1))
    }

    // [REQ:gemSpec_IDP_Frontend:A_20617-01]
    // [REQ:gemSpec_IDP_Frontend:A_20623]
    // [REQ:gemSpec_IDP_Frontend:A_20512#12] Testing the implementation
    func testLoadDiscoveryDocumentFromStorageOnInitFailesWhenTrustStoreThrows() throws {
        let trustStoreSessionMock = TrustStoreSessionMock()
        trustStoreSessionMock.validateEeCertificateX509BoolThrowableError = TrustStoreError.invalidOCSPResponse
        let idpClientMock = MockIDPClient()
        idpClientMock.discoveryDocument = nil
        let storage = MemStorage()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        storage.set(discovery: discoveryDocument(createdOn: issuedDate))

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        ) { issuedDate }

        expect(storage.discoveryDocumentState).toEventually(beNil())
        expect(trustStoreSessionMock.validateEeCertificateX509BoolCallsCount).to(equal(1))

        _ = sut
    }

    // [REQ:gemSpec_IDP_Frontend:A_20617-01]
    // [REQ:gemSpec_IDP_Frontend:A_20623]
    // [REQ:gemSpec_IDP_Frontend:A_20512#13] Testing the implementation
    func testLoadDiscoveryDocumentFromRemoteOnInitFailesWhenTrustStoreThrows() async throws {
        let trustStoreSessionMock = TrustStoreSessionMock()
        trustStoreSessionMock.validateEeCertificateX509BoolThrowableError = TrustStoreError.invalidOCSPResponse
        let idpClientMock = MockIDPClient()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        idpClientMock.discoveryDocument = discoveryDocument(createdOn: issuedDate)
        let storage = MemStorage()
        storage.set(discovery: nil)

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        ) { issuedDate }

        await expect(storage.discoveryDocumentState).toEventually(beNil())
        await expect(trustStoreSessionMock.validateEeCertificateX509BoolCallsCount).toEventually(equal(1))

        _ = sut
    }

    // [REQ:gemSpec_IDP_Frontend:A_20617-01]
    // [REQ:gemSpec_IDP_Frontend:A_20623]
    // [REQ:gemSpec_IDP_Frontend:A_20512#14] Testing the implementation
    func testLoadDiscoveryDocumentFromStorageOnInit() throws {
        let idpClientMock = MockIDPClient()
        idpClientMock.discoveryDocument = nil
        let storage = MemStorage()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        storage.set(discovery: discoveryDocument)

        // sut: IDPSession is not stored as we test its internals
        _ = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        ) { issuedDate }

        expect(storage.discoveryDocumentState) == discoveryDocument
        expect(self.trustStoreSessionMock.validateEeCertificateX509BoolCallsCount).to(equal(2))
    }

    // [REQ:gemSpec_IDP_Frontend:A_20617-01]
    // [REQ:gemSpec_IDP_Frontend:A_20623]
    // [REQ:gemSpec_IDP_Frontend:A_20512#15] Testing the implementation
    func testLoadDiscoveryDocumentFromRemoteOnInit() async throws {
        let trustStoreSessionMock = TrustStoreSessionMock()
        trustStoreSessionMock.validateEeCertificateX509BoolReturnValue = true
        let idpClientMock = MockIDPClient()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        idpClientMock.discoveryDocument = discoveryDocument
        let storage = MemStorage()
        storage.set(discovery: nil)

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock
        ) { issuedDate }

        await expect(storage.discoveryDocumentState).toEventually(equal(discoveryDocument))
        await expect(trustStoreSessionMock.validateEeCertificateX509BoolCallsCount).toEventually(equal(2))

        _ = sut
    }

    func testInvalidateLoadDiscoveryDocumentOnInit() {
        let idpClientMock = MockIDPClient()
        let storage = MemStorage()
        storage.set(discovery: nil)

        // sut: IDPSession is not stored as we test its internals
        _ = DefaultIDPSession( // swiftlint:disable:this trailing_closure
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: { Date.distantPast }
        )

        expect(storage.discoveryDocumentState).to(beNil())
    }

    func testInvalidationRemovesToken() throws {
        let currentDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-18 08:51:16.0000+0000"))
        let token = IDPToken(
            accessToken: "access-token",
            expires: currentDate.advanced(by: 10),
            idToken: "id-token",
            ssoToken: "sso-token",
            tokenType: "Bearer",
            redirect: "redirect"
        )
        let idpClientMock = MockIDPClient()
        let storage = MemStorage()
        storage.set(token: token)

        let dateProvider = {
            currentDate
        }
        let schedulers = Schedulers.immediate

        let sut = DefaultIDPSession(client: idpClientMock,
                                    storage: storage,
                                    schedulers: schedulers,
                                    trustStoreSession: trustStoreSessionMock,
                                    extAuthRequestStorage: extAuthRequestStorageMock,
                                    time: dateProvider)

        storage.token.first().test(expectations: { token in
            expect(token).toNot(beNil())
        })

        sut.invalidateAccessToken()

        storage.token.first().test(expectations: { token in
            expect(token).to(beNil())
        })
    }

    func testInvalidateStoredDocumentWhenExpired() async throws {
        let idpClientMock = MockIDPClient()
        // Date provider provides a date that should invalidate the DiscoveryDocument when reading from IDPStorage
        // But provide a date that would validate the (same) document when coming from the IDPClient
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-18 08:51:16.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        idpClientMock.discoveryDocument = discoveryDocument
        let storage = MemStorage()
        storage.set(discovery: discoveryDocument)

        var calls = 0
        let dateProvider: TimeProvider = { [weak self] in
            calls += 1
            if calls == 1 {
                return self!.dateFormatter.date(from: "2021-03-19 16:42:28.0000+0000")!
            } else {
                return issuedDate
            }
        }

        let schedulers = Schedulers.immediate
        var receivedDocuments = [DiscoveryDocument?]()
        let storageCancellable = storage.discoveryDocument // swiftlint:disable:this trailing_closure
            .receive(on: DispatchQueue.immediate)
            .sink(receiveValue: { document in
                receivedDocuments.append(document)
            })

        let sut = DefaultIDPSession(client: idpClientMock,
                                    storage: storage,
                                    schedulers: schedulers,
                                    trustStoreSession: trustStoreSessionMock,
                                    extAuthRequestStorage: extAuthRequestStorageMock,
                                    time: dateProvider)

        await expect(storage.discoveryDocumentState).toEventually(equal(discoveryDocument))
        expect(receivedDocuments) == [discoveryDocument, nil, discoveryDocument]
        expect(calls) == 3

        storageCancellable.cancel()
        _ = sut
    }

    func testRequestChallenge() async throws {
        let trustStoreSessionMock = TrustStoreSessionMock()
        trustStoreSessionMock.validateEeCertificateX509BoolReturnValue = true
        let idpClientMock = MockIDPClient()
        idpClientMock.discoveryDocument = nil
        idpClientMock.requestChallenge_Publisher = Just(challengeDocument)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        let storage = MemStorage()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:00:00.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        storage.set(discovery: discoveryDocument)
        // must be between iat date and exp date from `challengeDocument`
        let nowDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:56:38.0000+0000"))
        // must be exact exp date from `challengeDocument`
        let challengeExpirationDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:58:38.0000+0000"))

        let codeVerifier = "very-random-string"
        let codeChallenge = try XCTUnwrap(codeVerifier.encodeBase64urlsafe()?.sha256().encodeBase64UrlSafe()?
            .asciiString)
        var randomGeneratorCalls = 0
        var randomGeneratorParams = [Int]()
        let stateOrNonce = Data([0x1, 0x2, 0x3])
        let randomGeneratorFunc: Random<Data> = { length in
            randomGeneratorCalls += 1
            randomGeneratorParams.append(length)
            if randomGeneratorCalls == 1 || randomGeneratorCalls == 4 {
                return codeVerifier.data(using: .ascii)!
            } else {
                return stateOrNonce
            }
        }

        let timerScheduler = DispatchQueue.test
        let schedulers = Schedulers(computeScheduler: timerScheduler.eraseToAnyScheduler())
        let verifierLength = 13
        let nonceLength = 10
        let stateLength = 17
        let cryptoBox = IDPCrypto(verifierLength: 13,
                                  nonceLength: 10,
                                  stateLength: 17,
                                  randomGenerator: randomGeneratorFunc)
        let sut: IDPSession = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: { nowDate },
            idpCrypto: cryptoBox
        )

        var receivedChallenges = [IDPChallengeSession]()
        let cancellable = sut.requestChallenge()
            .receive(on: DispatchQueue.immediate)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    fail("Failed: \(error)")
                }
            }, receiveValue: { value in
                receivedChallenges.append(value)
            })

        await expect(randomGeneratorCalls).toEventually(equal(3))
        if randomGeneratorCalls == 3 {
            expect(randomGeneratorParams[0]) == verifierLength
            expect(randomGeneratorParams[1]) == stateLength
            expect(randomGeneratorParams[2]) == nonceLength
        } else {
            fail("unexpected calls count of randomGenerator")
        }
        expect(idpClientMock.requestChallenge_CallsCount) == 1
        if let firstCallArguments = idpClientMock.requestChallenge_ReceivedArguments.first {
            expect(firstCallArguments.codeChallenge) == codeChallenge
            expect(firstCallArguments.method) == IDPCodeChallengeMode.sha256
            expect(firstCallArguments.state) == stateOrNonce.hexString()
            expect(firstCallArguments.nonce) == stateOrNonce.hexString()
            expect(firstCallArguments.discovery) == discoveryDocument
        } else {
            fail("request challenge did not get called")
        }

        let expInterval = challengeExpirationDate.timeIntervalSince(nowDate)
        await timerScheduler.advance(by: .init(floatLiteral: expInterval + 1))

        expect(randomGeneratorCalls) == 6
        if randomGeneratorCalls == 6 {
            expect(randomGeneratorParams[3]) == verifierLength
            expect(randomGeneratorParams[4]) == stateLength
            expect(randomGeneratorParams[5]) == nonceLength
        } else {
            fail("unexpected calls count of randomGenerator")
        }
        expect(idpClientMock.requestChallenge_CallsCount) == 2
        if idpClientMock.requestChallenge_CallsCount == 2 {
            let secondCallArguments = idpClientMock.requestChallenge_ReceivedArguments[1]
            expect(secondCallArguments.codeChallenge) == codeChallenge
            expect(secondCallArguments.method) == IDPCodeChallengeMode.sha256
            expect(secondCallArguments.state) == stateOrNonce.hexString()
            expect(secondCallArguments.discovery) == discoveryDocument
        } else {
            fail("request challenge did not get called for the second time")
        }

        cancellable.cancel()
        _ = sut
    }

    func testRequestChallengeInvalidSignature() throws {
        let storage = MemStorage()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:00:00.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        storage.set(discovery: discoveryDocument)
        let idpClientMock = MockIDPClient()
        idpClientMock.requestChallenge_Publisher = Just(invalidChallenge)
            .setFailureType(to: IDPError.self).eraseToAnyPublisher()
        idpClientMock.discoveryDocument = discoveryDocument

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: { issuedDate }
        )

        let expectedError = IDPError.validation(error: JWT.Error.invalidSignature)
        expect(try self.awaitPublisher(sut.requestChallenge())).to(throwError(expectedError))
    }

    func testVerifySignedChallenge() throws {
        let idpClientMock = MockIDPClient()
        // Date provider provides a date that should validate the DiscoveryDocument when reading from IDPStorage
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 16:42:28.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        idpClientMock.discoveryDocument = discoveryDocument
        let storage = MemStorage()
        storage.set(discovery: discoveryDocument)
        let dateProvider: TimeProvider = {
            issuedDate
        }
        let schedulers = Schedulers.immediate
        let expectedToken = IDPExchangeToken(
            code: "exchange-token",
            sso: "sso-token",
            state: "1234567890",
            redirect: "redirect"
        )
        idpClientMock.verify_Publisher = Just(expectedToken).setFailureType(to: IDPError.self).eraseToAnyPublisher()
        let signedJwt = try JWT(from: XCTUnwrap(Bundle.module
                .path(forResource: "signed-challenge-query-param", ofType: "jwt", inDirectory: "Resources/JWT.bundle")?
                .readFileContents()))
        let challenge = try IDPChallenge(
            challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
        )
        let signedChallenge = SignedChallenge(
            originalChallenge: IDPChallengeSession(challenge: challenge,
                                                   verifierCode: "verifier",
                                                   state: "1234567890",
                                                   nonce: "1234567890"),
            signedChallenge: signedJwt
        )

        let sut = DefaultIDPSession(client: idpClientMock,
                                    storage: storage,
                                    schedulers: schedulers,
                                    trustStoreSession: trustStoreSessionMock,
                                    extAuthRequestStorage: extAuthRequestStorageMock,
                                    time: dateProvider)
        sut.verify(signedChallenge)
            .test(expectations: { token in
                expect(token) == expectedToken
            })

        expect(idpClientMock.verify_Called) == true
        expect(idpClientMock.verify_ReceivedArguments?.challenge).notTo(beNil())
        expect(idpClientMock.verify_ReceivedArguments?.document) == discoveryDocument
    }

    let cryptoBox: IDPCrypto = {
        let privateKey = try! BrainpoolP256r1.KeyExchange.generateKey()
        let nonce = try! generateSecureRandom(length: 12)
        let aesKeyData = try! Data(hex: "668D155004E1110DB6914BA40346A302312FA3F1AB647EC79FA12F96793E5205")
        return IDPCrypto(randomGenerator: { _ in Data("UWWzuvaSG".utf8) },
                         brainpoolKeyPairGenerator: { privateKey },
                         aesNonceGenerator: { nonce },
                         aesKey: SymmetricKey(data: aesKeyData))
    }()

    let encryptedTokenPayload: TokenPayload = {
        let tokenPayloadPath = Bundle.module
            .path(forResource: "idp_token_encrypted", ofType: "json", inDirectory: "Resources/JWT.bundle")!
        let encryptedTokenData = try! tokenPayloadPath.readFileContents()
        return try! JSONDecoder().decode(TokenPayload.self, from: encryptedTokenData)
    }()

    let decryptedTokenPayload: TokenPayload = {
        let tokenPath = Bundle.module
            .path(forResource: "idp_token_decrypted", ofType: "json", inDirectory: "Resources/JWT.bundle")!
        let tokenData = try! tokenPath.readFileContents()
        return try! JSONDecoder().decode(TokenPayload.self, from: tokenData)
    }()

    func testExchangeToken() throws {
        let idpClientMock = MockIDPClient()
        // Date provider provides a date that should validate the DiscoveryDocument when reading from IDPStorage
        var issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        idpClientMock.discoveryDocument = discoveryDocument
        let storage = MemStorage()
        storage.set(discovery: discoveryDocument)
        storage.set(token: nil)
        let dateProvider: TimeProvider = {
            issuedDate
        }
        let schedulers = Schedulers.immediate
        let expirationInterval = 300

        // encrypted token payload (send by the client)
        idpClientMock.exchange_Publisher = Just(encryptedTokenPayload)
            .setFailureType(to: IDPError.self).eraseToAnyPublisher()

        let exchangeToken = IDPExchangeToken(code: "code", sso: "sso-token", state: "state", redirect: "redirect")

        // expected (decrypted) token result
        let expectedToken = IDPToken(
            accessToken: decryptedTokenPayload.accessToken,
            expires: issuedDate.addingTimeInterval(TimeInterval(expirationInterval)),
            idToken: decryptedTokenPayload.idToken,
            ssoToken: exchangeToken.sso,
            redirect: "redirect"
        )

        var receivedTokens: [IDPToken?] = []
        let tokenSubscriber = storage.token
            .sink(receiveValue: { tokenValue in
                receivedTokens.append(tokenValue)
            })

        let sut = DefaultIDPSession(client: idpClientMock,
                                    storage: storage,
                                    schedulers: schedulers,
                                    trustStoreSession: trustStoreSessionMock,
                                    extAuthRequestStorage: extAuthRequestStorageMock,
                                    time: dateProvider,
                                    idpCrypto: cryptoBox)
        let originalChallenge = try IDPChallenge(
            challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
        )
        let challengeSession = IDPChallengeSession(
            challenge: originalChallenge,
            verifierCode: "verifier",
            state: "state",
            nonce: "5557577A7576615347" // nonce must be equal to the one in idToken
        )
        sut.exchange(token: exchangeToken, challengeSession: challengeSession)
            .test(expectations: { token in
                expect(token) == expectedToken
            })

        expect(idpClientMock.exchange_Called) == true
        expect(idpClientMock.exchange_ReceivedArguments?.token) == exchangeToken
        expect(idpClientMock.exchange_ReceivedArguments?.verifier) == challengeSession.verifierCode

        expect(receivedTokens.count) == 2 // one for subscription one for actual test
        expect(receivedTokens).to(equal([nil, expectedToken]))

        sut.autoRefreshedToken.first().test(expectations: { token in
            expect(token).toNot(beNil())
        })
        issuedDate = issuedDate.advanced(by: TimeInterval(expirationInterval + 1))
        sut.autoRefreshedToken.first().test(expectations: { token in
            expect(token).to(beNil())
        })

        tokenSubscriber.cancel()
    }

    func testUpdateWithSSOToken() throws {
        let idpClientMock = MockIDPClient()
        // Date provider provides a date that should validate the DiscoveryDocument when reading from IDPStorage
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate.addingTimeInterval(TimeInterval(-10)))
        idpClientMock.discoveryDocument = discoveryDocument

        // 1 second before token expiration
        var dateProviderDate = issuedDate.addingTimeInterval(TimeInterval(-1))
        let dateProvider: TimeProvider = {
            dateProviderDate
        }

        let schedulers = Schedulers.immediate
        let expirationInterval = 300
        let tokenPayload = TokenPayload(
            accessToken: encryptedTokenPayload.accessToken,
            expiresIn: expirationInterval,
            idToken: encryptedTokenPayload.idToken,
            ssoToken: "refreshed-sso-token",
            tokenType: "Bearer"
        )

        let expectedToken = IDPToken(
            accessToken: decryptedTokenPayload.accessToken,
            expires: issuedDate.addingTimeInterval(TimeInterval(expirationInterval * 2)),
            idToken: decryptedTokenPayload.idToken,
            ssoToken: "refreshed-sso-token",
            tokenType: "Bearer",
            redirect: "redirect"
        )

        let initialToken = IDPToken(
            accessToken: "initial-access-token",
            expires: issuedDate,
            idToken: decryptedTokenPayload.idToken,
            ssoToken: "sso-token",
            tokenType: "Bearer",
            redirect: "redirect"
        )

        // Set initial (valid) token
        let storage = MemStorage()
        storage.set(discovery: discoveryDocument)
        storage.set(token: initialToken)

        idpClientMock.requestChallenge_Publisher = Just(challengeDocument)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        idpClientMock.exchange_Publisher = Just(tokenPayload).setFailureType(to: IDPError.self).eraseToAnyPublisher()
        idpClientMock.ssoLogin_Publisher =
            Just(IDPExchangeToken(code: "SUPER_SECRET_AUTH_CODE",
                                  sso: "refreshed-sso-token",
                                  state: "state",
                                  redirect: "redirect"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        var receivedTokens: [IDPToken?] = []
        let tokenSubscriber = storage.token
            .sink(receiveValue: { tokenValue in
                receivedTokens.append(tokenValue)
            })

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        expect(idpClientMock.exchange_Called) == false

        sut.autoRefreshedToken.first().test(expectations: { token in
            expect(token).toNot(beNil())
        })
        // advancing invalidates the initialToken, as the expirationdate is hit
        dateProviderDate = dateProviderDate.advanced(by: TimeInterval(expirationInterval + 1))
        sut.autoRefreshedToken.first().test(expectations: { token in
            expect(token).to(equal(expectedToken))
        })

        expect(idpClientMock.ssoLogin_Called) == true
        expect(idpClientMock.exchange_Called) == true

        expect(receivedTokens.count) == 2
        expect(receivedTokens).to(equal([initialToken, expectedToken]))

        tokenSubscriber.cancel()
    }

    func testPair() throws {
        let idpClientMock = MockIDPClient()
        // Date provider provides a date that should validate the DiscoveryDocument when reading from IDPStorage
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate.addingTimeInterval(TimeInterval(-10)))

        idpClientMock.discoveryDocument = discoveryDocument

        // 1 second before token expiration
        let dateProviderDate = issuedDate.addingTimeInterval(TimeInterval(-1))
        let dateProvider: TimeProvider = {
            dateProviderDate
        }

        let schedulers = Schedulers.immediate

        let initialToken = IDPToken(
            // swiftlint:disable:next line_length
            accessToken: "eyJhbGciOiJCUDI1NlIxIiwidHlwIjoiYXQrSldUIiwia2lkIjoicHVrX2lkcF9zaWcifQ.eyJzdWIiOiJRWFkzUUx2dDhnX09BdVZkZldOM2xyVjBhNThISzRhMU1rSWJ2YlpkQm9BIiwicHJvZmVzc2lvbk9JRCI6IjEuMi4yNzYuMC43Ni40LjQ5Iiwib3JnYW5pemF0aW9uTmFtZSI6IlRlc3QgR0tWLVNWTk9ULVZBTElEIiwiaWROdW1tZXIiOiJYMTEwNDQzODc0IiwiYW1yIjpbIm1mYSIsInNjIiwicGluIl0sImlzcyI6Imh0dHBzOi8vaWRwLmRldi5nZW1hdGlrLnNvbHV0aW9ucyIsImdpdmVuX25hbWUiOiJIZWlueiBIaWxsYmVydCIsImNsaWVudF9pZCI6ImVSZXplcHRBcHAiLCJhY3IiOiJnZW1hdGlrLWVoZWFsdGgtbG9hLWhpZ2giLCJhdWQiOiJodHRwczovL2VycC10ZXN0LnplbnRyYWwuZXJwLnNwbGl0ZG5zLnRpLWRpZW5zdGUuZGUvIiwiYXpwIjoiZVJlemVwdEFwcCIsInNjb3BlIjoiZS1yZXplcHQgb3BlbmlkIiwiYXV0aF90aW1lIjoxNjE5NTE2OTk0LCJleHAiOjE2MTk1MTcyOTQsImZhbWlseV9uYW1lIjoiQ8O2cmRlcyIsImlhdCI6MTYxOTUxNjk5NCwianRpIjoiYjUzYTIwYzFmMzM1MTBlOCJ9.E9K6Wsjyxe-udXWgkk-pk6esZd2rw6UP5Ang_KV8-eBd0PvW663I-zcIcPVds2H939wBoRnPAzXmvipxxdnHPg",
            expires: issuedDate,
            idToken: decryptedTokenPayload.idToken,
            ssoToken: "sso-token",
            tokenType: "Bearer",
            redirect: "redirect"
        )

        let storage = MemStorage()
        storage.set(discovery: discoveryDocument)

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        let deviceType = RegistrationData.DeviceInformation.DeviceType(
            product: "product",
            model: "model",
            os: "os",
            osVersion: "osVersion",
            manufacturer: "manufacturer"
        )

        let deviceInformation = RegistrationData.DeviceInformation(
            name: "name",
            deviceType: deviceType
        )

        let registrationData = RegistrationData(
            authCert: "DummyCert",
            signedParingData: "DummySignedParingData",
            deviceInformation: deviceInformation
        )

        let pairingEntry = PairingEntry(
            name: "PairingEntryName",
            signedPairingData: "DummySignedParingData",
            creationTime: Date()
        )

        idpClientMock.registerDevice_Publisher =
            Just(pairingEntry)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()

        sut.pairDevice(with: registrationData, token: initialToken).test(
            failure: { error in
                fail("Received unexpected error '\(error)'")
            },
            expectations: { entry in
                expect(entry.name).to(equal("PairingEntryName"))
                expect(entry).to(equal(pairingEntry))
            }
        )

        let (_, _, resultDD) = try XCTUnwrap(idpClientMock.registerDevice_ReceivedArguments)

        expect(resultDD).to(equal(discoveryDocument))
    }

    func testAltVerify() throws {
        let idpClientMock = MockIDPClient()
        // Date provider provides a date that should validate the DiscoveryDocument when reading from IDPStorage
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:42:03.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate.addingTimeInterval(TimeInterval(-10)))
        idpClientMock.discoveryDocument = discoveryDocument

        // 1 second before token expiration
        let dateProviderDate = issuedDate.addingTimeInterval(TimeInterval(-1))
        let dateProvider: TimeProvider = {
            dateProviderDate
        }

        let schedulers = Schedulers.immediate

        let storage = MemStorage()
        storage.set(discovery: discoveryDocument)

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        let deviceType = RegistrationData.DeviceInformation.DeviceType(
            product: "product",
            model: "model",
            os: "os",
            osVersion: "osVersion",
            manufacturer: "manufacturer"
        )

        let deviceInformation = RegistrationData.DeviceInformation(
            name: "name",
            deviceType: deviceType
        )

        let idpExchangeToken = IDPExchangeToken(
            code: "exchange-token",
            sso: "sso-token",
            state: "1234567890",
            redirect: "redirect"
        )

        idpClientMock.altVerify_Publisher =
            Just(idpExchangeToken)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()

        let challenge = try IDPChallenge(
            challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
        )
        let idpChallengeSession = IDPChallengeSession(challenge: challenge,
                                                      verifierCode: "verifier",
                                                      state: "1234567890",
                                                      nonce: "1234567890")

        let authenticationData = AuthenticationData(
            authCert: "cert",
            challengeToken: "challengeToken",
            deviceInformation: deviceInformation,
            amr: ["amr"],
            keyIdentifier: "keyIdentifier",
            exp: 0
        )
        let header = JWT.Header(alg: .secp256r1)

        let jwt = try JWT(header: header, payload: authenticationData)

        let signedAuthenticationData = SignedAuthenticationData(
            originalChallenge: idpChallengeSession,
            signedAuthenticationData: jwt
        )

        sut.altVerify(signedAuthenticationData).test(
            failure: { error in
                fail("Received unexpected error '\(error)'")
            }, expectations: { token in
                expect(token).to(equal(idpExchangeToken))
            }
        )

        let (_, resultDD) = try XCTUnwrap(idpClientMock.altVerify_ReceivedArguments)

        expect(resultDD).to(equal(discoveryDocument))
    }

    func testLoadDirectoryKKApps() throws {
        sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        let mocked =
            try IDPDirectoryKKApps(
                jwt: "eyJhbGciOiJCUDI1NlIxIiwidHlwIjoiSldUIiwia2lkIjoicHVrX2Rpc2Nfc2lnIiwieDVjIjpbIk1JSUNzVENDQWxpZ0F3SUJBZ0lIQWJzc3FRaHFPekFLQmdncWhrak9QUVFEQWpDQmhERUxNQWtHQTFVRUJoTUNSRVV4SHpBZEJnTlZCQW9NRm1kbGJXRjBhV3NnUjIxaVNDQk9UMVF0VmtGTVNVUXhNakF3QmdOVkJBc01LVXR2YlhCdmJtVnVkR1Z1TFVOQklHUmxjaUJVWld4bGJXRjBhV3RwYm1aeVlYTjBjblZyZEhWeU1TQXdIZ1lEVlFRRERCZEhSVTB1UzA5TlVDMURRVEV3SUZSRlUxUXRUMDVNV1RBZUZ3MHlNVEF4TVRVd01EQXdNREJhRncweU5qQXhNVFV5TXpVNU5UbGFNRWt4Q3pBSkJnTlZCQVlUQWtSRk1TWXdKQVlEVlFRS0RCMW5aVzFoZEdscklGUkZVMVF0VDA1TVdTQXRJRTVQVkMxV1FVeEpSREVTTUJBR0ExVUVBd3dKU1VSUUlGTnBaeUF6TUZvd0ZBWUhLb1pJemowQ0FRWUpLeVFEQXdJSUFRRUhBMElBQklZWm53aUdBbjVRWU94NDNaOE13YVpMRDNyL2J6NkJUY1FPNXBiZXVtNnFRellENWREQ2NyaXcvVk5QUFpDUXpYUVBnNFN0V3l5NU9PcTlUb2dCRW1PamdlMHdnZW93RGdZRFZSMFBBUUgvQkFRREFnZUFNQzBHQlNza0NBTURCQ1F3SWpBZ01CNHdIREFhTUF3TUNrbEVVQzFFYVdWdWMzUXdDZ1lJS29JVUFFd0VnZ1F3SVFZRFZSMGdCQm93R0RBS0JnZ3FnaFFBVEFTQlN6QUtCZ2dxZ2hRQVRBU0JJekFmQmdOVkhTTUVHREFXZ0JRbzhQam1xY2gzekVORjI1cXUxenFEckE0UHFEQTRCZ2dyQmdFRkJRY0JBUVFzTUNvd0tBWUlLd1lCQlFVSE1BR0dIR2gwZEhBNkx5OWxhR05oTG1kbGJXRjBhV3N1WkdVdmIyTnpjQzh3SFFZRFZSME9CQllFRkM5NE05TGdXNDRsTmdvQWJrUGFvbW5MalM4L01Bd0dBMVVkRXdFQi93UUNNQUF3Q2dZSUtvWkl6ajBFQXdJRFJ3QXdSQUlnQ2c0eVpEV215QmlyZ3h6YXd6L1M4REpuUkZLdFlVL1lHTmxSYzcra0JIY0NJQnV6YmEzR3NwcVNtb1AxVndNZU5OS05hTHNnVjh2TWJESmIzMGFxYWlYMSJdfQ.eyJmZWRfaWRwX2xpc3QiOlt7ImlkcF9uYW1lIjogIkdlbWF0aWsgS0siLCJpZHBfaXNzIjogImtrQXBwSWQwMDEiLCAiaWRwX3Nla18yIjogdHJ1ZX0seyAgICAiaWRwX25hbWUiOiAiQW5kZXJlIEtLIiwgImlkcF9pc3MiOiAia2tBcHBJZDAwMiIsICJpZHBfc2VrXzIiOiB0cnVlfSx7ICAgICJpZHBfbmFtZSI6ICJBbmRlcmUgS0syIiwgImlkcF9pc3MiOiAia2tBcHBJZDAwMiIsICJpZHBfc2VrXzIiOiBmYWxzZX0seyAgICAiaWRwX25hbWUiOiAiQW5kZXJlIEtLMyIsICJpZHBfaXNzIjogImtrQXBwSWQwMDIifV19.NnAngqzLOG9aP-QIr_GvEbCdyTE9NqzR8NiEOWu8rR8FZJE136iC1Tft2mglZ0f2oTQM0JLquzKouaeui8qAgA" // swiftlint:disable:this line_length
            )
        let fixture = KKAppDirectory(
            apps: [
                KKAppDirectory.Entry(name: "Andere KK", identifier: "kkAppId002"),
                KKAppDirectory.Entry(name: "Andere KK2", identifier: "kkAppId002"),
                KKAppDirectory.Entry(name: "Andere KK3", identifier: "kkAppId002"),
                KKAppDirectory.Entry(name: "Gematik KK", identifier: "kkAppId001"),
            ]
        )

        idpClientMock.loadDirectoryKKAppsUsingReturnValue = Just(mocked)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        var actual: KKAppDirectory?

        sut.loadDirectoryKKApps()
            .test(
                failure: { error in
                    fail("Error: \(error)")
                },
                expectations: { directory in
                    expect(directory).toNot(beNil())
                    actual = directory
                }
            )

        expect(actual).toNot(beNil())
        expect(actual).to(equal(fixture))
    }

    // [REQ:gemSpec_IDP_Frontend:A_22296-01] Test
    // [REQ:gemSpec_IDP_Frontend:A_23082#4] Test
    func testLoadDirectoryKKAppsInvalidSignature() throws {
        sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        let mocked =
            try IDPDirectoryKKApps(
                jwt: "eyJhbGciOiJCUDI1NlIxIiwidHlwIjoiSldUIiwia2lkIjoicHVrX2Rpc2Nfc2lnIiwieDVjIjpbIk1JSUNzVENDQWxpZ0F3SUJBZ0lIQWJzc3FRaHFPekFLQmdncWhrak9QUVFEQWpDQmhERUxNQWtHQTFVRUJoTUNSRVV4SHpBZEJnTlZCQW9NRm1kbGJXRjBhV3NnUjIxaVNDQk9UMVF0VmtGTVNVUXhNakF3QmdOVkJBc01LVXR2YlhCdmJtVnVkR1Z1TFVOQklHUmxjaUJVWld4bGJXRjBhV3RwYm1aeVlYTjBjblZyZEhWeU1TQXdIZ1lEVlFRRERCZEhSVTB1UzA5TlVDMURRVEV3SUZSRlUxUXRUMDVNV1RBZUZ3MHlNVEF4TVRVd01EQXdNREJhRncweU5qQXhNVFV5TXpVNU5UbGFNRWt4Q3pBSkJnTlZCQVlUQWtSRk1TWXdKQVlEVlFRS0RCMW5aVzFoZEdscklGUkZVMVF0VDA1TVdTQXRJRTVQVkMxV1FVeEpSREVTTUJBR0ExVUVBd3dKU1VSUUlGTnBaeUF6TUZvd0ZBWUhLb1pJemowQ0FRWUpLeVFEQXdJSUFRRUhBMElBQklZWm53aUdBbjVRWU94NDNaOE13YVpMRDNyL2J6NkJUY1FPNXBiZXVtNnFRellENWREQ2NyaXcvVk5QUFpDUXpYUVBnNFN0V3l5NU9PcTlUb2dCRW1PamdlMHdnZW93RGdZRFZSMFBBUUgvQkFRREFnZUFNQzBHQlNza0NBTURCQ1F3SWpBZ01CNHdIREFhTUF3TUNrbEVVQzFFYVdWdWMzUXdDZ1lJS29JVUFFd0VnZ1F3SVFZRFZSMGdCQm93R0RBS0JnZ3FnaFFBVEFTQlN6QUtCZ2dxZ2hRQVRBU0JJekFmQmdOVkhTTUVHREFXZ0JRbzhQam1xY2gzekVORjI1cXUxenFEckE0UHFEQTRCZ2dyQmdFRkJRY0JBUVFzTUNvd0tBWUlLd1lCQlFVSE1BR0dIR2gwZEhBNkx5OWxhR05oTG1kbGJXRjBhV3N1WkdVdmIyTnpjQzh3SFFZRFZSME9CQllFRkM5NE05TGdXNDRsTmdvQWJrUGFvbW5MalM4L01Bd0dBMVVkRXdFQi93UUNNQUF3Q2dZSUtvWkl6ajBFQXdJRFJ3QXdSQUlnQ2c0eVpEV215QmlyZ3h6YXd6L1M4REpuUkZLdFlVL1lHTmxSYzcra0JIY0NJQnV6YmEzR3NwcVNtb1AxVndNZU5OS05hTHNnVjh2TWJESmIzMGFxYWlYMSJdfQ.eyJra19hcHBfbGlzdCI6W3sia2tfYXBwX25hbWUiOiAiR2VtYXRpayBLSyIsImtrX2FwcF9pZCI6ICJra0FwcElkMDAxIn0seyAgICAia2tfYXBwX25hbWUiOiAiQW5kZXJlIEtLIiwgImtrX2FwcF9pZCI6ICJra0FwcElkMDAyIn1dfQ.YgsCr2Lr_OnwcSvhMQOUSKIb8wq8ueyJVM0x5_pCVfhgwVW9orQzynQ4gHNOpgdOqBlHlOjLID6YYdkZSrr" // swiftlint:disable:this line_length
            )

        idpClientMock.loadDirectoryKKAppsUsingReturnValue = Just(mocked)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        sut.loadDirectoryKKApps()
            .test(
                failure: { error in
                    expect(error).to(equal(IDPError.invalidSignature("kk_apps document signature wrong")))
                },
                expectations: { directory in
                    fail("Error: \(directory)")
                }
            )
    }

    // [REQ:gemSpec_IDP_Frontend:A_22295-01] Test
    // [REQ:gemSpec_IDP_Frontend:A_22299-01] Test
    func testExtAuthVerifyAndExchangeGID() throws {
        sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        let fixture = try XCTUnwrap(URL(string:
            "https://das-e-rezept-fuer-deutschland.de?state=mystate&code=testcode&kk_app_redirect_uri=kk_app_redirect_uri" // swiftlint:disable:this line_length
        ))
        idpClientMock.extAuthVerifyUsingReturnValue =
            Just(IDPExchangeToken(code: "code",
                                  sso: nil,
                                  state: "state",
                                  redirect: "https://das-e-rezept-fuer-deutschland.de"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        idpClientMock.exchange_Publisher = Just(encryptedTokenPayload)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        extAuthRequestStorageMock
            .getExtAuthRequestForStateStringExtAuthChallengeSessionReturnValue = ExtAuthChallengeSession(
                verifierCode: "verifier_code",
                nonce: "5557577A7576615347",
                for: KKAppDirectory.Entry(name: "Gematik KK", identifier: "K1234")
            )

        sut.extAuthVerifyAndExchange(fixture, idTokenValidator: { _ in .success(true) })
            .test(
                failure: { error in
                    fail("Error: \(error)")
                },
                expectations: { response in
                    let expected = IDPToken(accessToken: self.decryptedTokenPayload.accessToken,
                                            expires: self.dateProvider().addingTimeInterval(300),
                                            idToken: self.decryptedTokenPayload.idToken,
                                            ssoToken: self.decryptedTokenPayload.ssoToken,
                                            tokenType: self.decryptedTokenPayload.tokenType,
                                            redirect: "https://das-e-rezept-fuer-deutschland.de")
                    expect(response).to(equal(expected))
                }
            )
        expect(self.extAuthRequestStorageMock.getExtAuthRequestForStateStringExtAuthChallengeSessionCalled).to(beTrue())
        expect(self.extAuthRequestStorageMock.getExtAuthRequestForStateStringExtAuthChallengeSessionReceivedInvocations
            .first).to(equal("state"))

        expect(self.idpClientMock.exchange_Called).to(beTrue())
        expect(self.idpClientMock.exchange_ReceivedArguments).toNot(beNil())
        guard let receivedArguments = idpClientMock.exchange_ReceivedArguments else {
            fail("received Arguments nil")
            return
        }

        expect(receivedArguments.redirectURI).to(equal("https://das-e-rezept-fuer-deutschland.de"))
    }

    // [REQ:gemSpec_IDP_Frontend:A_22301-01#20] Negative Test
    func testExtAuthVerifyAndExchangeFailesWithoutReferenceStateGID() throws {
        idpClientMock.extAuthVerifyUsingReturnValue =
            Just(IDPExchangeToken(code: "code",
                                  sso: nil,
                                  state: "state",
                                  redirect: "https://das-e-rezept-fuer-deutschland.de"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        let fixture = try XCTUnwrap(URL(string:
            "https://das-e-rezept-fuer-deutschland.de/extauth?state=mystate&code=testcode&kk_app_redirect_uri=kk_app_redirect_uri" // swiftlint:disable:this line_length
        ))

        extAuthRequestStorageMock.getExtAuthRequestForStateStringExtAuthChallengeSessionReturnValue = nil

        sut.extAuthVerifyAndExchange(fixture, idTokenValidator: { _ in .success(true) })
            .test(
                failure: { error in
                    expect(error).to(equal(IDPError.extAuthOriginalRequestMissing))
                },
                expectations: { _ in
                    fail("Should not be called!")
                }
            )
        expect(self.extAuthRequestStorageMock.getExtAuthRequestForStateStringExtAuthChallengeSessionCalled).to(beTrue())
        expect(self.extAuthRequestStorageMock.getExtAuthRequestForStateStringExtAuthChallengeSessionReceivedInvocations
            .first).to(equal("state"))
    }

    func testExtAuthVerifyAndExchange_kkHasPkvIdentifierFlag() throws {
        sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: dateProvider,
            idpCrypto: cryptoBox // the crypto box used is the one used to encrypt the example data
        )

        let fixture = try XCTUnwrap(URL(string:
            "https://das-e-rezept-fuer-deutschland.de?state=mystate&code=testcode"))
        idpClientMock.extAuthVerifyUsingReturnValue =
            Just(IDPExchangeToken(code: "code",
                                  sso: nil,
                                  state: "state",
                                  redirect: "https://das-e-rezept-fuer-deutschland.de"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        idpClientMock.exchange_Publisher = Just(encryptedTokenPayload)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        extAuthRequestStorageMock
            .getExtAuthRequestForStateStringExtAuthChallengeSessionReturnValue = ExtAuthChallengeSession(
                verifierCode: "verifier_code",
                nonce: "5557577A7576615347",
                for: KKAppDirectory.Entry(name: "Gematik KK", identifier: "K1234", pkv: true)
            )

        sut.extAuthVerifyAndExchange(fixture, idTokenValidator: { _ in .success(true) })
            .test(
                failure: { error in
                    fail("Error: \(error)")
                },
                expectations: { response in
                    let expected = IDPToken(
                        accessToken: self.decryptedTokenPayload.accessToken,
                        expires: self.dateProvider().addingTimeInterval(300),
                        idToken: self.decryptedTokenPayload.idToken,
                        ssoToken: self.decryptedTokenPayload.ssoToken,
                        tokenType: self.decryptedTokenPayload.tokenType,
                        redirect: "https://das-e-rezept-fuer-deutschland.de",
                        isPkvExtAuthFlowInitiated: true
                    )
                    expect(response).to(equal(expected))
                }
            )
        expect(self.extAuthRequestStorageMock.getExtAuthRequestForStateStringExtAuthChallengeSessionCalled).to(beTrue())
        expect(self.extAuthRequestStorageMock.getExtAuthRequestForStateStringExtAuthChallengeSessionReceivedInvocations
            .first).to(equal("state"))

        expect(self.idpClientMock.exchange_Called).to(beTrue())
        expect(self.idpClientMock.exchange_ReceivedArguments).toNot(beNil())
        guard let receivedArguments = idpClientMock.exchange_ReceivedArguments else {
            fail("received Arguments nil")
            return
        }

        expect(receivedArguments.redirectURI).to(equal("https://das-e-rezept-fuer-deutschland.de"))
    }

    // MARK: - DiscoveryDocument reset on invalid challenge signature

    func testRequestChallengeInvalidSignatureResetsDiscoveryDocument() throws {
        let storage = MemStorage()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:00:00.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        storage.set(discovery: discoveryDocument)

        // Verify the discovery document is initially set
        expect(storage.discoveryDocumentState).toNot(beNil())

        let idpClientMock = MockIDPClient()
        idpClientMock.requestChallenge_Publisher = Just(invalidChallenge)
            .setFailureType(to: IDPError.self).eraseToAnyPublisher()
        idpClientMock.discoveryDocument = discoveryDocument

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: Schedulers.immediate,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: { issuedDate }
        )

        // The challenge has an invalid signature, so requestChallenge should fail
        let expectedError = IDPError.validation(error: JWT.Error.invalidSignature)
        expect(try self.awaitPublisher(sut.requestChallenge())).to(throwError(expectedError))

        // After the invalid signature error, the DiscoveryDocument should be reset to nil
        // so that the next request triggers a fresh reload (certificate rollover recovery).
        expect(storage.discoveryDocumentState).to(beNil())

        // expect 1 retry to have happened
        expect(idpClientMock.loadDiscoveryDocument_CallsCount).to(equal(1))
    }

    func testRequestChallengeInvalidSignatureRetriesSuccessfully() async throws {
        let storage = MemStorage()
        let issuedDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:00:00.0000+0000"))
        let discoveryDocument = discoveryDocument(createdOn: issuedDate)
        storage.set(discovery: discoveryDocument)

        let idpClientMock = MockIDPClient()
        // The client must have a discovery document so the retry can load a fresh one
        idpClientMock.discoveryDocument = discoveryDocument

        // First call returns invalid challenge (triggers retry), second call returns valid challenge
        var challengeCallCount = 0
        idpClientMock.requestChallenge_Publisher = Deferred { () -> AnyPublisher<IDPChallenge, IDPError> in
            challengeCallCount += 1
            if challengeCallCount <= 1 {
                return Just(self.invalidChallenge)
                    .setFailureType(to: IDPError.self)
                    .eraseToAnyPublisher()
            } else {
                return Just(self.challengeDocument)
                    .setFailureType(to: IDPError.self)
                    .eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()

        // nowDate must be between iat date and exp date from `challengeDocument`
        let nowDate = try XCTUnwrap(dateFormatter.date(from: "2021-03-16 14:56:38.0000+0000"))

        // Use a test scheduler for compute to prevent infinite recursion in requestChallenge's delay/merge
        let timerScheduler = DispatchQueue.test
        let schedulers = Schedulers(computeScheduler: timerScheduler.eraseToAnyScheduler())

        let sut = DefaultIDPSession(
            client: idpClientMock,
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSessionMock,
            extAuthRequestStorage: extAuthRequestStorageMock,
            time: { nowDate }
        )

        var receivedChallenges = [IDPChallengeSession]()
        var receivedError: IDPError?
        let cancellable = sut.requestChallenge()
            .receive(on: DispatchQueue.immediate)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
            }, receiveValue: { value in
                receivedChallenges.append(value)
            })

        // After retry, a valid challenge session should have been received
        await expect(receivedChallenges).toEventually(haveCount(1))
        expect(receivedError).to(beNil())

        // requestChallenge on the client should have been called twice
        // (first with invalid signature, then with valid challenge after retry)
        expect(challengeCallCount) == 2
        expect(idpClientMock.requestChallenge_CallsCount) == 2

        // loadDiscoveryDocument on the client should have been called once
        // (to fetch a fresh document after the stored one was reset)
        expect(idpClientMock.loadDiscoveryDocument_CallsCount) == 1

        // After the successful retry, the discovery document should be restored in storage
        expect(storage.discoveryDocumentState).toNot(beNil())

        cancellable.cancel()
        _ = sut
    }
}

extension String {
    func encodeBase64urlsafe() -> Data? {
        data(using: .utf8)?.encodeBase64UrlSafe()
    }
}

extension DiscoveryDocument: Equatable {
    public static func ==(lhs: DiscoveryDocument, rhs: DiscoveryDocument) -> Bool {
        lhs.createdOn == rhs.createdOn &&
            lhs.backing == rhs.backing &&
            lhs.discKey.derBytes == rhs.discKey.derBytes &&
            lhs.signingCert.derBytes == rhs.signingCert.derBytes &&
            lhs.encryptionPublicKey == rhs.encryptionPublicKey &&
            lhs.payload == rhs.payload
    }
}

extension BrainpoolP256r1.KeyExchange.PublicKey: @retroactive Equatable {
    public static func ==(lhs: BrainpoolP256r1.KeyExchange.PublicKey,
                          rhs: BrainpoolP256r1.KeyExchange.PublicKey) -> Bool {
        guard let lhsValue = try? lhs.rawValue(),
              let rhsValue = try? rhs.rawValue() else {
            return false
        }
        return lhsValue == rhsValue
    }
}
