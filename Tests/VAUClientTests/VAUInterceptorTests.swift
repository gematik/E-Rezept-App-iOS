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
import Foundation
import HTTPClient
import Nimble
import OpenSSL
import TestUtils
import TrustStore
@testable import VAUClient
import XCTest

final class VAUInterceptorTests: XCTestCase {
    func testIntercept() async throws {
        // given
        let vauAccessTokenProvider = VAUAccessTokenProviderMock()
        vauAccessTokenProvider.vauBearerToken = Just("SomeAccessToken").setFailureType(to: VAUError.self)
            .eraseToAnyPublisher()
        let mockVAUCrypto = VAUCryptoMock()
        mockVAUCrypto.decryptDataDataStringReturnValue = ""
        mockVAUCrypto.encryptDataReturnValue = Data()
        let mockVAUCryptoProvider = VAUCryptoProviderMock()
        mockVAUCryptoProvider
            .provideForMessageStringVauCertificateVAUCertificateBearerTokenBearerTokenVAUCryptoReturnValue =
            mockVAUCrypto
        let trustStoreSession = TrustStoreSessionMock()
        trustStoreSession.vauCertificateX509ReturnValue = Self.defaultVauCertificate

        let session = try VAUSession(
            vauServer: XCTUnwrap(URL(string: "http://some-service.com")),
            vauAccessTokenProvider: vauAccessTokenProvider,
            vauCryptoProvider: mockVAUCryptoProvider,
            vauStorage: MemStorage(),
            trustStoreSession: trustStoreSession
        )
        let request = try URLRequest(url: XCTUnwrap(URL(string: "http://www.url.com")))
        let chain = PassThroughChain(request: request)

        let sut = VAUInterceptor(vauSession: session)

        // expectations
        _ = try? await sut.intercept(chain: chain)
        expect(chain.incomingProceedRequests.count) == 1
    }

    func testProcessToVauRequest() throws {
        // given
        var urlRequest = try URLRequest(url: XCTUnwrap(URL(string: "http://some-service.com/path")))
        urlRequest.httpBody = Data([0x0, 0x1])
        let vauCryptoProvider = EciesVAUCryptoProvider()
        let vauEndPoint = try XCTUnwrap(URL(string: "http://some-service.com/VAU/a1b2"))
        let bearerToken = "Bearer Bearer"
        let vauCertificate = X509VAUCertificate(x509: Self.defaultVauCertificate)

        // when
        let (_, vauRequest) = try VAUInterceptor.processToVauRequest(
            urlRequest: urlRequest,
            vauCryptoProvider: vauCryptoProvider,
            vauEndPoint: vauEndPoint,
            bearerToken: bearerToken,
            vauCertificate: vauCertificate
        )

        // then
        expect(vauRequest.url) == vauEndPoint
        expect(vauRequest.allHTTPHeaderFields?["Content-Type"]) == "application/octet-stream"
    }

    func testProcessVauResponse_negative() throws {
        // given
        let vauResponse = HTTPResponse(data: Data(), response: HTTPURLResponse(), status: .forbidden)
        let vauCertificate = X509VAUCertificate(x509: Self.defaultVauCertificate)
        let vauCrypto = try EciesVAUCryptoProvider()
            .provide(for: "message", vauCertificate: vauCertificate, bearerToken: "Bearer xyz")
        let url = try XCTUnwrap(URL(string: "http://some-service.com/path"))

        // when
        let processedResponse =
            try VAUInterceptor.processVauResponse(httpResponse: vauResponse, vauCrypto: vauCrypto, originalUrl: url)

        // then
        expect(processedResponse == vauResponse).to(beTrue())
    }

    static let defaultVauCertificate: X509 = {
        let pemString = """
        -----BEGIN CERTIFICATE-----
        MIICWzCCAgKgAwIBAgIUXcN6K1n5kgykxETzVBv/WoRt01YwCgYIKoZIzj0EAwIw
        gYIxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xDzANBgNVBAcMBkJlcmxp
        bjEQMA4GA1UECgwHZ2VtYXRpazEQMA4GA1UECwwHZ2VtYXRpazEtMCsGA1UEAwwk
        RS1SZXplcHQtVkFVIEJlaXNwaWVsaW1wbGVtZW50aWVydW5nMB4XDTIwMDUyMjE2
        NTgyNFoXDTIxMDUyMjE2NTgyNFowgYIxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZC
        ZXJsaW4xDzANBgNVBAcMBkJlcmxpbjEQMA4GA1UECgwHZ2VtYXRpazEQMA4GA1UE
        CwwHZ2VtYXRpazEtMCsGA1UEAwwkRS1SZXplcHQtVkFVIEJlaXNwaWVsaW1wbGVt
        ZW50aWVydW5nMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABIY0ISgw2tRXygUw
        XmaHE0FmucIaZf/r9VX05137BIiIZuS2hDYky9pDyX6omWi8Qf1TV2+CwD76fWAb
        n6ysKymjUzBRMB0GA1UdDgQWBBQh8MUVY5pJH8c0O/RVpDOPUIMXLjAfBgNVHSME
        GDAWgBQh8MUVY5pJH8c0O/RVpDOPUIMXLjAPBgNVHRMBAf8EBTADAQH/MAoGCCqG
        SM49BAMCA0cAMEQCIC8jRqHV/dHK+N9Y0NF5MVHS2RvtP3ndzCPhwKBz0UW9AiA6
        oJnHJ2OP68rqpnbHG1/WWGJEfVT9Fig3zeYwYZKYvg==
        -----END CERTIFICATE-----
        """
        let pem = pemString.data(using: .ascii)! // swiftlint:disable:this force_unwrapping
        return try! X509(pem: pem)
    }()
}
