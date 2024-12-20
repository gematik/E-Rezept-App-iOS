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

class MessagesUITests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUp() {
        super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "MessagesUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    /// [TEST:COM001]
    /// [TEST:COM002]
    /// [TEST:COM003]
    @MainActor
    func testMessages() {
        let tabBar = TabBarScreen(app: app)

        struct Message {
            let title: String
            let link: String?
            let DMC: Bool
            let HDMC: String?
        }

        let orders = [
            // [TEST:COM001]
            "ZoTI_01_TEST-ONLY": [
                Message(
                    title: "01 Info/Para + HRcode/Para + DMC/Para + URL/Para",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: "T01__R01"
                ),
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil
                ),
                Message(
                    title: "🎉 Ihre Bestellung liegt zur Abholung bereit. Bitte zeigen Sie diesen Abholcode vor um" +
                        " sich auszuweisen.",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: "T03__R01"
                ),
                Message(
                    title: "04 Info_Para + HRcode_Para + DMC_noPara + URL_Para",
                    link: "https://www.gematik.de",
                    DMC: true,
                    HDMC: "T04__R01"
                ),
            ].reversed(),
            // [TEST:COM002]
            "ZoTI_02_TEST-ONLY": [
                Message(
                    title: "05 Info/Para + NoHRcode + NoDMC + URL/Para",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: nil
                ),
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil
                ),
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil
                ),
                Message(
                    title: "08 Info/Para + NoHRcode + NoDMC + NoURL",
                    link: nil,
                    DMC: false,
                    HDMC: nil
                ),
            ].reversed(),
            // [TEST:COM003]
            "ZoTI_03_TEST-ONLY": [
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil
                ),
                Message(
                    title: "10 Info/Para + NoHRcode + NoDMC + URL/Para",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: nil
                ),
                Message(title: "11 Info/Para + NoHRcode + NoDMC + NoURL", link: nil, DMC: false, HDMC: nil),
                Message(
                    title: "Die Apotheke hat Ihnen einen Link zur Verfügung gestellt.",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: nil
                ),
            ].reversed(),
        ]

        // Prefill Pharmacies by adding favorites
        let pharmacySearch = tabBar.tapRedeemTab()
        pharmacySearch.searchFor("A")

        for name in orders.keys {
            let details = pharmacySearch.pharmacyDetailsForPharmacy(name)
            details.tapFavorite()
            details.tapBackButton()
        }

        // Navigate to Orders
        let messagesScreen = tabBar
            .tapOrderTab()

        for (name, messages) in orders {
            let orderDetails = messagesScreen.tapOrderDetailsForPharmacyNamed(name)

            for (index, message) in messages.enumerated() {
                let messageDescription = "\(name) - \(messages.count - 1 - index)"
                let messageContainer = orderDetails.message(at: index)
                let title = messageContainer.title()
                expect(title.value as? String).to(equal(message.title), description: messageDescription)
                expect(messageContainer.linkButton().exists)
                    .to(equal(message.link != nil), description: messageDescription)

                if message.DMC || message.HDMC != nil {
                    // open dmc sheet
                    let dmcScreen = messageContainer.tapDmcButton()

                    if let hdmc = message.HDMC {
                        expect(dmcScreen.humanReadableCode().label).to(equal(hdmc))
                    }
                    if message.DMC {
                        print("DMC")
                    }
                    dmcScreen.tapClose()
                    // close dmc sheet
                } else {
                    expect(messageContainer.dmcButton().exists).to(beFalse())
                }
            }

            orderDetails.tapBackButton()
        }

        expect(messagesScreen.navigationTitle()).to(exist("Navigation Title"))
    }

    @MainActor
    func testWelcomeMessage() {
        let tabBar = TabBarScreen(app: app)

        let messages = tabBar.tapOrderTab().tapOrderDetailsForPharmacyNamed("E-Rezept App Team")
        expect(messages.app.textViews
            .containing(NSPredicate(format: "label BEGINSWITH %@", "Herzlich Willkommen in der E-Rezept App!")).element
            .exists).to(beTrue())
    }
}
