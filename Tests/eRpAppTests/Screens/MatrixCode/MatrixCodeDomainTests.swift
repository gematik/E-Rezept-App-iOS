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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import XCTest

@MainActor
final class MatrixCodeDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    let mockDMCGenerator = MockErxMatrixCodeGenerator()
    let isDismissInvoked = LockIsolated(false)

    typealias TestStore = TestStoreOf<MatrixCodeDomain>

    func testStore(
        with type: MatrixCodeDomain.MatrixCodeType,
        isMatrixCodeZoomed: Bool = false
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        let testState = MatrixCodeDomain.State(
            type: type,
            erxTasks: [ErxTask.Fixtures.erxTaskRedeemed],
            erxChargeItem: ErxChargeItem.Fixtures.chargeItem1,
            isMatrixCodeZoomed: isMatrixCodeZoomed
        )
        let savingError: ErxRepositoryError = .local(.notImplemented)
        let saveErxTaskPublisher = Fail<Bool, ErxRepositoryError>(error: savingError).eraseToAnyPublisher()
        let deleteErxTaskPublisher = Fail<Bool, ErxRepositoryError>(error: savingError).eraseToAnyPublisher()
        let findPublisher = Just<ErxTask?>(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        let mockRepository = MockErxTaskRepository(
            stored: [],
            saveErxTasks: saveErxTaskPublisher,
            deleteErxTasks: deleteErxTaskPublisher,
            find: findPublisher
        )
        return TestStore(initialState: testState) {
            MatrixCodeDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.erxMatrixCodeGenerator = mockDMCGenerator
            dependencies.erxTaskRepository = mockRepository
            dependencies.fhirDateFormatter = FHIRDateFormatter.shared
            dependencies.dismiss = DismissEffect { self.isDismissInvoked.setValue(true) }
            dependencies.uuid = UUIDGenerator.incrementing
        }
    }

    /// Use DMC publisher to generate an exact same image
    func generateMockDMCImage(uuid: UUID, includeChunk: Bool = true) -> MatrixCodeDomain.State.IdentifiedImage {
        var generatedImage: UIImage?
        _ = mockDMCGenerator.matrixCodePublisher(
            for: [ErxTask.Fixtures.erxTaskRedeemed],
            with: CGSize(width: 400, height: 800)
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { image in
                generatedImage = image
            }
        )
        return .init(
            identifier: uuid,
            image: generatedImage!,
            chunk: includeChunk ? [ErxTask.Fixtures.erxTaskRedeemed] : nil
        )
    }

    /// Tests the case when DMC code for scanned/low-detail prescriptions is generated and a redeemedOn
    /// date is set.
    func testGenerateErxTaskDataMatrixCodeAndRedeemedOnSaveReceived() async {
        let store = testStore(with: .erxTask)

        let expected: MatrixCodeDomain.ImageLoadingState =
            .value(IdentifiedArray(uniqueElements: [generateMockDMCImage(uuid: UUID(0))]))

        // when
        await store.send(.loadMatrixCodeImage(screenSize: CGSize(width: 400, height: 800)))
        await store.receive(.response(.matrixCodeImageReceived(expected))) { sut in
            sut.loadingState = expected
        }
        await store.receive(.response(.redeemedOnSavedReceived(false)))
    }

    func testGenerateErxChargeItemDataMatrixCodeDoesNotRedeem() async {
        let store = testStore(with: .erxChargeItem)

        let expected: MatrixCodeDomain.ImageLoadingState =
            .value(IdentifiedArray(uniqueElements: [generateMockDMCImage(uuid: UUID(0), includeChunk: false)]))

        // when
        await store.send(.loadMatrixCodeImage(screenSize: CGSize(width: 400, height: 800)))
        await store.receive(.response(.matrixCodeImageReceived(expected))) { sut in
            sut.loadingState = expected
        }
    }

    func testZoomDataMatrixCode() async {
        let store = testStore(with: .erxTask)

        await store.send(.zoomButtonTapped) {
            $0.isMatrixCodeZoomed = true
        }

        await store.send(.zoomButtonTapped) {
            $0.isMatrixCodeZoomed = false
        }
    }

    func testShareMatrixCodeView() async {
        let task = ErxTask.Fixtures.erxTaskRedeemed
        let dmcImage = Asset.qrcode.image
        let testState = MatrixCodeDomain.State(
            type: .erxTask,
            erxTasks: [task],
            loadingState: .value(
                [MatrixCodeDomain.State.IdentifiedImage(
                    identifier: UUID(),
                    image: dmcImage,
                    chunk: [task]
                )]
            )
        )

        let store = TestStore(initialState: testState) {
            MatrixCodeDomain()
        }

        await store.send(.shareButtonTapped) {
            $0
                .destination = .sharePrescription(
                    .init(
                        string: L10n.dmcTxtShareMessage(task.medication!.displayName).text,
                        url: URL( // swiftlint:disable:next line_length
                            string: "https://erezept.gematik.de/prescription#%5B%227350f983-1e67-11b2-8555-63bf44e44fb8%7Ce46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24%7CSaflorbl%C3%BCten-Extrakt%20Pulver%20Peroral%22%5D"
                        )!,
                        dataMatrixCodeImage: ImageGenerator.testValue.addCaption(UIImage(), "", "")
                    )
                )
        }
    }

    func testShareMatrixCodeWithError() async {
        let task = ErxTask.Fixtures.erxTaskRedeemed
        let dmcImage = Asset.qrcode.image
        let testState = MatrixCodeDomain.State(
            type: .erxTask,
            erxTasks: [task],
            loadingState: .value(
                [MatrixCodeDomain.State.IdentifiedImage(
                    identifier: UUID(),
                    image: dmcImage,
                    chunk: [task]
                )]
            )
        )

        let store = TestStore(initialState: testState) {
            MatrixCodeDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }

        await store.send(.shareButtonTapped) {
            $0
                .destination = .sharePrescription(
                    .init(
                        string: L10n.dmcTxtShareMessage(task.medication!.displayName).text,
                        url: URL( // swiftlint:disable:next line_length
                            string: "https://erezept.gematik.de/prescription#%5B%227350f983-1e67-11b2-8555-63bf44e44fb8%7Ce46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24%7CSaflorbl%C3%BCten-Extrakt%20Pulver%20Peroral%22%5D"
                        )!,
                        dataMatrixCodeImage: ImageGenerator.testValue.addCaption(UIImage(), "", "")
                    )
                )
        }
        let expectedError = ShareSheetDomain.Error.shareFailure("038.01")
        await store
            .send(.destination(.presented(.sharePrescription(.delegate(ShareSheetDomain.Action.Delegate
                    .close(expectedError)))))) {
                    $0.destination = nil
            }

        await store.receive(.showAlert(expectedError)) {
            $0.destination = .alert(.init(for: expectedError, title: L10n.dmcAlertTitle))
        }
    }

    func testChunkingOfErxTasks() async {
        let tasks = [
            ErxTask.Fixtures.erxTask1,
            ErxTask.Fixtures.erxTask2,
            ErxTask.Fixtures.erxTask3,
            ErxTask.Fixtures.erxTask4,
            ErxTask.Fixtures.erxTask5,
        ]
        let mockRepository = MockErxTaskRepository(
            stored: [],
            saveErxTasks: Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        )

        let store = TestStore(
            initialState: MatrixCodeDomain.State(
                type: .erxTask,
                erxTasks: tasks,
                erxChargeItem: nil,
                loadingState: .idle,
                isMatrixCodeZoomed: false
            )
        ) {
            MatrixCodeDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.erxMatrixCodeGenerator = mockDMCGenerator
            dependencies.erxTaskRepository = mockRepository
            dependencies.fhirDateFormatter = FHIRDateFormatter.shared
            dependencies.uuid = UUIDGenerator.incrementing
        }

        await store.send(.loadMatrixCodeImage(screenSize: CGSize(width: 100, height: 100)))

        let expectedElements: [MatrixCodeDomain.State.IdentifiedImage] = [
            .init(
                identifier: UUID(0),
                image: mockDMCGenerator.uiImage,
                chunk: [
                    ErxTask.Fixtures.erxTask1,
                    ErxTask.Fixtures.erxTask2,
                    ErxTask.Fixtures.erxTask3,
                ]
            ),
            .init(
                identifier: UUID(1),
                image: mockDMCGenerator.uiImage,
                chunk: [
                    ErxTask.Fixtures.erxTask4,
                    ErxTask.Fixtures.erxTask5,
                ]
            ),
        ]
        let expected: MatrixCodeDomain.ImageLoadingState = .value(.init(uniqueElements: expectedElements))
        await store.receive(.response(.matrixCodeImageReceived(expected))) { state in
            state.loadingState = expected
        }

        await store.receive(.response(.redeemedOnSavedReceived(true)))

        await store.finish()
    }
}
