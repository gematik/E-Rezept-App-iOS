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
import Foundation
import HTTPClient
import Sharing

/// FHIRVZDSession acts as an interactor/mediator for the FHIRVZDClient and FHIRVZDStorage
public protocol FHIRVZDSession {
    /// FHIR VZD token
    ///
    /// - Returns: renewed token or error
    func autoRefreshedToken() async throws -> FHIRVZDToken
}

public class DefaultFHIRVZDSession: FHIRVZDSession {
    private let config: FHIRVZDClient.Configuration

    public init(config: FHIRVZDClient.Configuration) {
        self.config = config
    }

    public func autoRefreshedToken() async throws -> FHIRVZDToken {
        @Dependency(\.fhirVZDClient) var client
        @Dependency(\.date.now) var now
        @Shared(.fhirVZDToken) var token
        // Return stored token if still valid (more than 15 min)
        if let token, token.expires >= now.addingTimeInterval(-60 * 15) {
            return token
        }
        // Otherwise refresh and store new token
        let newToken = try await client.refresh(config)
        await $token.withLock { $0 = newToken }
        return newToken
    }
}

extension SharedReaderKey
    where Self == InMemoryKey<FHIRVZDToken?>.Default {
    /// The access token to interact with the FHIR VZD service stored in memory
    public static var fhirVZDToken: Self {
        Self[.inMemory("fhir_vzd_access_token"), default: nil]
    }
}
