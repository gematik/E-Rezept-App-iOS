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
import Pharmacy

/// Protocol describing the FHIR Client for healthcare services
public protocol HealthcareServiceFHIRClient {
    /// Convenience function for searching for pharmacies
    ///
    /// [REQ:gemSpec_eRp_FdV:A_19984] validate pharmacy data format conforming to FHIR
    ///
    /// - Parameters:
    ///   - searchTerm: Search term
    ///   - position: Pharmacy position (latitude and longitude)
    /// - Returns: `AnyPublisher` that emits a list of `PharmacyLocation`s or is empty when not found
    func searchPharmacies(
        by searchTerm: String,
        position: Pharmacy.Position?,
        filter: [PharmacyRemoteDataStoreFilter],
        accessToken: String?
    ) -> AnyPublisher<[PharmacyLocation], FHIRClient.Error>

    /// Convenience function for requesting a certain pharmacy by ID
    ///
    /// - Parameters:
    ///   - telematikId: The Telematik-ID of the pharmacy to be requested
    /// - Returns: `AnyPublisher` that emits the `PharmacyLocation` or nil when not found
    func fetchPharmacy(by telematikId: String, accessToken: String?)
        -> AnyPublisher<PharmacyLocation?, FHIRClient.Error>

    /// Convenience function for requesting a telematikId by institution identifier (IK)
    ///
    /// - Parameters:
    ///   - ikNumber: The institution (IK) identifier of the organization to be requested
    /// - Returns: `AnyPublisher` that emits the `TelematikId` or nil when not found
    func fetchTelematikId(by ikNumber: String, accessToken: String?)
        -> AnyPublisher<String?, FHIRClient.Error>
}
