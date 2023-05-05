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
import ComposableArchitecture
@testable import eRpApp
import HealthCardControl
import Nimble
import TestUtils
import XCTest

final class HealthCardPasswordReadCardDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        HealthCardPasswordReadCardDomain.State,
        HealthCardPasswordReadCardDomain.Action,
        HealthCardPasswordReadCardDomain.State,
        HealthCardPasswordReadCardDomain.Action,
        Void
    >

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
        .init(
            initialState: state,
            reducer: HealthCardPasswordReadCardDomain()
        ) { dependecies in
            dependecies.schedulers = schedulers
            dependecies.nfcHealthCardPasswordController = mockNFCSessionController
        }
    }

    func testUnlockCard_Success() throws {
        let sut = testStore(
            for: .init(mode: .healthCardResetPinCounterNoNewSecret(can: "123123", puk: "12345678"))
        )

        mockNFCSessionController
            .resetEgkMrPinRetryCounterCanPukModeReturnValue = Just(NFCHealthCardPasswordControllerResponse.success)
            .setFailureType(to: NFCHealthCardPasswordControllerError.self)
            .eraseToAnyPublisher()

        sut.send(.readCard)
        uiScheduler.advance()
        sut.receive(.response(.nfcHealthCardPasswordControllerResponseReceived(.success))) {
            $0.destination = .alert(HealthCardPasswordReadCardDomain.AlertStates.cardUnlocked)
        }

        sut.send(.alertOkButtonTapped) {
            $0.destination = nil
        }
        sut.receive(.delegate(.navigateToSettings))
    }

    func testSetNewPin_Success() {
        let sut = testStore(
            for: .init(
                mode: .healthCardSetNewPinSecret(can: "123123", oldPin: "123456", newPin: "654321")
            )
        )

        mockNFCSessionController
            .changeReferenceDataCanOldNewModeReturnValue = Just(NFCHealthCardPasswordControllerResponse.success)
            .setFailureType(to: NFCHealthCardPasswordControllerError.self)
            .eraseToAnyPublisher()

        sut.send(.readCard)
        uiScheduler.advance()
        sut.receive(.response(.nfcHealthCardPasswordControllerResponseReceived(.success))) {
            $0.destination = .alert(HealthCardPasswordReadCardDomain.AlertStates.setNewPin)
        }

        sut.send(.alertOkButtonTapped) {
            $0.destination = nil
        }
        sut.receive(.delegate(.navigateToSettings))
    }

    func testSetNewPin_PinCounterExhausted() {
        let sut = testStore(
            for: .init(
                mode: .healthCardSetNewPinSecret(can: "123123", oldPin: "123456", newPin: "654321")
            )
        )

        mockNFCSessionController
            .changeReferenceDataCanOldNewModeReturnValue = Just(NFCHealthCardPasswordControllerResponse
                .commandBlocked)
            .setFailureType(to: NFCHealthCardPasswordControllerError.self)
            .eraseToAnyPublisher()

        sut.send(.readCard)
        uiScheduler.advance()
        sut.receive(.response(.nfcHealthCardPasswordControllerResponseReceived(.commandBlocked))) {
            $0.destination = .alert(HealthCardPasswordReadCardDomain.AlertStates.pinCounterExhausted)
        }

        sut.send(.alertOkButtonTapped) {
            $0.destination = nil
        }
        sut.receive(.delegate(.navigateToSettings))
    }
}
