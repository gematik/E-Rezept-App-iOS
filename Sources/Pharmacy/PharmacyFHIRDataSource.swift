//
//  Copyright (c) 2023 gematik GmbH
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
import eRpKit
import FHIRClient
import Foundation

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
    /// - Parameter searchTerm: String that send to the server for filtering the pharmacies response
    /// - Parameter position: Position (latitude and longitude) of pharmacy
    /// - Parameter filter: further filter parameters for pharmacies
    /// - Returns: `AnyPublisher` that emits all `PharmacyLocation`s for the given `searchTerm`
    public func searchPharmacies(by searchTerm: String,
                                 position: Position?,
                                 filter: [String: String])
        -> AnyPublisher<[PharmacyLocation], Error> {
        fhirClient.searchPharmacies(by: searchTerm, position: position, filter: filter)
            .mapError { Error.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    /// Convenience function for requesting a certain pharmacy by ID
    ///
    /// - Parameters:
    ///   - telematikId: The Telematik-ID of the pharmacy to be requested
    /// - Returns: `AnyPublisher` that emits the pharmacy or nil when not found
    public func fetchPharmacy(by telematikId: String)
        -> AnyPublisher<PharmacyLocation?, Error> {
        fhirClient.fetchPharmacy(by: telematikId)
            .mapError { Error.fhirClient($0) }
            .eraseToAnyPublisher()
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
