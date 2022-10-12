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
import eRpKit
import Foundation

/// Interface for the app to the Pharmacy data layer
/// sourcery: StreamWrapped
public protocol PharmacyRepository {
    /// Loads the `PharmacyLocation` by its telematik ID from disk or if not present from a remote (server).
    ///
    /// - Parameters:
    ///   - telematikId: the telematik ID of the pharmacy
    /// - Returns: Publisher for the load request
    func loadCached(by telematikId: String)
        -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError>

    /// Loads `PharmacyLocation`s  with search term from a remote (server).
    ///
    /// - Parameters:
    ///   - searchTerm: the `searchTerm` for the pharmacy
    ///   - position: the Position which is used as a search point for an "around me" search
    ///   - filter: further filter parameters for pharmacies
    /// - Returns: `AnyPublisher` that emits a list of `PharmacyLocation`s or is empty when not found
    func searchRemote(searchTerm: String,
                      position: Position?,
                      filter: [PharmacyRepositoryFilter])
        -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError>

    /// Loads the `PharmacyLocation` by its telematik ID from disk
    ///
    /// - Parameters:
    ///   - telematikId: the telematik ID of the pharmacy
    /// - Returns: Publisher for the load request
    func loadLocal(by telematikId: String)
        -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError>

    /// Load all local `PharmacyLocation`s (from disk)
    /// - Returns: Publisher for the load request
    func loadLocalAll() -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError>

    /// Saves an array of `PharmacyLocation`s
    /// - Parameters:
    ///   - pharmacies: the `PharmacyLocation`s to be saved
    /// - Returns: `AnyPublisher` that emits a boolean on success or fails with a `PharmacyRepositoryError`
    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError>

    /// Delete an array of `PharmacyLocation`s
    /// - Parameters:
    ///   - pharmacies: the `PharmacyLocation`s to be deleted
    /// - Returns: `AnyPublisher` that emits a boolean on success or fails with a `PharmacyRepositoryError`
    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError>
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

// swiftlint:disable:next no_extension_access_modifier
public extension Collection where Element == PharmacyRepositoryFilter {
    /// Group elements for `PharmacyRepositoryFilter` elements
    func asAPIFilter() -> [String: String] {
        Dictionary(uniqueKeysWithValues: compactMap(\.asAPIFilter))
    }
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
