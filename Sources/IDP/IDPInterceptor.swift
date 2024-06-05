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
import HTTPClient

/// Delegate for HTTPClient Interceptor(s)
public protocol IDPSessionDelegate: AnyObject {
    /// Asks the delegate whether the given request should be authorized
    ///
    /// - Parameter request: request to authorize
    /// - Returns: when returning true the Interceptor must authorize the request
    func shouldAuthorize(request: URLRequest) -> Bool
}

/// The IDP HTTP Interceptor to authenticate HTTP-Requests
public class IDPInterceptor: Interceptor {
    private let session: IDPSession

    /// The IDPSession delegate used for the intercept
    public weak var delegate: IDPSessionDelegate?

    /// Initialize with IDPSession
    ///
    /// - Parameters:
    ///   - session: the session to use
    ///   - delegate: optional delegate
    public init(session: IDPSession, delegate: IDPSessionDelegate? = nil) {
        self.session = session
        self.delegate = delegate
    }

    /// Intercepting a `Chain` to set the Authorization header
    ///
    /// - Note: when the session cannot provide a valid accessToken upon intercept and the delegate is nil or
    ///         `delegate.shouldAuthorize(request:)` returns `true`, the interceptor invalidates the request chain
    ///         with a HTTPError.authentication error.
    ///
    /// - Parameter chain: the request chain to proceed authenticated hereafter
    /// - Returns: Publisher that continues the chain authenticated
    public func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        var request = chain.request
        if let delegate = self.delegate, delegate.shouldAuthorize(request: request) == false {
            return chain.proceed(request: request)
        } else {
            return session
                .autoRefreshedToken
                .first()
                .tryMap { token in
                    guard let token = token else {
                        throw IDPError.tokenUnavailable
                    }
                    // [REQ:gemSpec_IDP_Frontend:A_20602,A_21325#1]
                    request.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
                    return request
                }
                .mapError { error in
                    // [REQ:gemSpec_eRp_FdV:A_20167-02#4] no token available, bailout
                    .authentication(error)
                }
                .flatMap { request -> AnyPublisher<HTTPResponse, HTTPClientError> in
                    chain
                        // swiftlint:disable:previous trailing_closure
                        .proceed(request: request)
                        .handleEvents(receiveOutput: { httpResponse in
                            if httpResponse.status == HTTPStatusCode.unauthorized {
                                // [REQ:gemSpec_eRp_FdV:A_20167-02#5] invalidate/delete unauthorized token
                                // [REQ:BSI-eRp-ePA:O.Source_5#2] invalidate/delete unauthorized token
                                self.session.invalidateAccessToken()
                            }
                        })
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }
}
