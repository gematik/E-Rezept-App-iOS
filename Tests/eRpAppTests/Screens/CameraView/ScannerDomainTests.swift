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
import ComposableArchitecture
import Dependencies
@testable import eRpFeatures
import eRpKit
import Foundation
import Nimble
import XCTest

// swiftlint:disable line_length
@MainActor
final class ScannerDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    let isDismissInvoked = LockIsolated(false)

    typealias TestStore = TestStoreOf<ScannerDomain>

    private func testStore(
        with state: ScannerDomain.State = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: []),
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let userSessionContainer = MockUsersSessionContainer()
        userSessionContainer.userSession = MockUserSession()

        return TestStore(initialState: state) {
            ScannerDomain(messageInterval: 0.0)
        } withDependencies: { dependencies in
            dependencies.changeableUserSessionContainer = userSessionContainer
            dependencies.erxTaskRepository = FakeErxTaskRepository()
            dependencies.fhirDateFormatter = FHIRDateFormatter.shared
            dependencies.schedulers = schedulers
            dependencies.dismiss = DismissEffect { self.isDismissInvoked.setValue(true) }
            prepareDependencies(&dependencies)
        }
    }

    private var scannedString: String {
        """
        {"urls":["Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
        """
    }

    private var scannedOutput: ScanOutput {
        ScanOutput.text(scannedString)
    }

    private var scannedTasks: [ScannedErxTask] {
        try! ScannedErxTask.from(tasks: scannedString)
    }

    func testScanStateAfterFirstValidScanToBeSuccessWithOneResult() async {
        let expectedState = ScannerDomain.State(
            scanState: .value(scannedTasks),
            acceptedTaskBatches: Set([scannedTasks])
        )
        let store = testStore()

        await store.send(.analyse(scanOutput: [scannedOutput])) {
            $0.scanState = .loading(nil)
        }
        await testScheduler.advance()
        await store.receive(.response(.analyseReceived(.value(scannedTasks)))) { state in
            state.scanState = .value(self.scannedTasks)
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
    }

    func testScanUniversalLink() async {
        let mockRouter = MockRouting()
        let store = testStore { dependencies in
            dependencies.router = mockRouter
        }

        let url: URL = "https://erezept.gematik.de/pharmacies/#tiid=123"

        expect(mockRouter.routeToCallsCount).to(equal(0))
        await store.send(.analyse(scanOutput: [.text(url.absoluteString)])) {
            $0.scanState = .loading(nil)
        }
        await testScheduler.advance()
        expect(mockRouter.routeToCallsCount).to(equal(1))
        expect(mockRouter.routeToReceivedEndpoint).to(equal(.universalLink(url)))
    }

    func testScanStateAfterTwoEqualValidScanToBeOneResult() async {
        let expectedState = ScannerDomain.State(
            scanState: .value(scannedTasks),
            acceptedTaskBatches: Set([scannedTasks])
        )
        let store = testStore()

        // when two identivcal codes were scanned
        await store.send(.analyse(scanOutput: [scannedOutput, scannedOutput])) {
            $0.scanState = .loading(nil)
        }
        await testScheduler.advance()
        // then only one should be returned
        await store.receive(.response(.analyseReceived(.value(scannedTasks)))) { state in
            state.scanState = .value(self.scannedTasks)
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
    }

    func testScanStateAfterOneInvalidErxCodeScanToErrorWithWrongFormats() async {
        let invalidScannedOutput = ScanOutput.text(
            """
            {"urls":["wrongFormat"]}
            """
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> =
            .error(.scannedErxTask(ScannedErxTask.Error.format))
        let store = testStore()

        // when a code with a invalid format was scanned
        await store.send(.analyse(scanOutput: [invalidScannedOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        // then no code should be returned and state should be Error.format
        await store.receive(.response(.analyseReceived(expectedScanState))) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = Set([])
        }
        await testScheduler.advance()
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = Set([])
        }
    }

    func testScanStateAfterOneInvalidErxCodeScanToErrorWithEmptyArray() async {
        let invalidScannedOutput = ScanOutput.text(
            """
            {"urls":[]}
            """
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .error(.empty)
        let store = testStore()

        // when an empty code was scanned
        await store.send(.analyse(scanOutput: [invalidScannedOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        // then no code should be returned and state should be empty
        await store.receive(.response(.analyseReceived(expectedScanState))) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = Set([])
        }
        await testScheduler.advance()
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = Set([])
        }
    }

    func testScanStateAfterScanningSameCodeAgainToReturnDuplicateError() async {
        let initialState = ScannerDomain.State(scanState: .idle,
                                               acceptedTaskBatches: Set([scannedTasks]))
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .error(.duplicate)
        let store = testStore(with: initialState)

        // when scanning the same code as already scanned
        await store.send(.analyse(scanOutput: [scannedOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        // then an error of type duplicate should be returned
        await store.receive(.response(.analyseReceived(expectedScanState))) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        await testScheduler.advance()
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
    }

    func testScanStateToBeStoreDuplicateWhenScanningACodeAlreadySaved() async {
        let alreadySavedTaskInStore = ScanOutput.text(
            """
            {"urls":["Task/0390f983-1e67-11b2-8555-63bf44e44fb8/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"]}
            """
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .error(.storeDuplicate)
        let store = testStore()

        // when scanning a code that is already in store
        await store.send(.analyse(scanOutput: [alreadySavedTaskInStore])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        await testScheduler.advance()
        // then an error of type storeDuplicate should be returned
        await store.receive(.response(.analyseReceived(expectedScanState))) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = Set([])
        }
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = Set([])
        }
    }

    func testScanStateToBeSuccessWhenScanningCodesWhereOneIsAlreadyInStore() async {
        // scan output with one task already saved in store and new tasks
        let scanOutput = ScanOutput.text(
            """
            {"urls":["Task/0390f983-1e67-11b2-8555-63bf44e44fb8/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            	 "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
                 "Task/4713/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
            """
        )
        let newScan1 = try! ScannedErxTask(
            taskString: "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
        let newScan2 = try! ScannedErxTask(
            taskString: "Task/4713/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .value([newScan1, newScan2])
        let expectedAcceptedBatches = Set([[newScan1, newScan2]])
        let store = testStore()

        // when scanning a code that is already in store and one that is new
        await store.send(.analyse(scanOutput: [scanOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        await testScheduler.advance()
        // then only the new one should be returned as successful scan
        await store.receive(.response(.analyseReceived(expectedScanState))) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
    }

    func testScanStateToBeSuccessWhenScanningCodesWhereOneWasAlreadyScanned() async {
        // scan output with one task already saved in store and new tasks
        let scanOutput = ScanOutput.text(
            """
            {"urls":["Task/4710/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            	 "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
            	 "Task/4712/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
            """
        )
        let newScan1 = try! ScannedErxTask(
            taskString: "Task/4710/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"
        )
        let newScan2 = try! ScannedErxTask(
            taskString: "Task/4712/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .value([newScan1, newScan2])
        var expectedAcceptedBatches = Set([scannedTasks])
        expectedAcceptedBatches.insert([newScan1, newScan2])
        let initialState = ScannerDomain.State(scanState: .idle,
                                               acceptedTaskBatches: Set([scannedTasks]))
        let store = testStore(with: initialState)

        // when scanning 3 codes where one was previously scanned
        await store.send(.analyse(scanOutput: [scanOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        await testScheduler.advance()
        // then only the new ones should be returned as successful scan and added as separate batch
        await store.receive(.response(.analyseReceived(expectedScanState))) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
        await store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
    }

    @MainActor
    func testSuccessfulSavingAndClosingScannedErxTasks() async {
        // given
        let initialState = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: Set([scannedTasks]))
        let saveErxTaskPublisher = Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let deleteErxTaskPublisher = Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let findPublisher = Just<ErxTask?>(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let repository = MockErxTaskRepository(stored: [],
                                               saveErxTasks: saveErxTaskPublisher,
                                               deleteErxTasks: deleteErxTaskPublisher,
                                               find: findPublisher)
        let store = testStore(with: initialState)
        store.dependencies.erxTaskRepository = repository

        // when
        await store.send(.saveAndClose(initialState.acceptedTaskBatches))
        await testScheduler.advance()
        // then
        await store.receive(.response(.saveAndCloseReceived(.success(true))))
        XCTAssertEqual(isDismissInvoked.value, true)
    }

    func testFailureSavingAndClosingScannedErxTasks() async {
        // given
        let initialState = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: Set([scannedTasks]))
        let savingError: ErxRepositoryError = .local(.notImplemented)
        let saveErxTaskPublisher = Fail<Bool, ErxRepositoryError>(error: savingError).eraseToAnyPublisher()
        let deleteErxTaskPublisher = Fail<Bool, ErxRepositoryError>(error: savingError).eraseToAnyPublisher()
        let findPublisher = Just<ErxTask?>(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let repository = MockErxTaskRepository(stored: [],
                                               saveErxTasks: saveErxTaskPublisher,
                                               deleteErxTasks: deleteErxTaskPublisher,
                                               find: findPublisher)
        let store = testStore(with: initialState)
        store.dependencies.erxTaskRepository = repository
        let expectedAlert = ScannerDomain.savingAlertState

        // when
        await store.send(.saveAndClose(initialState.acceptedTaskBatches))
        await testScheduler.advance()
        // then
        await store.receive(.response(.saveAndCloseReceived(.failure(savingError)))) { state in
            state.scanState = initialState.scanState
            state.acceptedTaskBatches = initialState.acceptedTaskBatches
            state.destination = .alert(expectedAlert)
            expect(repository.saveCalled).to(beTrue())
        }
        await store.send(.destination(.dismiss)) { state in
            state.destination = nil
        }
    }

    func testClosingViewWithScannedErxTasks() async {
        // given
        let initialState = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: Set([scannedTasks]))
        let store = testStore(with: initialState)

        // expectations
        let expectedAlert = ScannerDomain.closeAlertState

        // when touching cancel while having scanned tasks
        await store.send(.closeWithoutSave) {
            // then the expected alert should be display
            $0.scanState = .idle
            $0.destination = .alert(expectedAlert)
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        // when one of the two close buttons is tapped
        await store.send(.destination(.dismiss)) {
            $0.scanState = .idle
            // then the alert state should be nil again
            $0.destination = nil
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
    }
}

// swiftlint:enable line_length
