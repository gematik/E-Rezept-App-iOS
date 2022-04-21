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

/// Interface for saving, loading and deleting address
///
/// sourcery: StreamWrapped
public protocol ShipmentInfoDataStore {
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
