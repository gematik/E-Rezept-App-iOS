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
class OrderHealthCardUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "1"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testStatus() async {
        await UITestBridgeClient().sendMessage(.loginStatus(false))

        let tabBar = TabBarScreen(app: app)

        let orderHealthCard = tabBar
            .tapPrescriptionsTab()
            .tapOpenCardwall()
            .tapOrderHealthCard()

        let details = orderHealthCard.selectInsuranceCompany("AOK - Die Gesundheitskasse Niedersachsen")

        let contact = details.tapPin()

        expect(contact.mailBtn().exists).to(beFalse())
        expect(contact.webBtn().exists).to(beTrue())
        expect(contact.phoneBtn().exists).to(beTrue())

        let contact2 = contact
            .tapBackButton()
            .tapPinAndCard()

        expect(contact2.mailBtn().exists).to(beFalse())
        expect(contact2.webBtn().exists).to(beFalse())
        expect(contact2.phoneBtn().exists).to(beTrue())
    }
}
