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
import Foundation
import Nimble
import OpenSSL
import TestUtils
import TrustStore
@testable import VAUClient
import XCTest

final class VAUSessionTests: XCTestCase {
    func testSessionRetainsCurrentUserPseudonym() throws {
        // given
        let url = URL(string: "http://some-service.com")!
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)

        let vauAccessTokenProvider = MockVAUAccessTokenProvider()
        vauAccessTokenProvider.vauBearerToken = Just("SomeAccessToken").setFailureType(to: VAUError.self)
            .eraseToAnyPublisher()
        let mockVAUCrypto = MockVAUCrypto()
        mockVAUCrypto.decryptDataReturnValue = ""
        mockVAUCrypto.encryptReturnValue = Data()
        let mockVAUCryptoProvider = MockVAUCryptoProvider()
        mockVAUCryptoProvider.provideForVauCertificateBearerTokenReturnValue = mockVAUCrypto
        let trustStoreSession = MockTrustStoreSession()
        trustStoreSession.loadVauCertificateReturnValue = Just(Self.defaultVauCertificate)
            .setFailureType(to: TrustStoreError.self).eraseToAnyPublisher()

        let sut = VAUSession(
            vauServer: url,
            vauAccessTokenProvider: vauAccessTokenProvider,
            vauCryptoProvider: mockVAUCryptoProvider,
            vauStorage: MemStorage(),
            trustStoreSession: trustStoreSession
        )
        let interceptor = sut.provideInterceptor()

        // helping subscriber
        var currentVauEndpoints: [URL?] = []
        let currentVauEndpointSubscriber = sut.vauEndpoint
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { currentVauEndpoints.append($0) }
            )

        // If nothing was assigned, the VAU endpoint should default to ___/VAU/0
        expect(currentVauEndpoints.count) == 1
        expect(currentVauEndpoints[0]?.absoluteString) == "\(url)/VAU/0"

        // Mock first response containing a new user pseudonym for further use
        let userPseudonymHeaders1 = ["userpseudonym": "pseudo1"]
        let response1 = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "1/1",
            headerFields: userPseudonymHeaders1
        )!
        chain.response = response1
        interceptor.intercept(chain: chain)
            .test(expectations: { _ in
                expect(currentVauEndpoints.count) == 2
                expect(currentVauEndpoints[1]?.absoluteString) == "\(url)/VAU/pseudo1"
            })

        // Mock second response containing another user pseudonym for further use
        let userPseudonymHeaders2 = ["userpseudonym": "pseudo2"]
        let response2 = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "1/1",
            headerFields: userPseudonymHeaders2
        )!
        chain.response = response2
        interceptor.intercept(chain: chain)
            .test(expectations: { _ in
                expect(currentVauEndpoints.count) == 3
                expect(currentVauEndpoints[2]?.absoluteString) == "\(url)/VAU/pseudo2"
            })

        currentVauEndpointSubscriber.cancel()
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
