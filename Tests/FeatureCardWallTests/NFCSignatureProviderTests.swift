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

import Combine
import Dependencies
import eRpKit
@testable import FeatureCardWall
import Foundation
@testable import HealthCardControl
import IDP
import Nimble
import OpenSSL
import XCTest

final class NFCSignatureProviderTests: XCTestCase {
    var mockJWTSigner: JWTSignerMock!
    var mockNFCHealthCardSessionHandle: MockNFCHealthCardSessionHandle!

    override func setUp() {
        super.setUp()
        mockJWTSigner = JWTSignerMock()
        mockNFCHealthCardSessionHandle = MockNFCHealthCardSessionHandle()
    }

    func testSignChallenge_certificateInStorage_verifiesSignature() async throws {
        // given
        let profileId = UUID()
        let idpChallengeSession = Self.Fixtures.idpChallengeSession

        var readCertificateCallsCount = 0
        let readCertificateFromCard = {
            readCertificateCallsCount += 1
            return Self.Fixtures.autCertificateResponse
        }
        mockJWTSigner.signMessageDataDataReturnValue = Data()

        let mockIdpChallengeSigner = NFCSignatureProvider.IDPChallengeSessionSigner { _, _, _, _ in
            Self.Fixtures.signedChallenge
        }
        let mockSignedChallengeSignatureVerifier = NFCSignatureProvider.SignedChallengeSignatureVerifier { _, _ in
            true
        }

        try await withDependencies { dependencies in
            dependencies.secureEGKCertificateStorageClient.certificate = { _ in
                Just(Self.Fixtures.x509).eraseToAnyPublisher()
            }
        } operation: {
            // when
            let (signedChallenge, _) = try await NFCSignatureProvider.signChallenge(
                challenge: idpChallengeSession,
                nfcHealthCardSessionHandle: mockNFCHealthCardSessionHandle,
                readCertificateFromCard: readCertificateFromCard,
                jwtSigner: mockJWTSigner,
                idpChallengeSigner: mockIdpChallengeSigner,
                signedChallengeSignatureVerifier: mockSignedChallengeSignatureVerifier,
                profileId: profileId
            )

            // then
            expect(readCertificateCallsCount) == 0
            expect(signedChallenge).to(equal(Self.Fixtures.signedChallenge))
        }
    }

    func testSignChallenge_certificateInStorage_failsVerifingSignature() async throws {
        // given
        let profileId = UUID()
        let idpChallengeSession = Self.Fixtures.idpChallengeSession

        var readCertificateCallsCount = 0
        let readCertificateFromCard = {
            readCertificateCallsCount += 1
            return Self.Fixtures.autCertificateResponse
        }
        let mockIdpChallengeSigner = NFCSignatureProvider.IDPChallengeSessionSigner { _, _, _, _ in
            Self.Fixtures.signedChallenge
        }
        var signatureVerifierCallsCount = 0
        let mockSignedChallengeSignatureVerifier = NFCSignatureProvider.SignedChallengeSignatureVerifier { _, _ in
            signatureVerifierCallsCount += 1
            return false
        }

        try await withDependencies { dependencies in
            dependencies.secureEGKCertificateStorageClient.certificate = { _ in
                Just(Self.Fixtures.x509).eraseToAnyPublisher()
            }
            dependencies.secureEGKCertificateStorageClient.setCertificate = { _, _ in }
        } operation: {
            // when
            let (signedChallenge, _) = try await NFCSignatureProvider.signChallenge(
                challenge: idpChallengeSession,
                nfcHealthCardSessionHandle: mockNFCHealthCardSessionHandle,
                readCertificateFromCard: readCertificateFromCard,
                jwtSigner: mockJWTSigner,
                idpChallengeSigner: mockIdpChallengeSigner,
                signedChallengeSignatureVerifier: mockSignedChallengeSignatureVerifier,
                profileId: profileId
            )

            // then
            expect(readCertificateCallsCount) == 1
            expect(signatureVerifierCallsCount) == 1
            expect(signedChallenge).to(equal(Self.Fixtures.signedChallenge))
        }
    }

    func testSignChallenge_noCertificateInStorage() async throws {
        // given
        let profileId = UUID()
        let idpChallengeSession = Self.Fixtures.idpChallengeSession

        var setCertificateCallsCount = 0
        var readCertificateCallsCount = 0
        let readCertificateFromCard = {
            readCertificateCallsCount += 1
            return Self.Fixtures.autCertificateResponse
        }
        mockJWTSigner.signMessageDataDataReturnValue = Data()

        let mockIdpChallengeSigner = NFCSignatureProvider.IDPChallengeSessionSigner { _, _, _, _ in
            Self.Fixtures.signedChallenge
        }
        var signatureVerifierCallsCount = 0
        let mockSignedChallengeSignatureVerifier = NFCSignatureProvider.SignedChallengeSignatureVerifier { _, _ in
            signatureVerifierCallsCount += 1
            return false
        }

        try await withDependencies { dependencies in
            dependencies.secureEGKCertificateStorageClient.certificate = { _ in
                Just(nil).eraseToAnyPublisher()
            }
            dependencies.secureEGKCertificateStorageClient.setCertificate = { _, _ in
                setCertificateCallsCount += 1
            }
        } operation: {
            // when
            let (signedChallenge, _) = try await NFCSignatureProvider.signChallenge(
                challenge: idpChallengeSession,
                nfcHealthCardSessionHandle: mockNFCHealthCardSessionHandle,
                readCertificateFromCard: readCertificateFromCard,
                jwtSigner: mockJWTSigner,
                idpChallengeSigner: mockIdpChallengeSigner,
                signedChallengeSignatureVerifier: mockSignedChallengeSignatureVerifier,
                profileId: profileId
            )

            // then
            expect(readCertificateCallsCount) == 1
            expect(signatureVerifierCallsCount) == 0
            expect(setCertificateCallsCount) == 2
            expect(signedChallenge).to(equal(Self.Fixtures.signedChallenge))
        }
    }
}

extension NFCSignatureProviderTests {
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
