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

import ComposableArchitecture
import eRpKit
import Foundation
import HTTPClient

/// BfArMSession acts as an interactor/mediator for the BfArMClient
public protocol BfArMSession {
    /// fetches BfArMDiGaDetails based on provided pzn
    ///
    /// - Returns: BfArMDiGaDetails or Error
    func fetchBfArMInfo(pzn: String) async throws -> BfArMDiGaDetails?
    /// fetches Date(asset) based on provided url
    ///
    /// - Returns: Data or Error
    func fetchCachedImage(url: String) async throws -> Data?
}

public class DefaultBfArMSession: BfArMSession {
    private let config: BfArMClient.Configuration
    @Dependency(\.bfarmClient) var client

    public init(config: BfArMClient.Configuration) {
        self.config = config
    }

    public func fetchBfArMInfo(pzn: String) async throws -> BfArMDiGaDetails? {
        try await client.bfarmInfo(pzn, config)
    }

    public func fetchCachedImage(url: String) async throws -> Data? {
        try await client.fetchCachedImage(url, config)
    }
}
