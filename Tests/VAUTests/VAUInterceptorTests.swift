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
import Nimble
import TestUtils
import TrustStore
@testable import VAUClient
import XCTest

final class VAUInterceptorTests: XCTestCase {
    func testIntercept() throws {
        // given
        let session = VAUSession(
            vauServer: URL(string: "http://some-service.com")!,
            vauAccessTokenProvider: VAUAccessTokenProviderMock(),
            vauCryptoProvider: VAUCryptoProviderMock(),
            vauStorage: MemStorage(),
            trustStoreSession: TrustStoreSessionMock()
        )
        let request = URLRequest(url: URL(string: "http://www.url.com")!)
        let chain = PassThroughChain(request: request)
        let sut = session.provideInterceptor()

        // expectations
        sut.intercept(chain: chain)
            .test(expectations: { _ in
                expect(chain.incomingProceedRequests.count) == 1
            })
    }

    // Crypto only works from macOS 11 and onwards.
    #if os(iOS)
    func testProcessToVauRequest() throws {
        // given
        var urlRequest = URLRequest(url: URL(string: "http://some-service.com/path")!)
        urlRequest.httpBody = Data([0x0, 0x1])
        let vauCryptoProvider = EciesVAUCryptoProvider()
        let vauEndPoint = URL(string: "http://some-service.com/VAU/a1b2")!
        let bearerToken = "Bearer Bearer"
        let vauCertificate = X509VAUCertificate(x509: TrustStoreSessionMock().vauCertificate)

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
    #endif

    func testProcessVauResponse_negative() throws {
        // given
        let vauResponse = HTTPResponse(data: Data(), response: HTTPURLResponse(), status: .forbidden)
        let vauCertificate = X509VAUCertificate(x509: TrustStoreSessionMock().vauCertificate)
        let vauCrypto = try EciesVAUCryptoProvider()
            .provide(for: "message", vauCertificate: vauCertificate, bearerToken: "Bearer xyz")
        let url = URL(string: "http://some-service.com/path")!

        // when
        let processedResponse =
            try VAUInterceptor.processVauResponse(httpResponse: vauResponse, vauCrypto: vauCrypto, originalUrl: url)

        // then
        expect(processedResponse == vauResponse).to(beTrue())
    }
}
