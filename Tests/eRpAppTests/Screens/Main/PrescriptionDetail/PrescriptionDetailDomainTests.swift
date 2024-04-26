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

import Combine
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import XCTest

@MainActor
final class PrescriptionDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    let mockErxTaskRepository = MockErxTaskRepository()
    let uiDateFormatter = UIDateFormatter(fhirDateFormatter: FHIRDateFormatter.shared)
    let mockResourceHandler = MockResourceHandler()
    let mockMatrixCodeGenerator = MockErxMatrixCodeGenerator()

    typealias TestStore = TestStoreOf<PrescriptionDetailDomain>

    func testStore(
        _ state: PrescriptionDetailDomain.State? = nil,
        dateProvider: @escaping (() -> Date) = Date.init,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let userSessionContainer = MockUsersSessionContainer()
        userSessionContainer.userSession = MockUserSession()

        return TestStore(initialState: state ?? Self.Fixtures.prescriptionDetailDomainInitialState) {
            PrescriptionDetailDomain()
        } withDependencies: { dependencies in
            dependencies.changeableUserSessionContainer = userSessionContainer
            dependencies.erxTaskRepository = mockErxTaskRepository
            dependencies.schedulers = schedulers
            dependencies.fhirDateFormatter = FHIRDateFormatter.shared
            dependencies.dateProvider = dateProvider
            dependencies.uiDateFormatter = uiDateFormatter
            dependencies.resourceHandler = mockResourceHandler
            dependencies.erxMatrixCodeGenerator = mockMatrixCodeGenerator

            prepareDependencies(&dependencies)
        }
    }

    /// Tests the case when delete was hit but in the alert 'No' was chosen.
    func testCancelDeleteWithAlert() async {
        let store = testStore()

        // when
        await store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.Alerts.confirmDeleteAlertState)
        }
        await store.send(.setNavigation(tag: .none)) { sut in
            // then
            sut.destination = nil
        }
    }

    /// Tests the case when delete was hit and in the alert 'Yes' was chosen.
    func testDeleteWithAlertSuccess() async {
        let store = testStore()

        mockErxTaskRepository.deletePublisher = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        // when
        await store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.Alerts.confirmDeleteAlertState)
        }
        await store.send(.destination(.presented(.alert(.confirmedDelete)))) { sut in
            // then
            sut.isDeleting = true
            sut.destination = nil
        }
        await store.receive(.response(.taskDeletedReceived(Result.success(true)))) { state in
            // then
            state.isDeleting = false
            state.destination = nil
        }
        await store.receive(.delegate(.close))
    }

    /// Tests the case when delete was hit and deletion has failed when not being logged in
    func testDeleteWhenNotLoggedIn() async {
        let store = testStore()
        let expectedError = ErxRepositoryError
            .remote(.fhirClient(.http(.init(httpClientError: .authentication(IDPError.tokenUnavailable),
                                            operationOutcome: nil))))

        mockErxTaskRepository.deletePublisher = Fail(error: expectedError).eraseToAnyPublisher()
        // when
        await store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.Alerts.confirmDeleteAlertState)
        }
        await store.send(.destination(.presented(.alert(.confirmedDelete)))) { sut in
            // then
            sut.destination = nil
            sut.isDeleting = true
        }
        await store.receive(.response(.taskDeletedReceived(Result.failure(expectedError)))) { state in
            // then
            state.destination = .alert(PrescriptionDetailDomain.Alerts.missingTokenAlertState())
            state.isDeleting = false
        }
        await store.send(.setNavigation(tag: .none)) { state in
            state.destination = nil
        }

        await store.send(.delegate(.close))
    }

    /// Tests the case when delete was hit and deletion has failed with other errors.
    func testDeleteWithOtherErrorMessage() async {
        let store = testStore()
        let expectedError = ErxRepositoryError.local(.notImplemented)
        mockErxTaskRepository.deletePublisher = Fail(error: expectedError).eraseToAnyPublisher()

        // when
        await store.send(.delete) { sut in
            // then
            sut.destination = .alert(PrescriptionDetailDomain.Alerts.confirmDeleteAlertState)
        }
        await store.send(.destination(.presented(.alert(.confirmedDelete)))) { sut in
            // then
            sut.isDeleting = true
            sut.destination = nil
        }
        await store.receive(.response(.taskDeletedReceived(
            Result.failure(ErxRepositoryError.local(.notImplemented))
        ))) { state in
            // then
            state.isDeleting = false
            state.destination = .alert(
                PrescriptionDetailDomain.Alerts.deleteFailedAlertState(
                    error: ErxRepositoryError.local(.notImplemented),
                    localizedError: ErxRepositoryError.local(.notImplemented).localizedDescriptionWithErrorList
                )
            )
        }
        await store.send(.setNavigation(tag: nil)) { state in
            state.destination = nil
        }
        await store.send(.delegate(.close))
    }

    func testDeletingPrescriptionInProgress() async {
        let prescription = Prescription(
            erxTask: ErxTask.Fixtures.erxTaskInProgressAndValid,
            dateFormatter: UIDateFormatter.testValue
        )
        let sut = testStore(.init(
            prescription: prescription,
            isArchived: true
        ))

        await sut.send(.delete) {
            $0.destination = .alert(ErpAlertState(
                title: L10n.dtlBtnDeleteDisabledNote,
                actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                }
            ))
        }
    }

    func testDeletingPrescriptionWithDirectAssignment() async {
        let prescription = Prescription(
            erxTask: ErxTask.Fixtures.erxTaskDirectAssigned,
            dateFormatter: UIDateFormatter.testValue
        )
        let sut = testStore(.init(
            prescription: prescription,
            isArchived: true
        ))

        await sut.send(.delete) {
            $0.destination = .alert(ErpAlertState(
                title: L10n.prscDeleteNoteDirectAssignment,
                actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                }
            ))
        }
    }

    /// Test redeem low-detail prescriptions.
    func testManualRedeemScannedTaskWithoutCommunicationsOrAvsTransactions() async {
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
        await store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.prescription = expectedPrescription
            sut.isArchived = true
        }
        await store.receive(.response(.redeemedOnSavedReceived(true)))
        await store.send(.toggleRedeemPrescription) { sut in
            // then
            sut.prescription = prescription
            sut.isArchived = false
        }
        await store.receive(.response(.redeemedOnSavedReceived(true)))
    }

    func testManualRedeemScannedTaskWithAVSTransaction() async {
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
        await store.send(.toggleRedeemPrescription)
        // then no state change should be allowed
    }

    func testManualRedeemARemoteTask() async {
        let dateToday = Date()
        // given a tasks that has been loaded from fachdienst
        let store = testStore(dateProvider: { dateToday })

        // when trying to toggle the state manually
        await store.send(.toggleRedeemPrescription)
        // then no state change should be allowed
    }

    func testShowDirectAssignmentInfo() async {
        let sut = testStore()

        await sut.send(.setNavigation(tag: .directAssignmentInfo)) {
            $0.destination = .directAssignmentInfo
        }
    }

    func testShowEmergencyServiceFeeInfo() async {
        let sut = testStore()

        await sut.send(.setNavigation(tag: .emergencyServiceFeeInfo)) {
            $0.destination = .emergencyServiceFeeInfo
        }
    }

    func testShowCoPaymentInfo() async {
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

        await sut.send(.setNavigation(tag: .coPaymentInfo)) {
            $0.destination = .coPaymentInfo(expectedCoPaymentState)
        }
    }

    func testNotShowingCoPaymentInfo() async {
        let taskWithoutCoPaymentInfo = ErxTask.Fixtures.erxTask12
        let sut = testStore(
            .init(
                prescription: Prescription(erxTask: taskWithoutCoPaymentInfo, dateFormatter: UIDateFormatter.testValue),
                isArchived: false
            )
        )

        // then no state change expected
        await sut.send(.setNavigation(tag: .coPaymentInfo))
    }

    func testShowCoPaymentInfoState_noCharge() async {
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

        await sut.send(.setNavigation(tag: .coPaymentInfo)) {
            $0.destination = .coPaymentInfo(expectedCoPaymentState)
        }
    }

    func testOpenUrlGesundBundle() async {
        let sut = testStore()
        mockResourceHandler.canOpenURLReturnValue = true

        expect(self.mockResourceHandler.canOpenURLCalled).to(beFalse())
        await sut.send(.openUrlGesundBundDe)
        expect(self.mockResourceHandler.canOpenURLCalled).to(beTrue())
        expect(self.mockResourceHandler.canOpenURLCalled).to(beTrue())
    }

    func testShowPrescriptionValidityInfo() async {
        let sut = testStore()
        let expectedValidityInfo = PrescriptionDetailDomain.Destinations.PrescriptionValidityState(
            acceptBeginDisplayDate: uiDateFormatter.date(sut.state.prescription.authoredOn),
            acceptEndDisplayDate: uiDateFormatter.date(
                sut.state.prescription.acceptedUntil,
                advancedBy: -60 * 60 * 24
            ),
            expiresBeginDisplayDate: uiDateFormatter.date(sut.state.prescription.acceptedUntil),
            expiresEndDisplayDate: uiDateFormatter.date(sut.state.prescription.expiresOn, advancedBy: -60 * 60 * 24)
        )

        await sut.send(.setNavigation(tag: .prescriptionValidityInfo)) {
            $0.destination = .prescriptionValidityInfo(expectedValidityInfo)
        }
    }

    func testShowErrorInfo() async {
        let sut = testStore()

        await sut.send(.setNavigation(tag: .errorInfo)) {
            $0.destination = .errorInfo
        }
    }

    func testShowSubstitutionInfo() async {
        let sut = testStore()

        await sut.send(.setNavigation(tag: .substitutionInfo)) {
            $0.destination = .substitutionInfo
        }
    }

    func testShowScannedPrescriptionInfo() async {
        let sut = testStore()

        await sut.send(.setNavigation(tag: .scannedPrescriptionInfo)) {
            $0.destination = .scannedPrescriptionInfo
        }
    }

    func testLoadingImageAndShowShareSheet() async {
        let sut = testStore()
        let expectedUrl = sut.state.prescription.erxTask.shareUrl()!
        let expectedImage = mockMatrixCodeGenerator.uiImage
        let expectedLoadingState: LoadingState<UIImage, PrescriptionDetailDomain.LoadingImageError> =
            .value(expectedImage)

        let shareState = PrescriptionDetailDomain.Destinations.ShareState(
            url: expectedUrl,
            dataMatrixCodeImage: expectedImage
        )
        await sut.send(.loadMatrixCodeImage(screenSize: CGSize(width: 100.0, height: 100.0))) {
            $0.loadingState = .loading(nil)
        }

        await sut.receive(.response(.matrixCodeImageReceived(expectedLoadingState))) {
            $0.loadingState = expectedLoadingState
            $0.destination = .sharePrescription(shareState)
        }
    }

    func testShowTechnicalInformations() async {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.TechnicalInformationsState(
            taskId: sut.state.prescription.erxTask.identifier,
            accessCode: sut.state.prescription.erxTask.accessCode
        )

        await sut.send(.setNavigation(tag: .technicalInformations)) {
            $0.destination = .technicalInformations(expectedState)
        }
    }

    func testShowPatient() async {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.PatientState(
            patient: sut.state.prescription.patient!
        )

        await sut.send(.setNavigation(tag: .patient)) {
            $0.destination = .patient(expectedState)
        }
    }

    func testShowPractitioner() async {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.PractitionerState(
            practitioner: sut.state.prescription.practitioner!
        )

        await sut.send(.setNavigation(tag: .practitioner)) {
            $0.destination = .practitioner(expectedState)
        }
    }

    func testShowOrganization() async {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.OrganizationState(
            organization: sut.state.prescription.organization!
        )

        await sut.send(.setNavigation(tag: .organization)) {
            $0.destination = .organization(expectedState)
        }
    }

    func testShowAccidentInfo() async {
        let sut = testStore()
        let expectedState = PrescriptionDetailDomain.Destinations.AccidentInfoState(
            accidentInfo: sut.state.prescription.medicationRequest.accidentInfo!
        )

        await sut.send(.setNavigation(tag: .accidentInfo)) {
            $0.destination = .accidentInfo(expectedState)
        }
    }

    func testShowMedication_when_not_dispensed() async {
        let sut = testStore()
        let expectedState = MedicationDomain.State(
            subscribed: sut.state.prescription.medication!
        )

        await sut.send(.setNavigation(tag: .medication)) {
            $0.destination = .medication(expectedState)
        }
    }

    func testShowMedicationOverview_when_dispensed() async {
        let redeemedPrescription = Prescription(
            erxTask: ErxTask.Fixtures.erxTaskRedeemed,
            dateFormatter: UIDateFormatter.testValue
        )
        let sut = testStore(.init(prescription: redeemedPrescription, isArchived: true))
        let expectedState = MedicationOverviewDomain.State(
            subscribed: redeemedPrescription.medication!,
            dispensed: redeemedPrescription.medicationDispenses
        )

        await sut.send(.setNavigation(tag: .medication)) {
            $0.destination = .medicationOverview(expectedState)
        }
    }

    func testUpdateMedicationName() async {
        let dateFormatter = UIDateFormatter.previewValue
        let authoredOn = DemoDate.createDemoDate(.today)
        let expiresOn = DemoDate.createDemoDate(.ninetyTwoDaysAhead)
        let acceptedUntil = DemoDate.createDemoDate(.tomorrow)
        let sut = testStore(
            PrescriptionDetailDomain.State(
                prescription: Prescription(
                    erxTask: Self.Fixtures.erxTaskFixtureWith(
                        erxMedication: Self.Fixtures.medicationFixture,
                        authoredOn: authoredOn,
                        expiresOn: expiresOn,
                        acceptedUntil: acceptedUntil
                    ),
                    dateFormatter: dateFormatter
                ),
                isArchived: false
            )
        )
        let validName = "Hustenbonbons"

        await sut.send(.pencilButtonTapped) { state in
            state.focus = .medicationName
        }

        mockErxTaskRepository.savePublisher = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        let expectedErxTask = Self.Fixtures.erxTaskFixtureWith(
            erxMedication: ErxMedication(
                name: "Hustenbonbons",
                pzn: "06876512",
                amount: ErxMedication.Ratio(
                    numerator: ErxMedication.Quantity(value: "10", unit: "St.")
                ),
                dosageForm: "PUL",
                normSizeCode: "N1",
                batch: .init(
                    lotNumber: "TOTO-5236-VL",
                    expiresOn: "12.12.2024"
                ),
                packaging: "Box",
                manufacturingInstructions: "Anleitung beiliegend",
                ingredients: []
            ),
            authoredOn: authoredOn,
            expiresOn: expiresOn,
            acceptedUntil: acceptedUntil
        )

        await sut.send(.setName(validName)) { state in
            state.prescription = Prescription(
                erxTask: expectedErxTask,
                dateFormatter: dateFormatter
            )
        }

        await sut.receive(.response(.changeNameReceived(.success(expectedErxTask))))

        expect(self.mockErxTaskRepository.saveCalled).to(beTrue())
        expect(self.mockErxTaskRepository.saveCallsCount).to(equal(1))

        // Set name again but now the repo returns an error
        let error = ErxRepositoryError.remote(.notImplemented)
        mockErxTaskRepository.savePublisher = Fail(outputType: Bool.self, failure: error).eraseToAnyPublisher()

        await sut.send(.setName("Hustenbonbonssss")) { state in
            state.prescription = Prescription(
                erxTask: Self.Fixtures.erxTaskFixtureWith(
                    erxMedication: ErxMedication(
                        name: "Hustenbonbonssss",
                        pzn: "06876512",
                        amount: ErxMedication.Ratio(
                            numerator: ErxMedication.Quantity(value: "10", unit: "St.")
                        ),
                        dosageForm: "PUL",
                        normSizeCode: "N1",
                        batch: .init(
                            lotNumber: "TOTO-5236-VL",
                            expiresOn: "12.12.2024"
                        ),
                        packaging: "Box",
                        manufacturingInstructions: "Anleitung beiliegend",
                        ingredients: []
                    ),
                    authoredOn: authoredOn,
                    expiresOn: expiresOn,
                    acceptedUntil: acceptedUntil
                ),
                dateFormatter: dateFormatter
            )
        }

        await sut.receive(.response(.changeNameReceived(Result.failure(error)))) { state in
            state.destination = .alert(PrescriptionDetailDomain.Alerts.changeNameReceivedAlertState(error: error))
        }
        expect(self.mockErxTaskRepository.saveCallsCount).to(equal(2))
    }

    func testUpdateMedicationNameEmptyFailure() async {
        let sut = testStore()
        let invalidName = " "

        await sut.send(.setName(invalidName))

        expect(self.mockErxTaskRepository.saveCalled).to(beFalse())
    }

    func testMedicationReminderButtonTapped_medicationReminderParser() async {
        // given
        let medicationSchedule = Self.Fixtures.medicationSchedule
        let sut = testStore(
            withDependencies: { dependencies in
                dependencies.medicationReminderParser = MedicationReminderParser(parse: { _ in
                    medicationSchedule
                })
            }
        )

        // then
        await sut.send(.setNavigation(tag: .medicationReminder)) {
            $0.destination = .medicationReminder(.init(medicationSchedule: medicationSchedule))
        }
    }

    func testMedicationReminderButtonTapped_existingMedicationReminder() async {
        // given
        let medicationSchedule = Self.Fixtures.medicationSchedule
        let sut = testStore(
            .init(prescription: .init(
                erxTask: .init(
                    identifier: "identifier",
                    status: .ready,
                    medicationSchedule: medicationSchedule
                ),
                dateFormatter: UIDateFormatter.previewValue
            ),
            isArchived: false)
        )

        // then
        await sut.send(.setNavigation(tag: .medicationReminder)) {
            $0.destination = .medicationReminder(.init(medicationSchedule: medicationSchedule))
        }
    }
}

extension PrescriptionDetailDomainTests {
    enum Fixtures {
        static let medicationFixture = ErxMedication(
            name: "Saflorblüten-Extrakt Pulver Peroral",
            pzn: "06876512",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "10", unit: "St.")
            ),
            dosageForm: "PUL",
            normSizeCode: "N1",
            batch: .init(
                lotNumber: "TOTO-5236-VL",
                expiresOn: "12.12.2024"
            ),
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static func erxTaskFixtureWith(
            erxMedication: ErxMedication,
            authoredOn: String?,
            expiresOn: String?,
            acceptedUntil: String?
        ) -> ErxTask {
            ErxTask(
                identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOn,
                expiresOn: expiresOn,
                acceptedUntil: acceptedUntil,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: erxMedication,
                medicationRequest: .init(
                    substitutionAllowed: true,
                    hasEmergencyServiceFee: true,
                    accidentInfo: AccidentInfo(
                        type: .workAccident,
                        workPlaceIdentifier: "1234567890",
                        date: "9.4.2021"
                    ),
                    coPaymentStatus: .subjectToCharge
                ),
                patient: ErxPatient(
                    name: "Ludger Königsstein",
                    address: "Musterstr. 1 \n10623 Berlin",
                    birthDate: "22.6.1935",
                    phone: "555 1234567",
                    status: "Mitglied",
                    insurance: "AOK Rheinland/Hamburg",
                    insuranceId: "A123456789"
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. Dr. med. Carsten van Storchhausen",
                    qualification: "Allgemeinarzt/Hausarzt",
                    email: "noreply@google.de",
                    address: "Hinter der Bahn 2\n12345 Berlin"
                ),
                organization: ErxOrganization(
                    identifier: "987654321",
                    name: "Praxis van Storchhausen",
                    phone: "555 76543321",
                    email: "noreply@praxisvonstorchhausen.de",
                    address: "Vor der Bahn 6\n54321 Berlin"
                )
            )
        }

        static let prescriptionDetailDomainStateFixture = PrescriptionDetailDomain.State(
            prescription: Prescription(
                erxTask: ErxTask(
                    identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                    status: .ready,
                    accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                    fullUrl: nil,
                    authoredOn: DemoDate.createDemoDate(.today),
                    expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
                    acceptedUntil: DemoDate.createDemoDate(.tomorrow),
                    author: "Dr. Dr. med. Carsten van Storchhausen",
                    medication: medicationFixture,
                    medicationRequest: .init(
                        substitutionAllowed: true,
                        hasEmergencyServiceFee: true,
                        accidentInfo: AccidentInfo(
                            type: .workAccident,
                            workPlaceIdentifier: "1234567890",
                            date: "9.4.2021"
                        ),
                        coPaymentStatus: .subjectToCharge
                    ),
                    patient: ErxPatient(
                        name: "Ludger Königsstein",
                        address: "Musterstr. 1 \n10623 Berlin",
                        birthDate: "22.6.1935",
                        phone: "555 1234567",
                        status: "Mitglied",
                        insurance: "AOK Rheinland/Hamburg",
                        insuranceId: "A123456789"
                    ),
                    practitioner: ErxPractitioner(
                        lanr: "123456789",
                        name: "Dr. Dr. med. Carsten van Storchhausen",
                        qualification: "Allgemeinarzt/Hausarzt",
                        email: "noreply@google.de",
                        address: "Hinter der Bahn 2\n12345 Berlin"
                    ),
                    organization: ErxOrganization(
                        identifier: "987654321",
                        name: "Praxis van Storchhausen",
                        phone: "555 76543321",
                        email: "noreply@praxisvonstorchhausen.de",
                        address: "Vor der Bahn 6\n54321 Berlin"
                    )
                ),
                dateFormatter: UIDateFormatter.previewValue
            ),
            isArchived: false
        )

        static let prescriptionDetailDomainInitialState = PrescriptionDetailDomain.State(
            prescription: Prescription(
                erxTask: ErxTask(
                    identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                    status: .ready,
                    accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                    fullUrl: nil,
                    authoredOn: DemoDate.createDemoDate(.today),
                    expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
                    acceptedUntil: DemoDate.createDemoDate(.tomorrow),
                    author: "Dr. Dr. med. Carsten van Storchhausen",
                    medication: ErxMedication(
                        name: "Saflorblüten-Extrakt Pulver Peroral",
                        pzn: "06876512",
                        amount: ErxMedication.Ratio(
                            numerator: ErxMedication.Quantity(value: "10", unit: "St.")
                        ),
                        dosageForm: "PUL",
                        normSizeCode: "N1",
                        batch: .init(
                            lotNumber: "TOTO-5236-VL",
                            expiresOn: "12.12.2024"
                        ),
                        packaging: "Box",
                        manufacturingInstructions: "Anleitung beiliegend",
                        ingredients: []
                    ),
                    medicationRequest: .init(
                        substitutionAllowed: true,
                        hasEmergencyServiceFee: true,
                        accidentInfo: AccidentInfo(
                            type: .workAccident,
                            workPlaceIdentifier: "1234567890",
                            date: "9.4.2021"
                        ),
                        coPaymentStatus: .subjectToCharge
                    ),
                    patient: ErxPatient(
                        name: "Ludger Königsstein",
                        address: "Musterstr. 1 \n10623 Berlin",
                        birthDate: "22.6.1935",
                        phone: "555 1234567",
                        status: "Mitglied",
                        insurance: "AOK Rheinland/Hamburg",
                        insuranceId: "A123456789"
                    ),
                    practitioner: ErxPractitioner(
                        lanr: "123456789",
                        name: "Dr. Dr. med. Carsten van Storchhausen",
                        qualification: "Allgemeinarzt/Hausarzt",
                        email: "noreply@google.de",
                        address: "Hinter der Bahn 2\n12345 Berlin"
                    ),
                    organization: ErxOrganization(
                        identifier: "987654321",
                        name: "Praxis van Storchhausen",
                        phone: "555 76543321",
                        email: "noreply@praxisvonstorchhausen.de",
                        address: "Vor der Bahn 6\n54321 Berlin"
                    )
                ),
                dateFormatter: UIDateFormatter.previewValue
            ),
            isArchived: false
        )

        static let medicationSchedule = MedicationSchedule(
            id: UUID(0),
            start: Date(),
            end: Date().addingTimeInterval(60 * 60 * 24 * 7),
            title: "dummy",
            dosageInstructions: "schedule",
            taskId: "1234.5678.9012",
            isActive: true,
            entries: [
                .init(
                    id: UUID(1),
                    title: "1",
                    hourComponent: 8,
                    minuteComponent: 0,
                    dosageForm: "Dosage",
                    amount: "2"
                ),
            ]
        )
    }
}
