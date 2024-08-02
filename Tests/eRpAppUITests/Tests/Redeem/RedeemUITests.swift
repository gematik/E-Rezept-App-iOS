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
        let redeemScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()

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

    func testRedeemFromDetailsPharmacyRedeem() {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Adavomilproston")

        _ = details
            .tapRedeemPharmacyButton()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()

        let prescriptions = app.buttons["pha_redeem_btn_edit_prescription"]
        expect(prescriptions.staticTexts["Adavomilproston"]).to(exist("Adavomilproston"))
        expect(prescriptions.staticTexts["1 Rezepte"]).to(exist("1 Rezepte"))
    }

    func testRedeemFromDetailsShowMatrixCode() {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Adavomilproston")

        let redeem = details
            .tapShowMatrixCodeButton()

        expect(self.app.staticTexts["Adavomilproston"]).to(exist("Adavomilproston"))
        expect(redeem.title().label).to(equal("Rezeptcode"))
    }
}