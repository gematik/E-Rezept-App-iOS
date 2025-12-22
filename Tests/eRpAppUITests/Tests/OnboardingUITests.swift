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
class OnboardingUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        disableAutoFillPasswords()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "OnboardingUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testOnboardingPassword() async throws {
        let onboardingStartScreen = OnboardingStartScreen(app: app)

        await onboardingStartScreen.tapWelcomeButton { legalScreen in
            await legalScreen.tapDataButton { dataScreen in
                expect(dataScreen.webViewDataHeader().waitForExistence(timeout: 5)).to(beTrue())
                dataScreen.tapCloseDataButton()
            }
            await legalScreen.tapUsageButton { usageScreen in
                expect(usageScreen.webViewUsageHeader().waitForExistence(timeout: 5)).to(beTrue())
                usageScreen.tapCloseUsageButton()
            }

            // OnboardingRegisterPasswordView
            await legalScreen.tapNextButton().tapPasswordButton { pwdScreen in
                pwdScreen.typePassword("1n1n1n1n")
                pwdScreen.typePassword("\r")
                expect(pwdScreen.passwordStrengthErrorFooter().label)
                    .to(equal("Sicherheitsstufe des gewählten Passwortes nicht ausreichend"))

                pwdScreen.typePassword(XCUIKeyboardKey.delete.rawValue)
                pwdScreen.typePassword("1n1n1n1n1n1n")
                pwdScreen.typePassword("\r")
                expect(pwdScreen.passwordStrengthIndicator().label).to(beginWith("Passwortstärke ausreichend"))
                expect(pwdScreen.passwordStrengthErrorFooter().exists).to(beFalse())

                pwdScreen.typePassword(XCUIKeyboardKey.delete.rawValue)
                pwdScreen.typePassword("1n1n1n1n1n1n1n1n1n")
                pwdScreen.typePassword("\r")
                expect(pwdScreen.passwordStrengthIndicator().label).to(beginWith("Passwortstärke sehr gut"))

                pwdScreen.typePasswordSecond("1n1n1n1n1n1n1n1n")
                pwdScreen.typePasswordSecond("\r")

                expect(pwdScreen.passwordStrengthErrorFooter().label)
                    .to(equal("Die Eingaben weichen voneinander ab."))

                pwdScreen.typePasswordSecond(XCUIKeyboardKey.delete.rawValue)
                pwdScreen.typePasswordSecond("1n1n1n1n1n1n1n1n1n")
                pwdScreen.typePasswordSecond("\r")

                expect(pwdScreen.passwordStrengthErrorFooter().exists).to(beFalse())

                // OnboardingAnalyticsView
                await pwdScreen.tapNextButton { analyticScreen in
                    await analyticScreen.tapAnalyticButton { detailScreen in
                        expect(detailScreen.analyticsDetailHeader().waitForExistence(timeout: 5)).to(beTrue())
                        detailScreen.tapBackButton()
                    }

                    analyticScreen.tapAcceptAnalyticsButton()
                }
            }
        }
    }
}
