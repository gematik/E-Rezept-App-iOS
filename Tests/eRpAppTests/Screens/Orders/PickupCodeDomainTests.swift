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
import Nimble
import XCTest

final class PickupCodeDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var matrixCodeGenerator: MockMatrixCodeGenerator!

    static let testBundleName = "qrcode"

    override func setUp() {
        super.setUp()

        matrixCodeGenerator = MockMatrixCodeGenerator()
        let uiImage = UIImage(testBundleNamed: MockErxTaskMatrixCodeGenerator.testBundleName)!
        let cgImage = uiImage.cgImage!
        matrixCodeGenerator.generateImageForWidthHeightReturnValue = cgImage
    }

    typealias TestStore = ComposableArchitecture.TestStore<
        PickupCodeDomain.State,
        PickupCodeDomain.Action,
        PickupCodeDomain.State,
        PickupCodeDomain.Action,
        Void
    >

    private func testStore(for state: PickupCodeDomain.State) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        return TestStore(
            initialState: state,
            reducer: PickupCodeDomain()
        ) { dependencies in
            dependencies.schedulers = schedulers
            dependencies.matrixCodeGenerator = matrixCodeGenerator
        }
    }

    func testWithHRCodeOnly() {
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(pickupCodeHR: "4711"))

        store.send(.loadMatrixCodeImage(screenSize: size))
    }

    /// Use DMC publisher to generate an exact same image
    private func generateMockDMCImage() -> UIImage {
        var generatedImage: UIImage?
        _ = matrixCodeGenerator.matrixCodePublisher(
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

        store.send(.loadMatrixCodeImage(screenSize: size))
        testScheduler.advance()
        store.receive(.response(.matrixCodeImageReceived(expectedImage))) {
            $0.pickupCodeHR = nil
            $0.pickupCodeDMC = "Data Matrix Code Content"
            $0.dmcImage = expectedImage
            expect(self.matrixCodeGenerator.generateImageForWidthHeightCallsCount) == 2
        }
    }

    func testWithHRCodeAndDMCCode() {
        let expectedImage = generateMockDMCImage()
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(
            pickupCodeHR: "4711",
            pickupCodeDMC: "Data Matrix Code Content",
            dmcImage: nil
        ))
        store.send(.loadMatrixCodeImage(screenSize: size))
        testScheduler.advance()
        store.receive(.response(.matrixCodeImageReceived(expectedImage))) {
            $0.pickupCodeHR = "4711"
            $0.pickupCodeDMC = "Data Matrix Code Content"
            $0.dmcImage = expectedImage
            expect(self.matrixCodeGenerator.generateImageForWidthHeightCallsCount) == 2
        }
        store.send(.loadMatrixCodeImage(screenSize: size))
    }
}
