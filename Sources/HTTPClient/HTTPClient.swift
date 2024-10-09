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

// swiftlint:disable large_tuple

/// Typealias for Output that is emitted by the `DataTaskPublisher`
public typealias HTTPResponse = (data: Data, response: HTTPURLResponse, status: HTTPStatusCode)
/// URLRequest redirect handler as described in URLSessionTaskDelegate
/// - Parameter original: the original response with a redirect status
/// - Parameter redirect: the pre-composed URLRequest that follows the redirect
/// - Parameter completionHandler: the function that takes the newRequest to follow or nil to not follow the redirect
public typealias RedirectHandler = (
    _ original: HTTPURLResponse,
    _ redirect: URLRequest
) async -> URLRequest?

// swiftlint:enable large_tuple

/// Protocol HTTPClient
public protocol HTTPClient {
    /// Send the given request. The request will be processed by the list of `Interceptors`.
    ///
    /// - Parameter request: The request to be (modified and) sent.
    /// - Parameter interceptors: per request interceptors.
    /// - Parameter handler: handler that should be called in case of redirect.
    /// - Returns: `AnyPublisher` that emits a response as `HTTPResponse`
    func send(request: URLRequest, interceptors: [Interceptor], redirect handler: RedirectHandler?)
        -> AnyPublisher<HTTPResponse, HTTPClientError>

    /// List of all active interceptors of the HTTP client.
    var interceptors: [Interceptor] { get }
}

extension HTTPClient {
    /// Send the given request. The request will be processed by the list of `Interceptors`.
    ///
    /// - Parameter request: The request to be (modified and) sent.
    /// - Parameter interceptors: per request interceptors.
    /// - Returns: `AnyPublisher` that emits a response as `HTTPResponse`
    public func send(request: URLRequest, interceptors: [Interceptor]) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        send(request: request, interceptors: interceptors, redirect: nil)
    }

    /// Send the given request.
    ///
    /// - Parameter request: The request to be (modified and) sent.
    /// - Returns: `AnyPublisher` that emits a response as `HTTPResponse`
    public func send(request: URLRequest) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        send(request: request, interceptors: [])
    }
}

// sourcery: CodedError = "530"
/// HTTP Error
public enum HTTPClientError: Swift.Error, Equatable, LocalizedError {
    // sourcery: errorCode = "01"
    /// Internal error in the request/chain handling
    case internalError(String)
    // sourcery: errorCode = "02"
    /// The server responded with an error
    case httpError(URLError)
    // sourcery: errorCode = "03"
    /// The connection to the server has gone bad
    case networkError(String)
    // sourcery: errorCode = "04"
    /// Authentication error
    case authentication(Swift.Error)
    // sourcery: errorCode = "05"
    /// Error emitted by the VAU client
    case vauError(Swift.Error)
    // sourcery: errorCode = "06"
    /// Unclassified error
    case unknown(Swift.Error)

    public static func ==(lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
        switch (lhs, rhs) {
        case let (.internalError(lhsInternal), .internalError(rhsInternal)): return lhsInternal == rhsInternal
        case let (.httpError(lhsError), .httpError(rhsError)): return lhsError.errorCode == rhsError.errorCode
        case let (.networkError(lhsError), .networkError(rhsError)): return lhsError == rhsError
        // We must compair the raw error in this context since the `LocalizedError` description
        // can be part of a extension outside the scope of the HTTPClient package
        case let (.authentication(lhsError), .authentication(rhsError)):
            let lhsNSError = lhsError as NSError
            let rhsNSError = rhsError as NSError
            return lhsNSError.code == rhsNSError.code && lhsNSError.domain == rhsNSError.domain
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
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case instanceManipulationUsed = 226
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
    case preconditionFailure = 412
    case requestEntityTooLarge = 413
    case requestUriTooLong = 414
    case unsupportedMediaType = 415
    case rangeNotSatisfiable = 416
    case expectationFailed = 417
    case imateapot = 418
    case misdirectedRequest = 421
    case unprocessableEntity = 422
    case locked = 423
    case failedDependency = 424
    case tooEarly = 425
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431
    case unavailableForLegalReasons = 451
    // server error
    case serverError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficentStorage = 507
    case loopDetected = 508
    case notExtended = 510
    case networkAuthenticationRequired = 511
    case networkConnectTimeoutError = 599
    case debug = -2
}

/// HTTP Method
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
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
