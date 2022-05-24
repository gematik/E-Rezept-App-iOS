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
@testable import eRpApp
import eRpKit
import Foundation

class MockShipmentInfoDataStore: ShipmentInfoDataStore {
    init() {}

    var setSelectedShipmentInfoIdCallsCount = 0
    var setSelectedShipmentInfoIdCalled: Bool {
        setSelectedShipmentInfoIdCallsCount > 0
    }

    func set(selectedShipmentInfoId _: UUID) {
        setSelectedShipmentInfoIdCallsCount += 1
    }

    var selectedShipmentInfoCallsCount = 0
    var selectedShipmentInfoCalled: Bool {
        selectedShipmentInfoCallsCount > 0
    }

    var selectedShipmentInfoReturnValue: AnyPublisher<ShipmentInfo?, LocalStoreError>!

    var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
        selectedShipmentInfoCallsCount += 1
        return selectedShipmentInfoReturnValue
    }

    func fetchShipmentInfo(by _: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    var saveShipmentInfoCallsCount = 0
    var saveShipmentInfoCalled: Bool {
        saveShipmentInfoCallsCount > 0
    }

    var saveShipmentInfoReturnValue: AnyPublisher<[ShipmentInfo], LocalStoreError>!

    func save(shipmentInfos _: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        saveShipmentInfoCallsCount += 1
        return saveShipmentInfoReturnValue
    }

    func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        Just([]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func update(identifier _: UUID,
                mutating _: @escaping (inout ShipmentInfo) -> Void) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
    }

    func delete(shipmentInfos _: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        Just([]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }
}
