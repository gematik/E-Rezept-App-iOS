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

import ComposableArchitecture
@testable import eRpFeatures
import Nimble
import XCTest

@MainActor
final class CardWallLoginDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CardWallLoginOptionDomain>

    func testStore() -> TestStore {
        testStore(for: CardWallLoginOptionDomain.Dummies.state)
    }

    let mockSecurityPolicyEvaluator = MockSecurityPolicyEvaluator()

    func testStore(for state: CardWallLoginOptionDomain.State) -> TestStore {
        TestStore(initialState: state) {
            CardWallLoginOptionDomain()
        } withDependencies: { dependencies in
            dependencies.securityPolicyEvaluator = mockSecurityPolicyEvaluator
            dependencies.userSession = MockUserSession()
            dependencies.schedulers = Schedulers()
            dependencies.resourceHandler = MockResourceHandler()
        }
    }

    func testSelectingOptionTriggersWarning() async {
        let store = testStore(for: CardWallLoginOptionDomain
            .State(
                isDemoModus: false,
                profileId: UUID(),
                pin: "",
                selectedLoginOption: .notSelected,
                destination: .none
            ))

        mockSecurityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = true

        await store.send(.binding(.set(\.selectedLoginOption, .withBiometry))) {
            $0.selectedLoginOption = .withBiometry
        }

        await store.receive(.presentSecurityWarning) { state in
            state.destination = .warning
        }
    }

    func testLoginOptionProceedWithBiometrie() async {
        let store = testStore(for: CardWallLoginOptionDomain
            .State(
                isDemoModus: false,
                profileId: UUID(),
                pin: "",
                selectedLoginOption: .withBiometry,
                destination: .none
            ))

        await store.send(.advance) { state in
            state.destination = .readCard(CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: state.profileId,
                pin: "",
                loginOption: .withBiometry,
                output: .idle
            ))
        }
    }

    func testLoginOptionProceedWithBiometrieButDemoMode() async {
        let store = testStore(for: CardWallLoginOptionDomain
            .State(
                isDemoModus: true,
                profileId: UUID(),
                pin: "",
                selectedLoginOption: .withBiometry,
                destination: .none
            ))

        await store.send(.advance) { state in
            state.destination = .readCard(CardWallReadCardDomain.State(
                isDemoModus: true,
                profileId: state.profileId,
                pin: "",
                loginOption: .withoutBiometry,
                output: .idle
            ))
        }
    }

    func testLoginOptionProceedWithoutBiometrie() async {
        let store = testStore(for: CardWallLoginOptionDomain
            .State(
                isDemoModus: false,
                profileId: UUID(),
                pin: "",
                selectedLoginOption: .withoutBiometry,
                destination: .none
            ))

        await store.send(.advance) { state in
            state.destination = .readCard(CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: state.profileId,
                pin: "",
                loginOption: .withoutBiometry,
                output: .idle
            ))
        }
    }
}
