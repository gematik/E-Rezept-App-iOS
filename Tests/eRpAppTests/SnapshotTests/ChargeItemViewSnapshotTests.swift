//
//  Copyright (c) 2024 gematik GmbH
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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class ChargeItemViewSnapshotTests: ERPSnapshotTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    override func tearDown() {
        isRecording = false
        super.tearDown()
    }

    func store(
        with state: ChargeItemDomain.State = {
            .init(profileId: DummyUserProfileService.dummyProfile.id,
                  chargeItem: ErxChargeItem.Dummies.dummy)
        }()
    ) -> StoreOf<ChargeItemDomain> {
        Store(initialState: state, reducer: EmptyReducer.init)
    }

    func testChargeItemView() {
        let sut = ChargeItemView(store: store())

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testChargeItemView_withRouting() {
        let sut = ChargeItemView(store: store(with: .init(
            profileId: DummyUserProfileService.dummyProfile.id,
            chargeItem: ErxChargeItem.Dummies.dummy,
            showRouteToChargeItemListButton: true
        )))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testChargeItemAlterViaPharmacyMatrixCodeViewSnapshot() {
        let sut = MatrixCodeView(
            store: MatrixCodeDomain.Store(
                initialState: .init(
                    type: .erxChargeItem,
                    erxChargeItem: ErxChargeItem.Dummies.dummy,
                    loadingState: .value(.init(uniqueElements: [
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: UIImage(testBundleNamed: "qrcode")!,
                            chunk: []
                        ),
                    ]))
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiCurrentDevice())
    }
}
