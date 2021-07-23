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

import BundleKit
import Combine
import CryptoKit
import DataKit
import HTTPClient
@testable import IDP
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import OpenSSL
import TestUtils
import XCTest

final class RealIDPClientTests: XCTestCase {
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    let config = DefaultIDPSession.Configuration(
        clientId: "test_client_id",
        redirectURL: URL(string: "http://redirect.com/path?query=something&extra=5")!,
        discoveryURL: URL(string: "http://idp.gematik/discoveryDocument")!,
        scopes: ["e-rezept", "openid"]
    )

    var documentPath: String {
        guard let documentPath = Bundle(for: Self.self)
            .path(forResource: "discovery-doc", ofType: "jwt", inDirectory: "JWT.bundle") else {
            fatalError("Could not load  discovery document")
        }
        return documentPath
    }

    var jwkPath: String {
        guard let path = Bundle(for: Self.self)
            .path(forResource: "jwk", ofType: "json", inDirectory: "JWT.bundle") else {
            fatalError("Could not load JWK")
        }
        return path
    }

    var localDocumentPath: String {
        guard let documentPath = Bundle(for: Self.self)
            .path(forResource: "test-discovery-doc", ofType: "jwt", inDirectory: "JWT.bundle") else {
            fatalError("Could not load test discovery document")
        }
        return documentPath
    }

    func testLoadDiscoveryDocument() throws {
        var counter = 0
        stub(condition: isAbsoluteURLString(config.discoveryURL.absoluteString) && isMethodGET() &&
            !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            return fixture(filePath: self.documentPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isPath("/ipdSig/jwk.json") && isMethodGET()) { _ in
            counter += 1
            return fixture(filePath: self.jwkPath, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isPath("/idpEnc/jwk.json") && isMethodGET()) { _ in
            counter += 1
            return fixture(filePath: self.jwkPath, headers: ["Content-Type": "application/json"])
        }

        let sut = RealIDPClient(client: config)
        sut.loadDiscoveryDocument()
            .test(expectations: { document in
                expect(document.authentication.url) ==
                    URL(string: "http://localhost:8888/sign_response")
            })
        expect(counter) == 3
    }

    func testLoadInvalidDiscoveryDocument() throws {
        guard let jwksPath = Bundle(for: Self.self)
            .path(forResource: "jwks-keys", ofType: "json", inDirectory: "JWT.bundle") else {
            throw IDPError.internalError("Could not load test discovery document")
        }

        var counter = 0
        stub(condition: isAbsoluteURLString(config.discoveryURL.absoluteString) && isMethodGET() &&
            !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            return fixture(filePath: jwksPath, headers: ["Content-Type": "application/json"])
        }

        RealIDPClient(client: config)
            .loadDiscoveryDocument() // swiftlint:disable:this trailing_closure
            .test(failure: { error in
                expect(error) == IDPError.decoding(error: JWT.Error.malformedJWT)
            })
        expect(counter) == 1
    }

    func testLoadDiscoveryDocumentNetworkError() throws {
        var counter = 0
        let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
        stub(condition: isAbsoluteURLString(config.discoveryURL.absoluteString) && isMethodGET() &&
            !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            let response = HTTPStubsResponse(error: notConnectedError)
            response.requestTime = 0.0
            return response
        }

        RealIDPClient(client: config)
            .loadDiscoveryDocument()
            .test(failure: { error in
                expect(counter) == 1
                expect(error) == IDPError
                    .network(error: HTTPError
                        .httpError(URLError(URLError.notConnectedToInternet, userInfo: notConnectedError.userInfo)))
            }, expectations: { _ in
                fail()
            })
    }

    var localDiscoveryDocument: DiscoveryDocument {
        let documentContents = try! localDocumentPath.readFileContents()
        let jwt = try! JWT(from: documentContents)
        let jwkData = try! Bundle(for: Self.self)
            .path(forResource: "jwk", ofType: "json", inDirectory: "JWT.bundle")!
            .readFileContents()
        let jwk = try! JSONDecoder().decode(JWK.self, from: jwkData)
        return try! DiscoveryDocument(jwt: jwt, encryptPuks: jwk, signingPuks: jwk)
    }

    func testRequestChallenge() {
        let codeChallenge = "1234567890abcdefghijklmnop"
        let state = "D1FC3A1F5303B169C51D85ACFD1DA845F8A33447A1A549636B6B5456C6AF"
        let nonce = "01379FF7F0754551CFA484FF19061EB61E847EF72D9886BA0180C8DD4F11"

        guard let challengePath = Bundle(for: Self.self)
            .path(forResource: "challenge", ofType: "json", inDirectory: "JWT.bundle") else {
            fatalError("Could not load test challenge json")
        }

        var counter = 0
        let authenticationEndpoint = localDiscoveryDocument.authentication.url
        stub(condition: isHost("localhost")
            && isPath(authenticationEndpoint.path)
            && isMethodGET()
            && hasHeaderNamed("Accept", value: "application/json")
            && containsQueryParams([
                "client_id": config.clientId,
                "code_challenge": codeChallenge,
                "code_challenge_method": "S256",
                "state": state,
                "redirect_uri": config.redirectURL.absoluteString,
            ])
            && !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            return fixture(filePath: challengePath, headers: ["Content-Type": "application/json"])
        }

        let expectedChallenge = try! IDPChallenge(
            challenge: JWT(
                from: "eyJhbGciOiJCUDI1NlIxIiwiZXhwIjoxNjE1OTA2NzE4LCJ0eXAiOiJKV1QiLCJraWQiOiJpZHBTaWcifQ.eyJpc3MiOiJodHRwczovL2lkcC56ZW50cmFsLmlkcC5zcGxpdGRucy50aS1kaWVuc3RlLmRlIiwicmVzcG9uc2VfdHlwZSI6ImNvZGUiLCJzbmMiOiJraFd5MmpaTlZoK1FOUlFMbmlPQkhORjZjR0Y1SUJrcmFZU1ZNdDhaT0tZPSIsImNvZGVfY2hhbGxlbmdlX21ldGhvZCI6IlMyNTYiLCJ0b2tlbl90eXBlIjoiY2hhbGxlbmdlIiwiY2xpZW50X2lkIjoiZVJlemVwdEFwcCIsInNjb3BlIjoiZS1yZXplcHQgb3BlbmlkIiwic3RhdGUiOiIzSXhCcjNKb2htZmxMcTFHIiwicmVkaXJlY3RfdXJpIjoiaHR0cDovL3JlZGlyZWN0LmdlbWF0aWsuZGUvZXJlemVwdCIsImV4cCI6MTYxNTkwNjcxOCwiaWF0IjoxNjE1OTA2NTM4LCJjb2RlX2NoYWxsZW5nZSI6IjdObnFpWG0tenM5RFNabHRPRnMwYXdabDlmU1hFU2wwc0lhTnVqWmF0N0EiLCJqdGkiOiI1OWIzNzRlZDg3MmIzNDJkIn0.BJyePEkKU-RUs37f2GVvHOt-MDnwW40JmO5IsPj1uzgApqnC97Ei_ev99-gjiRRkt2_QsOsz9d6XBRAPRBzT6w" // swiftlint:disable:this line_length
            ),
            consent: IDPChallenge.UserConsent(
                requestedScopes: [
                    "e-rezept": "Zugriff auf die E-Rezept-Funktionalität.",
                    "openid": "Zugriff auf den ID-Token.",
                ],
                requestedClaims: [
                    "organizationName": "Zustimmung zur Verarbeitung der Organisationszugehörigkeit",
                    "professionOID": "Zustimmung zur Verarbeitung der Rolle",
                    "idNummer": "Zustimmung zur Verarbeitung der Id (z.B. Krankenversichertennummer, Telematik-Id)",
                    "given_name": "Zustimmung zur Verarbeitung des Vornamens",
                    "family_name": "Zustimmung zur Verarbeitung des Nachnamens",
                ]
            )
        )
        RealIDPClient(client: config)
            .requestChallenge(
                codeChallenge: codeChallenge,
                method: .sha256,
                state: state,
                nonce: nonce,
                using: localDiscoveryDocument
            )
            .test(expectations: { challenge in
                expect(challenge) == expectedChallenge
            })
        expect(counter) == 1
    }

    func testRequestChallengeInvalidSignature() {
        let codeChallenge = "1234567890abcdefghijklmnop"
        let state = "D1FC3A1F5303B169C51D85ACFD1DA845F8A33447A1A549636B6B5456C6AF"
        let nonce = "01379FF7F0754551CFA484FF19061EB61E847EF72D9886BA0180C8DD4F11"

        guard let challengePath = Bundle(for: Self.self)
            .path(forResource: "challenge-invalid", ofType: "json", inDirectory: "JWT.bundle") else {
            fatalError("Could not load test challenge json")
        }

        var counter = 0
        let authenticationEndpoint = localDiscoveryDocument.authentication.url
        stub(condition: isHost("localhost")
            && isPath(authenticationEndpoint.path)
            && isMethodGET()
            && hasHeaderNamed("Accept", value: "application/json")
            && containsQueryParams([
                "client_id": config.clientId,
                "code_challenge": codeChallenge,
                "code_challenge_method": "S256",
                "state": state,
                "redirect_uri": config.redirectURL.absoluteString,
            ])
            && !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            return fixture(filePath: challengePath, headers: ["Content-Type": "application/json"])
        }

        RealIDPClient(client: config)
            .requestChallenge(
                codeChallenge: codeChallenge,
                method: .sha256,
                state: state,
                nonce: nonce,
                using: localDiscoveryDocument
            )
            .test(failure: { error in
                expect(error) == IDPError.validation(error: JWT.Error.invalidSignature)
            })
        expect(counter) == 1
    }

    func testSendVerify() {
        let signedChallengeResponse = try! JWT(from: Bundle(for: Self.self)
            .path(forResource: "signed-challenge-query-param", ofType: "jwt", inDirectory: "JWT.bundle")!
            .readFileContents())

        let exchangeString = exchangeToken.asciiString!
        let ssoToken = try! Bundle(for: Self.self)
            .path(forResource: "sso-token", ofType: "jwt", inDirectory: "JWT.bundle")!
            .readFileContents()
        let ssoString = ssoToken.asciiString!

        let privateKey = try! BrainpoolP256r1.KeyExchange.generateKey(compactRepresentable: true)
        let nonce = try! IDPRandom.generateSecureRandom(length: 12)
        let cryptoBox = IDPCrypto(randomGenerator: { _ in Data(base64Encoded: "random")! },
                                  brainpoolKeyPairGenerator: { privateKey },
                                  aesNonceGenerator: { nonce },
                                  aesKey: SymmetricKey(data: Data()))

        let header = try! JWE.Header(algorithm: JWE.Algorithm
                                        .ecdh_es(.bpp256r1(localDiscoveryDocument.encryptionPublicKey,
                                                           keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator)),
                                     encryption: .a256gcm,
                                     contentType: "NJWT")

        let signedChallengePayload = NestedJWT(njwt: signedChallengeResponse.serialize())
        let jwePayload = try! JSONEncoder().encode(signedChallengePayload)
        guard let jwe = try? JWE(
            header: header,
            payload: jwePayload,
            nonceGenerator: cryptoBox.aesNonceGenerator
        ) else {
            fail("JWE construction failed")
            return
        }

        let encodedJwe = jwe.encoded().utf8string!
        let encodedJWEBody = "signed_challenge=\(encodedJwe)".data(using: .utf8)!

        let state = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc"

        var counter = 0
        let authenticationEndpoint = localDiscoveryDocument.authentication.url

        stub(condition: isHost("localhost")
            && isPath(authenticationEndpoint.path)
            && isMethodPOST()
            && hasHeaderNamed("Content-Type", value: "application/x-www-form-urlencoded")
            && hasBody(encodedJWEBody)
            && !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            let response = HTTPStubsResponse()
            let location = "http://localhost:9999/token?code=\(exchangeString)&ssotoken=\(ssoString)&state=\(state)"
            response.statusCode = 302
            response.httpHeaders = [
                "Cache-Control": "no-store",
                "Pragma": "no-cache",
                "Location": location,
                "Content-Length": "0",
            ]
            return response
        }

        let expectedToken = IDPExchangeToken(
            code: exchangeToken.asciiString!,
            sso: ssoToken.asciiString,
            state: state
        )

        RealIDPClient(client: config)
            .verify(
                jwe,
                using: localDiscoveryDocument
            )
            .test(expectations: { token in
                expect(token) == expectedToken
            },
                  // We need to do some scheduling here because of a known issue with OHHTTPStubs and redirects
            // https://github.com/AliSoftware/OHHTTPStubs - Known limitations
            subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler(),
                  receivingScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(counter) == 1
    }

    func dummyJwe() throws -> JWE {
        let privateKey = try! BrainpoolP256r1.KeyExchange.generateKey(compactRepresentable: true)
        let nonce = try! IDPRandom.generateSecureRandom(length: 12)
        let cryptoBox = IDPCrypto(randomGenerator: { _ in Data(base64Encoded: "random")! },
                                  brainpoolKeyPairGenerator: { privateKey },
                                  aesNonceGenerator: { nonce },
                                  aesKey: SymmetricKey(data: Data()))

        let header = try! JWE.Header(algorithm: JWE.Algorithm
                                        .ecdh_es(.bpp256r1(localDiscoveryDocument.encryptionPublicKey,
                                                           keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator)),
                                     encryption: .a256gcm,
                                     contentType: "NJWT")

        let jwePayload = "<dummy_jwe_payload>".data(using: .utf8)!

        let jwe = try JWE(
            header: header,
            payload: jwePayload,
            nonceGenerator: cryptoBox.aesNonceGenerator
        )

        return jwe
    }

    let dummyIdpToken = IDPToken(accessToken: "accesToken", expires: Date(), idToken: "idToken")

    func testRegisterDeviceSuccess() throws {
        let expected = PairingEntry(
            name: "PairedEntry_Name",
            signedPairingData: "signedPairingData",
            creationTime: Date()
        )

        let jwe = try dummyJwe()
        let encodedJwe = jwe.encoded().utf8string!
        let encodedJWEBody = "encrypted_registration_data=\(encodedJwe)".data(using: .utf8)!

        var counter = 0
        let endpoint = localDiscoveryDocument.pairing.url

        stub(condition: isHost("localhost")
            && isPath(endpoint.path)
            && isMethodPOST()
            && hasHeaderNamed("Content-Type", value: "application/x-www-form-urlencoded")
            && hasBody(encodedJWEBody)
            && hasHeaderNamed("Authorization")) { _ in
            counter += 1
            return HTTPStubsResponse(data: try! JSONEncoder().encode(expected),
                                     statusCode: 200,
                                     headers: [
                                         "Cache-Control": "no-store",
                                         "Pragma": "no-cache",
                                         "Content-Length": "0",
                                     ])
        }

        RealIDPClient(client: config)
            .registerDevice(jwe, token: dummyIdpToken, using: localDiscoveryDocument)
            .test(failure: { error in
                fail("Received error: '\(error)'")
            }, expectations: { pairingEntry in
                expect(pairingEntry).to(equal(expected))
            },
                  // We need to do some scheduling here because of a known issue with OHHTTPStubs and redirects
            // https://github.com/AliSoftware/OHHTTPStubs - Known limitations
            subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler(),
                  receivingScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(counter) == 1
    }

    func testRegisterDeviceFailure() throws {
        let responseError = IDPError.ServerResponse(
            error: "error",
            errorText: "errorText",
            timestamp: Int(Date().timeIntervalSince1970),
            uuid: "uuid",
            code: "code"
        )

        let jwe = try dummyJwe()
        let encodedJwe = jwe.encoded().utf8string!
        let encodedJWEBody = "encrypted_registration_data=\(encodedJwe)".data(using: .utf8)!

        var counter = 0
        let endpoint = localDiscoveryDocument.pairing.url

        stub(condition: isHost("localhost")
            && isPath(endpoint.path)
            && isMethodPOST()
            && hasHeaderNamed("Content-Type", value: "application/x-www-form-urlencoded")
            && hasBody(encodedJWEBody)
            && hasHeaderNamed("Authorization")) { _ in
            counter += 1
            return HTTPStubsResponse(data: try! JSONEncoder().encode(responseError),
                                     statusCode: 400,
                                     headers: [
                                         "Cache-Control": "no-store",
                                         "Pragma": "no-cache",
                                         "Content-Length": "0",
                                     ])
        }

        RealIDPClient(client: config)
            .registerDevice(jwe, token: dummyIdpToken, using: localDiscoveryDocument)
            .test(failure: { error in
                expect(error).to(equal(IDPError.serverError(responseError)))
            }, expectations: { _ in
                fail("Received unexpeted success")
            },
                  // We need to do some scheduling here because of a known issue with OHHTTPStubs and redirects
            // https://github.com/AliSoftware/OHHTTPStubs - Known limitations
            subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler(),
                  receivingScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(counter) == 1
    }

    func testSendAltVerifySucceeds() throws {
        let exchangeString = exchangeToken.asciiString!
        let ssoToken = try! Bundle(for: Self.self)
            .path(forResource: "sso-token", ofType: "jwt", inDirectory: "JWT.bundle")!
            .readFileContents()
        let ssoString = ssoToken.asciiString!

        let jwe = try dummyJwe()
        let encodedJwe = jwe.encoded().utf8string!
        let encodedJWEBody = "encrypted_signed_authentication_data=\(encodedJwe)".data(using: .utf8)!

        let state = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc"

        var counter = 0
        let authenticationEndpoint = localDiscoveryDocument.authenticationPaired.url

        stub(condition: isHost("localhost")
            && isPath(authenticationEndpoint.path)
            && isMethodPOST()
            && hasHeaderNamed("Content-Type", value: "application/x-www-form-urlencoded")
            && hasBody(encodedJWEBody)
            && !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            let response = HTTPStubsResponse()
            let location = "http://localhost:9999/token?code=\(exchangeString)&ssotoken=\(ssoString)&state=\(state)"
            response.statusCode = 302
            response.httpHeaders = [
                "Cache-Control": "no-store",
                "Pragma": "no-cache",
                "Location": location,
                "Content-Length": "0",
            ]
            return response
        }

        let expectedToken = IDPExchangeToken(
            code: exchangeToken.asciiString!,
            sso: ssoToken.asciiString,
            state: state
        )

        RealIDPClient(client: config)
            .altVerify(
                jwe,
                using: localDiscoveryDocument
            )
            .test(failure: { error in
                fail("Received error: '\(error)'")
            }, expectations: { token in
                expect(token) == expectedToken
            },
                  // We need to do some scheduling here because of a known issue with OHHTTPStubs and redirects
            // https://github.com/AliSoftware/OHHTTPStubs - Known limitations
            subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler(),
                  receivingScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(counter) == 1
    }

    func testSendAltVerifyReturnsError() throws {
        let jwe = try dummyJwe()
        let encodedJwe = jwe.encoded().utf8string!
        let encodedJWEBody = "encrypted_signed_authentication_data=\(encodedJwe)".data(using: .utf8)!

        var counter = 0
        let authenticationEndpoint = localDiscoveryDocument.authenticationPaired.url

        let responseError = IDPError.ServerResponse(
            error: "error",
            errorText: "errorText",
            timestamp: Int(Date().timeIntervalSince1970),
            uuid: "uuid",
            code: "code"
        )

        stub(condition: isHost("localhost")
            && isPath(authenticationEndpoint.path)
            && isMethodPOST()
            && hasHeaderNamed("Content-Type", value: "application/x-www-form-urlencoded")
            && hasBody(encodedJWEBody)
            && !hasHeaderNamed("Authorization")) { _ in
            counter += 1

            return HTTPStubsResponse(data: try! JSONEncoder().encode(responseError),
                                     statusCode: 400,
                                     headers: [
                                         "Cache-Control": "no-store",
                                         "Pragma": "no-cache",
                                         "Content-Length": "0",
                                     ])
        }

        RealIDPClient(client: config)
            .altVerify(
                jwe,
                using: localDiscoveryDocument
            )
            .test(failure: { error in
                expect(error).to(equal(IDPError.serverError(responseError)))
            }, expectations: { _ in
                fail("Received success")
            },
                  // We need to do some scheduling here because of a known issue with OHHTTPStubs and redirects
            // https://github.com/AliSoftware/OHHTTPStubs - Known limitations
            subscribeScheduler: DispatchQueue.global().eraseToAnyScheduler(),
                  receivingScheduler: DispatchQueue.global().eraseToAnyScheduler())
        expect(counter) == 1
    }

    let challenge = try! IDPChallenge(
        challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
    )

    let ssoToken: String = {
        try! Bundle(for: RealIDPClientTests.self)
            .path(forResource: "sso-token", ofType: "jwt", inDirectory: "JWT.bundle")!
            .readFileContents().asciiString!
    }()

    let exchangeToken: Data = {
        try! Bundle(for: RealIDPClientTests.self)
            .path(forResource: "exchange-code", ofType: "jwt", inDirectory: "JWT.bundle")!
            .readFileContents()
    }()

    var ssoRequestStubCondition: HTTPStubsTestBlock {
        let ssoEndpoint = localDiscoveryDocument.sso.url

        return isHost("localhost")
            && isPath(ssoEndpoint.path)
            && isMethodPOST()
            && hasHeaderNamed("Content-Type", value: "application/x-www-form-urlencoded")
            && !hasHeaderNamed("Authorization")
    }

    func testSSORefreshHappyPath() {
        // given
            // a valid exchangeToken
            // a valid ssoToken
            // a valid server response

        let state = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc"

        let expectedToken = IDPExchangeToken(
            code: exchangeToken.asciiString!,
            sso: ssoToken,
            state: state
        )

        stub(condition: ssoRequestStubCondition) { _ in
            let location = "http://localhost:9999/token?code=\(self.exchangeToken.asciiString!)&state=\(state)"

            return HTTPStubsResponse(data: Data(), statusCode: 302, headers: [
                "Cache-Control": "no-store",
                "Pragma": "no-cache",
                "Location": location,
                "Content-Length": "0",
            ])
        }
        // when I trigger a refresh
        RealIDPClient(client: config)
            .refresh(with: challenge, ssoToken: ssoToken, using: localDiscoveryDocument)
            .test(expectations: { token in
                // then I get a valid token
                expect(token).to(equal(expectedToken))
            })
    }

    func testSSORefreshInvalidTokenResponse() {
        // given
            // a valid exchangeToken
            // a valid ssoToken
            // server responds with error
        let serverError = IDPError.ServerResponse(
            error: "error",
            errorText: "gematik_error_text",
            timestamp: 1000,
            uuid: "uuid-uuid-uuid",
            code: "gematic_code"
        )

        stub(condition: ssoRequestStubCondition) { _ in
            HTTPStubsResponse(data: try! JSONEncoder().encode(serverError), statusCode: 400, headers: nil)
        }
        // when I trigger a refresh
        RealIDPClient(client: config)
            .refresh(with: challenge, ssoToken: ssoToken, using: localDiscoveryDocument)
            .test(failure: { error in
                // then I get the error
                expect(error).to(equal(IDPError.serverError(serverError)))
            })
    }

    let cryptoBox: IDPCrypto = {
        let privateKey = try! BrainpoolP256r1.KeyExchange.generateKey(compactRepresentable: true)
        let nonce = try! IDPRandom.generateSecureRandom(length: 12)
        let aesKeyData = try! Data(hex: "668D155004E1110DB6914BA40346A302312FA3F1AB647EC79FA12F96793E5205")
        return IDPCrypto(randomGenerator: { _ in "UWWzuvaSG".data(using: .utf8)! },
                         brainpoolKeyPairGenerator: { privateKey },
                         aesNonceGenerator: { nonce },
                         aesKey: SymmetricKey(data: aesKeyData))
    }()

    private func encryptedKeyVerifier(for verifier: String) -> JWE {
        let keyVerifier = try! KeyVerifier(with: cryptoBox.aesKey, codeVerifier: verifier)
        let keyVerifierEncoded = try! JSONEncoder().encode(keyVerifier)

        let header = try! JWE.Header(
            algorithm: JWE.Algorithm.ecdh_es(.bpp256r1(localDiscoveryDocument.encryptionPublicKey,
                                                       keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator)),
            encryption: .a256gcm,
            contentType: "JWT"
        )

        return try! JWE(header: header,
                        payload: keyVerifierEncoded,
                        nonceGenerator: cryptoBox.aesNonceGenerator)
    }

    func testExchange() {
        let verifier = "123456789&=^"
        let keyVerifier = encryptedKeyVerifier(for: verifier)
        let keyVerifierString = keyVerifier.encoded().utf8string!
        let exchangeTokenDummy = IDPExchangeToken(code: "exchange-code!", sso: nil, state: "state-123")
        let parameters: [String: String] = [
            "key_verifier": keyVerifierString,
            "code": exchangeTokenDummy.code,
            "grant_type": "authorization_code",
            "redirect_uri": config.redirectURL.absoluteString,
            "code_verifier": verifier,
            "client_id": config.clientId,
        ]

        let httpBodyData = parameters
            .sorted(by: { $0.0 > $1.0 })
            .map { key, value -> String in
                let escapedValue = value.urlPercentEscapedString()
                return "\(key)=\(escapedValue ?? value)"
            }
            .joined(separator: "&")
            .data(using: .utf8)!

        let idpTokenResponsePath = Bundle(for: Self.self)
            .path(forResource: "idp_token_encrypted", ofType: "json", inDirectory: "JWT.bundle")!
        let expectedTokenData = try! idpTokenResponsePath.readFileContents()
        let expectedToken = try! JSONDecoder().decode(TokenPayload.self, from: expectedTokenData)

        var counter = 0
        let tokenEndpoint = localDiscoveryDocument.token.url
        stub(condition: isHost("localhost")
            && isPath(tokenEndpoint.path)
            && isMethodPOST()
            && hasHeaderNamed("Content-Type", value: "application/x-www-form-urlencoded")
            && hasBody(httpBodyData)
            && !hasHeaderNamed("Authorization")) { _ in
            counter += 1

            return fixture(filePath: idpTokenResponsePath, headers: ["Content-Type": "application/json"])
        }

        RealIDPClient(client: config)
            .exchange(token: exchangeTokenDummy,
                      verifier: verifier,
                      encryptedKeyVerifier: keyVerifier,
                      using: localDiscoveryDocument)
            .test(expectations: { token in
                expect(token) == expectedToken
            })
        expect(counter) == 1
    }
}
