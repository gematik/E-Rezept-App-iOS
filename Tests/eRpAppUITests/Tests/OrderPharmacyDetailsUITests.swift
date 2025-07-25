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
class OrderPharmacyDetailsUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "OrderPharmacyDetailsUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testPharmacyDetails() async throws {
        let bridge = UITestBridgeClient()
        let pharmacyName = "Schloss Apotheke"
        let tabBar = TabBarScreen(app: app)
        let orderView = tabBar.tapOrderTab()

        let orderDetailsView = orderView.tapOrderDetailsForPharmacyNamed(pharmacyName)
        let pharmacyDetails = orderDetailsView.tapOpenPharmacyDetails()

        expect(pharmacyDetails.buttonForContact(.phone).exists).to(beTrue())
        expect(pharmacyDetails.buttonForContact(.mail).exists).to(beTrue())
        expect(pharmacyDetails.buttonForContact(.map).exists).to(beTrue())

        pharmacyDetails.expandSheet()

        expect(pharmacyDetails.contactSectionHeader().exists).to(beTrue())

        pharmacyDetails.tapClose()

        await bridge.sendMessage(.scenarioStep(1))

        let pharmacyDetails2 = orderDetailsView.tapOpenPharmacyDetails()

        expect(pharmacyDetails2.buttonForContact(.mail).exists).to(beTrue())
        expect(pharmacyDetails2.buttonForContact(.map).exists).to(beTrue())

        pharmacyDetails.tapClose()

        await bridge.sendMessage(.scenarioStep(2))

        let pharmacyDetails3 = orderDetailsView.tapOpenPharmacyDetails()

        expect(pharmacyDetails3.buttonForContact(.map).exists).to(beTrue())

        pharmacyDetails.tapClose()
    }
}
