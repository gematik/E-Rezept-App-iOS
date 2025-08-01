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
import HTTPClient

protocol AVSClient {
    /// Send data to the given endpoint
    /// Note: Only `AVSError`s are supposed to be thrown
    func send(data: Data, to endpoint: AVSEndpoint) async throws -> HTTPResponse
}

class RealAVSClient {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
}

extension RealAVSClient: AVSClient {
    func send(data: Data, to endpoint: AVSEndpoint) async throws -> HTTPResponse {
        var request = URLRequest(url: endpoint.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = "POST"
        request.addValue("application/pkcs7-mime", forHTTPHeaderField: "Content-Type")
        for (key, value) in endpoint.additionalHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = data
        do {
            return try await httpClient.sendAsync(request: request)
        } catch {
            throw error.asAVSError()
        }
    }
}
