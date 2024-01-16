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

#if ENABLE_DEBUG_VIEW
extension UserDefaults {
    private static let kIsLoggingEnabledKey = "kIsLoggingEnabled"
    private static let kIsVirtualEGKEnabledKey = "kIsVirtualEGKEnabled"
    private static let kVirtualEGKPrkCHAUTKey = "kVirtualEGKPrkCHAUT"
    private static let kVirtualEGKCCHAUTKey = "kVirtualEGKCCHAUT"

    @objc var isLoggingEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.kIsLoggingEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.kIsLoggingEnabledKey)
        }
    }

    @objc var isVirtualEGKEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.kIsVirtualEGKEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.kIsVirtualEGKEnabledKey)
        }
    }

    @objc var virtualEGKPrkCHAut: String? {
        get {
            UserDefaults.standard.string(forKey: Self.kVirtualEGKPrkCHAUTKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.kVirtualEGKPrkCHAUTKey)
        }
    }

    @objc var virtualEGKCCHAut: String? {
        get {
            UserDefaults.standard.string(forKey: Self.kVirtualEGKCCHAUTKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.kVirtualEGKCCHAUTKey)
        }
    }
}
#endif

class DebugLiveLogger {
    #if ENABLE_DEBUG_VIEW
    static var shared = DebugLiveLogger()

    var requests: [RequestLog] = []

    var isLoggingEnabled: Bool {
        get {
            UserDefaults.standard.isLoggingEnabled
        }
        set {
            UserDefaults.standard.isLoggingEnabled = newValue
        }
    }

    private init() {}

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
        func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
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
                                  DebugLiveLogger.shared.log(
                                      request: request,
                                      sentAt: sentAt,
                                      response: nil,
                                      receivedAt: Date()
                                  )
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
            guard let body = request.httpBody else { return "no request body" }
            if let utf8String = body.utf8string {
                return utf8String
            }
            return body.base64EncodedString()
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

extension DebugLiveLogger {
    struct HARFile: Codable {
        let log: Log

        struct Log: Codable {
            var version = "1.2"
            var creator: Creator
            var browser: Creator
            var pages: [Page]? // swiftlint:disable:this discouraged_optional_collection
            var entries: [Entry]
            var comment: String?
        }

        struct Creator: Codable {
            var name: String
            var version: String
            var comment: String?
        }

        struct Page: Codable {
            var startedDateTime: Date // "2009-04-16T12:07:25.123+01:00",
            var id: String
            var title: String
            var pageTimings: Timing
            var comment: String?

            struct Timing: Codable {
                var onContentLoad: Int? // 1720,
                var onLoad: Int? // 2500,
                var comment: String?
            }
        }

        struct Entry: Codable {
            var pageref: String? // "page_0"
            var startedDateTime: Date // "2009-04-16T12:07:23.596Z",
            var time: Int // 50,
            var request: Request
            var response: Response
            var cache: Cache
            var timings: Timing
            var serverIPAddress: String? // "10.0.0.1",
            var connection: String? // "52492",
            var comment: String?
        }

        struct Request: Codable {
            var method: String
            var url: String
            var httpVersion: String // "HTTP/1.1",
            var cookies: [Cookie]
            var headers: [Header]
            var queryString: [QueryString]
            var postData: PostData?
            var headersSize: Int
            var bodySize: Int
            var comment: String?
        }

        struct Response: Codable {
            var status: Int // 200,
            var statusText: String // "OK",
            var httpVersion: String // "HTTP/1.1",
            var cookies: [Cookie]
            var headers: [Header]
            var content: Content
            var redirectURL: String
            var headersSize: Int
            var bodySize: Int
            var comment: String?
        }

        struct Cache: Codable {}

        struct Timing: Codable {
            var blocked: Int // 0,
            var dns: Int // -1,
            var connect: Int // 15,
            var send: Int // 20,
            var wait: Int // 38,
            var receive: Int // 12,
            var ssl: Int // -1,
            var comment: String? // ""
        }

        struct PostData: Codable {
            var mimeType: String // "multipart/form-data",
            var params: [Param]
            var text: String
            var comment: String?
        }

        struct Param: Codable {
            var name: String // "paramName",
            var value: String // "paramValue",
            var fileName: String // "example.pdf",
            var contentType: String // "application/pdf",
            var comment: String?
        }

        struct Cookie: Codable {
            var name: String // "TestCookie",
            var value: String // "Cookie Value",
            var path: String // "/",
            var domain: String? // "www.janodvarko.cz",
            var expires: Date? // "2009-07-24T19:20:30.123+02:00",
            var httpOnly: Bool? // false,
            var secure: Bool? // false,
            var comment: String? // ""
        }

        struct Header: Codable {
            var name: String
            var value: String
            var comment: String?
        }

        struct QueryString: Codable {
            var name: String
            var value: String
            var comment: String?
        }

        struct Content: Codable {
            var size: Int // 33,
            var compression: Int // 0,
            var mimeType: String // "text/html; charset=utf-8",
            var text: String // "\n",
            var comment: String?
        }
    }
}

extension DebugLiveLogger.RequestLog {
    func toHARRequest() -> DebugLiveLogger.HARFile.Request {
        let headers = requestHeader.map { (key: String, value: String) in
            DebugLiveLogger.HARFile.Header(name: key, value: value)
        }

        let postData: DebugLiveLogger.HARFile.PostData =
            .init(mimeType: "text", params: [], text: requestBody)

        return .init(
            method: request.httpMethod ?? "GET",
            url: requestUrl,
            httpVersion: "unknown",
            cookies: [],
            headers: headers,
            queryString: [],
            postData: postData,
            headersSize: -1,
            bodySize: -1
        )
    }

    func toHARResponse() -> DebugLiveLogger.HARFile.Response {
        let headers = (responseHeader as? [String: String])?.map { (key: String, value: String) in
            DebugLiveLogger.HARFile.Header(name: key, value: value)
        } ?? []

        let body = responseBody

        return .init(
            status: responseStatus?.rawValue ?? -1,
            statusText: responseStatus.debugDescription,
            httpVersion: "unknown",
            cookies: [],
            headers: headers,
            content: .init(size: -1, compression: -1, mimeType: response?.response.mimeType ?? "unknown", text: body),
            redirectURL: "",
            headersSize: -1,
            bodySize: -1
        )
    }
}

extension DebugLiveLogger {
    func asHARFile() -> HARFile {
        let entries = requests.map { request in
            let harRequest = request.toHARRequest()
            let harResponse = request.toHARResponse()

            return HARFile.Entry(
                startedDateTime: request.sentAt,
                time: Int(request.receivedAt.timeIntervalSince(request.sentAt) * 1000),
                request: harRequest,
                response: harResponse,
                cache: .init(),
                timings: .init(blocked: -1, dns: -1, connect: -1, send: -1, wait: -1, receive: -1, ssl: -1)
            )
        }
        return HARFile(
            log: .init(
                creator: .init(name: "E-Rezept-App iOS", version: AppVersion.current.productVersion),
                browser: .init(name: "Debug Log", version: AppVersion.current.productVersion),
                entries: entries
            )
        )
    }

    func serializedHARFile() -> String {
        let harFile = asHARFile()

        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        encoder.dateEncodingStrategy = .formatted(formatter)

        let data = (try? encoder.encode(harFile)) ?? Data()

        return String(data: data, encoding: .utf8) ?? "encoding failed"
    }
}
#endif
