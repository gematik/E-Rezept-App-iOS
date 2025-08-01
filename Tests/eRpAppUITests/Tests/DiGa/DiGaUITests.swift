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
import Foundation
@preconcurrency import Nimble
import XCTest

@MainActor
final class DiGaUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "DiGaUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launchEnvironment["UITEST.SET_IKNR"] = "1234567890"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    override func tearDown() async throws {
        try await super.tearDown()

        if let notificationAlertMonitor {
            removeUIInterruptionMonitor(notificationAlertMonitor)
        }
    }

    @MainActor var locationDialogInterruptAnswered = false
    var notificationAlertMonitor: NSObjectProtocol?

    @MainActor
    func testDiGaHappyPath() async {
        // Happy path
        let bridge = UITestBridgeClient()

        let tabBar = TabBarScreen(app: app)

        // Check no "einlösen Button"

        await tabBar.tapPrescriptionsTab { mainScreen in
            await mainScreen.tapDetailsForDiGaNamed("Vantis KHK und Herzinfarkt 001") { diGaDetails in
                // einlösen
                diGaDetails.tapMainButton()
                expect(self.app.buttons[A11y.digaDetail.digaDtlBtnMainAction].exists).to(beFalse())

                await bridge.sendMessage(.scenarioStep(1))

                diGaDetails.tapRefreshButton()
                expect(self.app.buttons[A11y.digaDetail.digaDtlBtnMainAction].exists).to(beFalse())

                // erfolgreich
                await bridge.sendMessage(.scenarioStep(2))
                diGaDetails.tapRefreshButton()

                expect(diGaDetails.mainButton()).to(exist("DiGa main button"))

                expect(diGaDetails.mainButton().label).to(equal("DiGA App herunterladen"))
                diGaDetails.tapMainButton()

                // Umfrage Bubble ist aktiv
                await expect(self.app.tabBars.buttons["Einstellungen"].value as? String == "Neu")
                    .toEventually(beTrue(), timeout: .seconds(2), pollInterval: .microseconds(100))

                expect(diGaDetails.mainButton().label).to(equal("DiGA App aktivieren"))
                diGaDetails.tapMainButton()
                // archivieren
                expect(diGaDetails.mainButton().label).to(equal("Rezept archivieren"))

                // zurück, ins archiv, status checken
                diGaDetails.tapMainButton()
                expect(diGaDetails.mainButton().label).to(equal("Wiederherstellen"))
            }
            await mainScreen.tapArchive { archive in
                await archive.detailsForDiGaNamed("Vantis KHK und Herzinfarkt 001") { details in
                    expect(details.mainButton().label).to(equal("Wiederherstellen"))
                    details.tapMainButton()
                }
            }
        }

        // Umfrage Bubble ist aktiv
        await tabBar.tapSettingsTab { settings in
            expect(settings.app.buttons[A11y.settings.contact.stgConTxtDigaSurvey].label)
                .to(equal("Umfrage zur DiGA Verordnung, Neu"))
        }
    }

    @MainActor
    func testDigaDeclinedByInsuranceCompany() async {
        let bridge = UITestBridgeClient()

        let tabBar = TabBarScreen(app: app)

        await tabBar.tapPrescriptionsTab { prescriptionsTab in
            await prescriptionsTab.tapDetailsForDiGaNamed("Vantis KHK und Herzinfarkt 001") { diGaDetails in
                // Redeem
                diGaDetails.tapMainButton()
                expect(self.app.buttons[A11y.digaDetail.digaDtlBtnMainAction].exists).to(beFalse())

                // Accept
                await bridge.sendMessage(.scenarioStep(1))

                diGaDetails.tapRefreshButton()
                expect(self.app.buttons[A11y.digaDetail.digaDtlBtnMainAction].exists).to(beFalse())

                // Declined
                await bridge.sendMessage(.scenarioStep(3))
                diGaDetails.tapRefreshButton()

                expect(self.app.staticTexts[A11y.digaDetail.digaDtlTxtDeclineNote].label)
                    .to(equal("##Insurance company decline reason##"))
            }

            // Check mainscreen status
            let cell = prescriptionsTab.prescriptionCellByName("Vantis KHK und Herzinfarkt 001")

            expect(cell.staticTexts["erx_detailed_status"].label).to(equal("Abgelehnt"))
        }
    }

    @MainActor
    func testDigaAndNormalPrescriptionHasEinlösenButton() async {
        let tabBar = TabBarScreen(app: app)

        await tabBar.tapPrescriptionsTab { prescriptionsTab in
            let refreshButton = prescriptionsTab.button(
                by: A11y.mainScreen.erxBtnRedeemPrescriptions,
                fileID: #fileID,
                file: #file,
                line: #line,
                checkExistence: false
            )

            expect(refreshButton).to(isDisabledOrDoesNotExist("Einlösen Button"))

            let bridge = UITestBridgeClient()
            await bridge.sendMessage(.scenarioStep(4))

            prescriptionsTab.swipeToRefresh()

            // Einlösen Button exists
            expect(refreshButton).to(exist("Einlösen Button"))

            let redeemScreen = prescriptionsTab.tapRedeem().tapRedeemRemote()

            let editPrescriptionsButton = redeemScreen.editPrescriptionButton()
            expect(editPrescriptionsButton.label).to(equal("1 Rezepte, Regular 160 Prescriptions, Ändern"))
            // redeem -> only normal prescription on redeem screen
        }
    }

    @MainActor
    func testDeleteDiga() async {
        let bridge = UITestBridgeClient()

        let tabBar = TabBarScreen(app: app)

        await tabBar.tapPrescriptionsTab { prescriptionsTab in
            let diGaDetails = prescriptionsTab.tapDetailsForDiGaNamed("Vantis KHK und Herzinfarkt 001")

            // Einlösbar -> Löschbar
            diGaDetails.tapMainButton()
            // Check no "einlösen Button"
            expect(self.app.buttons[A11y.digaDetail.digaDtlBtnMainAction].exists).to(beFalse())

            let menu = diGaDetails.tapMenu()
            menu.tapDelete()

            expect(self.app.alerts["Rezept löschen?"].waitForExistence(timeout: 5.0)).to(beTrue())
            self.app.alerts["Rezept löschen?"].buttons["Abbrechen"].tap()

            // Status Acceptet -> nicht löschbar
            await bridge.sendMessage(.scenarioStep(1))

            diGaDetails.tapRefreshButton()
            expect(self.app.buttons[A11y.digaDetail.digaDtlBtnMainAction].exists).to(beFalse())

            _ = diGaDetails.tapMenu()
            menu.tapDelete()

            expect(self.app
                .alerts["Das Rezept ist gerade in Bearbeitung durch Ihre Krankenkasse und kann nicht gelöscht werden."]
                .waitForExistence(timeout: 5.0)).to(beTrue())
            self.app.alerts.buttons["Okay"].tap()

            // Eingelöst -> Löschbar
            await bridge.sendMessage(.scenarioStep(2))
            diGaDetails.tapRefreshButton()

            _ = diGaDetails.tapMenu()
            menu.tapDelete()

            expect(self.app.alerts["Rezept löschen?"].waitForExistence(timeout: 5.0)).to(beTrue())
            self.app.alerts["Rezept löschen?"].buttons["Abbrechen"].tap()
        }
    }

    @MainActor
    func testCardWallTriggersWhenNotLoggedIn() async {
        // Einlösen without login -> show cardwall
        let bridge = UITestBridgeClient()

        let tabBar = TabBarScreen(app: app)

        await tabBar.tapPrescriptionsTab { prescriptionsTab in
            let diGaDetails = prescriptionsTab.tapDetailsForDiGaNamed("Vantis KHK und Herzinfarkt 001")

            await bridge.sendMessage(.loginStatus(false))

            // einlösen
            diGaDetails.tapMainButton()

            expect(self.app.buttons[A11y.cardWall.intro.cdwBtnIntroCancel])
                .to(exist(A11y.cardWall.intro.cdwBtnIntroCancel))
        }
    }

    @MainActor
    func testChangeInsurance() async {
        let bridge = UITestBridgeClient()

        let tabBar = TabBarScreen(app: app)

        await tabBar.tapPrescriptionsTab { prescriptionsTab in
            // To load the correct insurance scenarioStep needs to be set before opening digaDetailsView
            await bridge.sendMessage(.scenarioStep(6))

            await prescriptionsTab.tapDetailsForDiGaNamed("Vantis KHK und Herzinfarkt 001") { diGaDetails in

                diGaDetails.tapInsuranceNotFoundAlert()

                // Select Insurance
                await diGaDetails.tapSelectInsurance { insuranceList in
                    insuranceList.selectInsurance("Test GKV-SV")
                }

                await diGaDetails.tapSelectedInsurance { insuranceList in
                    insuranceList.selectInsurance("KNAPPSCHAFT")
                }

                expect(diGaDetails.app.buttons[A11y.digaDetail.digaDtlBtnMainSelectedInsurance].label)
                    .to(equal("Wir fragen den Code an bei: KNAPPSCHAFT"))
            }
        }
    }
}
