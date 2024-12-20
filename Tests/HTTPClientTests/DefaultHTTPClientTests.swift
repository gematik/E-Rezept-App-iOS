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
@testable import HTTPClient
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import TestUtils
import XCTest

final class DefaultHTTPClientTests: XCTestCase {
    func testSendRequest() {
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

        DefaultHTTPClient(urlSessionConfiguration: .default)
            .send(request: request)
            .test(expectations: { _, response, _ in
                expect(response.url) == request.url
                expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
            })
        expect(counter) == 1
    }

    func testSendRequestWithInterceptor() {
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

        DefaultHTTPClient(urlSessionConfiguration: .default, interceptors: [PathInterceptor(path: alternatePath)])
            .send(request: request)
            .test(expectations: { _, response, _ in
                expect(response.url?.path) == alternatePath
                expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
            })
        expect(counter) == 1
    }

    func testSendRequestWithLocalRequestInterceptor() {
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

        DefaultHTTPClient(urlSessionConfiguration: .default, interceptors: [PathInterceptor(path: alternatePath)])
            .send(request: request, interceptors: [QueryInterceptor(name: "query", value: "value")])
            .test(expectations: { _, response, _ in
                expect(response.url?.path) == alternatePath
                expect(response.url?.query) == "query=value"
                expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
            })
        expect(counter) == 1
    }

    func testSendRequestAndFollowRedirect() {
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

        DefaultHTTPClient(urlSessionConfiguration: .default)
            .send(request: request)
            .test(expectations: { body, response, _ in
                expect(response.url?.absoluteString) == redirectURL
                expect(response.value(forHTTPHeaderField: "Content-Type")) == "html/text"
                expect(try! url.readFileContents()) == body
            })
        expect(counter) == 2
    }

    func testSendRequestAndHandleRedirect() async {
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

        DefaultHTTPClient(urlSessionConfiguration: .default)
            .send(request: request, interceptors: [], redirect: redirectHandler)
            .test(expectations: { _, response, _ in
                expect(response.statusCode) == 302
                expect(response.value(forHTTPHeaderField: "Location")) == redirectURL
            })
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

    func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
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
        return chain.proceed(request: request)
    }

    func interceptAsync(chain _: Chain) async throws -> HTTPResponse {
        throw HTTPClientError.internalError("notImplemented")
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

    func intercept(chain: Chain) -> AnyPublisher<HTTPResponse, HTTPClientError> {
        var request = chain.request
        var url = request.url
        let components = url?.pathComponents.count ?? 0
        for _ in 1 ..< components {
            url?.deleteLastPathComponent()
        }
        url?.appendPathComponent(path)
        request.url = url
        return chain.proceed(request: request)
    }

    func interceptAsync(chain _: Chain) async throws -> HTTPResponse {
        throw HTTPClientError.internalError("notImplemented")
    }
}
