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
import eRpKit
import LocalAuthentication
import SnapshotTesting
import SwiftUI
import XCTest

final class OnboardingSnapshotTests: ERPSnapshotTestCase {
    let next: (() -> Void) = {}

    func testOnboardingStartView() {
        let sut = OnboardingStartView(action: next)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testOnboardingAnalyticsView() {
        let state = OnboardingDomain.State()
        let sut = OnboardingAnalyticsView(store: StoreOf<OnboardingDomain>(
            initialState: state
        ) {
            EmptyReducer()
        })
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_NoBiometrics() {
        // Pickers `selected` parameter is false positive triggering the perception tracking on iOS 18
        Perception.isPerceptionCheckingEnabled = false

        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password],
            selectedSecurityOption: .password,
            securityOptionsError: AppSecurityManagerError.localAuthenticationContext(
                NSError(domain: "", code: LAError.Code.biometryNotEnrolled.rawValue)
            )
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: StoreOf<RegisterAuthenticationDomain>(
                initialState: state

            ) {
                EmptyReducer()
            }
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password, .biometry(.faceID)]
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: StoreOf<RegisterAuthenticationDomain>(
                initialState: state

            ) {
                EmptyReducer()
            }
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testOnboardingRegisterPasswordView() {
        let state = RegisterPasswordDomain.State()
        let sut = OnboardingRegisterPasswordView(
            store: StoreOf<RegisterPasswordDomain>(
                initialState: state

            ) {
                EmptyReducer()
            }
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testOnboardingRegisterPasswordView_WithNonEqualPasswords() {
        let store = StoreOf<RegisterPasswordDomain>(
            initialState: RegisterPasswordDomain.State(
                passwordA: "Abc",
                passwordB: "A",
                passwordStrength: .strong,
                showPasswordErrorMessage: true
            )

        ) {
            EmptyReducer()
        }

        let sut = OnboardingRegisterPasswordView(store: store)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testOnboardingRegisterPasswordView_WithInsufficientPasswordStrength() {
        let store = StoreOf<RegisterPasswordDomain>(
            initialState: RegisterPasswordDomain.State(
                passwordA: "Abc",
                passwordB: "Abc",
                passwordStrength: .veryWeak,
                showPasswordErrorMessage: true
            )

        ) {
            EmptyReducer()
        }

        let sut = OnboardingRegisterPasswordView(store: store)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testOnboardingLegalInfoView() {
        let state = OnboardingDomain.State()
        let sut = OnboardingLegalInfoView(store: StoreOf<OnboardingDomain>(
            initialState: state
        ) {
            EmptyReducer()
        })
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(of: sut, as: snapshotModi())
    }
}
