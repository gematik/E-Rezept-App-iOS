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
import Nimble
import XCTest

@MainActor
final class PickupCodeDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var matrixCodeGenerator: MockMatrixCodeGenerator!

    override func setUp() {
        super.setUp()

        matrixCodeGenerator = MockMatrixCodeGenerator()
        let uiImage = Asset.qrcode.image
        let cgImage = uiImage.cgImage!
        matrixCodeGenerator.generateImageForWidthHeightReturnValue = cgImage
    }

    typealias TestStore = TestStoreOf<PickupCodeDomain>

    private func testStore(for state: PickupCodeDomain.State) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        return TestStore(initialState: state) {
            PickupCodeDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.matrixCodeGenerator = matrixCodeGenerator
        }
    }

    func testWithHRCodeOnly() async {
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(pickupCodeHR: "4711"))

        await store.send(.loadMatrixCodeImage(screenSize: size))
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

    func testWithDMCCodeOnly() async {
        let expectedImage = generateMockDMCImage()
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(pickupCodeDMC: "Data Matrix Code Content", dmcImage: nil))

        await store.send(.loadMatrixCodeImage(screenSize: size))
        await testScheduler.advance()
        await store.receive(.response(.matrixCodeImageReceived(expectedImage))) {
            $0.pickupCodeHR = nil
            $0.pickupCodeDMC = "Data Matrix Code Content"
            $0.dmcImage = expectedImage
            expect(self.matrixCodeGenerator.generateImageForWidthHeightCallsCount) == 2
        }
    }

    func testWithHRCodeAndDMCCode() async {
        let expectedImage = generateMockDMCImage()
        let size = CGSize(width: 200, height: 200)
        let store = testStore(for: PickupCodeDomain.State(
            pickupCodeHR: "4711",
            pickupCodeDMC: "Data Matrix Code Content",
            dmcImage: nil
        ))
        await store.send(.loadMatrixCodeImage(screenSize: size))
        await testScheduler.advance()
        await store.receive(.response(.matrixCodeImageReceived(expectedImage))) {
            $0.pickupCodeHR = "4711"
            $0.pickupCodeDMC = "Data Matrix Code Content"
            $0.dmcImage = expectedImage
            expect(self.matrixCodeGenerator.generateImageForWidthHeightCallsCount) == 2
        }
        await store.send(.loadMatrixCodeImage(screenSize: size))
    }
}
