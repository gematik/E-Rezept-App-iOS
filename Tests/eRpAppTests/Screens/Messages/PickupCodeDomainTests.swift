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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class PickupCodeDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    let matrixCodeGenerator = MockMatrixCodeGenerator()

    typealias TestStore = ComposableArchitecture.TestStore<
        PickupCodeDomain.State,
        PickupCodeDomain.State,
        PickupCodeDomain.Action,
        PickupCodeDomain.Action,
        PickupCodeDomain.Environment
    >

    private func testStore(for state: PickupCodeDomain.State) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        return TestStore(
            initialState: state,
            reducer: PickupCodeDomain.reducer,
            environment: PickupCodeDomain.Environment(
                schedulers: schedulers,
                matrixCodeGenerator: matrixCodeGenerator
            )
        )
    }

    func testWithHRCodeOnly() {
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(pickupCodeHR: "4711"))
        store.assert(
            .send(.loadMatrixCodeImage(screenSize: size)) {
                $0.pickupCodeHR = "4711"
                $0.pickupCodeDMC = nil
                $0.dmcImage = nil
                expect(self.matrixCodeGenerator.generateImageCallsCount) == 0
            }
        )
    }

    /// Use DMC publisher to generate an exact same image
    private func generateMockDMCImage() -> UIImage {
        var generatedImage: UIImage?
        _ = matrixCodeGenerator.publishedMatrixCode(
            for: "Data Matrix Code Content",
            with: CGSize(width: 200, height: 200)
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { image in
                generatedImage = image
            }
        )
        return generatedImage!
    }

    func testWithDMCCodeOnly() {
        let expectedImage = generateMockDMCImage()
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(pickupCodeDMC: "Data Matrix Code Content", dmcImage: nil))
        store.assert(
            .send(.loadMatrixCodeImage(screenSize: size)) {
                $0.pickupCodeHR = nil
                $0.pickupCodeDMC = "Data Matrix Code Content"
                $0.dmcImage = nil
            },
            .do { self.testScheduler.advance() },
            .receive(.matrixCodeImageReceived(expectedImage)) {
                $0.pickupCodeHR = nil
                $0.pickupCodeDMC = "Data Matrix Code Content"
                $0.dmcImage = expectedImage
                expect(self.matrixCodeGenerator.generateImageCallsCount) == 2
            }
        )
    }

    func testWithHRCodeAndDMCCode() {
        let expectedImage = generateMockDMCImage()
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(
            pickupCodeHR: "4711",
            pickupCodeDMC: "Data Matrix Code Content",
            dmcImage: nil
        ))
        store.assert(
            .send(.loadMatrixCodeImage(screenSize: size)) {
                $0.pickupCodeHR = "4711"
                $0.pickupCodeDMC = "Data Matrix Code Content"
                $0.dmcImage = nil
            },
            .do { self.testScheduler.advance() },
            .receive(.matrixCodeImageReceived(expectedImage)) {
                $0.pickupCodeHR = "4711"
                $0.pickupCodeDMC = "Data Matrix Code Content"
                $0.dmcImage = expectedImage
                expect(self.matrixCodeGenerator.generateImageCallsCount) == 2
            },
            .send(.loadMatrixCodeImage(screenSize: size)) {
                $0.pickupCodeHR = "4711"
                $0.pickupCodeDMC = "Data Matrix Code Content"
                $0.dmcImage = expectedImage
            }
        )
    }
}
