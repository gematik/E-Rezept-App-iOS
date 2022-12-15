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
    let initialState = PrescriptionDetailDomain.Dummies.state

    typealias TestStore = ComposableArchitecture.TestStore<
        PrescriptionDetailDomain.State,
        PrescriptionDetailDomain.State,
        PrescriptionDetailDomain.Action,
        PrescriptionDetailDomain.Action,
        PrescriptionDetailDomain.Environment
    >

    func testStore(dateProvider: @escaping (() -> Date) = Date.init) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let erxTaskRepository = PrescriptionDetailDomain.Dummies
            .demoSessionContainer.userSession.erxTaskRepository
        return TestStore(
            initialState: initialState,
            reducer: PrescriptionDetailDomain.reducer,
            environment: PrescriptionDetailDomain.Environment(
                schedulers: schedulers,
                taskRepository: erxTaskRepository,
                fhirDateFormatter: FHIRDateFormatter.shared,
                userSession: MockUserSession(),
                dateProvider: dateProvider
            )
        )
    }

    /// Tests the case when delete was hit but in the alert 'No' was chosen.
    func testCancelDeleteWithAlert() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.route = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.setNavigation(tag: .none)) { sut in
            // then
            sut.route = nil
        }
    }

    /// Tests the case when delete was hit and in the alert 'Yes' was chosen.
    func testDeleteWithAlertSuccess() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.route = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.isDeleting = true
            sut.route = nil
        }
        store.send(.taskDeletedReceived(Result.success(true))) { state in
            // then
            state.isDeleting = false
            state.route = nil
        }
        store.receive(.close)
    }

    /// Tests the case when delete was hit and deletion has failed when not being logged in
    func testDeleteWhenNotLoggedIn() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.route = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.route = nil
            sut.isDeleting = true
        }
        store.send(.taskDeletedReceived(
            Result.failure(ErxRepositoryError.remote(.fhirClientError(IDPError.tokenUnavailable)))
        )) { state in
            // then
            state.route = .alert(PrescriptionDetailDomain.missingTokenAlertState())
            state.isDeleting = false
        }
        store.send(.setNavigation(tag: .none)) { state in
            state.route = nil
        }
    }

    /// Tests the case when delete was hit and deletion has failed with other errors.
    func testDeleteWithOtherErrorMessage() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.route = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.isDeleting = true
            sut.route = nil
        }
        store.send(.taskDeletedReceived(
            Result.failure(ErxRepositoryError.local(.notImplemented))
        )) { state in
            // then
            state.isDeleting = false
            state.route = .alert(
                PrescriptionDetailDomain.deleteFailedAlertState(
                    error: ErxRepositoryError.local(.notImplemented),
                    localizedError: ErxRepositoryError.local(.notImplemented).localizedDescriptionWithErrorList
                )
            )
        }
        store.send(.setNavigation(tag: nil)) { state in
            state.route = nil
        }
    }

    /// Test redeem low-detail prescriptions.
    func testRedeemLowDetail() {
        let dateToday = Date()

        let store = testStore(dateProvider: { dateToday })

        let expectedRedeemDate = FHIRDateFormatter.shared.stringWithLongUTCTimeZone(from: dateToday)
        var erxTask = initialState.prescription.erxTask
        let prescription = GroupedPrescription.Prescription(erxTask: erxTask, date: dateToday)
        erxTask.update(with: expectedRedeemDate)
        let expectedPrescription = GroupedPrescription.Prescription(erxTask: erxTask, date: dateToday)
        // when
        store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.prescription = expectedPrescription
            sut.isArchived = true
        }
        testScheduler.advance()
        store.receive(.redeemedOnSavedReceived(true))
        store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.prescription = prescription
            sut.isArchived = false
        }
        testScheduler.advance()
        store.receive(.redeemedOnSavedReceived(true))
    }
}
