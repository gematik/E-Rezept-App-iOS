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

/// Modifies `URLRequests` going out and the corresponding `URLResponse` coming back in.
/// Usage e.g. for manipulating header field of an existing request.
public protocol Interceptor {
    /// Intercept the chain (e.g. modify it's request)
    ///
    /// - Parameter chain: request chain to be intercepted
    /// - Note: A call to `chain.proceed(request:)` is critical when implementing this protocol function.
    /// - Returns: `AnyPublisher` that emits the response as `HTTPClient.Response`
    @available(*, deprecated, message: "Use async version instead")
    func interceptPublisher(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError>

    /// Intercept the chain (e.g. modify it's request)
    ///
    /// - Parameter chain: request chain to be intercepted
    /// - Note: A call to `chain.proceed(request:)` is critical when implementing this protocol function.
    /// - Note: Only `HTTPClientError` are supposed to be thrown.
    /// - Returns: Response emitted as `HTTPClient.Response`
    func interceptAsync(chain: Chain) async throws -> HTTPResponse
}

extension Interceptor {
    /// Intercept the chain (e.g. modify it's request)
    ///
    /// - Parameter chain: request chain to be intercepted
    /// - Note: A call to `chain.proceed(request:)` is critical when implementing this protocol function.
    /// - Returns: `AnyPublisher` that emits the response as `HTTPClient.Response`
    @available(
        *,
        deprecated,
        renamed: "interceptPublisher(chain:)",
        message: "Use async version instead"
    )
    public func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        interceptPublisher(chain: chain)
    }
}
