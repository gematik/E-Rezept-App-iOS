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

import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class CardWallDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallDomain.State,
        CardWallDomain.State,
        CardWallDomain.Action,
        CardWallDomain.Action,
        CardWallDomain.Environment
    >

    func testStore() -> TestStore {
        testStore(for: CardWallDomain.Dummies.state)
    }

    func testStore(for state: CardWallDomain.State) -> TestStore {
        TestStore(initialState: state,
                  reducer: CardWallDomain.domainReducer,
                  environment: CardWallDomain.Environment(
                      schedulers: Schedulers(),
                      userSession: MockUserSession(),
                      signatureProvider: DummySecureEnclaveSignatureProvider(),
                      accessibilityAnnouncementReceiver: { _ in }
                  ))
    }

    func testCanCloseActionShouldBeForwarded() {
        let store = testStore()

        // when
        store.send(.canAction(action: .close))
        // then
        store.receive(.close)
    }

    func testPinCloseActionShouldBeForwarded() {
        let store = testStore()

        // when
        store.send(.pinAction(action: .close))
        // then
        store.receive(.close)
    }

    func testIntroductionCloseActionShouldBeForwarded() {
        let store = testStore()

        // when
        store.send(.introduction(action: .close))
        // then
        store.receive(.close)
    }

    func testLoginOptionProceedWithBiometrie() {
        let store = testStore(for: CardWallDomain.State(
            introAlreadyDisplayed: true,
            isNFCReady: true,
            isMinimalOS14: true,
            can: nil,
            pin: CardWallPINDomain.State(isDemoModus: false),
            loginOption: CardWallLoginOptionDomain.State(
                isDemoModus: false,
                pin: "",
                selectedLoginOption: .withBiometry,
                isSecurityWarningPresented: true,
                showNextScreen: true
            ),
            introduction: CardWallIntroductionDomain.State(showNextScreen: true),
            readCard: nil
        ))

        store.send(CardWallDomain.Action.loginOption(action: .advance)) { state in
            state.readCard = CardWallReadCardDomain.State(isDemoModus: false,
                                                          pin: "",
                                                          loginOption: .withBiometry,
                                                          output: .idle)
        }
    }

    func testLoginOptionProceedWithBiometrieButDemoMode() {
        let store = testStore(for: CardWallDomain.State(
            introAlreadyDisplayed: true,
            isNFCReady: true,
            isMinimalOS14: true,
            can: nil,
            pin: CardWallPINDomain.State(isDemoModus: true),
            loginOption: CardWallLoginOptionDomain.State(
                isDemoModus: true,
                pin: "",
                selectedLoginOption: .withBiometry,
                isSecurityWarningPresented: true,
                showNextScreen: true
            ),
            introduction: CardWallIntroductionDomain.State(showNextScreen: true),
            readCard: nil
        ))

        store.send(CardWallDomain.Action.loginOption(action: .advance)) { state in
            state.loginOption.showNextScreen = true
            state.readCard = CardWallReadCardDomain.State(isDemoModus: false,
                                                          pin: "",
                                                          loginOption: .withoutBiometry,
                                                          output: .idle)
        }
    }

    func testLoginOptionProceedWithoutBiometrie() {
        let store = testStore(for: CardWallDomain.State(
            introAlreadyDisplayed: true,
            isNFCReady: true,
            isMinimalOS14: true,
            can: nil,
            pin: CardWallPINDomain.State(isDemoModus: true),
            loginOption: CardWallLoginOptionDomain.State(
                isDemoModus: false,
                pin: "",
                selectedLoginOption: .withoutBiometry,
                isSecurityWarningPresented: true,
                showNextScreen: true
            ),
            introduction: CardWallIntroductionDomain.State(showNextScreen: true),
            readCard: nil
        ))

        store.send(CardWallDomain.Action.loginOption(action: .advance)) { state in
            state.loginOption.showNextScreen = true
            state.readCard = CardWallReadCardDomain.State(isDemoModus: false,
                                                          pin: "",
                                                          loginOption: .withoutBiometry,
                                                          output: .idle)
        }
    }
}
