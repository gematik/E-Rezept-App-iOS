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
import OSLog

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
                Logger.httpClient
                    .debug(">> [\(request.httpMethod ?? "NO-METHOD")] \(request.url?.absoluteString ?? "NO-URL")")
            }
            if rawValue > 1 {
                Logger.httpClient.debug(">> [Headers]: \(request.allHTTPHeaderFields ?? [:])")
            }
            if rawValue > 2 {
                if let body = request.httpBody {
                    if let bodyString = String(data: body, encoding: .utf8) {
                        Logger.httpClient.debug(">> [BODY]: \(bodyString)")
                    } else {
                        Logger.httpClient.debug(">> [BODY (base64)]: \(body.base64EncodedString())")
                    }
                }
            }
        }

        func log(response object: HTTPResponse) {
            let (data, response, statusCode) = object
            if rawValue > 0 {
                let url = response.url?.absoluteString ?? "NO-URL"
                Logger.httpClient.debug("<< [StatusCode]: \(statusCode.rawValue) \(url)")
            }
            if rawValue > 1 {
                Logger.httpClient.debug("<< [Headers]: \(response.allHeaderFields)")
            }
            if rawValue > 2 {
                if data.isEmpty {
                    Logger.httpClient.debug("<< [BODY]: NO DATA")
                    Logger.httpClient.info("<< [BODY]: NO DATA (info level")
                } else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        Logger.httpClient.debug("<< [BODY]: \(responseString)")
                    } else {
                        Logger.httpClient.debug("<< [BODY (base64)]: \(data.base64EncodedString())")
                    }
                }
            }
        }
    }

    public var level: Level = .none

    public init(log level: Level) {
        self.level = level
    }

    public func interceptPublisher(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        #if DEBUG
        let request = chain.request
        level.log(request: request)
        let logger = self
        return chain.proceedPublisher(request: request)
            .map { response in
                logger.level.log(response: response)
                return response
            }
            .eraseToAnyPublisher()
        #else
        return chain.proceed(request: chain.request)
        #endif
    }

    public func interceptAsync(chain: Chain) async throws -> HTTPResponse {
        #if DEBUG
        let request = chain.request
        level.log(request: request)
        let logger = self
        let response = try await chain.proceedAsync(request: request)
        logger.level.log(response: response)
        return response
        #else
        return try await chain.proceedAsync(request: chain.request)
        #endif
    }
}
