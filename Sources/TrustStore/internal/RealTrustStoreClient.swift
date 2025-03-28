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

class RealTrustStoreClient {
    private let serverURL: URL
    private let httpClient: HTTPClient

    init(serverURL: URL, httpClient: HTTPClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)) {
        self.serverURL = serverURL
        self.httpClient = httpClient
    }

    // swiftlint:disable:next line_length
    // refer to https://github.com/gematik/api-erp/blob/master/docs/authentisieren.adoc#verbindungsaufbau-zum-e-rezept-fachdienst
    var certListEndpoint: URL {
        serverURL.appendingPathComponent("CertList")
    }

    var ocspListEndpoint: URL {
        serverURL.appendingPathComponent("OCSPList")
    }

    var pkiCertEndpoint: URL {
        serverURL.appendingPathComponent("PKICertificates")
    }

    var vauCertEndpoint: URL {
        serverURL.appendingPathComponent("VAUCertificate")
    }

    var ocspResponseEndpoint: URL {
        serverURL.appendingPathComponent("OCSPResponse")
    }
}

extension RealTrustStoreClient: TrustStoreClient {
    func loadCertListFromServer() -> AnyPublisher<CertList, TrustStoreError> {
        httpClient
            .sendPublisher(request: URLRequest(url: certListEndpoint, cachePolicy: .reloadIgnoringLocalCacheData))
            .processCertListResponse()
            .eraseToAnyPublisher()
    }

    func loadOCSPListFromServer() -> AnyPublisher<OCSPList, TrustStoreError> {
        httpClient
            .sendPublisher(request: URLRequest(url: ocspListEndpoint, cachePolicy: .reloadIgnoringLocalCacheData))
            .processOCSPListResponse()
            .eraseToAnyPublisher()
    }

    func loadPKICertificatesFromServer(rootSubjectCn: String) async throws -> PKICertificates {
        let httpResponse: HTTPResponse

        do {
            let url = pkiCertEndpoint.appending(
                queryItems: [
                    URLQueryItem(name: "currentRoot", value: rootSubjectCn),
                ]
            )
            let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            httpResponse = try await httpClient.sendAsync(request: urlRequest)
        } catch let error as HTTPClientError {
            throw TrustStoreError.network(error: error)
        } catch {
            throw error.asTrustStoreError()
        }

        guard httpResponse.status == .ok else {
            let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
            throw HTTPClientError.httpError(urlError).asTrustStoreError()
        }

        // process the response
        let pkiCertificates: PKICertificates
        do {
            pkiCertificates = try PKICertificates.from(data: httpResponse.data)
        } catch {
            throw error.asTrustStoreError()
        }
        return pkiCertificates
    }

    func loadVauCertificateFromServer() async throws -> Data {
        let httpResponse: HTTPResponse
        let urlRequest = URLRequest(url: vauCertEndpoint, cachePolicy: .reloadIgnoringLocalCacheData)

        do {
            httpResponse = try await httpClient.sendAsync(request: urlRequest)
        } catch let error as HTTPClientError {
            throw TrustStoreError.network(error: error)
        } catch {
            throw error.asTrustStoreError()
        }

        guard httpResponse.status == .ok else {
            let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
            throw HTTPClientError.httpError(urlError).asTrustStoreError()
        }
        return httpResponse.data
    }

    func loadOcspResponseFromServer(issuerCn: String, serialNr: String) async throws -> Data {
        let httpResponse: HTTPResponse

        do {
            let url = ocspResponseEndpoint.appending(
                queryItems: [
                    URLQueryItem(name: "issuer-cn", value: issuerCn),
                    URLQueryItem(name: "serial-nr", value: serialNr),
                ]
            )
            let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            httpResponse = try await httpClient.sendAsync(request: urlRequest)
        } catch let error as HTTPClientError {
            throw TrustStoreError.network(error: error)
        } catch {
            throw error.asTrustStoreError()
        }

        guard httpResponse.status == .ok else {
            let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
            throw HTTPClientError.httpError(urlError).asTrustStoreError()
        }
        return httpResponse.data
    }
}

extension Publisher where Output == HTTPResponse, Failure == HTTPClientError {
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
            throw HTTPClientError.httpError(urlError)
        }
        return try CertList.from(data: httpResponse.data)
    }

    static func processOCSPListResponse(httpResponse: HTTPResponse) throws -> OCSPList {
        guard httpResponse.status == .ok else {
            let urlError = URLError(URLError.Code(rawValue: httpResponse.status.rawValue))
            throw HTTPClientError.httpError(urlError)
        }
        return try OCSPList.from(data: httpResponse.data)
    }
}
