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

/// Interface for saving, loading and deleting AVSTransaction records
///
/// sourcery: StreamWrapped
public protocol AVSTransactionDataStore {
    /// Fetches a `AVSTransaction` by it's identifier
    /// - Parameter identifier: Identifier of the `AVSTransaction` to fetch
    func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError>

    /// List all `AVSTransaction`s contained in the store
    func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError>

    /// Creates or updates a sequence of `AVSTransaction` into the store.
    /// Updates if the identifier does already exist in store, otherwise creates a new instance.
    /// - Parameter avsTransactions: Array of `AVSTransaction` to be saved
    ///
    /// sourcery: SkipStreamWrapped
    func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>

    /// Deletes a sequence of `AVSTransaction` from the store with the related identifier
    /// - Parameter avsTransactions: Array of `AVSTransaction` to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>
}

extension AVSTransactionDataStore {
    /// Creates or updates a `AVSTransaction` into the store. Updates if the identifier does already exist in store
    /// - Parameter avsTransaction: Instance of `AVSTransaction` to be saved
    ///
    /// sourcery: SkipStreamWrapped
    public func save(avsTransaction: AVSTransaction) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        save(avsTransactions: [avsTransaction])
            .map(\.first)
            .eraseToAnyPublisher()
    }

    /// Deletes a `AVSTransaction` into from the store with the related identifier
    /// - Parameter avsTransaction: Instance of `AVSTransaction` to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    public func delete(avsTransaction: AVSTransaction) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        delete(avsTransactions: [avsTransaction])
            .map(\.first)
            .eraseToAnyPublisher()
    }
}
