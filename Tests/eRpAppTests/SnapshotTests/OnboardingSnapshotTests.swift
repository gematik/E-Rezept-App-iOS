//
//  Copyright (c) 2024 gematik GmbH
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
@testable import eRpFeatures
import eRpKit
import LocalAuthentication
import SnapshotTesting
import SwiftUI
import XCTest

final class OnboardingSnapshotTests: ERPSnapshotTestCase {
    let next: (() -> Void) = {}

    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testOnboardingStartView() {
        let sut = OnboardingStartView()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingAnalyticsView() {
        let sut = OnboardingAnalyticsView(action: next)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_NoBiometrics() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password],
            selectedSecurityOption: .password,
            securityOptionsError: AppSecurityManagerError.localAuthenticationContext(
                NSError(domain: "", code: LAError.Code.biometryNotEnrolled.rawValue)
            )
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: RegisterAuthenticationDomain.Store(
                initialState: state

            ) {
                EmptyReducer()
            }
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_WithSelectedFaceId() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password, .biometry(.faceID)],
            selectedSecurityOption: AppSecurityOption.biometry(.faceID)
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: RegisterAuthenticationDomain.Store(
                initialState: state

            ) {
                EmptyReducer()
            }
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_WithSelectedPasswordOption() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password, .biometry(.touchID)],
            selectedSecurityOption: AppSecurityOption.password
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: RegisterAuthenticationDomain.Store(
                initialState: state

            ) {
                EmptyReducer()
            }
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_WithNonEqualPasswords() {
        let store = RegisterAuthenticationDomain.Store(
            initialState: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.touchID)],
                selectedSecurityOption: .password,
                passwordA: "Abc",
                passwordB: "A",
                passwordStrength: .strong,
                showPasswordErrorMessage: true
            )

        ) {
            EmptyReducer()
        }

        let sut = OnboardingRegisterAuthenticationView(store: store)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_WithInsufficientPasswordStrength() {
        let store = RegisterAuthenticationDomain.Store(
            initialState: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.touchID)],
                selectedSecurityOption: .password,
                passwordA: "Abc",
                passwordB: "Abc",
                passwordStrength: .veryWeak,
                showPasswordErrorMessage: true
            )

        ) {
            EmptyReducer()
        }

        let sut = OnboardingRegisterAuthenticationView(store: store)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_WithNoSelectionError() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password, .biometry(.touchID)],
            selectedSecurityOption: .biometry(.touchID),
            showNoSelectionMessage: true
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: RegisterAuthenticationDomain.Store(
                initialState: state

            ) {
                EmptyReducer()
            }
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingLegalInfoView() {
        let sut = OnboardingLegalInfoView(
            isAllAccepted: .constant(false),
            showTermsOfUse: {},
            showTermsOfPrivacy: {},
            action: next
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
