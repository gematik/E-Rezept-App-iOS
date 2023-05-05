//
//  Copyright (c) 2023 gematik GmbH
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

// DH.TODO: remove test and snapshots after activating new DetailViews // swiftlint:disable:this todo
final class PrescriptionFullDetailSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func store(with state: PrescriptionDetailDomain.State) -> StoreOf<PrescriptionDetailDomain> {
        Store(initialState: state,
              reducer: EmptyReducer())
    }

    func testPrescriptionFullDetailView_Show() {
        let store = store(with: PrescriptionDetailDomain.Dummies.state)
        let sut = PrescriptionFullDetailView(store: store)
            .frame(width: 320, height: 4000)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionFullDetailView_WithInProgressPrescription() {
        let inProgressPrescription = Prescription(erxTask: ErxTask.Fixtures.erxTaskInProgress)
        let sut = PrescriptionFullDetailView(
            store: store(with:
                PrescriptionDetailDomain.State(prescription: inProgressPrescription, isArchived: false))
        )
        .frame(width: 320, height: 4000)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionFullDetailView_WithCompletedPrescription() {
        let completed = Prescription(erxTask: ErxTask.Fixtures.erxTaskCompleted)
        let sut = PrescriptionFullDetailView(
            store: store(with:
                PrescriptionDetailDomain.State(prescription: completed, isArchived: false))
        )
        .frame(width: 320, height: 4000)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionFullDetailView_WithDirectAssignedPrescription() {
        let inProgressDirectAssignedTask = Prescription(erxTask: ErxTask.Fixtures.erxTaskDirectAssigned)
        let sut = PrescriptionFullDetailView(
            store: store(with:
                PrescriptionDetailDomain.State(prescription: inProgressDirectAssignedTask, isArchived: false))
        )
        .frame(width: 320, height: 3000)
        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
