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

@MainActor
final class MatrixCodeDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    let mockDMCGenerator = MockErxMatrixCodeGenerator()
    let isDismissInvoked = LockIsolated(false)

    typealias TestStore = TestStoreOf<MatrixCodeDomain>

    func testStore(
        with type: MatrixCodeDomain.MatrixCodeType,
        isZoomedIn: Bool = false
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        let testState = MatrixCodeDomain.State(
            type: type,
            erxTasks: [ErxTask.Fixtures.erxTaskRedeemed],
            erxChargeItem: ErxChargeItem.Fixtures.chargeItem1,
            isZoomedIn: isZoomedIn
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
        }
    }

    /// Use DMC publisher to generate an exact same image
    func generateMockDMCImage() -> UIImage {
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
        return generatedImage!
    }

    /// Tests the case when DMC code for scanned/low-detail prescriptions is generated and a redeemedOn
    /// date is set.
    func testGenerateErxTaskDataMatrixCodeAndRedeemedOnSaveReceived() async {
        let store = testStore(with: .erxTask)

        let expected: LoadingState<UIImage, MatrixCodeDomain.LoadingImageError> =
            .value(generateMockDMCImage())

        // when
        await store.send(.loadMatrixCodeImage(screenSize: CGSize(width: 400, height: 800)))
        await testScheduler.advance()
        await store.receive(.response(.matrixCodeImageReceived(expected))) { sut in
            sut.loadingState = expected
        }
        await store.receive(.response(.redeemedOnSavedReceived(false)))
    }

    func testGenerateErxChargeItemDataMatrixCodeDoesNotRedeem() async {
        let store = testStore(with: .erxChargeItem)

        let expected: LoadingState<UIImage, MatrixCodeDomain.LoadingImageError> =
            .value(generateMockDMCImage())

        // when
        await store.send(.loadMatrixCodeImage(screenSize: CGSize(width: 400, height: 800)))
        await testScheduler.advance()
        await store.receive(.response(.matrixCodeImageReceived(expected))) { sut in
            sut.loadingState = expected
        }
    }

    func testZoomDataMatrixCode() async {
        let store = testStore(with: .erxTask)

        await store.send(.zoomButtonTapped) {
            $0.isZoomedIn = true
        }
    }

    func testCloseZoomDataMatrixCode() async {
        let store = testStore(with: .erxTask, isZoomedIn: true)

        await store.send(.closeZoomTapped) {
            $0.isZoomedIn = false
        }
    }

    func testCloseMatrixCodeView() async {
        let store = testStore(with: .erxTask)

        await store.send(.closeButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, true)
    }
}
