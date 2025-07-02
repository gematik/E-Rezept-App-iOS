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

class URLRequestChain: Chain {
    var request: URLRequest
    private let session: URLSession
    private let interceptors: [Interceptor]

    init(request: URLRequest, session: URLSession, with interceptors: [Interceptor]) {
        self.session = session
        self.request = request
        self.interceptors = interceptors
    }

    func proceedPublisher(request newRequest: URLRequest) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        guard let interceptor = interceptors.first else {
            // interceptors is empty
            request = newRequest
            return session.dataTaskPublisher(for: newRequest).mapToHTTPResponse()
        }
        request = newRequest
        let nextChain = URLRequestChain(request: newRequest, session: session, with: Array(interceptors.dropFirst()))
        return interceptor.interceptPublisher(chain: nextChain)
    }

    func proceedAsync(request newRequest: URLRequest) async throws -> HTTPResponse {
        request = newRequest
        if let interceptor = interceptors.first {
            let nextChain = URLRequestChain(
                request: newRequest,
                session: session,
                with: Array(interceptors.dropFirst())
            )
            return try await interceptor.interceptAsync(chain: nextChain)
        } else {
            // interceptors is empty
            let data: Data
            let urlResponse: URLResponse
            do {
                (data, urlResponse) = try await session.data(for: newRequest, delegate: nil)
            } catch {
                throw error.asHTTPClientError()
            }
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw HTTPClientError.internalError("URLResponse is not a HTTPURLResponse")
            }
            guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
                throw HTTPClientError.internalError("Unsupported http status code [\(httpResponse.statusCode)]")
            }
            return (data: data, response: httpResponse, status: statusCode)
        }
    }
}

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    func mapToHTTPResponse() -> AnyPublisher<HTTPResponse, HTTPClientError> {
        tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPClientError.internalError("URLResponse is not a HTTPURLResponse")
            }
            guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
                throw HTTPClientError.internalError("Unsupported http status code [\(httpResponse.statusCode)]")
            }
            return (data: data, response: httpResponse, status: statusCode)
        }
        .mapError { error in
            error.asHTTPClientError()
        }
        .eraseToAnyPublisher()
    }
}
