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

import Foundation
import HTTPClient
import Nimble
@testable import VAUClient
import XCTest

final class URLRequestExtSerializeTests: XCTestCase {
    func testURLRequestRawStringEncodedPost() throws {
        // given
        let url = URL(string: "http://some-service.com")!
        var sut = URLRequest(url: url)
        sut.httpMethod = "POST"
        sut.addValue("application/fhir+json", forHTTPHeaderField: "Accept")
        let body = "body".data(using: .utf8)!
        sut.httpBody = body

        // when
        let rawString = try sut.encodeToRawString()

        // then
        expect(rawString) ==
            "POST / HTTP/1.1\r\nHost: some-service.com\r\nAccept: application/fhir+json\r\n\r\nbody"
    }

    func testURLRequestRawStringEncodedGet() throws {
        // given
        let url = URL(string: "http://some-service.com/path")!
        var sut = URLRequest(url: url)
        sut.httpMethod = "GET"
        sut.addValue("value1", forHTTPHeaderField: "header1")

        // when
        let rawString = try sut.encodeToRawString()

        // then
        expect(rawString) == "GET /path HTTP/1.1\r\nHost: some-service.com\r\nheader1: value1\r\n\r\n"
    }

    func testURLRequestRawStringEncodedGetWithParameters() throws {
        // given
        let url = URL(string: "http://some-service.com/path?firstPara=firstValue&secondPara=secondValue")!
        var sut = URLRequest(url: url)
        sut.httpMethod = "GET"
        sut.addValue("value1", forHTTPHeaderField: "header1")

        // when
        let rawString = try sut.encodeToRawString()

        // then
        expect(rawString) == // swiftlint:disable:next line_length
            "GET /path?firstPara=firstValue&secondPara=secondValue HTTP/1.1\r\nHost: some-service.com\r\nheader1: value1\r\n\r\n"
    }

    func testDecodeFhirServerAnswerHtmlStringToHttpResponse() throws {
        // given
        let url = URL(string: "http://some-service.com")!
        let sut = // swiftlint:disable:next line_length
            "HTTP/1.1 200 OK\r\nDate: Fri, 13 Jan 2006 15:12:48 GMT\r\nContent-Type: application/json\r\n\r\n{\n  \"resourceType\": \"Bundle\"\n}"

        // when
        let httpResponse = try sut.decodeToHTTPResponse(url: url)

        // then
        expect(httpResponse.data.isEmpty).to(beFalse())
        expect(httpResponse.data.utf8string).to(contain("Bundle"))
        expect(httpResponse.response.statusCode) == 200
        expect(httpResponse.status) == .ok
    }

    func testDecodeGetAnswerHtmlStringToHttpResponse() throws {
        // given
        let url = URL(string: "http://some-service.com")!
        let sut = // swiftlint:disable:next line_length
            "HTTP/1.0 302 Found\r\nDate: Fri, 13 Jan 2006 15:12:44 GMT\r\nLocation: http://de.wikipedia.org/wiki/Katzen\r\n\r\n"

        // when
        let httpResponse = try sut.decodeToHTTPResponse(url: url)

        // then
        expect(httpResponse.data.isEmpty).to(beTrue())
        expect(httpResponse.response.statusCode) == 302
        expect(httpResponse.response.allHeaderFields["Date"] as? String) == "Fri, 13 Jan 2006 15:12:44 GMT"
        expect(httpResponse.response.allHeaderFields["Location"] as? String) == "http://de.wikipedia.org/wiki/Katzen"
        expect(httpResponse.status) == .found
    }

    func testDecodePostAnswerHtmlStringToHttpResponse() throws {
        // given
        let url = URL(string: "http://some-service.com")!
        let sut = // swiftlint:disable:next line_length
            "HTTP/1.1 200 OK\r\nDate: Fri, 13 Jan 2006 15:12:48 GMT\r\nLast-Modified: Tue, 10 Jan 2006 11:18:20 GMT\r\nContent-Language: de\r\nContent-Type: text/html; charset=utf-8\r\n\r\nDie Katzen (Felidae) sind eine Familie aus der Ordnung der Raubtiere (Carnivora)\r\ninnerhalb der Überfamilie der Katzenartigen (Feloidea).\r\n\r\nWeiteres ..."

        // when
        let httpResponse = try sut.decodeToHTTPResponse(url: url)

        // then
        expect(httpResponse.data.isEmpty).to(beFalse())
        expect(httpResponse.data.utf8string?.starts(with: "Die Katzen")).to(beTrue())
        expect(httpResponse.response.statusCode) == 200
        expect(httpResponse.response.allHeaderFields["Date"] as? String) == "Fri, 13 Jan 2006 15:12:48 GMT"
        expect(httpResponse.response.allHeaderFields["Content-Language"] as? String) == "de"
        expect(httpResponse.status) == .ok
    }

    func testDecodeFhirServiceResponseStringToHTTPResponse() throws {
        // given
        let url = URL(string: "http://some-service.com")!
        let sut = // swiftlint:disable:next line_length
            "HTTP/1.1 200 OK\r\ncontent-length: 54\r\nconnection: close\r\ncontent-type: application/fhir+json\r\ndate: Tue, 09 Feb 2021 14:19:16 GMT\r\n\r\n{\"resourceType\":\"Bundle\",\"type\":\"searchset\",\"total\":0}"

        // when
        let httpResponse = try sut.decodeToHTTPResponse(url: url)

        // then
        expect(httpResponse.data.isEmpty).to(beFalse())
        expect(httpResponse.data.utf8string).to(contain(["resourceType", "Bundle", "type", "searchset", "total", "0"]))
        expect(httpResponse.response.statusCode) == 200
        expect(httpResponse.status) == .ok
    }
}
