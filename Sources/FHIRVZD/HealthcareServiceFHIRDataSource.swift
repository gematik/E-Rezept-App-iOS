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

import Combine
import Dependencies
import eRpKit
import FHIRClient
import Foundation
import OpenSSL
import Pharmacy

/// The remote data source for any healthcare service request
public struct HealthcareServiceFHIRDataSource: PharmacyRemoteDataStore {
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
    ) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyFHIRDataSource.Error.fhirClient(.unknown($0)) }
        .flatMap { token in
            self.recursiveSearchPharamcies(token: token, by: searchTerm, position: position, filter: filter, index: 0)
        }
        .eraseToAnyPublisher()
    }

    static let distances = [2, 3, 5, 10, 20, 50]

    public func recursiveSearchPharamcies(
        token: String,
        by searchTerm: String,
        position: Pharmacy.Position?,
        filter: [PharmacyRemoteDataStoreFilter],
        index: Int = 0
    ) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
        var filter = filter

        if let position {
            let distance = Self.distances[index]
            filter.append(PharmacyRemoteDataStoreFilter(key: "_sortby", value: "near"))
            filter.append(PharmacyRemoteDataStoreFilter(
                key: "location.near",
                value: "\(position.latitude)|\(position.longitude)|\(distance)|km"
            ))

            // future api will support this syntax:
            // filter["longitude"] = "\(position.longitude)"
            // filter["latitude"] = "\(position.latitude)"
            // filter["distance"] = "\(distance)"
        }

        return fhirClient.searchPharmacies(by: searchTerm, position: nil, filter: filter, accessToken: token)
            .mapError { PharmacyFHIRDataSource.Error.fhirClient($0) }
            .flatMap { locations in

                // withouth position we have no distance information => no refinement
                // we are at the beginning or end of the distance array we have no other options
                guard position != nil, index < Self.distances.count - 1 else {
                    return Just(locations)
                        .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                        .eraseToAnyPublisher()
                }
                // We found a suitable number of pharmacies
                if locations.count > 50 {
                    return Just(locations)
                        .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return recursiveSearchPharamcies(
                        token: token,
                        by: searchTerm,
                        position: position,
                        filter: filter,
                        index: index + 1
                    )
                    .map { nextIndexLocation in
                        if nextIndexLocation.count == 100 {
                            return locations
                        } else {
                            return nextIndexLocation
                        }
                    }
                    .eraseToAnyPublisher()
                }
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
    ) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyFHIRDataSource.Error.fhirClient(.unknown($0)) }
        .flatMap { token in
            fhirClient.fetchPharmacy(by: telematikId, accessToken: token)
                .mapError { PharmacyFHIRDataSource.Error.fhirClient($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Convenience function for requesting a telematikId by institution identifier (IK)
    ///
    /// - Parameters:
    ///   - ikNumber: The institution (IK) identifier of the organization to be requested
    /// - Returns: `AnyPublisher` that emits the `TelematikId` or nil when not found
    public func fetchTelematikId(by ikNumber: String) -> AnyPublisher<String?, PharmacyFHIRDataSource.Error> {
        Future {
            try await session.autoRefreshedToken().accessToken
        }
        .mapError { PharmacyFHIRDataSource.Error.fhirClient(.unknown($0)) }
        .flatMap { token in
            fhirClient.fetchTelematikId(by: ikNumber, accessToken: token)
                .mapError { PharmacyFHIRDataSource.Error.fhirClient($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// This operation is not supported anymore
    @available(*, deprecated, message: "Service does no longer support loading AVS certificates")
    public func loadAvsCertificates(for _: String) -> AnyPublisher<[X509], PharmacyFHIRDataSource.Error> {
        Fail(
            outputType: [X509].self,
            failure: PharmacyFHIRDataSource.Error.notFound
        )
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
                return nil
            case .shipment:
                return PharmacyRemoteDataStoreFilter(key: "specialty", value: Specialty.shipment.rawValue)
            case .delivery:
                return PharmacyRemoteDataStoreFilter(key: "specialty", value: Specialty.delivery.rawValue)
            }
        }
    }
}
