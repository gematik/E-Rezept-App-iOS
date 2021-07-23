//
//  Copyright (c) 2021 gematik GmbH
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

final class OnboardingDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        OnboardingDomain.State,
        OnboardingDomain.State,
        OnboardingDomain.Action,
        OnboardingDomain.Action,
        OnboardingDomain.Environment
    >

    func testStore() -> TestStore {
        TestStore(initialState: OnboardingDomain.Dummies.state,
                  reducer: OnboardingDomain.reducer,
                  environment: OnboardingDomain.Dummies.environment)
    }

    func testActionsPageMovement() {
        let store = testStore()
        var expectedPage = OnboardingDomain.State.Page.features

        store.assert(
            // when
            .send(.setPage(page: OnboardingDomain.State.Page.features)) { sut in
                // then
                sut.page = expectedPage
            },
            // when
            .send(.nextPage) { sut in
                // then
                expectedPage.next()
                sut.page = expectedPage
            }
        )
    }

    func testActionDismiss() {
        let store = testStore()
        var expectedState = OnboardingDomain.Dummies.state
        expectedState.onboardingVisible = false

        store.assert(
            // when
            .send(.dismissOnboarding) { sut in
                // then
                sut.onboardingVisible = expectedState.onboardingVisible
            }
        )
    }
}
