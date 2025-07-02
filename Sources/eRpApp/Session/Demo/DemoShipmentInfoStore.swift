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
import eRpKit
import eRpLocalStorage
import Foundation

class DemoShipmentInfoStore: ShipmentInfoDataStore {
    static let anna = ShipmentInfo(
        name: "Anna Vetter",
        street: "Benzelrather Str. 29",
        zip: "50226",
        city: "Frechen"
    )

    init() {}

    private var selectedShipmentInfoId: CurrentValueSubject<UUID?, Never> = CurrentValueSubject(nil)
    private var dummyShipmentInfos: [ShipmentInfo] = [
        anna,
    ]

    var shipmentInfoPublisher: CurrentValueSubject<[ShipmentInfo], Never> = CurrentValueSubject([anna])

    func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        Just(dummyShipmentInfos.first { $0.id == identifier })
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }

    func set(selectedShipmentInfoId: UUID) {
        self.selectedShipmentInfoId.send(selectedShipmentInfoId)
    }

    var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
        selectedShipmentInfoId
            .setFailureType(to: LocalStoreError.self)
            .flatMap { [weak self] selectedShipmentId -> AnyPublisher<ShipmentInfo?, LocalStoreError> in
                guard let self = self,
                      let identifier = selectedShipmentId else {
                    return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
                }
                return self.fetchShipmentInfo(by: identifier)
            }
            .eraseToAnyPublisher()
    }

    func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        shipmentInfoPublisher.setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        dummyShipmentInfos = shipmentInfos + dummyShipmentInfos
        shipmentInfoPublisher.send(dummyShipmentInfos)
        return Just(shipmentInfos).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func update(
        identifier: UUID,
        mutating: @escaping (inout ShipmentInfo) -> Void
    ) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        var updatedShipmentInfo: ShipmentInfo?
        dummyShipmentInfos = dummyShipmentInfos.map { shipment in
            if shipment.id == identifier {
                updatedShipmentInfo = shipment
                mutating(&updatedShipmentInfo!) // swiftlint:disable:this force_unwrapping
                return updatedShipmentInfo! // swiftlint:disable:this force_unwrapping
            }
            return shipment
        }
        guard let updatedShipmentInfo = updatedShipmentInfo else {
            return Fail(error: LocalStoreError.write(error: ShipmentInfoCoreDataStore.Error.internalError))
                .eraseToAnyPublisher()
        }

        shipmentInfoPublisher.send(dummyShipmentInfos)
        return Just(updatedShipmentInfo).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        let allShipmentInfoIds = shipmentInfos.map(\.id)
        dummyShipmentInfos = dummyShipmentInfos.filter { !allShipmentInfoIds.contains($0.id) }
        shipmentInfoPublisher.send(dummyShipmentInfos)

        return Just(shipmentInfos).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }
}
