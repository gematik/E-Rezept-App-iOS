//
//  Copyright (c) 2021 gematik GmbH
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
import Foundation

/// sourcery: StreamWrapped
public protocol PharmacyRepository {
    /// Loads pharmacies with `searchTerm`
    func searchPharmacies(searchTerm: String,
                          position: Position?)
    -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError>
}

public enum PharmacyRepositoryError: Error, Equatable {
    case remote(PharmacyFHIRDataSource.Error)
}

/// Position which is used as a search point for an "around me" search.
public struct Position {
    /// Initializer for a search point
    public init(lat: Double, lon: Double) {
        latitude = lat
        longitude = lon
    }

    /// Latitude coordinate of search point
    public let latitude: Double
    /// Longitude coordinate of search point
    public let longitude: Double
}

public struct DefaultPharmacyRepository: PharmacyRepository {
    private let cloud: PharmacyFHIRDataSource

    public init(cloud: PharmacyFHIRDataSource) {
        self.cloud = cloud
    }

    public func searchPharmacies(searchTerm: String, position: Position?)
    -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        cloud.searchPharmacies(by: searchTerm, position: position)
            .mapError { PharmacyRepositoryError.remote($0) }
            .eraseToAnyPublisher()
    }
}
