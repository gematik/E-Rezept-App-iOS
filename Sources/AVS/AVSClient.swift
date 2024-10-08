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

protocol AVSClient {
    func send(data: Data, to endpoint: AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError>
}

class RealAVSClient {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)) {
        self.httpClient = httpClient
    }
}

extension RealAVSClient: AVSClient {
    func send(data: Data, to endpoint: AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError> {
        var request = URLRequest(url: endpoint.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = "POST"
        request.addValue("application/pkcs7-mime", forHTTPHeaderField: "Content-Type")
        for (key, value) in endpoint.additionalHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = data
        return httpClient
            .send(request: request)
            .mapError {
                $0.asAVSError()
            }
            .eraseToAnyPublisher()
    }
}
