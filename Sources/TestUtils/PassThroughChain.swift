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

public class PassThroughChain: Chain {
    public private(set) var request: URLRequest
    public var incomingProceedRequests = [URLRequest]()
    public var responseData = Data()
    public var response = HTTPURLResponse()
    public var statusCode = HTTPStatusCode.ok

    public init(request: URLRequest) {
        self.request = request
    }

    /// if set this response is used in favor of individual properties
    public var httpResponse: HTTPResponse?

    public func proceedPublisher(request: URLRequest) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        incomingProceedRequests.append(request)
        let fallback = HTTPResponse(data: responseData, response: response, status: statusCode)
        return Just(httpResponse ?? fallback)
            .setFailureType(to: HTTPClientError.self)
            .eraseToAnyPublisher()
    }

    public func proceedAsync(request: URLRequest) async -> HTTPResponse {
        incomingProceedRequests.append(request)
        let fallback = HTTPResponse(data: responseData, response: response, status: statusCode)
        return httpResponse ?? fallback
    }
}
