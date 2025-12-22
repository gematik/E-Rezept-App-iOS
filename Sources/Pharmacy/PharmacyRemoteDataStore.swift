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
import Dependencies
import DependenciesMacros
import eRpKit
import FHIRClient
import Foundation
import OpenSSL

public struct PharmacyRemoteDataStoreFilter: Codable, Equatable {
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// Interface for the remote data store
@DependencyClient
public struct PharmacyRemoteDataStore {
    /// API for requesting pharmacies with the passed search term
    ///
    /// [REQ:gemSpec_eRp_FdV:A_20183]
    ///
    /// - Parameters:
    ///   - searchTerm: String that send to the server for filtering the pharmacies response
    ///   - position: Position (latitude and longitude) of pharmacy
    ///   - filter: further filter parameters for pharmacies
    /// - Returns: `AnyPublisher` that emits all `PharmacyLocation`s for the given `searchTerm`
    public var searchPharmacies: @Sendable (
        _ searchTerm: String,
        _ position: Position?,
        _ filter: [PharmacyRepositoryFilter]
    ) async throws -> [PharmacyLocation]

    /// Convenience function for requesting a certain pharmacy by ID
    ///
    /// - Parameters:
    ///   - telematikId: The Telematik-ID of the pharmacy to be requested
    /// - Returns: `AnyPublisher` that emits the `PharmacyLocation` or nil when not found
    public var fetchPharmacy: @Sendable (_ telematikId: String) async throws -> PharmacyLocation?

    /// Load `Insurance` by institution identifier (IK) from a remote (server).
    ///
    /// - Parameters:
    ///   - ikNumber: The institution (IK) identifier of the organization to be requested
    /// - Returns: `AnyPublisher` that emits the `TelematikId` or nil when not found
    public var fetchInsurance: @Sendable (_ ikNumber: String) async throws -> Insurance?

    /// Loads an array of `Insurance` from a remote (server).
    ///
    /// - Parameters:
    /// - Returns: `AnyPublisher` that emits array of `Insurance` or empty when nothing is found
    public var fetchAllInsurances: @Sendable () async throws -> [Insurance]

    /// Loads an array of `Insurance` from a remote (server).
    ///
    /// - Parameters:
    /// - Returns: `AnyPublisher` that emits array of `Insurance` or empty when nothing is found
    public var fetchEuCountries: @Sendable () async throws -> [Country]
}

extension DependencyValues {
    /// PharmacyRemoteDataStore
    public var pharmacyRemoteDataStore: PharmacyRemoteDataStore {
        get { self[PharmacyRemoteDataStore.self] }
        set { self[PharmacyRemoteDataStore.self] = newValue }
    }
}

extension PharmacyRemoteDataStore: TestDependencyKey {
    public static let testValue: PharmacyRemoteDataStore = Self()
}

// sourcery: CodedError = "570"
public enum PharmacyRemoteStoreError: Swift.Error, Equatable {
    // sourcery: errorCode = "01"
    case fhirClient(FHIRClient.Error)
    // sourcery: errorCode = "02"
    case notFound
}
