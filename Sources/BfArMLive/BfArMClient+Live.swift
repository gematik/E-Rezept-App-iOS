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

import BfArM
import Dependencies
import DependenciesMacros
import eRpKit
import Foundation
import HTTPClient
import HTTPClientLive

extension BfArMClient: DependencyKey {
    public static let liveValue = Self(
        bfarmInfo: { pzn, configuration in
            let httpClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
            let decoder = JSONDecoder()

            let url = configuration.eRezeptAPIServer.appendingPathComponent("diga/pzn/\(pzn)")
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            for (key, value) in configuration.eRezeptAdditionalHeader {
                request.addValue(value, forHTTPHeaderField: key)
            }

            do {
                let result = try await httpClient.send(request: request)
                return try decoder.decode(BfArMDiGaDetails.self, from: result.data)
            } catch let error as HTTPClientError {
                throw BfArMError.network(error: error)
            } catch let error as DecodingError {
                throw BfArMError.decoding(error: error)
            } catch {
                throw BfArMError.unspecified(error: error)
            }
        },
        fetchCachedImage: { url, configuration in
            let httpClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral)
            let decoder = JSONDecoder()

            guard let url = URL(string: url) else { throw BfArMError.invalidAssetLink }
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            for (key, value) in configuration.eRezeptAdditionalHeader {
                request.addValue(value, forHTTPHeaderField: key)
            }

            do {
                return try await httpClient.send(request: request).data
            } catch let error as HTTPClientError {
                throw BfArMError.network(error: error)
            } catch let error as DecodingError {
                throw BfArMError.decoding(error: error)
            } catch {
                throw BfArMError.unspecified(error: error)
            }
        }
    )
}
