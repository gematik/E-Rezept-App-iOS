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
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Foundation
import Nimble
import XCTest

// swiftlint:disable line_length
final class ScannerDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        ScannerDomain.State,
        ScannerDomain.State,
        ScannerDomain.Action,
        ScannerDomain.Action,
        ScannerDomain.Environment
    >

    private func testStore(
        with state: ScannerDomain.State = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: [])
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        return TestStore(
            initialState: state,
            reducer: ScannerDomain.domainReducer,
            environment: ScannerDomain.Environment(repository: FakeErxTaskRepository(),
                                                   dateFormatter: FHIRDateFormatter.shared,
                                                   messageInterval: 0.0,
                                                   scheduler: schedulers)
        )
    }

    private var scannedString: String {
        """
        {"urls":["Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
        """
    }

    private var scannedOutput: ScanOutput {
        ScanOutput.erxCode(scannedString)
    }

    private var scannedTasks: [ScannedErxTask] {
        try! ScannedErxTask.from(tasks: scannedString)
    }

    func testScanStateAfterFirstValidScanToBeSuccessWithOneResult() {
        let expectedState = ScannerDomain.State(
            scanState: .value(scannedTasks),
            acceptedTaskBatches: Set([scannedTasks])
        )
        let store = testStore()

        store.send(.analyse(scanOutput: [scannedOutput])) {
            $0.scanState = .loading(nil)
        }
        testScheduler.advance()
        store.receive(.analyseReceived(.value(scannedTasks))) { state in
            state.scanState = .value(self.scannedTasks)
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
    }

    func testScanStateAfterTwoEqualValidScanToBeOneResult() {
        let expectedState = ScannerDomain.State(
            scanState: .value(scannedTasks),
            acceptedTaskBatches: Set([scannedTasks])
        )
        let store = testStore()

        // when two identivcal codes were scanned
        store.send(.analyse(scanOutput: [scannedOutput, scannedOutput])) {
            $0.scanState = .loading(nil)
        }
        testScheduler.advance()
        // then only one should be returned
        store.receive(.analyseReceived(.value(scannedTasks))) { state in
            state.scanState = .value(self.scannedTasks)
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedState.acceptedTaskBatches
        }
    }

    func testScanStateAfterOneInvalidErxCodeScanToErrorWithWrongFormats() {
        let invalidScannedOutput = ScanOutput.erxCode(
            """
            {"urls":["wrongFormat"]}
            """
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> =
            .error(.scannedErxTask(ScannedErxTask.Error.format))
        let store = testStore()

        // when a code with a invalid format was scanned
        store.send(.analyse(scanOutput: [invalidScannedOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        // then no code should be returned and state should be Error.format
        store.receive(.analyseReceived(expectedScanState)) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = Set([])
        }
        testScheduler.advance()
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = Set([])
        }
    }

    func testScanStateAfterOneInvalidErxCodeScanToErrorWithEmptyArray() {
        let invalidScannedOutput = ScanOutput.erxCode(
            """
            {"urls":[]}
            """
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .error(.empty)
        let store = testStore()

        // when an empty code was scanned
        store.send(.analyse(scanOutput: [invalidScannedOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        // then no code should be returned and state should be empty
        store.receive(.analyseReceived(expectedScanState)) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = Set([])
        }
        testScheduler.advance()
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = Set([])
        }
    }

    func testScanStateAfterScanningSameCodeAgainToReturnDuplicateError() {
        let initialState = ScannerDomain.State(scanState: .idle,
                                               acceptedTaskBatches: Set([scannedTasks]))
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .error(.duplicate)
        let store = testStore(with: initialState)

        // when scanning the same code as already scanned
        store.send(.analyse(scanOutput: [scannedOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        // then an error of type duplicate should be returned
        store.receive(.analyseReceived(expectedScanState)) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        testScheduler.advance()
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
    }

    func testScanStateToBeStoreDuplicateWhenScanningACodeAlreadySaved() {
        let alreadySavedTaskInStore = ScanOutput.erxCode(
            """
            {"urls":["Task/0390f983-1e67-11b2-8555-63bf44e44fb8/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"]}
            """
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .error(.storeDuplicate)
        let store = testStore()

        // when scanning a code that is already in store
        store.send(.analyse(scanOutput: [alreadySavedTaskInStore])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        testScheduler.advance()
        // then an error of type storeDuplicate should be returned
        store.receive(.analyseReceived(expectedScanState)) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = Set([])
        }
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = Set([])
        }
    }

    func testScanStateToBeSuccessWhenScanningCodesWhereOneIsAlreadyInStore() {
        // scan output with one task already saved in store and new tasks
        let scanOutput = ScanOutput.erxCode(
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
        store.send(.analyse(scanOutput: [scanOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = Set([])
        }
        testScheduler.advance()
        // then only the new one should be returned as successful scan
        store.receive(.analyseReceived(expectedScanState)) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
    }

    func testScanStateToBeSuccessWhenScanningCodesWhereOneWasAlreadyScanned() {
        // scan output with one task already saved in store and new tasks
        let scanOutput = ScanOutput.erxCode(
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
        store.send(.analyse(scanOutput: [scanOutput])) {
            $0.scanState = .loading(nil)
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        testScheduler.advance()
        // then only the new ones should be returned as successful scan and added as separate batch
        store.receive(.analyseReceived(expectedScanState)) { state in
            state.scanState = expectedScanState
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
        store.receive(.resetScannerState) { state in
            state.scanState = .idle
            state.acceptedTaskBatches = expectedAcceptedBatches
        }
    }

    func testSuccessfulSavingAndClosingScannedErxTasks() {
        // given
        let initialState = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: Set([scannedTasks]))
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let saveErxTaskPublisher = Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let deleteErxTaskPublisher = Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let findPublisher = Just<ErxTask?>(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let repository = MockErxTaskRepository(stored: [],
                                               saveErxTasks: saveErxTaskPublisher,
                                               deleteErxTasks: deleteErxTaskPublisher,
                                               find: findPublisher)
        let store = TestStore(
            initialState: initialState,
            reducer: ScannerDomain.domainReducer,
            environment: ScannerDomain.Environment(
                repository: repository,
                dateFormatter: FHIRDateFormatter.shared,
                messageInterval: 0.0,
                scheduler: schedulers
            )
        )

        // when
        store.send(.saveAndClose(initialState.acceptedTaskBatches))
        testScheduler.advance()
        // then
        store.receive(.close)
    }

    func testFailureSavingAndClosingScannedErxTasks() {
        // given
        let initialState = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: Set([scannedTasks]))
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        let savingError: ErxRepositoryError = .local(.notImplemented)
        let saveErxTaskPublisher = Fail<Bool, ErxRepositoryError>(error: savingError).eraseToAnyPublisher()
        let deleteErxTaskPublisher = Fail<Bool, ErxRepositoryError>(error: savingError).eraseToAnyPublisher()
        let findPublisher = Just<ErxTask?>(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let repository = MockErxTaskRepository(stored: [],
                                               saveErxTasks: saveErxTaskPublisher,
                                               deleteErxTasks: deleteErxTaskPublisher,
                                               find: findPublisher)
        let store = TestStore(
            initialState: initialState,
            reducer: ScannerDomain.domainReducer,
            environment: ScannerDomain.Environment(
                repository: repository,
                dateFormatter: FHIRDateFormatter.shared,
                messageInterval: 0.0,
                scheduler: schedulers
            )
        )
        let expectedAlert = ScannerDomain.savingAlertState

        // when
        store.send(.saveAndClose(initialState.acceptedTaskBatches))
        testScheduler.advance()
        // then
        store.receive(.saveAndCloseReceived(savingError)) { state in
            state.scanState = initialState.scanState
            state.acceptedTaskBatches = initialState.acceptedTaskBatches
            state.alertState = expectedAlert
            expect(repository.saveCalled).to(beTrue())
        }
        store.send(.alertDismissButtonTapped) { state in
            state.alertState = nil
        }
    }

    func testClosingViewWithScannedErxTasks() {
        // given
        let initialState = ScannerDomain.State(scanState: .idle, acceptedTaskBatches: Set([scannedTasks]))
        let store = testStore(with: initialState)

        // expectations
        let expectedAlert = ScannerDomain.closeAlertState

        // when touching cancel while having scanned tasks
        store.send(.closeWithoutSave) {
            // then the expected alert should be display
            $0.scanState = .idle
            $0.alertState = expectedAlert
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        // when one of the two close buttons is tapped
        store.send(.alertDismissButtonTapped) {
            $0.scanState = .idle
            // then the alert state should be nil again
            $0.alertState = nil
            $0.acceptedTaskBatches = initialState.acceptedTaskBatches
        }
        // when the ok button is tapped
        store.send(.close)
    }
}

// swiftlint:enable line_length
