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
import HealthCardControl
import Nimble
import TestUtils
import XCTest

final class ResetRetryCounterReadCardDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        ResetRetryCounterReadCardDomain.State,
        ResetRetryCounterReadCardDomain.State,
        ResetRetryCounterReadCardDomain.Action,
        ResetRetryCounterReadCardDomain.Action,
        ResetRetryCounterReadCardDomain.Environment
    >

    var mockNFCSessionController: MockNFCResetRetryCounterController!

    let uiScheduler = DispatchQueue.test
    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: self.uiScheduler.eraseToAnyScheduler()
        )
    }()

    override func setUp() {
        super.setUp()

        mockNFCSessionController = MockNFCResetRetryCounterController()
    }

    func testStore(for state: ResetRetryCounterReadCardDomain.State) -> TestStore {
        .init(
            initialState: state,
            reducer: ResetRetryCounterReadCardDomain.reducer,
            environment: .init(
                schedulers: schedulers,
                nfcSessionController: mockNFCSessionController
            )
        )
    }

    func testUnlockCardSuccess() {
        let sut = testStore(
            for: .init(withNewPin: true, can: "123123", puk: "12345678", newPin: "123456", route: .none)
        )

        mockNFCSessionController
            .resetEgkMrPinRetryCounterCanPukModeReturnValue = Just(ResetRetryCounterResponse.success)
            .setFailureType(to: ResetRetryCounterControllerError.self)
            .eraseToAnyPublisher()

        sut.send(.readCard)
        uiScheduler.advance()
        sut.receive(.resetRetryCounterResponseReceived(.success)) {
            $0.route = .alert(ResetRetryCounterReadCardDomain.AlertStates.cardUnlocked)
        }

        sut.send(.okButtonTapped)
        sut.receive(.navigateToSettings) {
            $0.route = nil
        }
    }
}
