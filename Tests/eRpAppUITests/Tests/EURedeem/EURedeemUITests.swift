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

import ComposableArchitecture
import Nimble
import XCTest

@MainActor
final class EURedeemUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"
        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "EURedeemUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        let flags = ["eu_redeem_prescriptions_feature"]
        let flagsData = try! JSONEncoder().encode(flags)
        let flagsString = String(data: flagsData, encoding: .utf8)
        app.launchEnvironment["UITEST.FLAGS"] = flagsString

        app.launch()

        _ = app.wait(for: .runningForeground, timeout: 10.0)
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    /// Tests the complete EU prescription redemption happy path:
    /// consent → prescription selection → country selection → redeem → verify communication entry.
    @MainActor
    func testEURedeemHappyPath() async {
        let bridge = UITestBridgeClient()

        let consentScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemEUToConsent()

        expect(consentScreen.title().waitForExistence(timeout: 1)).to(beTrue())

        let selectionScreen = consentScreen.tapAccept()

        await bridge.sendMessage(.scenarioStep(1))

        let prescriptionScreen = selectionScreen.tapPrescriptions()
        prescriptionScreen.tapFirstPrescription()

        await bridge.sendMessage(.scenarioStep(2))

        let selectionAfterPrescriptions = prescriptionScreen.tapBack()

        let countryScreen = selectionAfterPrescriptions.tapCountry()
        countryScreen.selectFirstCountry()

        let codeScreen = selectionAfterPrescriptions.tapRedeemToInstructions()
            .tapGenerateCode()
        expect(codeScreen.closeButton().waitForExistence(timeout: 1)).to(beTrue())
        codeScreen.tapClose()
    }

    @MainActor
    func testEURedeemFlowEntryPoints() {
        let redeemMethodsScreen = TabBarScreen(app: app).tapPrescriptionsTab()
            .tapRedeem()

        expect(redeemMethodsScreen.redeemEUButton().exists).to(beTrue())
        let prescriptionScreen = redeemMethodsScreen.tapClose()
            .tapDetailsForPrescriptionNamed("EU-Testmedikament")
            .tapNavigationMenu()

        expect(prescriptionScreen.redeemEUButton().exists).to(beTrue())

        let dmcScreen = prescriptionScreen.tapCenter()
            .tapShowMatrixCodeButton()

        expect(dmcScreen.redeemEUButton().exists).to(beTrue())

        _ = dmcScreen.tapRedeemEU()
    }

    @MainActor
    func testDeclineConsentClosesEURedeemFlow() {
        let consentScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemEUToConsent()

        expect(consentScreen.title().waitForExistence(timeout: 1)).to(beTrue())

        let mainScreen = consentScreen.tapDecline()
        expect(mainScreen.redeemButton().exists).to(beTrue())
    }

    @MainActor
    func testNoEURedeemablePrescriptionCantEnterFlow() async {
        let bridge = UITestBridgeClient()
        await bridge.sendMessage(.scenarioStep(3))

        let redeemMethodsScreen = TabBarScreen(app: app).tapPrescriptionsTab()
            .swipeToRefresh()
            .tapRedeem()

        expect(redeemMethodsScreen.redeemEUButton().exists).to(beFalse())

        let prescriptionScreen = redeemMethodsScreen.tapClose()
            .tapDetailsForPrescriptionNamed("EU-Testmedikament")
            .tapNavigationMenu()

        expect(prescriptionScreen.redeemEUButton().exists).to(beFalse())

        prescriptionScreen.tapCenter()

        let dmcScreen = prescriptionScreen.tapShowMatrixCodeButton()
        expect(dmcScreen.redeemEUButton().exists).to(beFalse())
    }

    @MainActor
    func testShowInstructionsInRedeemFlow() {
        let selectionScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemEUToConsent()
            .tapAccept()

        let instructionsScreen = selectionScreen.tapInstructionsLink()
        expect(instructionsScreen.closeButton().waitForExistence(timeout: 1.0)).to(beTrue())
    }

    @MainActor
    func testExpiredCodeMessageIsShown() async {
        let bridge = UITestBridgeClient()

        let selectionScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemEUToConsent()
            .tapAccept()

        await bridge.sendMessage(.scenarioStep(1))

        let prescriptionScreen = selectionScreen.tapPrescriptions()
        prescriptionScreen.tapFirstPrescription()

        await bridge.sendMessage(.scenarioStep(2))

        let selectionAfterPrescriptions = prescriptionScreen.tapBack()
        let countryScreen = selectionAfterPrescriptions.tapCountry()
        countryScreen.selectFirstCountry()

        await bridge.sendMessage(.scenarioStep(0))

        let codeScreen = selectionAfterPrescriptions.tapRedeem()
        expect(codeScreen.closeButton().waitForExistence(timeout: 1)).to(beTrue())

        expect(codeScreen.isExpiredMessage().waitForExistence(timeout: 1)).to(beTrue())
        expect(codeScreen.generateNewCodeButton().waitForExistence(timeout: 1)).to(beTrue())

        codeScreen.tapClose()
    }
}
