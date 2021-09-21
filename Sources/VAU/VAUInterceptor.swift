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

/// The VAU (trusted execution environment) http Interceptor to encrypt HTTP-Requests before sending them
/// and decrypting the received encrypted responses.
class VAUInterceptor: Interceptor {
    private let vauAccessTokenProvider: VAUAccessTokenProvider
    private let vauCertificateProvider: VAUCertificateProvider
    private let vauCryptoProvider: VAUCryptoProvider
    private let vauEndpointHandler: VAUEndpointHandler

    init(
        vauAccessTokenProvider: VAUAccessTokenProvider,
        vauCertificateProvider: VAUCertificateProvider,
        vauCryptoProvider: VAUCryptoProvider,
        vauEndpointHandler: VAUEndpointHandler
    ) {
        self.vauAccessTokenProvider = vauAccessTokenProvider
        self.vauCertificateProvider = vauCertificateProvider
        self.vauCryptoProvider = vauCryptoProvider
        self.vauEndpointHandler = vauEndpointHandler
    }

    func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPError> {
        let request = chain.request
        guard let originalUrl = request.url else {
            return Fail(error: HTTPError.vauError(VAUError.internalError("Could not prepare request for VAU service")))
                .eraseToAnyPublisher()
        }

        // [REQ:gemSpec_eRp_FdV:A_19187] VAU Bearer must be set to trigger a request
        return vauAccessTokenProvider.vauBearerToken
            .zip(
                vauCertificateProvider.loadAndVerifyVauCertificate(),
                vauEndpointHandler.vauEndpoint
            )
            .first()
            // Prepare outer request (encrypt original request and embed it into a new one)
            // [REQ:gemSpec_Krypt:A_20161-01]
            .processToVauRequest(urlRequest: request, vauCryptoProvider: vauCryptoProvider)
            .flatMap { vauCrypto, vauRequest -> AnyPublisher<HTTPResponse, HTTPError> in
                chain.proceed(request: vauRequest)
                    // Process VAU server response (validate and extract+decrypt inner FHIR service response)
                    // [REQ:gemSpec_Krypt:A_20174]
                    .handleUserPseudonym(vauEndpointHandler: self.vauEndpointHandler)
                    .processVauResponse(vauCrypto: vauCrypto, originalUrl: originalUrl)
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == (BearerToken, VAUCertificate, URL), Failure == VAUError {
    // Prepare outer request (encrypt original request and embed it into a new one)
    // [REQ:gemSpec_Krypt:A_20161-01]
    func processToVauRequest(
        urlRequest: URLRequest,
        vauCryptoProvider: VAUCryptoProvider
    ) -> AnyPublisher<(VAUCrypto, URLRequest), HTTPError> {
        tryMap { bearerToken, vauCertificate, vauEndPoint in
            try VAUInterceptor.processToVauRequest(
                urlRequest: urlRequest,
                vauCryptoProvider: vauCryptoProvider,
                vauEndPoint: vauEndPoint,
                bearerToken: bearerToken,
                vauCertificate: vauCertificate
            )
        }
        .mapError { .vauError($0) }
        .eraseToAnyPublisher()
    }
}

extension VAUInterceptor {
    static func processToVauRequest(
        urlRequest: URLRequest,
        vauCryptoProvider: VAUCryptoProvider,
        vauEndPoint: URL,
        bearerToken: BearerToken,
        vauCertificate: VAUCertificate
    ) throws -> (VAUCrypto, URLRequest) {
        let stringEncodedRequest = try urlRequest.encodeToRawString()
        let vauCrypto = try vauCryptoProvider.provide(
            for: stringEncodedRequest,
            vauCertificate: vauCertificate,
            bearerToken: bearerToken
        )
        let encrypted = try vauCrypto.encrypt()
        var outerRequest = URLRequest(url: vauEndPoint, cachePolicy: .reloadIgnoringLocalCacheData)
        outerRequest.httpMethod = "POST"
        outerRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        outerRequest.httpBody = encrypted
        return (vauCrypto, outerRequest)
    }
}

extension Publisher where Output == HTTPResponse, Failure == HTTPError {
    func handleUserPseudonym(vauEndpointHandler: VAUEndpointHandler) -> AnyPublisher<HTTPResponse, HTTPError> {
        handleEvents( // swiftlint:disable:this trailing_closure
            receiveOutput: { httpResponse in
                vauEndpointHandler.didReceiveUserPseudonym(in: httpResponse)
            }
        )
        .eraseToAnyPublisher()
    }

    func processVauResponse(vauCrypto: VAUCrypto, originalUrl: URL) -> AnyPublisher<HTTPResponse, HTTPError> {
        tryMap { httpResponse in
            try VAUInterceptor.processVauResponse(
                httpResponse: httpResponse,
                vauCrypto: vauCrypto,
                originalUrl: originalUrl
            )
        }
        .mapError { .vauError($0) }
        .eraseToAnyPublisher()
    }
}

extension VAUInterceptor {
    // Process VAU server response (validate and extract+decrypt inner FHIR service response)
    // [REQ:gemSpec_Krypt:A_20174]
    static func processVauResponse(httpResponse: HTTPResponse, vauCrypto: VAUCrypto, originalUrl: URL) throws
        -> HTTPResponse {
        guard httpResponse.status == .ok,
              httpResponse.response.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream"
        else {
            return httpResponse
        }
        let extracted = httpResponse.data
        let decrypted = try vauCrypto.decrypt(data: extracted)
        let decoded = try decrypted.decodeToHTTPResponse(url: originalUrl)
        return decoded
    }
}
