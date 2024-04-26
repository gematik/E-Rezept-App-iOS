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

import ComposableArchitecture
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class RedeemViewSnapshotTests: ERPSnapshotTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testRedeemViewSnapshot() {
        let sut = RedeemMethodsView(store: RedeemMethodsDomain.Dummies.store)

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(matching: sut, as: snapshotModiCurrentDevice())
    }

    func testRedeemMatrixCodeViewSnapshot() {
        let sut = MatrixCodeView(
            store: MatrixCodeDomain.Store(
                initialState: .init(
                    type: .erxTask,
                    erxTasks: ErxTask.Demo.erxTasks,
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

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(matching: sut, as: snapshotModiCurrentDevice())
    }

    func testRedeemMatrixCodeMultiplePrescriptionsViewSnapshot() {
        let sut = MatrixCodeView(
            store: MatrixCodeDomain.Store(
                initialState: .init(
                    type: .erxTask,
                    erxTasks: ErxTask.Demo.erxTasks,
                    loadingState: .value(.init(uniqueElements: [
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: UIImage(testBundleNamed: "qrcode")!,
                            chunk: [
                                ErxTask.Demo.erxTask1,
                                ErxTask.Demo.erxTask2,
                                ErxTask.Demo.erxTask3,
                            ]
                        ),
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: UIImage(testBundleNamed: "qrcode")!,
                            chunk: [
                                ErxTask.Demo.erxTask4,
                                ErxTask.Demo.erxTask5,
                            ]
                        ),
                    ]))
                )
            ) {
                EmptyReducer()
            }
        )

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(matching: sut, as: snapshotModiCurrentDevice())
    }
}
