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
final class SettingsUITests: XCTestCase, Sendable {
    var app: XCUIApplication!
    var settingsApp: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        settingsApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settingsApp.launch()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "MedicationReminderUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testLanguageSelection() {
        let tabBar = TabBarScreen(app: app)

        let settings = tabBar
            .tapSettingsTab()

        let alert = settings.tapLanguageSettingsButton()

        let okayButton = alert.buttons["Okay"]
        let openButton = alert.buttons["Einstellungen öffnen"]

        expect(okayButton).to(exist("Okay"))
        expect(openButton).to(exist("Einstellungen öffnen"))
        expect(alert.label).to(equal("Sprache der App ändern"))

        okayButton.tap()

        expect(alert.exists).to(beFalse())

        _ = settings.tapLanguageSettingsButton()
        openButton.tap()

        expect(self.app.state).toEventually(equal(.runningBackground), timeout: .seconds(5))
        expect(self.settingsApp.state).to(equal(.runningForeground))

        // broken since ~iOS 18.4
//        let titleCorrect = settingsApp.navigationBars.staticTexts.firstMatch.label == "E-prescription" ||
//            settingsApp.navigationBars.staticTexts.firstMatch.label == "E-Rezept"

        let titleCorrect = settingsApp.buttons["E-Rezept"].exists || settingsApp.buttons["E-prescription"].exists
        expect(titleCorrect).to(beTrue())
    }
}
