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

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class RedeemViewSnapshotTests: ERPSnapshotTestCase {
    func testRedeemViewSnapshot() {
        let sut = NavigationStack {
            RedeemMethodsView(store: RedeemMethodsDomain.Dummies.store)
        }

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(of: sut, as: snapshotModiCurrentDevice())
    }

    func testRedeemMatrixCodeViewSnapshot() {
        let sut = MatrixCodeView(
            store: StoreOf<MatrixCodeDomain>(
                initialState: .init(
                    type: .erxTask,
                    erxTasks: [ErxTask.Demo.erxTask1],
                    loadingState: .value(.init(uniqueElements: [
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: Asset.qrcode.image,
                            chunk: [ErxTask.Demo.erxTask1]
                        ),
                    ]))
                )
            ) {
                EmptyReducer()
            }
        )

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(of: sut, as: snapshotModiCurrentDevice())
    }

    func testRedeemMatrixCodeViewZoomedCodeSnapshot() {
        let sut = MatrixCodeView(
            store: StoreOf<MatrixCodeDomain>(
                initialState: .init(
                    type: .erxTask,
                    erxTasks: [ErxTask.Demo.erxTask1],
                    loadingState: .value(.init(uniqueElements: [
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: Asset.qrcode.image,
                            chunk: [ErxTask.Demo.erxTask1]
                        ),
                    ])),
                    isMatrixCodeZoomed: true
                )
            ) {
                EmptyReducer()
            }
        )

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(of: sut, as: snapshotModiCurrentDevice())
    }

    func testRedeemMatrixCodeMultiplePrescriptionsViewSnapshot() {
        let sut = MatrixCodeView(
            store: StoreOf<MatrixCodeDomain>(
                initialState: .init(
                    type: .erxTask,
                    erxTasks: ErxTask.Demo.erxTasks,
                    loadingState: .value(.init(uniqueElements: [
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: Asset.qrcode.image,
                            chunk: [
                                ErxTask.Demo.erxTask1,
                                ErxTask.Demo.erxTask2,
                                ErxTask.Demo.erxTask3,
                            ]
                        ),
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: Asset.qrcode.image,
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
        assertSnapshots(of: sut, as: snapshotModiCurrentDevice())
    }

    func testRedeemMatrixCode_SelfPayerWarning() {
        let sut = MatrixCodeView(
            store: StoreOf<MatrixCodeDomain>(
                initialState: .init(
                    type: .erxTask,
                    erxTasks: [ErxTask.Demo.erxTaskSelfPayer],
                    loadingState: .value(.init(uniqueElements: [
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: Asset.qrcode.image,
                            chunk: [ErxTask.Demo.erxTaskSelfPayer]
                        ),
                    ]))
                )
            ) {
                EmptyReducer()
            }
        )

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(of: sut, as: snapshotModiCurrentDevice())
    }

    func testRedeemMatrixCodeMultiple_SelfPayerPrescriptionsWarning() {
        let sut = MatrixCodeView(
            store: StoreOf<MatrixCodeDomain>(
                initialState: .init(
                    type: .erxTask,
                    erxTasks: ErxTask.Demo.erxTasks,
                    loadingState: .value(.init(uniqueElements: [
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: Asset.qrcode.image,
                            chunk: [
                                ErxTask.Demo.erxTaskSelfPayer,
                                ErxTask.Demo.erxTaskSelfPayer,
                                ErxTask.Demo.erxTaskSelfPayer,
                            ]
                        ),
                        MatrixCodeDomain.State.IdentifiedImage(
                            identifier: UUID(),
                            image: Asset.qrcode.image,
                            chunk: [
                                ErxTask.Demo.erxTaskSelfPayer,
                                ErxTask.Demo.erxTaskSelfPayer,
                            ]
                        ),
                    ]))
                )
            ) {
                EmptyReducer()
            }
        )

        // View takes current device Size into account, other devices would record wrong representations
        assertSnapshots(of: sut, as: snapshotModiCurrentDevice())
    }
}
