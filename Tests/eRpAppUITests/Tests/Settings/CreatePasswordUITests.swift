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

import Foundation
import Nimble
import XCTest

@MainActor
final class CreatePasswordUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func tearDown() async throws {
        try await super.tearDown()

        notificationAlertMonitor.map { [self] in removeUIInterruptionMonitor($0) }
    }

    var notificationAlertMonitor: NSObjectProtocol?

    override func setUp() async throws {
        try await super.setUp()

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

    @MainActor
    func testChangePassword() {
        let tabBar = TabBarScreen(app: app)

        let changePasswordScreen = tabBar
            .tapSettingsTab()
            .tapAppSecuritySelection()
            .tapChangePassword()

        changePasswordScreen.enterNewPassword("1n1n1n1n")
        changePasswordScreen.enterNewPassword("\r")
        expect(changePasswordScreen.passwordStrengthErrorFooter().label)
            .to(equal("Sicherheitsstufe des gewählten Passwortes nicht ausreichend"))

        changePasswordScreen.enterNewPassword(XCUIKeyboardKey.delete.rawValue)
        changePasswordScreen.enterNewPassword("1n1n1n1n1n1n")
        changePasswordScreen.enterNewPassword("\r")
        expect(changePasswordScreen.passwordStrengthIndicator().label).to(beginWith("Passwortstärke ausreichend"))
        expect(changePasswordScreen.passwordStrengthErrorFooter().exists).to(beFalse())

        changePasswordScreen.enterNewPassword(XCUIKeyboardKey.delete.rawValue)

        changePasswordScreen.enterNewPassword("1n1n1n1n1n1n1n1n1n")
        changePasswordScreen.enterNewPassword("\r")
        expect(changePasswordScreen.passwordStrengthIndicator().label).to(beginWith("Passwortstärke sehr gut"))

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
}
