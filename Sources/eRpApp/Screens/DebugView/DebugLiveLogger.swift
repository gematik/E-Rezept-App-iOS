//
//  Copyright (c) 2021 gematik GmbH
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

#if ENABLE_DEBUG_VIEW
extension UserDefaults {
    private static let kIsLoggingEnabledKey = "kIsLoggingEnabled"

    @objc var isLoggingEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.kIsLoggingEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.kIsLoggingEnabledKey)
        }
    }
}
#endif

class DebugLiveLogger {
    #if ENABLE_DEBUG_VIEW
    static var shared = DebugLiveLogger()

    var requests: [RequestLog] = []

    var isLoggingEnabled: Bool {
        didSet {
            UserDefaults.standard.isLoggingEnabled = isLoggingEnabled
        }
    }

    private init() {
        isLoggingEnabled = UserDefaults.standard.isLoggingEnabled
    }

    func log(request: URLRequest, sentAt: Date, response: HTTPResponse?, receivedAt: Date) {
        guard isLoggingEnabled else { return }

        let log = RequestLog(request: request, sentAt: sentAt, response: response, receivedAt: receivedAt)
        if response != nil {
            // Remove previous requests marked as cancelled (`.first()` marks all request streams as cancelled)
            requests = requests.filter { item in
                item.request != request &&
                    item.sentAt != sentAt
            }
        } else {
            // If a Request already exists with same information, but with a `response`, just keep it and throw the new
            // one away
            guard requests.first(where: { item in
                item.request == request && item.sentAt == sentAt
            }) == nil else {
                return
            }
        }
        requests.append(log)
    }

    #endif

    class LogInterceptor: Interceptor {
        func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPError> {
            #if ENABLE_DEBUG_VIEW
            let request = chain.request
            let sentAt = Date()

            return chain.proceed(request: request)
                .handleEvents(receiveOutput: { data, response, status in
                    DebugLiveLogger.shared.log(
                        request: request,
                        sentAt: sentAt,
                        response: (data, response, status),
                        receivedAt: Date()
                    )
                },
                              receiveCancel: {
                    DebugLiveLogger.shared.log(request: request, sentAt: sentAt, response: nil, receivedAt: Date())
                })
                .eraseToAnyPublisher()
            #else
            return chain.proceed(request: chain.request)
            #endif
        }
    }
}

#if ENABLE_DEBUG_VIEW
extension DebugLiveLogger {
    struct RequestLog: Identifiable, Equatable {
        // swiftlint:disable:next identifier_name
        var id: UUID

        let request: URLRequest
        let response: HTTPResponse?

        let sentAt: Date
        let receivedAt: Date

        var requestHeader: [String: String] {
            request.allHTTPHeaderFields ?? [:]
        }

        var requestUrl: String {
            request.url?.absoluteString ?? "missing url"
        }

        var requestType: String {
            request.httpMethod ?? "no http method specified"
        }

        var requestBody: String {
            request.httpBody?.utf8string ?? "no request body"
        }

        var responseStatus: HTTPStatusCode? {
            response?.status
        }

        var responseError: Error? {
            nil
        }

        var responseBody: String {
            response?.data.utf8string ?? "no response body"
        }

        var responseHeader: [AnyHashable: Any] {
            response?.response.allHeaderFields ?? [:]
        }

        init(request: URLRequest, sentAt: Date, response: HTTPResponse?, receivedAt: Date) {
            id = UUID()
            self.request = request
            self.sentAt = sentAt
            self.response = response
            self.receivedAt = receivedAt
        }

        static func ==(lhs: DebugLiveLogger.RequestLog, rhs: DebugLiveLogger.RequestLog) -> Bool {
            lhs.id == rhs.id
        }

        var shareText: String {
            var share = "# REQUEST:\n\n"

            share += "\(request.httpMethod ?? "NO_HTTP_METHOD") \(request.url?.relativePath ?? "no url found")"
            if let query = request.url?.query {
                share += "?\(query)"
            }
            share += "\n"
            share += "Host: \(request.url?.host ?? "NO_DOMAIN")\n"
            if let fields = request.allHTTPHeaderFields {
                share += fields.map { key, value in
                    "\(key): \(value)\n"
                }
                .reduce("", +)
            }
            if let body = request.httpBody {
                if let utf8body = body.utf8string {
                    share += "\n\(utf8body)\n"
                }
            }

            share += "\n# RESPONSE:\n\n"

            if let response = response {
                share += "STATUS: \(response.status.rawValue)\n"

                let fields = response.response.allHeaderFields
                share += fields.map { key, value in
                    "\(key): \(value)\n"
                }
                .reduce("", +)

                if let utf8body = response.data.utf8string {
                    share += "\n\(utf8body)\n"
                }
            }

            return share
        }
    }
}
#endif
