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

/// Simple interceptor that adds additional or changes existing HTTP Headers with given values
public class AdditionalHeaderInterceptor: Interceptor {
    public init(additionalHeader: [String: String]) {
        self.additionalHeader = additionalHeader
    }

    let additionalHeader: [String: String]

    public func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPError> {
        var request = chain.request

        for (header, value) in additionalHeader {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return chain.proceed(request: request)
    }
}
