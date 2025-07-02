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

/// Interface for saving, loading and deleting address
///
/// sourcery: StreamWrapped
public protocol ShipmentInfoDataStore {
    /// Set the selectedShipmentInfoId.
    /// The selected values of `ShipmentInfo` are published through `selectedShipmentInfo`
    /// - Parameter selectedShipmentInfoId: Identifier of the `ShipmentInfo` to be selected
    func set(selectedShipmentInfoId: UUID)

    /// Returns the selected `ShipmentInfo` if any has been selected.
    /// Returns `nil` if nothing was selected
    var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> { get }

    /// Fetches a `ShipmentInfo` by it's identifier
    /// - Parameter identifier: Identifier of the `ShipmentInfo` to fetch
    func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError>

    /// List all `ShipmentInfo`s contained in the store
    func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError>

    /// Creates or updates a sequence of `ShipmentInfo` into the store.
    /// Updates if the identifier does already exist in store, otherwise creates a new instance.
    /// - Parameter shipmentInfos: Array of `ShipmentInfo` to be saved
    ///
    /// sourcery: SkipStreamWrapped
    func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>

    /// Deletes a sequence of `ShipmentInfo` from the store with the related identifier
    /// - Parameter shipmentInfos: Array of `ShipmentInfo` to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError>

    /// Updates a `ShipmentInfo`
    /// - Parameters:
    ///   - identifier: Identifier of the `ShipmentInfo` to update
    ///   - mutating: Closure with the actual `ShipmentInfo` to be updated
    ///
    /// sourcery: SkipStreamWrapped
    func update(
        identifier: UUID,
        mutating: @escaping (inout ShipmentInfo) -> Void
    ) -> AnyPublisher<ShipmentInfo, LocalStoreError>
}

extension ShipmentInfoDataStore {
    /// Creates or updates a `ShipmentInfo` into the store. Updates if the identifier does already exist in store
    /// - Parameter shipmentInfo: Instance of `ShipmentInfo` to be saved
    ///
    /// sourcery: SkipStreamWrapped
    public func save(shipmentInfo: ShipmentInfo) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        save(shipmentInfos: [shipmentInfo])
            .map(\.first)
            .eraseToAnyPublisher()
    }

    /// Deletes a `ShipmentInfo` into from the store with the related identifier
    /// - Parameter shipmentInfo: Instance of `ShipmentInfo` to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    public func delete(shipmentInfo: ShipmentInfo) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        delete(shipmentInfos: [shipmentInfo])
            .map(\.first)
            .eraseToAnyPublisher()
    }
}
