//
//  Copyright (c) 2023 gematik GmbH
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

    public func proceed(request: URLRequest) -> AnyPublisher<HTTPResponse, HTTPError> {
        incomingProceedRequests.append(request)
        let fallback = HTTPResponse(data: responseData, response: response, status: statusCode)
        return Just(httpResponse ?? fallback)
            .setFailureType(to: HTTPError.self)
            .eraseToAnyPublisher()
    }
}
