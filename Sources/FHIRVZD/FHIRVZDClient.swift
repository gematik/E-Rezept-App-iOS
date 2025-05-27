//
//  Copyright (c) 2025 gematik GmbH
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

import Dependencies
import DependenciesMacros
import Foundation
import HTTPClient

/// FHIR VZD Client interacts with the authorization endpoints of the service
@DependencyClient
public struct FHIRVZDClient {
    /// Refreshes the access token for the FHIR VZD service
    var refresh: @Sendable (Configuration) async throws -> FHIRVZDToken
}

extension DependencyValues {
    var fhirVZDClient: FHIRVZDClient {
        get { self[FHIRVZDClient.self] }
        set { self[FHIRVZDClient.self] = newValue }
    }
}

extension FHIRVZDClient: TestDependencyKey {
    public static let testValue: FHIRVZDClient = Self()
}

extension FHIRVZDClient: DependencyKey {
    // swiftlint:disable:next trailing_closure
    public static let liveValue = Self(
        refresh: { configuration in
            let httpClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
            let decoder = JSONDecoder()

            let url = configuration.eRezeptAPIServer.appendingPathComponent("vzd/token")
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            for (key, value) in configuration.eRezeptAdditionalHeader {
                request.addValue(value, forHTTPHeaderField: key)
            }

            do {
                let result = try await httpClient.sendAsync(request: request)
                if result.status.isSuccessful {
                    let token = try decoder.decode(FHIRVZDToken.self, from: result.data)
                    return token
                } else {
                    throw FHIRVZDError.tokenUnavailable
                }
            } catch let error as HTTPClientError {
                throw FHIRVZDError.network(error: error)
            } catch let error as DecodingError {
                throw FHIRVZDError.decoding(error: error)
            } catch {
                throw FHIRVZDError.unspecified(error: error)
            }
        }
    )
}

extension FHIRVZDClient {
    /// FHIR VZD Configuration
    public struct Configuration {
        /// eRezept API URL
        let eRezeptAPIServer: URL
        /// eRezept API headers
        let eRezeptAdditionalHeader: [String: String]

        /// Initialize FHIR VZD Configuration
        ///
        /// - Parameters:
        ///   - eRezeptAPIServer: `URL` where the request will be sent to
        ///   - eRezeptAdditionalHeader: `HTTPHeaderField` that will be used for each request
        public init(
            eRezeptAPIServer: URL,
            eRezeptAdditionalHeader: [String: String]
        ) {
            self.eRezeptAPIServer = eRezeptAPIServer
            self.eRezeptAdditionalHeader = eRezeptAdditionalHeader
        }
    }
}
