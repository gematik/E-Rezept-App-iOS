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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class PrescriptionDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        PrescriptionDetailDomain.State,
        PrescriptionDetailDomain.State,
        PrescriptionDetailDomain.Action,
        PrescriptionDetailDomain.Action,
        PrescriptionDetailDomain.Environment
    >

    func testStore() -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let erxTaskRespository = PrescriptionDetailDomain.Dummies
            .demoSessionContainer.userSession.erxTaskRepository
        return TestStore(
            initialState: PrescriptionDetailDomain.Dummies.state,
            reducer: PrescriptionDetailDomain.reducer,
            environment: PrescriptionDetailDomain.Environment(
                schedulers: schedulers,
                taskRepository: erxTaskRespository,
                fhirDateFormatter: FHIRDateFormatter.shared,
                pharmacyRepository: MockPharmacyRepository(),
                userSession: MockUserSession()
            )
        )
    }

    /// Tests the case when delete was hit but in the alert 'No' was chosen.
    func testCancelDeleteWithAlert() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.alertState = PrescriptionDetailDomain.confirmDeleteAlertState
        }
        store.send(.cancelDelete) { sut in
            // then
            sut.alertState = nil
        }
    }

    /// Tests the case when delete was hit and in the alert 'Yes' was chosen.
    func testDeleteWithAlertSuccess() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.alertState = PrescriptionDetailDomain.confirmDeleteAlertState
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.alertState = nil
        }
        store.send(.taskDeletedReceived(Result.success(true))) { state in
            // then
            state.alertState = nil
        }
        store.receive(.close) { state in
            state.alertState = nil
        }
    }

    /// Tests the case when delete was hit and deletion has failed and an alert is shown to user
    func testDeleteWithAlertFailure() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.alertState = PrescriptionDetailDomain.confirmDeleteAlertState
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.alertState = nil
        }
        store.send(.taskDeletedReceived(
            Result.failure(ErxRepositoryError.local(.delete(error: IDPError.tokenUnavailable)))
        )) { state in
            // then
            state.alertState = PrescriptionDetailDomain.deleteFailedAlertState(
                IDPError.tokenUnavailable.errorDescription ?? ""
            )
        }
        store.send(.alertDismissButtonTapped) { state in
            state.alertState = nil
        }
    }

    /// Tests the case when delete was hit and deletion has failed but is silently ignored.
    func testDeleteWithAlertSilentFailure() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.alertState = PrescriptionDetailDomain.confirmDeleteAlertState
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.alertState = nil
        }
        store.send(.taskDeletedReceived(
            Result.failure(ErxRepositoryError.local(.notImplemented))
        )) { state in
            // then
            state.alertState = nil
        }
        store.send(.alertDismissButtonTapped) { state in
            state.alertState = nil
        }
    }

    /// Test redeem low-detail prescriptions.
    func testRedeemLowDetail() {
        let store = testStore()

        let expectedRedeemDate = FHIRDateFormatter.shared.string(
            from: Date(),
            format: .yearMonthDayTime
        )
        var erxTask = ErxTask.Dummies.erxTaskReady
        erxTask.update(with: expectedRedeemDate)
        let prescription = GroupedPrescription.Prescription.Dummies.prescriptionReady
        let expectedPrescription = GroupedPrescription.Prescription(erxTask: erxTask)
        // when
        store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.isArchived = true
        }
        testScheduler.advance()
        store.receive(.redeemedOnSavedReceived(true)) { state in
            state.prescription = prescription
        }
        store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.isArchived = false
        }
        testScheduler.advance()
        store.receive(.redeemedOnSavedReceived(true)) { state in
            state.prescription = expectedPrescription
        }
    }
}
