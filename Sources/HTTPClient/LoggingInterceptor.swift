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
import GemCommonsKit

/// Debug Logging interceptor
///
/// note: Only logs to console when compiled with Debug configuration
public class LoggingInterceptor: Interceptor {
    public enum Level: Int {
        case none = 0
        case url
        case headers
        case body

        func log(request: URLRequest) {
            if rawValue > 0 {
                DLog(">> [\(request.httpMethod ?? "NO-METHOD")] \(request.url?.absoluteString ?? "NO-URL")")
            }
            if rawValue > 1 {
                DLog(">> [Headers]: \(request.allHTTPHeaderFields ?? [:])")
            }
            if rawValue > 2 {
                if let body = request.httpBody {
                    if let bodyString = String(data: body, encoding: .utf8) {
                        DLog(">> [BODY]: \(bodyString)")
                    } else {
                        DLog(">> [BODY (base64)]: \(body.base64EncodedString())")
                    }
                }
            }
        }

        func log(response object: HTTPResponse) {
            let (data, response, statusCode) = object
            if rawValue > 0 {
                let url = response.url?.absoluteString ?? "NO-URL"
                DLog("<< [StatusCode]: \(statusCode) \(url)")
            }
            if rawValue > 1 {
                DLog("<< [Headers]: \(response.allHeaderFields)")
            }
            if rawValue > 2 {
                if data.isEmpty {
                    DLog("<< [BODY]: NO DATA")
                } else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        DLog("<< [BODY]: \(responseString)")
                    } else {
                        DLog("<< [BODY (base64)]: \(data.base64EncodedString())")
                    }
                }
            }
        }
    }

    public var level: Level = .none

    public init(log level: Level) {
        self.level = level
    }

    public func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        #if DEBUG
        let request = chain.request
        level.log(request: request)
        let logger = self
        return chain.proceed(request: request)
            .map { response in
                logger.level.log(response: response)
                return response
            }
            .eraseToAnyPublisher()
        #else
        return chain.proceed(request: chain.request)
        #endif
    }
}
