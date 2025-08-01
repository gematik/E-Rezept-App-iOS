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
import Nimble
import XCTest

// Note: Editing secure fields via UITests seems to be blocked by "autofill passwords" by now.
// For now employ a programmatic work around as in https://stackoverflow.com/a/76656325
@MainActor
struct ChangePasswordScreen: Screen {
    let app: XCUIApplication

    func enterOldPassword(_ password: String, fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        let textField = secureTextField(
            by: A18n.settings.createPassword.cpwInpCurrentPassword,
            fileID: fileID,
            file: file,
            line: line
        )
        textField.tap()
        textField.typeText(password)
    }

    func currentPasswordWrong(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A18n.settings.createPassword.cpwTxtCurrentPasswordWrong]
    }

    func enterNewPassword(_ password: String, fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        let textField = secureTextField(
            by: A11y.settings.createPassword.cpwInpPasswordA,
            fileID: fileID,
            file: file,
            line: line
        )
        textField.tap()
        textField.typeText(password)
    }

    func enterNewPasswordAgain(
        _ password: String,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) {
        let textField = secureTextField(
            by: A18n.settings.createPassword.cpwInpPasswordB,
            fileID: fileID,
            file: file,
            line: line
        )
        textField.tap()
        textField.typeText(password)
    }

    func passwordStrengthIndicator(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A18n.settings.createPassword.cpwTxtPasswordStrength]
    }

    func passwordStrengthErrorFooter(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.staticTexts[A18n.settings.createPassword.cpwTxtPasswordStrengthErrorFooter]
    }

    func tapUpdate(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A18n.settings.createPassword.cpwBtnUpdate, fileID: fileID, file: file, line: line).tap()
    }

    func tapSave(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A18n.settings.createPassword.cpwBtnSave, fileID: fileID, file: file, line: line).tap()
    }
}
