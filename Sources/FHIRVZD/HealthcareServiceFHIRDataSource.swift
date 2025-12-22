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
import eRpKit
import FHIRClient
import Foundation
import OpenSSL
import Pharmacy

/// The remote data source for any healthcare service request
public struct HealthcareServiceFHIRDataSource {
    private let fhirClient: HealthcareServiceFHIRClient
    private let session: FHIRVZDSession

    /// Default initializer of `HealthcareServiceFHIRDataSource`
    /// - Parameters:
    ///   - fhirClient: FHIRClient which is capable to perform FHIR requests
    ///   - session: FHIRVZD session
    public init(
        fhirClient: HealthcareServiceFHIRClient,
        session: FHIRVZDSession
    ) {
        self.fhirClient = fhirClient
        self.session = session
    }

    /// API for requesting pharmacies with the passed search term
    ///
    /// [REQ:gemSpec_eRp_FdV:A_20183]
    ///
    /// - Parameters:
    ///   - searchTerm: String that send to the server for filtering the pharmacies response
    ///   - position: Position (latitude and longitude) of pharmacy
    ///   - filter: further filter parameters for pharmacies
    /// - Returns: `AnyPublisher` that emits all `PharmacyLocation`s for the given `searchTerm`
    public func searchPharmacies(
        by searchTerm: String,
        position: Pharmacy.Position?,
        filter: [PharmacyRemoteDataStoreFilter]
    ) -> AnyPublisher<[PharmacyLocation], PharmacyRemoteStoreError> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyRemoteStoreError.fhirClient(.unknown($0)) }
        .flatMap { token in
            fhirClient.searchPharmacies(by: searchTerm, position: position, filter: filter, accessToken: token)
                .mapError { PharmacyRemoteStoreError.fhirClient($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Convenience function for requesting a certain pharmacy by ID
    ///
    /// - Parameters:
    ///   - telematikId: The Telematik-ID of the pharmacy to be requested
    /// - Returns: `AnyPublisher` that emits the `PharmacyLocation` or nil when not found
    public func fetchPharmacy(
        by telematikId: String
    ) -> AnyPublisher<PharmacyLocation?, PharmacyRemoteStoreError> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyRemoteStoreError.fhirClient(.unknown($0)) }
        .flatMap { token in
            fhirClient.fetchPharmacy(by: telematikId, accessToken: token)
                .mapError { PharmacyRemoteStoreError.fhirClient($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Load `Insurance` by institution identifier (IK) from a remote (server).
    ///
    /// - Parameters:
    ///   - ikNumber: The institution (IK) identifier of the organization to be requested
    /// - Returns: `AnyPublisher` that emits the `TelematikId` or nil when not found
    public func fetchInsurance(by ikNumber: String) -> AnyPublisher<Insurance?, PharmacyRemoteStoreError> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyRemoteStoreError.fhirClient(.unknown($0)) }
        .flatMap { token in
            fhirClient.fetchInsurance(by: ikNumber, accessToken: token)
                .mapError { PharmacyRemoteStoreError.fhirClient($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Loads an array of `Insurance` from a remote (server).
    ///
    /// - Parameters:
    /// - Returns: `AnyPublisher` that emits array of `Insurance` or empty when nothing is found
    public func fetchAllInsurances() -> AnyPublisher<[Insurance], PharmacyRemoteStoreError> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyRemoteStoreError.fhirClient(.unknown($0)) }
        .flatMap { token in
            fhirClient.fetchAllInsurances(accessToken: token)
                .mapError { PharmacyRemoteStoreError.fhirClient($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Loads an array of `Insurance` from a remote (server).
    ///
    /// - Parameters:
    /// - Returns: `AnyPublisher` that emits array of `Insurance` or empty when nothing is found
    public func fetchEuCountries() -> AnyPublisher<[Country], PharmacyRemoteStoreError> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyRemoteStoreError.fhirClient(.unknown($0)) }
        .flatMap { token in
            fhirClient.fetchEuCountries(accessToken: token)
                .mapError { PharmacyRemoteStoreError.fhirClient($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Converts pharmacy filter into query parameters
    ///
    /// - Parameter filter: `PharmacyRepositoryFilter`s for filtering the pharmacy response
    /// - Returns: Key / value query parameters to use in url requests
    public func apiFilters(for filter: [PharmacyRepositoryFilter]) -> [PharmacyRemoteDataStoreFilter] {
        let filterTexts: [String] = filter.compactMap {
            switch $0 {
            case .ready:
                return nil
            case .shipment:
                return "Versand"
            case .delivery:
                return "Botendienst"
            }
        }
        guard !filterTexts.isEmpty else {
            return []
        }
        return [PharmacyRemoteDataStoreFilter(key: "text", value: filterTexts.joined(separator: " "))]
    }
}
