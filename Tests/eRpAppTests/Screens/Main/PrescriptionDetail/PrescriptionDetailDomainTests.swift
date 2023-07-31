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

import Combine
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class PrescriptionDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    let initialState = PrescriptionDetailDomain.Dummies.state
    let mockErxTaskRepository = MockErxTaskRepository()
    let uiDateFormatter = UIDateFormatter(fhirDateFormatter: FHIRDateFormatter.shared)
    let mockResourceHandler = MockResourceHandler()
    let mockMatrixCodeGenerator = MockErxTaskMatrixCodeGenerator()

    typealias TestStore = ComposableArchitecture.TestStore<
        PrescriptionDetailDomain.State,
        PrescriptionDetailDomain.Action,
        PrescriptionDetailDomain.State,
        PrescriptionDetailDomain.Action,
        Void
    >

    func testStore(_ state: PrescriptionDetailDomain.State? = nil,
                   dateProvider: @escaping (() -> Date) = Date.init) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let userSessionContainer = MockUsersSessionContainer()
        userSessionContainer.userSession = MockUserSession()

        return TestStore(
            initialState: state ?? initialState,
            reducer: PrescriptionDetailDomain()
        ) { dependencies in
            dependencies.changeableUserSessionContainer = userSessionContainer
            dependencies.erxTaskRepository = mockErxTaskRepository
            dependencies.schedulers = schedulers
            dependencies.fhirDateFormatter = FHIRDateFormatter.shared
            dependencies.dateProvider = dateProvider
            dependencies.uiDateFormatter = uiDateFormatter
            dependencies.resourceHandler = mockResourceHandler
            dependencies.erxTaskMatrixCodeGenerator = mockMatrixCodeGenerator
        }
    }

    /// Tests the case when delete was hit but in the alert 'No' was chosen.
    func testCancelDeleteWithAlert() {
        let store = testStore()

        // when
        store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.setNavigation(tag: .none)) { sut in
            // then
            sut.destination = nil
        }
    }

    /// Tests the case when delete was hit and in the alert 'Yes' was chosen.
    func testDeleteWithAlertSuccess() {
        let store = testStore()

        mockErxTaskRepository.deletePublisher = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        // when
        store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.isDeleting = true
            sut.destination = nil
        }
        store.receive(.response(.taskDeletedReceived(Result.success(true)))) { state in
            // then
            state.isDeleting = false
            state.destination = nil
        }
        store.receive(.delegate(.close))
    }

    /// Tests the case when delete was hit and deletion has failed when not being logged in
    func testDeleteWhenNotLoggedIn() {
        let store = testStore()
        let expectedError = ErxRepositoryError.remote(.fhirClientError(IDPError.tokenUnavailable))
        mockErxTaskRepository.deletePublisher = Fail(error: expectedError).eraseToAnyPublisher()
        // when
        store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.destination = nil
            sut.isDeleting = true
        }
        store.receive(.response(.taskDeletedReceived(
            Result.failure(expectedError)
        ))) { state in
            // then
            state.destination = .alert(PrescriptionDetailDomain.missingTokenAlertState())
            state.isDeleting = false
        }
        store.send(.setNavigation(tag: .none)) { state in
            state.destination = nil
        }

        store.send(.delegate(.close))
    }

    /// Tests the case when delete was hit and deletion has failed with other errors.
    func testDeleteWithOtherErrorMessage() {
        let store = testStore()
        let expectedError = ErxRepositoryError.local(.notImplemented)
        mockErxTaskRepository.deletePublisher = Fail(error: expectedError).eraseToAnyPublisher()

        // when
        store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.confirmDeleteAlertState)
        }
        store.send(.confirmedDelete) { sut in
            // then
            sut.isDeleting = true
            sut.destination = nil
        }
        store.receive(.response(.taskDeletedReceived(
            Result.failure(ErxRepositoryError.local(.notImplemented))
        ))) { state in
            // then
            state.isDeleting = false
            state.destination = .alert(
                PrescriptionDetailDomain.deleteFailedAlertState(
                    error: ErxRepositoryError.local(.notImplemented),
                    localizedError: ErxRepositoryError.local(.notImplemented).localizedDescriptionWithErrorList
                )
            )
        }
        store.send(.setNavigation(tag: nil)) { state in
            state.destination = nil
        }
        store.send(.delegate(.close))
    }

    func testDeletingPrescriptionInProgress() {
        let prescription = Prescription(
            erxTask: ErxTask.Fixtures.erxTaskInProgressAndValid,
            dateFormatter: UIDateFormatter.testValue
        )
        let sut = testStore(.init(
            prescription: prescription,
            isArchived: true
        ))

        sut.send(.delete) {
            $0.destination = .alert(ErpAlertState(
                title: L10n.dtlBtnDeleteDisabledNote,
                actions: {
                    ButtonState(role: .cancel, action: .setNavigation(tag: .none)) {
                        .init(L10n.alertBtnOk)
                    }
                }
            ))
        }
    }

    func testDeletingPrescriptionWithDirectAssignemnt() {
        let prescription = Prescription(
            erxTask: ErxTask.Fixtures.erxTaskDirectAssigned,
            dateFormatter: UIDateFormatter.testValue
        )
        let sut = testStore(.init(
            prescription: prescription,
            isArchived: true
        ))

        sut.send(.delete) {
            $0.destination = .alert(ErpAlertState(
                title: L10n.prscDeleteNoteDirectAssignment,
                actions: {
                    ButtonState(role: .cancel, action: .setNavigation(tag: .none)) {
                        .init(L10n.alertBtnOk)
                    }
                }
            ))
        }
    }

    /// Test redeem low-detail prescriptions.
    func testManualRedeemScannedTaskWithoutCommunicationsOrAvsTransactions() {
        let dateToday = Date()
        var erxTask = ErxTask.Fixtures.scannedTask
        let store = testStore(
            .init(
                prescription: Prescription(erxTask: erxTask, dateFormatter: UIDateFormatter.testValue),
                isArchived: false
            ),
            dateProvider: { dateToday }
        )

        let expectedRedeemDate = FHIRDateFormatter.shared.stringWithLongUTCTimeZone(from: dateToday)
        let prescription = Prescription(erxTask: erxTask, date: dateToday, dateFormatter: UIDateFormatter.testValue)
        erxTask.update(with: expectedRedeemDate)
        let expectedPrescription = Prescription(
            erxTask: erxTask,
            date: dateToday,
            dateFormatter: UIDateFormatter.testValue
        )
        mockErxTaskRepository.savePublisher = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        // when
        store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.prescription = expectedPrescription
            sut.isArchived = true
        }
        store.receive(.response(.redeemedOnSavedReceived(true)))
        store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.prescription = prescription
            sut.isArchived = false
        }
        store.receive(.response(.redeemedOnSavedReceived(true)))
    }

    func testManualRedeemScannedTaskWithAVSTransaction() {
        let dateToday = Date()
        // given a scanned tasks that has been redeemed (via avs) before
        let erxTask = ErxTask.Fixtures.scannedTaskWithAVSTransaction
        let store = testStore(
            .init(
                prescription: Prescription(erxTask: erxTask, dateFormatter: UIDateFormatter.testValue),
                isArchived: true
            ),
            dateProvider: { dateToday }
        )

        // when trying to toggle the state manually
        store.send(.toggleRedeemPrescription)
        // then no state change should be allowed
    }

    func testManualRedeemARemoteTask() {
        let dateToday = Date()
        // given a tasks that has been loaded from fachdienst
        let store = testStore(dateProvider: { dateToday })

        // when trying to toggle the state manually
        store.send(.toggleRedeemPrescription)
        // then no state change should be allowed
    }

    func testShowDirectAssignmentInfo() {
        let sut = testStore()

        sut.send(.setNavigation(tag: .directAssignmentInfo)) {
            $0.destination = .directAssignmentInfo
        }
    }

    func testShowEmergencyServiceFeeInfo() {
        let sut = testStore()

        sut.send(.setNavigation(tag: .emergencyServiceFeeInfo)) {
            $0.destination = .emergencyServiceFeeInfo
        }
    }

    func testShowCoPaymentInfo() {
        let erxTaskWithSubjectToChargeStatus = ErxTask.Fixtures.erxTask3
        let sut = testStore(
            .init(
                prescription: Prescription(
                    erxTask: erxTaskWithSubjectToChargeStatus,
                    dateFormatter: UIDateFormatter.testValue
                ),
                isArchived: false
            )
        )
        let expectedCoPaymentState = PrescriptionDetailDomain.Destinations
            .CoPaymentState(status: erxTaskWithSubjectToChargeStatus.medicationRequest.coPaymentStatus!)

        sut.send(.setNavigation(tag: .coPaymentInfo)) {
            $0.destination = .coPaymentInfo(expectedCoPaymentState)
        }
    }

    func testNotShowingCoPaymentInfo() {
        let taskWithoutCoPaymentInfo = ErxTask.Fixtures.erxTask12
        let sut = testStore(
            .init(
                prescription: Prescription(erxTask: taskWithoutCoPaymentInfo, dateFormatter: UIDateFormatter.testValue),
                isArchived: false
            )
        )

        // then no state change expected
        sut.send(.setNavigation(tag: .coPaymentInfo))
    }

    func testShowCoPaymentInfoState_noCharge() {
        let erxTaskWithNoSubjectToChargeStatus = ErxTask.Fixtures.erxTask2
        let sut = testStore(
            .init(
                prescription: Prescription(
                    erxTask: erxTaskWithNoSubjectToChargeStatus,
                    dateFormatter: UIDateFormatter.testValue
                ),
                isArchived: false
            )
        )
        let expectedCoPaymentState = PrescriptionDetailDomain.Destinations
            .CoPaymentState(status: erxTaskWithNoSubjectToChargeStatus.medicationRequest.coPaymentStatus!)

        sut.send(.setNavigation(tag: .coPaymentInfo)) {
            $0.destination = .coPaymentInfo(expectedCoPaymentState)
        }
    }

    func testOpenUrlGesundBundDe() {
        let sut = testStore()
        mockResourceHandler.canOpenURLReturnValue = true

        expect(self.mockResourceHandler.canOpenURLCalled).to(beFalse())
        sut.send(.openUrlGesundBundDe)
        expect(self.mockResourceHandler.canOpenURLCalled).to(beTrue())
        expect(self.mockResourceHandler.canOpenURLCalled).to(beTrue())
    }

    func testShowPrescriptionValidityInfo() {
        let sut = testStore()
        let expectedValidityInfo = PrescriptionDetailDomain.Destinations.PrescriptionValidityState(
            authoredOnDate: uiDateFormatter.date(initialState.prescription.authoredOn),
            acceptUntilDate: uiDateFormatter.date(initialState.prescription.acceptedUntil),
            expiresOnDate: uiDateFormatter.date(initialState.prescription.expiresOn)
        )

        sut.send(.setNavigation(tag: .prescriptionValidityInfo)) {
            $0.destination = .prescriptionValidityInfo(expectedValidityInfo)
        }
    }

    func testShowErrorInfo() {
        let sut = testStore()

        sut.send(.setNavigation(tag: .errorInfo)) {
            $0.destination = .errorInfo
        }
    }

    func testShowSubstitutionInfo() {
        let sut = testStore()

        sut.send(.setNavigation(tag: .substitutionInfo)) {
            $0.destination = .substitutionInfo
        }
    }

    func testShowScannedPrescriptionInfo() {
        let sut = testStore()

        sut.send(.setNavigation(tag: .scannedPrescriptionInfo)) {
            $0.destination = .scannedPrescriptionInfo
        }
    }

    func testLoadingImageAndShowShareSheet() {
        let sut = testStore()
        let expectedUrl = initialState.prescription.erxTask.shareUrl()!
        let expectedImage = mockMatrixCodeGenerator.uiImage
        let expectedLoadingState: LoadingState<UIImage, PrescriptionDetailDomain.LoadingImageError> =
            .value(expectedImage)

        let shareState = PrescriptionDetailDomain.Destinations.ShareState(
            url: expectedUrl,
            dataMatrixCodeImage: expectedImage
        )
        sut.send(.loadMatrixCodeImage(screenSize: CGSize(width: 100.0, height: 100.0))) {
            $0.loadingState = .loading(nil)
        }

        sut.receive(.response(.matrixCodeImageReceived(expectedLoadingState))) {
            $0.loadingState = expectedLoadingState
            $0.destination = .sharePrescription(shareState)
        }
    }

    func testShowTechnicalInformations() {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.TechnicalInformationsState(
            taskId: initialState.prescription.erxTask.identifier,
            accessCode: initialState.prescription.erxTask.accessCode
        )

        sut.send(.setNavigation(tag: .technicalInformations)) {
            $0.destination = .technicalInformations(expectedState)
        }
    }

    func testShowPatient() {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.PatientState(
            patient: initialState.prescription.patient!
        )

        sut.send(.setNavigation(tag: .patient)) {
            $0.destination = .patient(expectedState)
        }
    }

    func testShowPractitioner() {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.PractitionerState(
            practitioner: initialState.prescription.practitioner!
        )

        sut.send(.setNavigation(tag: .practitioner)) {
            $0.destination = .practitioner(expectedState)
        }
    }

    func testShowOrganization() {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.OrganizationState(
            organization: initialState.prescription.organization!
        )

        sut.send(.setNavigation(tag: .organization)) {
            $0.destination = .organization(expectedState)
        }
    }

    func testShowAccidentInfo() {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.AccidentInfoState(
            accidentInfo: initialState.prescription.medicationRequest.accidentInfo!
        )

        sut.send(.setNavigation(tag: .accidentInfo)) {
            $0.destination = .accidentInfo(expectedState)
        }
    }

    func testShowMedication_when_not_dispensed() {
        let sut = testStore()
        let expectedState = MedicationDomain.State(
            subscribed: initialState.prescription.medication!
        )

        sut.send(.setNavigation(tag: .medication)) {
            $0.destination = .medication(expectedState)
        }
    }

    func testShowMedicationOverview_when_dispensed() {
        let redeemedPrescription = Prescription(
            erxTask: ErxTask.Fixtures.erxTaskRedeemed,
            dateFormatter: UIDateFormatter.testValue
        )
        let sut = testStore(.init(prescription: redeemedPrescription, isArchived: true))
        let expectedState = MedicationOverviewDomain.State(
            subscribed: redeemedPrescription.medication!,
            dispensed: redeemedPrescription.medicationDispenses
        )

        sut.send(.setNavigation(tag: .medication)) {
            $0.destination = .medicationOverview(expectedState)
        }
    }
}
