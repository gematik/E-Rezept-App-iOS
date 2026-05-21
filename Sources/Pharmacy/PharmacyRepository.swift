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
import Foundation
import OpenSSL

/// Interface for the app to the Pharmacy data layer
/// sourcery: StreamWrapped
@DependencyClient
public struct PharmacyRepository: Sendable {
    /// Loads the `PharmacyLocation` by its telematik ID from a remote server and updates *only* properties
    /// that are loaded from remote. If pharmacy is not yet in local store, this method will return an error.
    ///
    /// - Parameter telematikId: The telematik ID of the pharmacy
    /// - Returns: A `PharmacyLocation` or throws a `PharmacyRepositoryError`
    public var updateFromRemote: @Sendable (_ telematikId: String) async throws -> PharmacyLocation

    /// Loads the `PharmacyLocation` by its telematik ID from disk or if not present from a remote server.
    ///
    /// - Parameter telematikId: The telematik ID of the pharmacy
    /// - Returns: A `PharmacyLocation?` or throws a `PharmacyRepositoryError`
    public var loadCached: @Sendable (_ telematikId: String) async throws -> PharmacyLocation?

    /// Searches `PharmacyLocation`s from a remote server using a search term and filters.
    ///
    /// - Parameters:
    ///   - searchTerm: Search string for the pharmacy
    ///   - position: Location to use as search center
    ///   - filter: Optional filters
    /// - Returns: An array of matching `PharmacyLocation`s or throws a `PharmacyRepositoryError`
    public var searchRemote: @Sendable (
        _ searchTerm: String,
        _ position: Position?,
        _ filter: [PharmacyRepositoryFilter]
    ) async throws -> [PharmacyLocation]

    /// Loads a local `PharmacyLocation` by its telematik ID.
    ///
    /// - Parameter telematikId: The telematik ID of the pharmacy
    /// - Returns: A `PharmacyLocation?` or throws a `PharmacyRepositoryError`
    public var loadLocalById: @Sendable (_ telematikId: String) async throws -> PharmacyLocation?

    /// Loads up to `count` local `PharmacyLocation`s.
    ///
    /// - Parameter count: Optional number of results to limit
    /// - Returns: An array of `PharmacyLocation`s or throws a `PharmacyRepositoryError`
    public var loadLocalCount: @Sendable (_ count: Int?) async throws -> [PharmacyLocation]

    /// Saves an array of `PharmacyLocation`s.
    ///
    /// - Parameter pharmacies: The locations to save
    /// - Returns: `true` if successful, or throws a `PharmacyRepositoryError`
    public var saveMultiple: @Sendable (_ pharmacies: [PharmacyLocation]) async throws -> Bool

    /// Deletes an array of `PharmacyLocation`s.
    ///
    /// - Parameter pharmacies: The locations to delete
    /// - Returns: `true` if successful, or throws a `PharmacyRepositoryError`
    public var deleteMultiple: @Sendable (_ pharmacies: [PharmacyLocation]) async throws -> Bool

    /// Loads an insurance record by IK number.
    ///
    /// - Parameter ikNumber: Insurance institution identifier
    /// - Returns: The insurance or `nil`, or throws a `PharmacyRepositoryError`
    public var fetchInsurance: @Sendable (_ ikNumber: String) async throws -> Insurance?

    /// Loads all known insurances.
    ///
    /// - Returns: Array of `Insurance` or throws a `PharmacyRepositoryError`
    public var fetchAllInsurances: @Sendable () async throws -> [Insurance]

    /// Loads an array of `Country` from a remote (server).
    /// - Parameters:
    /// - Returns: `AnyPublisher` that emits array of `Country` or empty when nothing is found
    public var fetchEuCountries: @Sendable () async throws -> [Country]

    // MARK: - Convenience Methods

    /// Saves a single `PharmacyLocation`.
    public func save(pharmacy: PharmacyLocation) async throws -> Bool {
        try await saveMultiple([pharmacy])
    }

    /// Deletes a single `PharmacyLocation`.
    public func delete(pharmacy: PharmacyLocation) async throws -> Bool {
        try await deleteMultiple([pharmacy])
    }
}

extension DependencyValues {
    /// Access to the pharmacyRepository dependency.
    public var pharmacyRepository: PharmacyRepository {
        get { self[PharmacyRepository.self] }
        set { self[PharmacyRepository.self] = newValue }
    }
}

extension PharmacyRepository: TestDependencyKey {
    public static let testValue: PharmacyRepository = Self()
}

/// Available filters for the Pharmacy Repository
public enum PharmacyRepositoryFilter: Equatable {
    /// Matching pharmacies are marked as E-Rezept ready
    case ready
    /// Matching pharmacies provide online service for ordering medications
    case shipment
    /// Matching pharmacies provide local delivery services (Botendienst)
    case delivery
    /// Matching pharmacies provide in-store pickup (Handverkauf)
    case pickup
    /// Matching pharmacies have on-site physical features (characteristic)
    case characteristic(Characteristic)
    /// Matching pharmacies offer a specific service (specialty)
    case specialty(Specialty)

    /// Physical feature characteristics that can be queried via the FHIR `characteristic` search parameter.
    public enum Characteristic: String, Equatable, CaseIterable {
        case parking = "parkmoeglichkeit"
        case publicTransport = "oepnv"
        case barrierFree = "barrierefrei"
        case pickupAutomat = "abholautomat"
    }

    /// Service specialties that can be queried via the FHIR `specialty` search parameter.
    public enum Specialty: String, Equatable, CaseIterable {
        // PharmacyHealthcareSpecialtyCS (codes 50+)
        case sterileCompounding = "50"
        case hypertension = "60"
        case inhalationTechnique = "70"
        case polymedication = "80"
        case oralCancerTherapy = "90"
        case organTransplantation = "100"
        // HealthcareServiceSpecialtyCS
        case vaccination = "impfung"
        case bodyMeasurements = "koerperwerte"
        case allergyTest = "allergietest"
        case travelMedicineConsultation = "reisemedizin-beratung"
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
