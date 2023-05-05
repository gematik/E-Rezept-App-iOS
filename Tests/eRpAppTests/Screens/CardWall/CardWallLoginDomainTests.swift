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

import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class CardWallLoginDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallLoginOptionDomain.State,
        CardWallLoginOptionDomain.Action,
        CardWallLoginOptionDomain.State,
        CardWallLoginOptionDomain.Action,
        Void
    >

    func testStore() -> TestStore {
        testStore(for: CardWallLoginOptionDomain.Dummies.state)
    }

    func testStore(for state: CardWallLoginOptionDomain.State) -> TestStore {
        TestStore(initialState: state, reducer: CardWallLoginOptionDomain()) { dependencies in
            dependencies.userSession = MockUserSession()
            dependencies.schedulers = Schedulers()
            dependencies.resourceHandler = MockResourceHandler()
        }
    }

    func testLoginOptionProceedWithBiometrie() {
        let store = testStore(for: CardWallLoginOptionDomain
            .State(isDemoModus: false, pin: "", selectedLoginOption: .withBiometry, destination: .none))

        store.send(.advance) { state in
            state.destination = .readcard(CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: store.dependencies.userSession
                    .profileId,
                pin: "",
                loginOption: .withBiometry,
                output: .idle
            ))
        }
    }

    func testLoginOptionProceedWithBiometrieButDemoMode() {
        let store = testStore(for: CardWallLoginOptionDomain
            .State(isDemoModus: true, pin: "", selectedLoginOption: .withBiometry, destination: .none))

        store.send(.advance) { state in
            state.destination = .readcard(CardWallReadCardDomain.State(
                isDemoModus: true,
                profileId: store.dependencies.userSession
                    .profileId,
                pin: "",
                loginOption: .withoutBiometry,
                output: .idle
            ))
        }
    }

    func testLoginOptionProceedWithoutBiometrie() {
        let store = testStore(for: CardWallLoginOptionDomain
            .State(isDemoModus: false, pin: "", selectedLoginOption: .withoutBiometry, destination: .none))

        store.send(.advance) { state in
            state.destination = .readcard(CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: store.dependencies.userSession
                    .profileId,
                pin: "",
                loginOption: .withoutBiometry,
                output: .idle
            ))
        }
    }
}
