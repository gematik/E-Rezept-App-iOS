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

import Nimble
import XCTest

@MainActor
func disableAutoFillPasswords() {
    let settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    settingsApp.launch()

    // iOS 18
    if !(ProcessInfo.processInfo.environment["SIMULATOR_RUNTIME_VERSION"]?.starts(with: "17") ?? true) {
        var exists = false

        let generalEn = settingsApp.staticTexts["General"]
        let generalDe = settingsApp.staticTexts["Allgemein"]
        if generalEn.exists {
            generalEn.tap()
        } else {
            generalDe.tap()
        }

        if #available(iOS 26.0, *) {
            expect(settingsApp.buttons["AUTOFILL"].waitForExistence(timeout: TimeInterval(5))).to(beTrue())
            settingsApp.buttons["AUTOFILL"].tap()
        } else {
            expect(settingsApp.staticTexts["AUTOFILL"].waitForExistence(timeout: TimeInterval(5))).to(beTrue())
            settingsApp.staticTexts["AUTOFILL"].tap()
        }

        let switcher = settingsApp.switches["Passwörter und Passkeys automatisch ausfüllen"].switches.firstMatch

        exists = switcher.waitForExistence(timeout: TimeInterval(5))
        XCTAssertTrue(exists, "Switcher exists")
        if switcher.value as? String == "1" {
            switcher.tap()
        }

    } else {
        // iOS 17:
        let passRow = settingsApp.tables.staticTexts["PASSWORDS"]
        var exists = passRow.waitForExistence(timeout: TimeInterval(5))
        // sometimes the settings app opens with the passcodeInput screen already in place
        // so we ignore the next line's check
        //        XCTAssertTrue(exists, "PASSWORDS entry exists")
        if exists {
            passRow.tap()
        }

        let passcodeInput = springboard.secureTextFields.firstMatch
        exists = passcodeInput.waitForExistence(timeout: TimeInterval(5))
        XCTAssertTrue(exists, "Passcode field exists")
        passcodeInput.tap()
        passcodeInput.typeText("abc\r")
        let cell = settingsApp.tables.cells["PasswordOptionsCell"].buttons["chevron"]
        exists = cell.waitForExistence(timeout: TimeInterval(5))
        XCTAssertTrue(exists, "Password options cell exists")
        cell.tap()
        let toggleLabel = settingsApp.tables.staticTexts.firstMatch.label // "AutoFill Passwords"
        let switcher = settingsApp.switches[toggleLabel]
        exists = switcher.waitForExistence(timeout: TimeInterval(5))
        XCTAssertTrue(exists, "Switcher exists")
        let enabledState = switcher.value as? String
        if enabledState == "1" {
            switcher.tap()
        }
    }
}
