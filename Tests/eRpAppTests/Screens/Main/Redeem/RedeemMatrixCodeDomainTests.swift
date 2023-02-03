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

final class RedeemMatrixCodeDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    let mockDMCGenerator = MockErxTaskMatrixCodeGenerator()

    typealias TestStore = ComposableArchitecture.TestStore<
        RedeemMatrixCodeDomain.State,
        RedeemMatrixCodeDomain.Action,
        RedeemMatrixCodeDomain.State,
        RedeemMatrixCodeDomain.Action,
        RedeemMatrixCodeDomain.Environment
    >

    func testStore() -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        let testState = RedeemMatrixCodeDomain.State(
            erxTasks: [ErxTask.Fixtures.erxTaskRedeemed]
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
        return TestStore(
            initialState: testState,
            reducer: RedeemMatrixCodeDomain.reducer,
            environment: RedeemMatrixCodeDomain.Environment(
                schedulers: schedulers,
                matrixCodeGenerator: mockDMCGenerator,
                taskRepository: mockRepository,
                fhirDateFormatter: FHIRDateFormatter.shared
            )
        )
    }

    /// Use DMC publisher to generate an exact same image
    func generateMockDMCImage() -> UIImage {
        var generatedImage: UIImage?
        _ = mockDMCGenerator.publishedMatrixCode(
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
    func testGenerateDataMatrixCodeAndRedeemedOnSaveReceived() {
        let store = testStore()

        let expected: LoadingState<UIImage, RedeemMatrixCodeDomain.LoadingImageError> =
            .value(generateMockDMCImage())

        // when
        store.send(.loadMatrixCodeImage(screenSize: CGSize(width: 400, height: 800)))
        testScheduler.advance()
        store.receive(.matrixCodeImageReceived(expected)) { sut in
            sut.loadingState = expected
        }
        store.receive(.redeemedOnSavedReceived(false))
    }
}
