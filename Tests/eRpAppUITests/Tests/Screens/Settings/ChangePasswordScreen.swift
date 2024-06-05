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

import Nimble
import XCTest

// Note: Editing secure fields via UITests seems to be blocked by "autofill passwords" by now.
// For now employ a programmatic work around as in https://stackoverflow.com/a/76656325
struct ChangePasswordScreen: Screen {
    let app: XCUIApplication

    func enterOldPassword(_ password: String, file: StaticString = #file, line: UInt = #line) {
        let textField = secureTextField(by: A18n.settings.createPassword.cpwInpCurrentPassword, file: file, line: line)
        textField.tap()
        textField.typeText(password)
    }

    func currentPasswordWrong(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A18n.settings.createPassword.cpwTxtCurrentPasswordWrong]
    }

    func enterNewPassword(_ password: String, file: StaticString = #file, line: UInt = #line) {
        let textField = secureTextField(by: A11y.settings.createPassword.cpwInpPasswordA, file: file, line: line)
        textField.tap()
        textField.typeText(password)
    }

    func enterNewPasswordAgain(_ password: String, file: StaticString = #file, line: UInt = #line) {
        let textField = secureTextField(by: A18n.settings.createPassword.cpwInpPasswordB, file: file, line: line)
        textField.tap()
        textField.typeText(password)
    }

    func passwordStrengthIndicator(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A18n.settings.createPassword.cpwTxtPasswordStrength]
    }

    func passwordStrengthErrorFooter(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A18n.settings.createPassword.cpwTxtPasswordStrengthErrorFooter]
    }

    func tapUpdate(file: StaticString = #file, line: UInt = #line) {
        button(by: A18n.settings.createPassword.cpwBtnUpdate, file: file, line: line).tap()
    }

    func tapSave(file: StaticString = #file, line: UInt = #line) {
        button(by: A18n.settings.createPassword.cpwBtnSave, file: file, line: line).tap()
    }
}
