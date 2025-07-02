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
@testable import eRpFeatures
import HealthCardControl
import Nimble
import TestUtils
import XCTest

@MainActor
final class HealthCardPasswordReadCardDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<HealthCardPasswordReadCardDomain>

    var mockNFCSessionController: MockNFCHealthCardPasswordController!

    let uiScheduler = DispatchQueue.test
    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: self.uiScheduler.eraseToAnyScheduler()
        )
    }()

    override func setUp() {
        super.setUp()

        mockNFCSessionController = MockNFCHealthCardPasswordController()
    }

    func testStore(for state: HealthCardPasswordReadCardDomain.State) -> TestStore {
        .init(initialState: state) {
            HealthCardPasswordReadCardDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.nfcHealthCardPasswordController = mockNFCSessionController
        }
    }

    func testUnlockCard_Success() async throws {
        let sut = testStore(
            for: .init(mode: .healthCardResetPinCounterNoNewSecret(can: "123123", puk: "12345678"))
        )

        mockNFCSessionController
            .resetEgkMrPinRetryCounterCanPukModeReturnValue = .success(NFCHealthCardPasswordControllerResponse.success)

        await sut.send(.readCard)
        await uiScheduler.advance()
        await sut.receive(.response(.nfcHealthCardPasswordControllerResponseReceived(.success))) {
            $0.destination = .alert(HealthCardPasswordReadCardDomain.AlertStates.cardUnlocked)
        }

        await sut.send(.destination(.presented(.alert(.settings)))) {
            $0.destination = nil
        }
        await uiScheduler.run()
        await sut.receive(.delegate(.navigateToSettings))
    }

    func testSetNewPin_Success() async {
        let sut = testStore(
            for: .init(
                mode: .healthCardSetNewPinSecret(can: "123123", oldPin: "123456", newPin: "654321")
            )
        )

        mockNFCSessionController.changeReferenceDataCanOldNewModeReturnValue = .success(.success)

        await sut.send(.readCard)
        await uiScheduler.advance()
        await sut.receive(.response(.nfcHealthCardPasswordControllerResponseReceived(.success))) {
            $0.destination = .alert(HealthCardPasswordReadCardDomain.AlertStates.setNewPin)
        }

        await sut.send(.destination(.presented(.alert(.settings)))) {
            $0.destination = nil
        }
        await uiScheduler.run()
        await sut.receive(.delegate(.navigateToSettings))
    }

    func testSetNewPin_PinCounterExhausted() async {
        let sut = testStore(
            for: .init(
                mode: .healthCardSetNewPinSecret(can: "123123", oldPin: "123456", newPin: "654321")
            )
        )

        mockNFCSessionController.changeReferenceDataCanOldNewModeReturnValue = .success(.commandBlocked)

        await sut.send(.readCard)
        await uiScheduler.advance()
        await sut.receive(.response(.nfcHealthCardPasswordControllerResponseReceived(.commandBlocked))) {
            $0.destination = .alert(HealthCardPasswordReadCardDomain.AlertStates.pinCounterExhausted)
        }

        await sut.send(.destination(.presented(.alert(.settings)))) {
            $0.destination = nil
        }
        await uiScheduler.run()
        await sut.receive(.delegate(.navigateToSettings))
    }
}
