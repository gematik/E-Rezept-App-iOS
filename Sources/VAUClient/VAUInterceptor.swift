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
import Foundation
import HTTPClient

/// The VAU (trusted execution environment) http Interceptor to encrypt HTTP-Requests before sending them
/// and decrypting the received encrypted responses.
/// [REQ:BSI-eRp-ePA:O.Ntwk_6#2] Interceptor implementing request and response encryption.
public class VAUInterceptor: Interceptor {
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

    public func intercept(chain: Chain) async throws -> HTTPResponse {
        let request = chain.request
        guard let originalUrl = request.url else {
            throw HTTPClientError.vauError(VAUError.internalError("Could not prepare request for VAU service"))
        }
        // [REQ:gemSpec_eRp_FdV:A_19187] VAU Bearer must be set to trigger a request
        async let vauBearerToken = vauAccessTokenProvider.vauBearerToken.async()
        async let vauCertificate = vauCertificateProvider.loadAndVerifyVauCertificate().async()
        async let vauEndPoint = vauEndpointHandler.vauEndpoint.async()

        let vauRequest: URLRequest
        let vauCrypto: VAUCrypto
        do {
            // Prepare outer request (encrypt original request and embed it into a new one)
            // [REQ:gemSpec_Krypt:A_20161-01#3] Encapsulate "real" HTTPRequest into VAU envelop
            (vauCrypto, vauRequest) = try await VAUInterceptor.processToVauRequest(
                urlRequest: request,
                vauCryptoProvider: vauCryptoProvider,
                vauEndPoint: vauEndPoint,
                bearerToken: vauBearerToken,
                vauCertificate: vauCertificate
            )
        } catch {
            throw HTTPClientError.vauError(error)
        }

        let vauResponse = try await chain.proceed(request: vauRequest)
        // Process VAU server response (validate and extract+decrypt inner FHIR service response)
        // [REQ:gemSpec_Krypt:A_20174#12] 2: Handle userpseudonym
        vauEndpointHandler.didReceiveUserPseudonym(in: vauResponse)

        let processedVauResponse: HTTPResponse
        do {
            // [REQ:gemSpec_Krypt:A_20174#16] 6: Remove the envelop
            processedVauResponse = try VAUInterceptor.processVauResponse(
                httpResponse: vauResponse,
                vauCrypto: vauCrypto,
                originalUrl: originalUrl
            )
        } catch {
            throw HTTPClientError.vauError(error)
        }
        return processedVauResponse
    }
}

// swiftlint:disable:next large_tuple
extension Publisher where Output == (BearerToken, VAUCertificate, URL), Failure == VAUError {
    // Prepare outer request (encrypt original request and embed it into a new one)
    // [REQ:gemSpec_Krypt:A_20161-01#4] Encapsulate "real" HTTPRequest into VAU envelop
    func processToVauRequest(
        urlRequest: URLRequest,
        vauCryptoProvider: VAUCryptoProvider
    ) -> AnyPublisher<(VAUCrypto, URLRequest), HTTPClientError> {
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
        // [REQ:gemSpec_Krypt:A_20161-01#14|5] 4: vauCrypto is generating new entity and thus a new request/id everytime
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

extension Publisher where Output == HTTPResponse, Failure == HTTPClientError {
    func handleUserPseudonym(vauEndpointHandler: VAUEndpointHandler) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        handleEvents(
            receiveOutput: { httpResponse in
                vauEndpointHandler.didReceiveUserPseudonym(in: httpResponse)
            },
            receiveRequest: nil
        )
        .eraseToAnyPublisher()
    }

    func processVauResponse(vauCrypto: VAUCrypto, originalUrl: URL) -> AnyPublisher<HTTPResponse, HTTPClientError> {
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
    // [REQ:gemSpec_Krypt:A_20174#11|12] 1: Check Content-Type
    static func processVauResponse(httpResponse: HTTPResponse, vauCrypto: VAUCrypto, originalUrl: URL) throws
        -> HTTPResponse {
        guard httpResponse.status == .ok,
              httpResponse.response.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream"
        else {
            return httpResponse
        }
        let extracted = httpResponse.data
        let decrypted = try vauCrypto.decrypt(data: extracted)
        return try decrypted.decodeToHTTPResponse(url: originalUrl)
    }
}
