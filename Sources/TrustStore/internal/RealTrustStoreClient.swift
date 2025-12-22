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

class RealTrustStoreClient {
    private let serverURL: URL
    private let httpClient: HTTPClient

    init(serverURL: URL, httpClient: HTTPClient) {
        self.serverURL = serverURL
        self.httpClient = httpClient
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
    func loadPKICertificatesFromServer(rootSubjectCn: String) async throws -> PKICertificates {
        let httpResponse: HTTPResponse

        do {
            let url = pkiCertEndpoint.appending(
                queryItems: [
                    URLQueryItem(name: "currentRoot", value: rootSubjectCn),
                ]
            )
            let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            httpResponse = try await httpClient.send(request: urlRequest)
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
            httpResponse = try await httpClient.send(request: urlRequest)
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
            httpResponse = try await httpClient.send(request: urlRequest)
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
