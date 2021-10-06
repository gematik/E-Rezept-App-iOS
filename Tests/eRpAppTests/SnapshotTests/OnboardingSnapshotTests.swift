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

@testable import eRpApp
import LocalAuthentication
import SnapshotTesting
import SwiftUI
import XCTest

final class OnboardingSnapshotTests: XCTestCase {
    let next: (() -> Void) = {}

    func testOnboardingStartView() {
        let sut = OnboardingStartView()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingWelcomeView() {
        let sut = OnboardingWelcomeView()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingFeaturesView() {
        let sut = OnboardingFeaturesView()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_NoBiometrics() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password],
            securityOptionsError: AppSecurityManagerError.localAuthenticationContext(
                NSError(domain: "", code: LAError.Code.biometryNotEnrolled.rawValue)
            )
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: RegisterAuthenticationDomain.Dummies.store(with: state)
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
            store: RegisterAuthenticationDomain.Dummies.store(with: state)
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
            store: RegisterAuthenticationDomain.Dummies.store(with: state)
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_WithWrongPasswordOption() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password, .biometry(.touchID)],
            selectedSecurityOption: AppSecurityOption.password,
            passwordA: "Abc",
            showPasswordsNotEqualMessage: true
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: RegisterAuthenticationDomain.Dummies.store(with: state)
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingRegisterAuthenticationView_WithNoSelectionError() {
        let state = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [.password, .biometry(.touchID)],
            showNoSelectionMessage: true
        )
        let sut = OnboardingRegisterAuthenticationView(
            store: RegisterAuthenticationDomain.Dummies.store(with: state)
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOnboardingLegalInfoView() {
        let sut = OnboardingLegalInfoView(action: next)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
