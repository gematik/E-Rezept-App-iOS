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

/// Interface for saving, loading and deleting pharmacies
///
/// sourcery: StreamWrapped
public protocol PharmacyLocalDataStore {
    /// Fetches a pharmacy by it's telematik-id
    /// - Parameter telematikId: Identifier of the pharmacy to fetch
    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>

    /// List all pharmacies contained in the store
    func listAllPharmacies() -> AnyPublisher<[PharmacyLocation], LocalStoreError>

    /// Creates or updates a sequence of pharmacies into the store
    /// - Parameter pharmacies: Array of pharmacies to be saved
    ///
    /// sourcery: SkipStreamWrapped
    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>

    /// Deletes a sequence of pharmacies from the store
    /// - Parameter pharmacies: Array of pharmacies to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>

    /// Updates a Pharmacy entity
    /// - Parameters:
    ///   - identifier: Identifier of the Pharmacy to update
    ///   - mutating: Closure with the actual pharmacy to be updated
    ///
    /// sourcery: SkipStreamWrapped
    func update(
        identifier: String,
        mutating: @escaping (inout PharmacyLocation) -> Void
    ) -> AnyPublisher<Bool, LocalStoreError>
}
