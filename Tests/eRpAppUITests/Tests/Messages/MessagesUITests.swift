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
class MessagesUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        // https://chromium.googlesource.com/chromium/src/+/HEAD/ios/build/bots/scripts/iossim_util_test.py
        if let defaults = UserDefaults(suiteName: "com.apple.keyboard.preferences") {
            defaults.set(true, forKey: "DidShowContinuousPathIntroduction")
            defaults.set(true, forKey: "UIKeyboardDidShowInternationalInfoIntroduction")
        }

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
            let chips: [String]
        }

        let dispReqBaseText = """
        Rezept an %@ gesendet. Einige Apotheken haben noch keine digitale Antwortmöglichkeit. \
        Falls bis morgen keine Rückmeldung erfolgt, rufen Sie bitte vorsichtshalber an.
        """

        let orders = [
            // [TEST:COM001]
            "ZoTI_01_TEST-ONLY": [
                Message(
                    title: String(format: dispReqBaseText, "ZoTI_01_TEST-ONLY"),
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Alle Rezepte der Bestellung"]
                ),
                Message(
                    title: "01 Info/Para + HRcode/Para + DMC/Para + URL/Para",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: "T01__R01",
                    chips: ["Ibuprofen 08", "Traubenzucker 5g"]
                ),
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Ibuprofen 08", "Super Heiler 15g"]
                ),
                Message(
                    title: "🎉 Ihre Bestellung liegt zur Abholung bereit. Bitte zeigen Sie diesen Abholcode vor um" +
                        " sich auszuweisen.",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: "T03__R01",
                    chips: ["Ibuprofen 08"]
                ),
                Message(
                    title: "04 Info_Para + HRcode_Para + DMC_noPara + URL_Para",
                    link: "https://www.gematik.de",
                    DMC: true,
                    HDMC: "T04__R01",
                    chips: ["Ibuprofen 08"]
                ),
            ].reversed(),
            // [TEST:COM002]
            "ZoTI_02_TEST-ONLY": [
                Message(
                    title: String(format: dispReqBaseText, "ZoTI_02_TEST-ONLY"),
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Vita-Tee"]
                ),
                Message(
                    title: "05 Info/Para + NoHRcode + NoDMC + URL/Para",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: nil,
                    chips: ["Vita-Tee"]
                ),
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Vita-Tee"]
                ),
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Vita-Tee"]
                ),
                Message(
                    title: "08 Info/Para + NoHRcode + NoDMC + NoURL",
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Vita-Tee"]
                ),
            ].reversed(),
            // [TEST:COM003]
            "ZoTI_03_TEST-ONLY": [
                Message(
                    title: String(format: dispReqBaseText, "ZoTI_03_TEST-ONLY"),
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Traubenzucker 5g"]
                ),
                Message(
                    title: "Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.",
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Traubenzucker 5g"]
                ),
                Message(
                    title: "10 Info/Para + NoHRcode + NoDMC + URL/Para",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: nil,
                    chips: ["Traubenzucker 5g"]
                ),
                Message(
                    title: "11 Info/Para + NoHRcode + NoDMC + NoURL",
                    link: nil,
                    DMC: false,
                    HDMC: nil,
                    chips: ["Traubenzucker 5g"]
                ),
                Message(
                    title: "Die Apotheke hat Ihnen einen Link zur Verfügung gestellt.",
                    link: "https://www.gematik.de",
                    DMC: false,
                    HDMC: nil,
                    chips: ["Traubenzucker 5g"]
                ),
            ].reversed(),
        ]

        // Prefill Pharmacies by adding favorites
        let pharmacySearch = tabBar.tapPharmacySearchTab()
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
                let chipsLabel = messageContainer.chipTexts().map(\.label)
                expect(chipsLabel).to(contain(message.chips))
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
