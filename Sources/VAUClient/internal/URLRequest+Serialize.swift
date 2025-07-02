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

import Foundation
import HTTPClient

extension URLRequest {
    /// Serialize the request into a String that can be interpreted by the VAU server
    /// - Note: A HTTP body is only included into the string representation when it is UTF-8 encoded.
    /// [REQ:gemSpec_Krypt:A_20161-01#11] 1:
    func encodeToRawString() throws -> String {
        var string = ""
        guard let method = httpMethod,
              let url = url,
              let host = url.host
        else {
            throw VAUError.internalError("Could not encode URLRequest to raw string")
        }

        let pathWithQuery: String
        if !url.path.isEmpty {
            if let query = url.query {
                pathWithQuery = "\(url.path)?\(query)"
            } else {
                pathWithQuery = url.path
            }
        } else {
            pathWithQuery = "/"
        }

        string += "\(method) \(pathWithQuery) HTTP/1.1\r\n"
        string += "Host: \(host)\r\n"
        if let headers = allHTTPHeaderFields {
            string += headers.map { key, value -> String in "\(key): \(value)" }.joined(separator: "\r\n") + "\r\n"
        }
        string += "\r\n"
        if let body = httpBody,
           let utf8 = String(data: body, encoding: .utf8) {
            string += utf8
        }

        return string
    }
}

extension String {
    /// Decode a raw string encoded HTTPResponse into a HTTPResponse instance
    func decodeToHTTPResponse(url: URL) throws -> HTTPResponse {
        // Expect and divide the HTTPString at "\r\n\r\n" as specified in RFC 1945
        guard let divider = range(of: "\r\n\r\n") else {
            throw VAUError.responseValidation
        }
        let head = self[..<divider.lowerBound]
        let body = self[divider.upperBound...]

        // Process first line + (optional) header fields
        let headComponents = head.components(separatedBy: "\r\n")
        guard let firstLineSplit = headComponents.first?.split(separator: " ", maxSplits: 2),
              let httpVersionSubstring = firstLineSplit.first,
              let statusCodeString = firstLineSplit.dropFirst().first,
              let statusCode = Int(statusCodeString) else {
            throw VAUError.responseValidation
        }
        let httpVersion = String(httpVersionSubstring)

        var headerFields = [String: String]()
        var headerLineComponents = [String]()
        try headComponents.dropFirst().forEach { headerLine in
            // Expect "key: value"
            headerLineComponents = headerLine.components(separatedBy: ": ")
            guard headerLineComponents.count == 2 else {
                throw VAUError.responseValidation
            }
            headerFields.updateValue(headerLineComponents[1], forKey: headerLineComponents[0])
        }

        guard let httpURLResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
        ) else {
            throw VAUError.internalError("Could not create HTTPURLResponse")
        }

        // Process body - set only, if content-type is "text-ish"
        var data = Data()
        let acceptContentTypes = [
            "text/html",
            "application/json",
            "application/xml",
            "application/fhir+json",
            "application/fhir+xml",
        ]
        if let contentType = httpURLResponse.value(forHTTPHeaderField: "Content-Type") {
            guard acceptContentTypes.contains(where: { contentType.contains($0) }),
                  let bodyData = body.data(using: .utf8) else {
                throw VAUError.responseValidation
            }
            data = bodyData
        }

        guard let status = HTTPStatusCode(rawValue: statusCode) else {
            throw HTTPClientError.internalError("Unknown status code")
        }

        return HTTPResponse(data: data, response: httpURLResponse, status: status)
    }
}
