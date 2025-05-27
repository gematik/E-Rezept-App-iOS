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

final class RedeemUITests: XCTestCase {
    var app: XCUIApplication!

    override func tearDown() {
        super.tearDown()
    }

    @MainActor
    override func setUp() {
        super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "RedeemUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testRedeemSuccessScreenShowsRatingDialog() async throws {
        let redeemScreenNoPharm = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()

        expect(redeemScreenNoPharm.redeemButton().isEnabled).to(beFalse())

        let redeemScreen = redeemScreenNoPharm
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()

        redeemScreen.editPrescriptionButton().tap()
        expect(self.app.buttons["Bdavomilproston"].isSelected).to(beTrue())
        expect(self.app.buttons["Adavomilproston"].isSelected).to(beTrue())

        app.buttons["Zurück"].tap()

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        try await redeemScreen
            .tapRedeem()
            .tapClose()

        let de = app.staticTexts["Gefällt dir E-Rezept?"]
        let en = app.staticTexts["Enjoying E-prescription?"]

        var result = false

        for _ in 1 ... 10 {
            if !result {
                try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 200)
                result = de.exists || en.exists
            } else {
                break
            }
        }
        expect(result).to(beTrue())
        if app.buttons["Not Now"].exists {
            app.buttons["Not Now"].tap()
        }
        if app.buttons["Später"].exists {
            app.buttons["Später"].tap()
        }
    }

    @MainActor
    func testRedeemWithPickupSuccess() async throws {
        let redeemScreenNoPharm = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()

        expect(redeemScreenNoPharm.redeemButton().isEnabled).to(beFalse())

        let redeemScreen = redeemScreenNoPharm
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_02_TEST-ONLY")
            .tapRedeem(.pickup)

        redeemScreen.editPrescriptionButton().tap()
        expect(self.app.buttons["Bdavomilproston"].isSelected).to(beTrue())
        expect(self.app.buttons["Adavomilproston"].isSelected).to(beTrue())

        app.buttons["Zurück"].tap()

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testRedeemWithDelivierySuccess() async throws {
        let redeemScreenNoPharm = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()

        expect(redeemScreenNoPharm.redeemButton().isEnabled).to(beFalse())

        let redeemScreen = redeemScreenNoPharm
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_03_TEST-ONLY")
            .tapRedeem(.delivery)

        redeemScreen.editPrescriptionButton().tap()
        expect(self.app.buttons["Bdavomilproston"].isSelected).to(beTrue())
        expect(self.app.buttons["Adavomilproston"].isSelected).to(beTrue())

        app.buttons["Zurück"].tap()

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testRedeemChecksForInProgressPrescriptions() async throws {
        let bridge = UITestBridgeClient()

        let redeemScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()

        await bridge.sendMessage(.scenarioStep(1))

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        redeemScreen.redeemButton().tap()

        let alert = app.alerts["Rezept nicht einlösbar"]
        expect(alert.waitForExistence(timeout: 1)).to(beTrue())
        let alertButtonA = alert.buttons["Ohne dieses Rezept fortfahren"]
        expect(alertButtonA.exists).to(beTrue())
        alertButtonA.tap()

        let successScreen = SuccessScreen(app: app)
        try await successScreen.tapClose()
    }

    @MainActor
    func testRedeemChecksForInProgressPrescriptionsB() async throws {
        let bridge = UITestBridgeClient()

        let redeemScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()

        await bridge.sendMessage(.scenarioStep(1))

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        redeemScreen.redeemButton().tap()

        let alert = app.alerts["Rezept nicht einlösbar"]
        expect(alert.waitForExistence(timeout: 1)).to(beTrue())
        let alertButtonA = alert.buttons["Abbrechen"]
        expect(alertButtonA.exists).to(beTrue())
        alertButtonA.tap()

        await bridge.sendMessage(.scenarioStep(2))

        redeemScreen.redeemButton().tap()

        let alertB = app.alerts["Rezept nicht einlösbar"]
        expect(alertB.waitForExistence(timeout: 1)).to(beTrue())
        let alertButtonB = alert.buttons["Bestellung verwerfen"]
        expect(alertButtonB.exists).to(beTrue())
        alertButtonB.tap()
    }

    @MainActor
    func testRedeemFromDetailsPharmacyRedeem() async throws {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Adavomilproston")

        let redeemScreen = details
            .tapRedeemPharmacyButton()
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()

        expect(redeemScreen.editPharmacyButton().exists).to(beTrue())
        expect(redeemScreen.redeemButton().isEnabled).to(beFalse())

        let prescriptions = redeemScreen.editPrescriptionButton()
        expect(prescriptions.staticTexts["Adavomilproston"]).to(exist("Adavomilproston"))
        expect(prescriptions.staticTexts["1 Rezepte"]).to(exist("1 Rezepte"))

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testRedeemFromDetailsWithPickupSuccess() async throws {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Adavomilproston")

        let redeemScreen = details
            .tapRedeemPharmacyButton()
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_02_TEST-ONLY")
            .tapRedeem(.pickup)

        expect(redeemScreen.editPharmacyButton().exists).to(beTrue())
        expect(redeemScreen.redeemButton().isEnabled).to(beTrue())

        let prescriptions = redeemScreen.editPrescriptionButton()
        expect(prescriptions.staticTexts["Adavomilproston"]).to(exist("Adavomilproston"))
        expect(prescriptions.staticTexts["1 Rezepte"]).to(exist("1 Rezepte"))

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testRedeemFromDetailsWithDeliverySuccess() async throws {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Adavomilproston")

        let redeemScreen = details
            .tapRedeemPharmacyButton()
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_03_TEST-ONLY")
            .tapRedeem(.delivery)

        expect(redeemScreen.editPharmacyButton().exists).to(beTrue())
        expect(redeemScreen.redeemButton().isEnabled).to(beFalse())

        let prescriptions = redeemScreen.editPrescriptionButton()
        expect(prescriptions.staticTexts["Adavomilproston"]).to(exist("Adavomilproston"))
        expect(prescriptions.staticTexts["1 Rezepte"]).to(exist("1 Rezepte"))

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testRedeemChangePharmacyAndServiceOptions() async throws {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Adavomilproston")

        let redeemScreen = details
            .tapRedeemPharmacyButton()
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()
            .tapEditPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_08_TEST-ONLY")
            .tapRedeem(.pickup)
            .tapServiceOption(.delivery)
            .tapServiceOption(.shipment)

        let pharmacy = redeemScreen.editPharmacyButton()
        expect(pharmacy.staticTexts["ZoTI_08_TEST-ONLY"].exists).to(beTrue())
        expect(redeemScreen.editPharmacyButton().exists).to(beTrue())
    }

    @MainActor
    func testRedeemFromDetailsShowMatrixCode() {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Adavomilproston")

        let redeem = details
            .tapShowMatrixCodeButton()

        expect(self.app.staticTexts["Adavomilproston"].waitForExistence(timeout: 3)).to(beTrue())
        expect(self.app.staticTexts["Adavomilproston"]).to(exist("Adavomilproston"))
        expect(redeem.title().label).to(equal("Rezeptcode"))
    }
}
