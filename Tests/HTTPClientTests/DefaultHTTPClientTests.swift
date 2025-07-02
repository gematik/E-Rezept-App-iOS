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
@testable import HTTPClient
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import TestUtils
import XCTest

final class DefaultHTTPClientTests: XCTestCase {
    func testSendRequest() async throws {
        let host = "some-url.com"
        let path = "/path/to/resource.html"
        guard let url = Bundle.module
            .path(forResource: "file", ofType: "json", inDirectory: "Resources/HTTPClientResponses.bundle") else {
            fail("Bundle could not find URL")
            return
        }

        let baseURL = "http://\(host)\(path)"
        let request = URLRequest(url: URL(string: baseURL)!)

        var counter = 0
        stub(condition: isHost(host) && isPath(path) && isMethodGET() && !hasHeaderNamed("Authorization")) { _ in
            counter += 1
            return fixture(filePath: url, headers: ["Content-Type": "html/text"])
        }

        let (_, response, _) = try await DefaultHTTPClient(urlSessionConfiguration: .default)
            .sendAsync(request: request)
        expect(response.url) == request.url
        expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
        expect(counter) == 1
    }

    func testSendRequestWithInterceptor() async throws {
        let host = "some-url.com"
        let path = "/path/to/resource.html"
        let alternatePath = "/path/to/alternate-resource.html"
        guard let url = Bundle.module
            .path(forResource: "file", ofType: "json", inDirectory: "Resources/HTTPClientResponses.bundle") else {
            fail("Bundle could not find URL")
            return
        }

        let baseURL = "http://\(host)\(path)"
        let request = URLRequest(url: URL(string: baseURL)!)

        var counter = 0
        stub(condition: isHost(host) && isPath(alternatePath) && isMethodGET()) { _ in
            counter += 1
            return fixture(filePath: url, headers: ["Content-Type": "html/text"])
        }

        let (_, response, _) = try await DefaultHTTPClient(
            urlSessionConfiguration: .default,
            interceptors: [PathInterceptor(path: alternatePath)]
        )
        .sendAsync(request: request)
        expect(response.url?.path) == alternatePath
        expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
        expect(counter) == 1
    }

    func testSendRequestWithLocalRequestInterceptor() async throws {
        let host = "some-url.com"
        let path = "/path/to/resource.html"
        let alternatePath = "/path/to/alternate-resource.html"
        guard let url = Bundle.module
            .path(forResource: "file", ofType: "json", inDirectory: "Resources/HTTPClientResponses.bundle") else {
            fail("Bundle could not find URL")
            return
        }

        let baseURL = "http://\(host)\(path)"
        let request = URLRequest(url: URL(string: baseURL)!)

        var counter = 0
        stub(condition: isHost(host) && isPath(alternatePath) && isMethodGET()) { _ in
            counter += 1
            return fixture(filePath: url, headers: ["Content-Type": "html/text"])
        }

        let (_, response, _) = try await DefaultHTTPClient(
            urlSessionConfiguration: .default,
            interceptors: [PathInterceptor(path: alternatePath)]
        )
        .sendAsync(request: request, interceptors: [QueryInterceptor(name: "query", value: "value")])
        expect(response.url?.path) == alternatePath
        expect(response.url?.query) == "query=value"
        expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
        expect(counter) == 1
    }

    func testSendRequestAndFollowRedirect() async throws {
        let host = "some-url.com"
        let path = "/path/to/resource.html"
        guard let url = Bundle.module
            .path(forResource: "file", ofType: "json", inDirectory: "Resources/HTTPClientResponses.bundle") else {
            fail("Bundle could not find URL")
            return
        }

        let baseURL = "http://\(host)\(path)"
        let request = URLRequest(url: URL(string: baseURL)!)
        let redirectURL = "http://redirect.me/path/file.txt"

        var counter = 0
        stub(condition: isHost(host) && isPath(path) && isMethodGET()) { _ in
            counter += 1
            let response = HTTPStubsResponse()
            response.statusCode = 302
            response.httpHeaders = [
                "Cache-Control": "no-store",
                "Pragma": "no-cache",
                "Location": redirectURL,
                "Content-Length": "0",
            ]
            return response
        }
        stub(condition: isAbsoluteURLString(redirectURL)) { _ in
            counter += 1
            return fixture(filePath: url, headers: ["Content-Type": "html/text"])
        }

        let (body, response, _) = try await DefaultHTTPClient(urlSessionConfiguration: .default)
            .sendAsync(request: request)
        expect(response.url?.absoluteString) == redirectURL
        expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
        expect(try! url.readFileContents()) == body
        expect(counter) == 2
    }

    func testSendRequestAndHandleRedirect() async throws {
        let host = "some-url.com"
        let path = "/path/to/resource.html"
        guard let url = Bundle.module
            .path(forResource: "file", ofType: "json", inDirectory: "Resources/HTTPClientResponses.bundle") else {
            fail("Bundle could not find URL")
            return
        }

        let baseURL = "http://\(host)\(path)"
        let request = URLRequest(url: URL(string: baseURL)!)
        let redirectURL = "http://redirect.me/path/file.txt"

        var counter = 0
        stub(condition: isHost(host) && isPath(path) && isMethodGET()) { _ in
            counter += 1
            let response = HTTPStubsResponse()
            response.statusCode = 302
            response.httpHeaders = [
                "Cache-Control": "no-store",
                "Pragma": "no-cache",
                "Location": redirectURL,
                "Content-Length": "0",
            ]
            return response
        }
        stub(condition: isAbsoluteURLString(redirectURL)) { _ in
            counter += 1
            return fixture(filePath: url, headers: ["Content-Type": "html/text"])
        }

        let redirectHandler: RedirectHandler = { _, _ in
            nil
        }

        let (_, response, _) = try await DefaultHTTPClient(urlSessionConfiguration: .default)
            .sendAsync(request: request, interceptors: [], redirect: redirectHandler)
        expect(response.statusCode) == 302
        expect(response.value(forHTTPHeaderField: "Location")) == redirectURL
        expect(counter) == 1
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
}

struct QueryInterceptor: Interceptor {
    let name: String
    let value: String

    func interceptPublisher(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        var request = chain.request
        var components = URLComponents(
            url: request.url!,
            resolvingAgainstBaseURL: false
        )
        let queryItems = [
            URLQueryItem(name: name, value: value.urlPercentEscapedString()),
        ]
        components?.percentEncodedQueryItems = queryItems
        guard let url = components?.url else {
            return Fail(error: HTTPClientError.internalError("Could not assemble url from components"))
                .eraseToAnyPublisher()
        }
        request.url = url
        return chain.proceedPublisher(request: request)
    }

    func interceptAsync(chain: Chain) async throws -> HTTPResponse {
        var request = chain.request
        var components = URLComponents(
            url: request.url!,
            resolvingAgainstBaseURL: false
        )
        let queryItems = [
            URLQueryItem(name: name, value: value.urlPercentEscapedString()),
        ]
        components?.percentEncodedQueryItems = queryItems
        guard let url = components?.url else {
            throw HTTPClientError.internalError("Could not assemble url from components")
        }
        request.url = url
        return try await chain.proceedAsync(request: request)
    }
}

struct PathInterceptor: Interceptor {
    let path: String

    init(path: String) {
        if path.hasPrefix("/") {
            self.path = String(path.dropFirst())
        } else {
            self.path = path
        }
    }

    func interceptPublisher(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        var request = chain.request
        var url = request.url
        let components = url?.pathComponents.count ?? 0
        for _ in 1 ..< components {
            url?.deleteLastPathComponent()
        }
        url?.appendPathComponent(path)
        request.url = url
        return chain.proceedPublisher(request: request)
    }

    func interceptAsync(chain: Chain) async throws -> HTTPResponse {
        var request = chain.request
        var url = request.url
        let components = url?.pathComponents.count ?? 0
        for _ in 1 ..< components {
            url?.deleteLastPathComponent()
        }
        url?.appendPathComponent(path)
        request.url = url
        return try await chain.proceedAsync(request: request)
    }
}
