//
//  Copyright (c) 2022 gematik GmbH
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

/// Typealias for Output that is emitted by the `DataTaskPublisher`
public typealias HTTPResponse = (data: Data, response: HTTPURLResponse, status: HTTPStatusCode)
/// URLRequest redirect handler as described in URLSessionTaskDelegate
/// - Parameter original: the original response with a redirect status
/// - Parameter redirect: the pre-composed URLRequest that follows the redirect
/// - Parameter completionHandler: the function that takes the newRequest to follow or nil to not follow the redirect
public typealias RedirectHandler = (
    _ original: HTTPURLResponse,
    _ redirect: URLRequest,
    _ completionHandler: (URLRequest?) -> Void
) -> Void

/// Protocol HTTPClient
public protocol HTTPClient {
    /// Send the given request. The request will be processed by the list of `Interceptors`.
    ///
    /// - Parameter request: The request to be (modified and) sent.
    /// - Parameter interceptors: per request interceptors.
    /// - Parameter handler: handler that should be called in case of redirect.
    /// - Returns: `AnyPublisher` that emits a response as `HTTPResponse`
    func send(request: URLRequest, interceptors: [Interceptor], redirect handler: RedirectHandler?)
        -> AnyPublisher<HTTPResponse, HTTPError>

    /// List of all active interceptors of the HTTP client.
    var interceptors: [Interceptor] { get }
}

extension HTTPClient {
    /// Send the given request. The request will be processed by the list of `Interceptors`.
    ///
    /// - Parameter request: The request to be (modified and) sent.
    /// - Parameter interceptors: per request interceptors.
    /// - Returns: `AnyPublisher` that emits a response as `HTTPResponse`
    public func send(request: URLRequest, interceptors: [Interceptor]) -> AnyPublisher<HTTPResponse, HTTPError> {
        send(request: request, interceptors: interceptors, redirect: nil)
    }

    /// Send the given request.
    ///
    /// - Parameter request: The request to be (modified and) sent.
    /// - Returns: `AnyPublisher` that emits a response as `HTTPResponse`
    public func send(request: URLRequest) -> AnyPublisher<HTTPResponse, HTTPError> {
        send(request: request, interceptors: [])
    }
}

/// HTTP Error
public enum HTTPError: Swift.Error, Equatable, LocalizedError {
    /// Internal error in the request/chain handling
    case internalError(String)
    /// The server responded with an error
    case httpError(URLError)
    /// The connection to the server has gone bad
    case networkError(String)
    /// Authentication error
    case authentication(Swift.Error)
    /// Error emitted by the VAU client
    case vauError(Swift.Error)
    /// Unclassified error
    case unknown(Swift.Error)

    public static func ==(lhs: HTTPError, rhs: HTTPError) -> Bool {
        switch (lhs, rhs) {
        case let (.internalError(lhsInternal), .internalError(rhsInternal)): return lhsInternal == rhsInternal
        case let (.httpError(lhsError), .httpError(rhsError)): return lhsError.errorCode == rhsError.errorCode
        case let (.networkError(lhsError), .networkError(rhsError)): return lhsError == rhsError
        case let (.authentication(lhsError), .authentication(rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.vauError(lhsError), .vauError(rhsError)): return lhsError.localizedDescription == rhsError
            .localizedDescription
        case let (.unknown(lhsError), .unknown(rhsError)): return lhsError.localizedDescription == rhsError
            .localizedDescription
        default: return false
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .internalError(string): return string
        case let .httpError(urlError): return urlError.localizedDescription
        case let .networkError(errorString): return errorString
        case let .authentication(error): return error.localizedDescription
        case let .vauError(error): return error.localizedDescription
        case let .unknown(error): return error.localizedDescription
        }
    }
}

/// HTTP Status codes
public enum HTTPStatusCode: Int {
    // success
    case ok = 200 // swiftlint:disable:this identifier_name
    case created = 201
    case accepted = 202
    case noContent = 204
    case partialContent = 206
    // Redirect
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case unused = 306
    case temporaryRedirect = 307
    case permanentRedirect = 308
    // client error
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case requestEntityTooLarge = 413
    case requestUriTooLong = 414
    case requestHeaderFieldsTooLarge = 431
    case unsupportedMediaType = 415
    case expectationFailed = 417
    case imateapot = 418
    case tooManyRequests = 429
    // server error
    case serverError = 500
    case notImplemented = 501
}

/// HTTP Method
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

extension HTTPStatusCode {
    /// Response status code is in the range of 200..<300
    public var isSuccessful: Bool {
        200 ..< 300 ~= rawValue
    }

    /// Response status code that indicates an empty body
    public var isNoContent: Bool {
        rawValue == 204
    }

    /// Response status code is in the range of 300..<400
    public var isRedirect: Bool {
        300 ..< 400 ~= rawValue
    }
}
