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
import HTTPClient

protocol AVSClient {
    func send(data: Data, to endpoint: AVSEndpoint, transactionId: UUID) -> AnyPublisher<UUID, AVSError>
}

class RealAVSClient {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)) {
        self.httpClient = httpClient
    }
}

extension RealAVSClient: AVSClient {
    func send(data: Data, to endpoint: AVSEndpoint, transactionId: UUID) -> AnyPublisher<UUID, AVSError> {
        var request = URLRequest(url: endpoint.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = "POST"
        request.addValue("application/pkcs7-mime", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        return httpClient
            .send(request: request)
            .tryMap { httpResponse in
                guard httpResponse.status == .ok else {
                    let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
                    throw HTTPError.httpError(urlError)
                }
                return transactionId
            }
            .mapError {
                $0.asAVSError()
            }
            .eraseToAnyPublisher()
    }
}
