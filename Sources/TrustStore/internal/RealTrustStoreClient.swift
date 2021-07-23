//
//  Copyright (c) 2021 gematik GmbH
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

class RealTrustStoreClient {
    private let serverURL: URL
    private let httpClient: HTTPClient

    init(serverURL: URL, httpClient: HTTPClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)) {
        self.serverURL = serverURL
        self.httpClient = httpClient
    }

    var certListEndpoint: URL {
        serverURL.appendingPathComponent("CertList")
    }

    var ocspListEndpoint: URL {
        serverURL.appendingPathComponent("OCSPList")
    }
}

extension RealTrustStoreClient: TrustStoreClient {
    func loadCertListFromServer() -> AnyPublisher<CertList, TrustStoreError> {
        httpClient
                .send(request: URLRequest(url: certListEndpoint, cachePolicy: .reloadIgnoringLocalCacheData))
                .processCertListResponse()
                .eraseToAnyPublisher()
    }

    func loadOCSPListFromServer() -> AnyPublisher<OCSPList, TrustStoreError> {
        httpClient
                .send(request: URLRequest(url: ocspListEndpoint, cachePolicy: .reloadIgnoringLocalCacheData))
                .processOCSPListResponse()
                .eraseToAnyPublisher()
    }
}

extension Publisher where Output == HTTPResponse, Failure == HTTPError {
    func processCertListResponse() -> AnyPublisher<CertList, TrustStoreError> {
        tryMap { httpResponse -> CertList in
            try RealTrustStoreClient.processCertListResponse(httpResponse: httpResponse)
        }
                .mapError { $0.asTrustStoreError() }
                .eraseToAnyPublisher()
    }

    func processOCSPListResponse() -> AnyPublisher<OCSPList, TrustStoreError> {
        tryMap { httpResponse -> OCSPList in
            try RealTrustStoreClient.processOCSPListResponse(httpResponse: httpResponse)
        }
                .mapError { $0.asTrustStoreError() }
                .eraseToAnyPublisher()
    }
}

extension RealTrustStoreClient {
    static func processCertListResponse(httpResponse: HTTPResponse) throws -> CertList {
        guard httpResponse.status == .ok else {
            let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
            throw HTTPError.httpError(urlError)
        }
        return try CertList.from(data: httpResponse.data)
    }

    static func processOCSPListResponse(httpResponse: HTTPResponse) throws -> OCSPList {
        guard httpResponse.status == .ok else {
            let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
            throw HTTPError.httpError(urlError)
        }
        return try OCSPList.from(data: httpResponse.data)
    }
}
