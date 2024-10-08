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

import Foundation
import Nimble
import XCTest

final class CreatePasswordUITests: XCTestCase {
    var app: XCUIApplication!

    override func tearDown() {
        super.tearDown()

        notificationAlertMonitor.map { [self] in removeUIInterruptionMonitor($0) }
    }

    var notificationAlertMonitor: NSObjectProtocol?

    @MainActor
    override func setUp() {
        super.setUp()

        disableAutoFillPasswords()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"
        app.launchEnvironment["UITEST.SET_APPLICATION_PASSWORD"] = "abc"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "CreatePasswordUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    // Disabled due to bug in iOS 17.2 Settings App, autofill is broken
    @MainActor
    func disabledtestChangePassword() {
        let tabBar = TabBarScreen(app: app)

        let changePasswordScreen = tabBar
            .tapSettingsTab()
            .tapAppSecuritySelection()
            .tapChangePassword()

        changePasswordScreen.enterNewPassword("1n1n1n1n")
        changePasswordScreen.enterNewPassword("\r")
        expect(changePasswordScreen.passwordStrengthErrorFooter().label)
            .to(equal("Sicherheitsstufe des gewählten Kennworts nicht ausreichend"))

        changePasswordScreen.enterNewPassword(XCUIKeyboardKey.delete.rawValue)
        changePasswordScreen.enterNewPassword("1n1n1n1n1n1n")
        changePasswordScreen.enterNewPassword("\r")
        expect(changePasswordScreen.passwordStrengthIndicator().label).to(beginWith("Kennwortstärke ausreichend"))
        expect(changePasswordScreen.passwordStrengthErrorFooter().exists).to(beFalse())

        changePasswordScreen.enterNewPassword(XCUIKeyboardKey.delete.rawValue)

        changePasswordScreen.enterNewPassword("1n1n1n1n1n1n1n1n1n")
        changePasswordScreen.enterNewPassword("\r")
        expect(changePasswordScreen.passwordStrengthIndicator().label).to(beginWith("Kennwortstärke sehr gut"))

        changePasswordScreen.enterNewPasswordAgain("1n1n1n1n1n1n1n1n")
        changePasswordScreen.enterNewPasswordAgain("\r")

        expect(changePasswordScreen.passwordStrengthErrorFooter().label)
            .to(equal("Die Eingaben weichen voneinander ab."))

        changePasswordScreen.enterNewPasswordAgain(XCUIKeyboardKey.delete.rawValue)
        changePasswordScreen.enterNewPasswordAgain("1n1n1n1n1n1n1n1n1n")
        var changePasswordScreenExists = changePasswordScreen.currentPasswordWrong()
            .waitForExistence(timeout: TimeInterval(5))
        expect(changePasswordScreenExists).to(beFalse())
        changePasswordScreen.enterNewPasswordAgain("\r")
        changePasswordScreenExists = changePasswordScreen.currentPasswordWrong()
            .waitForExistence(timeout: TimeInterval(5))
        expect(changePasswordScreenExists).to(beTrue())

        changePasswordScreen.tapUpdate()
        changePasswordScreenExists = changePasswordScreen.currentPasswordWrong()
            .waitForExistence(timeout: TimeInterval(5))
        expect(changePasswordScreenExists).to(beTrue())
    }

    @MainActor
    private func disableAutoFillPasswords() {
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
            settingsApp.staticTexts["AUTOFILL"].tap()
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
}
