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

import eRpResources
import XCTest

@MainActor
struct OnboardingAuthScreen: Screen {
    let app: XCUIApplication

    func tapPasswordButton(_ screen: (OnboardingRegisterPasswordScreen) async -> Void,
                           fileID: String = #fileID,
                           file: String = #filePath,
                           line: UInt = #line) async {
        button(by: A11y.onboarding.authentication.onbAuthBtnPassword, fileID: fileID, file: file, line: line).tap()

        let onboardingRegisterPasswordScreen = OnboardingRegisterPasswordScreen(app: app)
        await screen(onboardingRegisterPasswordScreen)
    }
}

@MainActor
struct OnboardingRegisterPasswordScreen: Screen {
    let app: XCUIApplication

    func typePassword(_ password: String, fileID: String = #fileID, file: String = #filePath,
                      line: UInt = #line) {
        let textField = secureTextField(
            by: A11y.onboarding.authentication.onbAuthInpPasswordA,
            fileID: fileID,
            file: file,
            line: line
        )
        textField.tap()
        textField.typeText(password)
    }

    func typePasswordSecond(_ password: String, fileID: String = #fileID, file: String = #filePath,
                            line: UInt = #line) {
        let textField = secureTextField(
            by: A11y.onboarding.authentication.onbAuthInpPasswordB,
            fileID: fileID,
            file: file,
            line: line
        )
        if !textField.hasFocus {
            textField.tap()
        }
        textField.typeText(password)
    }

    func passwordStrengthIndicator(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A11y.onboarding.authentication.onbAuthTxtPasswordStrength]
    }

    func passwordStrengthErrorFooter(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A11y.onboarding.authentication.onbAuthTxtPasswordsDontMatch]
    }

    func tapNextButton(_ screen: (OnboardingAnalyticScreen) async -> Void,
                       fileID: String = #fileID,
                       file: String = #filePath,
                       line: UInt = #line) async {
        button(by: A11y.onboarding.authentication.onbAuthBtnPassword, fileID: fileID, file: file, line: line).tap()

        let onboardingAnalyticScreen = OnboardingAnalyticScreen(app: app)
        await screen(onboardingAnalyticScreen)
    }
}
