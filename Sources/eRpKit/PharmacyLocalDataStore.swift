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
import Foundation

/// Interface for saving, loading and deleting pharmacies
///
/// sourcery: StreamWrapped
public protocol PharmacyLocalDataStore {
    /// Fetches a pharmacy by it's telematik-id
    /// - Parameter telematikId: Identifier of the pharmacy to fetch
    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>

    /// List all pharmacies contained in the store
    /// /// - Parameter count: Number of pharmacies to fetch, nil if no limit should be applied
    func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError>

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
    ///   - telematikId: telematik id of the Pharmacy to update
    ///   - mutating: Closure with the actual pharmacy to be updated
    ///
    /// sourcery: SkipStreamWrapped
    func update(
        telematikId: String,
        mutating: @escaping (inout PharmacyLocation) -> Void
    ) -> AnyPublisher<PharmacyLocation, LocalStoreError>
}
