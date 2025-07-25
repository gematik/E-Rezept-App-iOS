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
import eRpKit
import FHIRClient
import Foundation
import OpenSSL

/// The remote data source for any pharmacy requests
public struct PharmacyFHIRDataSource: PharmacyRemoteDataStore {
    private let fhirClient: FHIRClient

    /// Default initializer of `PharmacyFHIRDataSource`
    /// - Parameter fhirClient: FHIRClient which is capable to perform FHIR requests
    public init(fhirClient: FHIRClient) {
        self.fhirClient = fhirClient
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
    ) -> AnyPublisher<[PharmacyLocation], Error> {
        fhirClient.searchPharmacies(by: searchTerm, position: position, filter: filter)
            .mapError { Error.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    /// Convenience function for requesting a certain pharmacy by ID
    ///
    /// - Parameters:
    ///   - telematikId: The Telematik-ID of the pharmacy to be requested
    /// - Returns: `AnyPublisher` that emits the `PharmacyLocation` or nil when not found
    public func fetchPharmacy(
        by telematikId: String
    ) -> AnyPublisher<PharmacyLocation?, Error> {
        fhirClient.fetchPharmacy(by: telematikId)
            .mapError { Error.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    public func loadAvsCertificates(for locationId: String) -> AnyPublisher<[X509], Error> {
        fhirClient.loadAvsCertificates(for: locationId)
            .mapError { Error.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    /// Load `Insurance` by institution identifier (IK) from a remote (server).
    ///
    /// - Parameters:
    ///   - ikNumber: The institution (IK) identifier of the organization to be requested
    /// - Returns: `AnyPublisher` that emits the `TelematikId` or nil when not found
    public func fetchInsurance(by ikNumber: String) -> AnyPublisher<Insurance?, Error> {
        fhirClient.fetchInsurance(by: ikNumber)
            .mapError { Error.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    /// Loads an array of `Insurance` from a remote (server).
    ///
    /// - Parameters:
    /// - Returns: `AnyPublisher` that emits array of `Insurance` or empty when nothing is found
    public func fetchAllInsurances() -> AnyPublisher<[Insurance], Error> {
        fhirClient.fetchAllInsurances()
            .mapError { Error.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    /// Converts pharmacy filter into query parameters
    ///
    /// - Parameter filter: `PharmacyRepositoryFilter`s for filtering the pharmacy response
    /// - Returns: Key / value query parameters to use in url requests
    public func apiFilters(for filter: [PharmacyRepositoryFilter]) -> [PharmacyRemoteDataStoreFilter] {
        filter.compactMap {
            switch $0 {
            case .ready:
                return PharmacyRemoteDataStoreFilter(key: "status", value: "active")
            case .shipment:
                return PharmacyRemoteDataStoreFilter(key: "type", value: "mobl")
            case .delivery:
                return nil
            }
        }
    }
}

extension PharmacyFHIRDataSource {
    // sourcery: CodedError = "570"
    public enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case fhirClient(FHIRClient.Error)
        // sourcery: errorCode = "02"
        case notFound
    }
}
