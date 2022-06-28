//
//  Copyright (c) 2022 gematik GmbH
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
                          position: Position?,
                          filter: [PharmacyRepositoryFilter])
        -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError>
}

/// Available filters for the Pharmacy Repository
public enum PharmacyRepositoryFilter {
    /// Matching pharmacies are marked as E-Rezept ready
    case ready
    /// Matching pharmacies provide online service for ordering medications
    case shipment
    /// Matching pharmacies provide local delivery services (Botendienst)
    case delivery
}

extension PharmacyRepositoryFilter {
    var asAPIFilter: (String, String)? {
        switch self {
        case .ready:
            return ("status", "active")
        case .shipment:
            return ("type", "mobl")
        case .delivery:
            return nil
        }
    }
}

extension Collection where Element == PharmacyRepositoryFilter {
    func asAPIFilter() -> [String: String] {
        Dictionary(uniqueKeysWithValues: compactMap(\.asAPIFilter))
    }
}

// sourcery: CodedError = "571"
public enum PharmacyRepositoryError: Error, Equatable {
    // sourcery: errorCode = "01"
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

    public func searchPharmacies(searchTerm: String, position: Position?, filter: [PharmacyRepositoryFilter])
        -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        cloud.searchPharmacies(by: searchTerm, position: position, filter: filter.asAPIFilter())
            .map { pharmacies in
                if filter.contains(.delivery) {
                    return pharmacies.filter(\.hasDeliveryService)
                }
                return pharmacies
            }
            .mapError { PharmacyRepositoryError.remote($0) }
            .eraseToAnyPublisher()
    }
}
