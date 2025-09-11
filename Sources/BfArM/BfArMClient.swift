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

import Dependencies
import DependenciesMacros
import eRpKit
import Foundation

/// BfArM Client interacts with the authorization endpoints of the service
@DependencyClient
public struct BfArMClient {
    /// fetches information of the provided pzn
    public var bfarmInfo: @Sendable (String, Configuration) async throws -> BfArMDiGaDetails?
    /// fetches the images from the url provided by bfarmInfo function
    public var fetchCachedImage: @Sendable (String, Configuration) async throws -> Data?
}

extension DependencyValues {
    /// BfArM Client
    public var bfarmClient: BfArMClient {
        get { self[BfArMClient.self] }
        set { self[BfArMClient.self] = newValue }
    }
}

extension BfArMClient: TestDependencyKey {
    public static let testValue: BfArMClient = Self()
}

extension BfArMClient {
    /// BfArMClient Configuration
    public struct Configuration {
        /// eRezept API URL
        public let eRezeptAPIServer: URL
        /// eRezept API headers
        public let eRezeptAdditionalHeader: [String: String]

        /// Initialize BfArMClient Configuration
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
