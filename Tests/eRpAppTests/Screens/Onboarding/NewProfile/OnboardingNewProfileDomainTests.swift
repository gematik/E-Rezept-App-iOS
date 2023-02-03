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
import eRpKit
import Nimble
import XCTest

final class OnboardingNewProfileDomainTests: XCTestCase {
    let mockUserDataStore = MockUserDataStore()
    let mockAppSecurityManager = MockAppSecurityManager()
    let mockProfileDataStore = MockProfileDataStore()
    typealias TestStore = ComposableArchitecture.TestStore<
        OnboardingNewProfileDomain.State,
        OnboardingNewProfileDomain.Action,
        OnboardingNewProfileDomain.State,
        OnboardingNewProfileDomain.Action,
        OnboardingNewProfileDomain.Environment
    >

    func testStore(with state: OnboardingNewProfileDomain.State = OnboardingNewProfileDomain.Dummies
        .state) -> TestStore {
        TestStore(
            initialState: state,
            reducer: OnboardingNewProfileDomain.reducer,
            environment: OnboardingNewProfileDomain.Environment()
        )
    }

    func testSettingProfileName() {
        let sut = testStore(with: OnboardingNewProfileDomain.State(name: "Initial Name"))

        sut.send(.setName("   Trimmed Name   ")) {
            $0.name = "Trimmed Name"
        }
    }

    func testNoValidName() {
        let state = OnboardingNewProfileDomain.State(name: "Initial Name")
        let sut = testStore(with: state)

        sut.send(.setName("")) {
            $0.name = ""
            let state = $0
            expect(state.hasValidName).to(beFalse())
        }
    }

    func testDismissingAlert() {
        let state = OnboardingNewProfileDomain.State(
            name: "Initial Name",
            alertState: OnboardingNewProfileDomain.AlertStates.for(.notImplemented)
        )
        let sut = testStore(with: state)

        sut.send(.dismissAlert) {
            $0.alertState = nil
        }
    }
}
