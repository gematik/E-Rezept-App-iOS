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

import Combine
@testable import eRpFeatures
import eRpKit
import Foundation
@testable import HealthCardControl
import IDP
import Nimble
import OpenSSL
import XCTest

final class EGKSignatureProviderTests: XCTestCase {
    var mockSecureUserDataStore: MockSecureUserDataStore!
    var mockJWTSigner: MockJWTSigner!
    var mockNFCHealthCardSessionHandle: MockNFCHealthCardSessionHandle!

    override func setUp() {
        super.setUp()
        mockSecureUserDataStore = MockSecureUserDataStore()
        mockJWTSigner = MockJWTSigner()
        mockNFCHealthCardSessionHandle = MockNFCHealthCardSessionHandle()
    }

    func testSignChallenge_certificateInStorage_verifiesSignature() async throws {
        // given
        let sut = EGKSignatureProvider(storage: mockSecureUserDataStore)
        let idpChallengeSession = Self.Fixtures.idpChallengeSession

        mockSecureUserDataStore.underlyingCertificate = Just(Self.Fixtures.x509).eraseToAnyPublisher()
        var readCertificateCallsCount = 0
        let readCertificateFromCard = {
            readCertificateCallsCount += 1
            return Self.Fixtures.autCertificateResponse
        }
        mockJWTSigner.signMessageReturnValue = Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher()

        let mockIdpChallengeSigner = EGKSignatureProvider.IDPChallengeSessionSigner { _, _, _, _ in
            Self.Fixtures.signedChallenge
        }
        var signatureVerifierCallsCount = 0
        let mockSignedChallengeSignatureVerifier = EGKSignatureProvider.SignedChallengeSignatureVerifier { _, _ in
            signatureVerifierCallsCount += 1
            return true
        }

        // when
        let (signedChallenge, _) = try await sut.signChallenge(
            challenge: idpChallengeSession,
            nfcHealthCardSessionHandle: mockNFCHealthCardSessionHandle,
            readCertificateFromCard: readCertificateFromCard,
            jwtSigner: mockJWTSigner,
            idpChallengeSigner: mockIdpChallengeSigner,
            signedChallengeSignatureVerifier: mockSignedChallengeSignatureVerifier
        )

        // then
        expect(readCertificateCallsCount) == 0
        expect(signatureVerifierCallsCount) == 1
        expect(self.mockSecureUserDataStore.setCertificateCalled) == false
        expect(signedChallenge).to(equal(Self.Fixtures.signedChallenge))
    }

    func testSignChallenge_certificateInStorage_failsVerifingSignature() async throws {
        // given
        let sut = EGKSignatureProvider(storage: mockSecureUserDataStore)
        let idpChallengeSession = Self.Fixtures.idpChallengeSession

        mockSecureUserDataStore.underlyingCertificate = Just(Self.Fixtures.x509).eraseToAnyPublisher()
        var readCertificateCallsCount = 0
        let readCertificateFromCard = {
            readCertificateCallsCount += 1
            return Self.Fixtures.autCertificateResponse
        }
        mockJWTSigner.signMessageReturnValue = Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher()

        let mockIdpChallengeSigner = EGKSignatureProvider.IDPChallengeSessionSigner { _, _, _, _ in
            Self.Fixtures.signedChallenge
        }
        var signatureVerifierCallsCount = 0
        let mockSignedChallengeSignatureVerifier = EGKSignatureProvider.SignedChallengeSignatureVerifier { _, _ in
            signatureVerifierCallsCount += 1
            return false
        }

        // when
        let (signedChallenge, _) = try await sut.signChallenge(
            challenge: idpChallengeSession,
            nfcHealthCardSessionHandle: mockNFCHealthCardSessionHandle,
            readCertificateFromCard: readCertificateFromCard,
            jwtSigner: mockJWTSigner,
            idpChallengeSigner: mockIdpChallengeSigner,
            signedChallengeSignatureVerifier: mockSignedChallengeSignatureVerifier
        )

        // then
        expect(readCertificateCallsCount) == 1
        expect(signatureVerifierCallsCount) == 1
        expect(self.mockSecureUserDataStore.setCertificateCalled) == true
        expect(self.mockSecureUserDataStore.setCertificateCallsCount) == 2
        expect(self.mockSecureUserDataStore.setCertificateReceivedInvocations) == [nil, Self.Fixtures.x509]
        expect(signedChallenge).to(equal(Self.Fixtures.signedChallenge))
    }

    func testSignChallenge_noCertificateInStorage() async throws {
        // given
        let sut = EGKSignatureProvider(storage: mockSecureUserDataStore)
        let idpChallengeSession = Self.Fixtures.idpChallengeSession

        mockSecureUserDataStore.underlyingCertificate = Just(nil).eraseToAnyPublisher()
        var readCertificateCallsCount = 0
        let readCertificateFromCard = {
            readCertificateCallsCount += 1
            return Self.Fixtures.autCertificateResponse
        }
        mockJWTSigner.signMessageReturnValue = Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher()

        let mockIdpChallengeSigner = EGKSignatureProvider.IDPChallengeSessionSigner { _, _, _, _ in
            Self.Fixtures.signedChallenge
        }
        var signatureVerifierCallsCount = 0
        let mockSignedChallengeSignatureVerifier = EGKSignatureProvider.SignedChallengeSignatureVerifier { _, _ in
            signatureVerifierCallsCount += 1
            return false
        }

        // when
        let (signedChallenge, _) = try await sut.signChallenge(
            challenge: idpChallengeSession,
            nfcHealthCardSessionHandle: mockNFCHealthCardSessionHandle,
            readCertificateFromCard: readCertificateFromCard,
            jwtSigner: mockJWTSigner,
            idpChallengeSigner: mockIdpChallengeSigner,
            signedChallengeSignatureVerifier: mockSignedChallengeSignatureVerifier
        )

        // then
        expect(readCertificateCallsCount) == 1
        expect(signatureVerifierCallsCount) == 0
        expect(self.mockSecureUserDataStore.setCertificateCalled) == true
        expect(self.mockSecureUserDataStore.setCertificateCallsCount) == 2
        expect(self.mockSecureUserDataStore.setCertificateReceivedInvocations) == [nil, Self.Fixtures.x509]
        expect(signedChallenge).to(equal(Self.Fixtures.signedChallenge))
    }
}

extension EGKSignatureProviderTests {
    enum Fixtures {
        static let challenge = try! IDPChallenge(
            challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
        )
        static let idpChallengeSession = IDPChallengeSession(
            challenge: challenge,
            verifierCode: "1234567890",
            state: "random State",
            nonce: "random Nonce"
        )

        static let autCertificateResponse = AutCertificateResponse(info: .efAutE256, certificate: x509Data)

        static let signedChallenge = SignedChallenge(
            originalChallenge: idpChallengeSession,
            signedChallenge: try! JWT(from: "eyAiYWxnIjogIm5vbmUiIH0.eyJwYXlsb2FkIjoidGV4dCJ9")
        )

        static let x509: X509 = {
            let x509 = try! X509(der: x509Data)
            return x509
        }()

        static let x509Data: Data = {
            let base64 =
                // swiftlint:disable:next line_length
                "MIICsTCCAligAwIBAgIHA61I5ACUjTAKBggqhkjOPQQDAjCBhDELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxMjAwBgNVBAsMKUtvbXBvbmVudGVuLUNBIGRlciBUZWxlbWF0aWtpbmZyYXN0cnVrdHVyMSAwHgYDVQQDDBdHRU0uS09NUC1DQTEwIFRFU1QtT05MWTAeFw0yMDA4MDQwMDAwMDBaFw0yNTA4MDQyMzU5NTlaMEkxCzAJBgNVBAYTAkRFMSYwJAYDVQQKDB1nZW1hdGlrIFRFU1QtT05MWSAtIE5PVC1WQUxJRDESMBAGA1UEAwwJSURQIFNpZyAxMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABJZQrG1NWxIB3kz/6Z2zojlkJqN3vJXZ3EZnJ6JXTXw5ZDFZ5XjwWmtgfomv3VOV7qzI5ycUSJysMWDEu3mqRcajge0wgeowHQYDVR0OBBYEFJ8DVLAZWT+BlojTD4MT/Na+ES8YMDgGCCsGAQUFBwEBBCwwKjAoBggrBgEFBQcwAYYcaHR0cDovL2VoY2EuZ2VtYXRpay5kZS9vY3NwLzAMBgNVHRMBAf8EAjAAMCEGA1UdIAQaMBgwCgYIKoIUAEwEgUswCgYIKoIUAEwEgSMwHwYDVR0jBBgwFoAUKPD45qnId8xDRduartc6g6wOD6gwLQYFKyQIAwMEJDAiMCAwHjAcMBowDAwKSURQLURpZW5zdDAKBggqghQATASCBDAOBgNVHQ8BAf8EBAMCB4AwCgYIKoZIzj0EAwIDRwAwRAIgVBPhAwyX8HAVH0O0b3+VazpBAWkQNjkEVRkv+EYX1e8CIFdn4O+nivM+XVi9xiKK4dW1R7MD334OpOPTFjeEhIVV"
            let certData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
            return certData!
        }()
    }
}

// MARK: - MockNFCHealthCardSessionHandle -

import HealthCardAccess
import NFCCardReaderProvider

final class MockNFCHealthCardSessionHandle: NFCHealthCardSessionHandle {
    // MARK: - card

    var card: HealthCardType {
        get { underlyingCard }
        set(value) { underlyingCard = value }
    }

    var underlyingCard: HealthCardType!

    // MARK: - updateAlert

    var updateAlertMessageCallsCount = 0
    var updateAlertMessageCalled: Bool {
        updateAlertMessageCallsCount > 0
    }

    var updateAlertMessageReceivedMessage: String?
    var updateAlertMessageReceivedInvocations: [String] = []
    var updateAlertMessageClosure: ((String) -> Void)?

    func updateAlert(message: String) {
        updateAlertMessageCallsCount += 1
        updateAlertMessageReceivedMessage = message
        updateAlertMessageReceivedInvocations.append(message)
        updateAlertMessageClosure?(message)
    }

    // MARK: - invalidateSession

    var invalidateSessionWithCallsCount = 0
    var invalidateSessionWithCalled: Bool {
        invalidateSessionWithCallsCount > 0
    }

    var invalidateSessionWithReceivedError: String?
    var invalidateSessionWithReceivedInvocations: [String?] = []
    var invalidateSessionWithClosure: ((String?) -> Void)?

    func invalidateSession(with error: String?) {
        invalidateSessionWithCallsCount += 1
        invalidateSessionWithReceivedError = error
        invalidateSessionWithReceivedInvocations.append(error)
        invalidateSessionWithClosure?(error)
    }
}
