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

import Combine
import ComposableArchitecture
import Dependencies
@testable import eRpFeatures
import eRpKit
import ErxTaskRepository
import FeatureHelpers
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
        let userSessionContainer = UsersSessionContainerMock()
        userSessionContainer.userSession = MockUserSession()

        return TestStore(initialState: state) {
            ScannerDomain(messageInterval: 0.0)
        } withDependencies: { dependencies in
            dependencies.changeableUserSessionContainer = userSessionContainer
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
        let store = testStore { dependencies in
            dependencies.erxTaskRepository.loadLocalTask = { _, _ in
                Fail(error: ErxRepositoryError.local(.notImplemented)).eraseToAnyPublisher()
            }
        }

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

    func testScanUniversalLink() async throws {
        let mockRouter = RoutingMock()
        let store = testStore { dependencies in
            dependencies.router = mockRouter
        }

        let url = try XCTUnwrap(URL(string: "https://erezept.gematik.de/pharmacies/#tiid=123"))

        expect(mockRouter.routeToEndpointEndpointVoidCallsCount).to(equal(0))
        await store.send(.analyse(scanOutput: [.text(url.absoluteString)])) {
            $0.scanState = .loading(nil)
        }
        await testScheduler.advance()
        expect(mockRouter.routeToEndpointEndpointVoidCallsCount).to(equal(1))
        expect(mockRouter.routeToEndpointEndpointVoidReceivedEndpoint).to(equal(.universalLink(url)))
    }

    func testScanForeignUrlIsIgnored() async throws {
        let mockRouter = RoutingMock()
        let store = testStore { dependencies in
            dependencies.router = mockRouter
        }

        let foreignUrl = try XCTUnwrap(URL(string: "https://example.com/some-page"))

        expect(mockRouter.routeToEndpointEndpointVoidCallsCount).to(equal(0))
        expect(self.isDismissInvoked.value).to(beFalse())

        await store.send(.analyse(scanOutput: [.text(foreignUrl.absoluteString)]))
        await testScheduler.advance()

        // Verify that router was NOT called and dismiss was NOT invoked
        expect(mockRouter.routeToEndpointEndpointVoidCallsCount).to(equal(0))
        expect(self.isDismissInvoked.value).to(beFalse())
    }

    func testScanSupportedUniversalLinks() async throws {
        let supportedUrls: [URL] = try [
            XCTUnwrap(URL(string: "https://erezept.gematik.de/extauth")),
            XCTUnwrap(URL(string: "https://erezept.gematik.de/pharmacies/index.html")),
            XCTUnwrap(URL(string: "https://erezept.gematik.de/pharmacies")),
            XCTUnwrap(URL(string: "https://erezept.gematik.de/prescription")),
        ]

        for url in supportedUrls {
            // Create a fresh store for each test to avoid dismissed store issues
            let mockRouter = RoutingMock()
            let store = testStore { dependencies in
                dependencies.router = mockRouter
            }
            isDismissInvoked.setValue(false)

            await store.send(.analyse(scanOutput: [.text(url.absoluteString)])) {
                $0.scanState = .loading(nil)
            }
            await testScheduler.advance()

            // Verify router was called for supported URL
            expect(mockRouter.routeToEndpointEndpointVoidCallsCount).to(equal(1))
            expect(mockRouter.routeToEndpointEndpointVoidReceivedEndpoint).to(equal(.universalLink(url)))
            expect(self.isDismissInvoked.value).to(beTrue())
        }
    }

    func testScanUnsupportedUniversalLinkPathsAreIgnored() async throws {
        let unsupportedUrls: [URL] = try [
            XCTUnwrap(URL(string: "https://erezept.gematik.de/unknown")),
            XCTUnwrap(URL(string: "https://erezept.gematik.de/some/other/path")),
            XCTUnwrap(URL(string: "https://example.org/pharmacies")), // wrong domain but correct path
            XCTUnwrap(URL(string: "https://erezept.gematik.de/")), // root path
        ]

        for url in unsupportedUrls {
            // Create a fresh store for each test
            let mockRouter = RoutingMock()
            let store = testStore { dependencies in
                dependencies.router = mockRouter
            }
            isDismissInvoked.setValue(false)

            // State changes to loading initially, but URL is then ignored, so it's set to idle
            await store.send(.analyse(scanOutput: [.text(url.absoluteString)]))
            await testScheduler.advance()

            // Verify router was NOT called for unsupported URL
            expect(mockRouter.routeToEndpointEndpointVoidCallsCount).to(equal(0))
            expect(self.isDismissInvoked.value).to(beFalse())
        }
    }

    func testScanStateAfterTwoEqualValidScanToBeOneResult() async {
        let expectedState = ScannerDomain.State(
            scanState: .value(scannedTasks),
            acceptedTaskBatches: Set([scannedTasks])
        )
        let store = testStore { dependencies in
            dependencies.erxTaskRepository.loadLocalTask = { _, _ in
                Fail(error: ErxRepositoryError.local(.notImplemented)).eraseToAnyPublisher()
            }
        }

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

        // return some fake task as already stored
        store.dependencies.erxTaskRepository.loadLocalTask = { _, _ in
            Just(ErxTask.Demo.erxTask1).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        }

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

    func testScanStateToBeSuccessWhenScanningCodesWhereOneIsAlreadyInStore() async throws {
        // scan output with one task already saved in store and new tasks
        let scanOutput = ScanOutput.text(
            """
            {"urls":["Task/0390f983-1e67-11b2-8555-63bf44e44fb8/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            	 "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
                 "Task/4713/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
            """
        )
        let oldScan = try ScannedErxTask(
            taskString: "Task/0390f983-1e67-11b2-8555-63bf44e44fb8/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"
        )
        let newScan1 = try ScannedErxTask(
            taskString: "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
        let newScan2 = try ScannedErxTask(
            taskString: "Task/4713/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .value([newScan1, newScan2])
        let expectedAcceptedBatches = Set([[newScan1, newScan2]])
        let store = testStore()

        // return some fake task as already stored
        store.dependencies.erxTaskRepository.loadLocalTask = { taskId, _ in
            if taskId == oldScan.id {
                return Just(ErxTask.Demo.erxTask1).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            } else {
                return Just(.none).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
        }

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

    func testScanStateToBeSuccessWhenScanningCodesWhereOneWasAlreadyScanned() async throws {
        // scan output with one task already saved in store and new tasks
        let scanOutput = ScanOutput.text(
            """
            {"urls":["Task/4710/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            	 "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
            	 "Task/4712/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
            """
        )
        let newScan1 = try ScannedErxTask(
            taskString: "Task/4710/$accept?ac=e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"
        )
        let newScan2 = try ScannedErxTask(
            taskString: "Task/4712/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
        let expectedScanState: LoadingState<[ScannedErxTask], ScannerDomain.Error> = .value([newScan1, newScan2])
        var expectedAcceptedBatches = Set([scannedTasks])
        expectedAcceptedBatches.insert([newScan1, newScan2])
        let initialState = ScannerDomain.State(scanState: .idle,
                                               acceptedTaskBatches: Set([scannedTasks]))
        let store = testStore(with: initialState) { dependencies in
            dependencies.erxTaskRepository.loadLocalTask = { _, _ in
                Fail(error: ErxRepositoryError.local(.notImplemented)).eraseToAnyPublisher()
            }
        }

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
        let store = testStore(with: initialState) { dependencies in
            dependencies.erxTaskRepository.loadLocalTask = { _, _ in
                Just(.none).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
            dependencies.erxTaskRepository.saveTask = { _, _ in }
            dependencies.erxTaskRepository.deleteTask = { _, _ in }
        }

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
        let store = testStore(with: initialState)
        let expectedAlert = ScannerDomain.savingAlertState
        store.dependencies.erxTaskRepository.loadLocalTask = { _, _ in
            Just(.none).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        }
        store.dependencies.erxTaskRepository.saveTask = { _, _ in throw savingError }
        store.dependencies.erxTaskRepository.deleteTask = { _, _ in throw savingError }
        // when
        await store.send(.saveAndClose(initialState.acceptedTaskBatches))
        await testScheduler.advance()
        // then
        await store.receive(.response(.saveAndCloseReceived(.failure(savingError)))) { state in
            state.scanState = initialState.scanState
            state.acceptedTaskBatches = initialState.acceptedTaskBatches
            state.destination = .alert(expectedAlert)
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
