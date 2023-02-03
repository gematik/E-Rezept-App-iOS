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

/// Modifies `URLRequests` going out and the corresponding `URLResponse` coming back in.
/// Usage e.g. for manipulating header field of an existing request.
public protocol Interceptor {
    /// Intercept the chain (e.g. modify it's request)
    ///
    /// - Parameter chain: request chain to be intercepted
    /// - Note: A call to `chain.proceed(request:)` is critical when implementing this protocol function.
    /// - Returns: `AnyPublisher` that emits the response as `HTTPClient.Response`
    func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPError>
}
