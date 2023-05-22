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
import Foundation
import OpenSSL

/// Interface for the app to the Pharmacy data layer
/// sourcery: StreamWrapped
public protocol PharmacyRepository {
    /// Loads the `PharmacyLocation` by its telematik ID from a remote server and updates *only* properties
    /// that are loaded from remote. If pharmacy is not jet in local store this method will return an error
    ///
    /// - Parameters:
    ///   - telematikId: The telematik ID of the pharmacy
    /// - Returns: Publisher for the load and saved request or fails
    func updateFromRemote(by telematikId: String) -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError>

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

    /// Load `count` local `PharmacyLocation`s (from disk)
    /// - Parameter count: Count of pharmacies to fetch, Nil if no fetch limit should be applied
    /// - Returns: Publisher for the load request
    func loadLocal(count: Int?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError>

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

    /// Load certificates for a given `PharmacyLocation` id
    /// - Parameter id: id of `PharmacyLocation` from which to load the certificate
    /// - Returns: Emits an array of certificates on success or fails with a `PharmacyRepositoryError`
    func loadAvsCertificates(for id: String) -> AnyPublisher<[X509], PharmacyRepositoryError>
}

extension PharmacyRepository {
    /// Creates or updates a `PharmacyLocation` into the store. Updates if the identifier does already exist in store
    /// - Parameter pharmacy: Instance of `PharmacyLocation` to be saved
    ///
    /// sourcery: SkipStreamWrapped
    public func save(pharmacy: PharmacyLocation) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        save(pharmacies: [pharmacy])
            .eraseToAnyPublisher()
    }

    /// Deletes a `PharmacyLocation` from the store with the related identifier
    /// - Parameter pharmacy: Instance of `PharmacyLocation` to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    public func delete(pharmacy: PharmacyLocation) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        delete(pharmacies: [pharmacy])
            .eraseToAnyPublisher()
    }
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
