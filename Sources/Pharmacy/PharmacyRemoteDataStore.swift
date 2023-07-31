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

/// Interface for the remote data store
public protocol PharmacyRemoteDataStore {
    /// API for requesting pharmacies with the passed search term
    ///
    /// [REQ:gemSpec_eRp_FdV:A_20183]
    ///
    /// - Parameter searchTerm: String that send to the server for filtering the pharmacies response
    /// - Parameter position: Position (latitude and longitude) of pharmacy
    /// - Parameter filter: further filter parameters for pharmacies
    /// - Returns: `AnyPublisher` that emits all `PharmacyLocation`s for the given `searchTerm`
    func searchPharmacies(by searchTerm: String,
                          position: Position?,
                          filter: [String: String])
        -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>

    /// Convenience function for requesting a certain pharmacy by ID
    ///
    /// - Parameters:
    ///   - telematikId: The Telematik-ID of the pharmacy to be requested
    /// - Returns: `AnyPublisher` that emits the `PharmacyLocation` or nil when not found
    func fetchPharmacy(by telematikId: String)
        -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error>

    /// Load certificates for a given `PharmacyLocation` id
    ///
    /// - Parameter locationId: id of `PharmacyLocation` from which to load the certificate
    /// - Returns: Emits an array of certificates on success or fails with a `PharmacyFHIRDataSource.Error`
    func loadAvsCertificates(for locationId: String) -> AnyPublisher<[X509], PharmacyFHIRDataSource.Error>
}
