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

/// Simple interceptor that adds additional or changes existing HTTP Headers with given values
public class AdditionalHeaderInterceptor: Interceptor {
    public init(additionalHeader: [String: String]) {
        self.additionalHeader = additionalHeader
    }

    let additionalHeader: [String: String]

    public func interceptPublisher(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        var request = chain.request

        for (header, value) in additionalHeader {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return chain.proceedPublisher(request: request)
    }

    public func interceptAsync(chain: Chain) async throws -> HTTPResponse {
        var request = chain.request

        for (header, value) in additionalHeader {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return try await chain.proceedAsync(request: request)
    }
}
