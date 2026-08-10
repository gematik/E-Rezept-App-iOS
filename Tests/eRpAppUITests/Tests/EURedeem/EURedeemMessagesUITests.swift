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

import Nimble
import XCTest

@MainActor
final class EURedeemMessagesUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"
        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "EURedeemMessagesUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 10.0)
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    @MainActor
    func testDispensedEUPrescriptionShowsPharmacyName() {
        let ordersScreen = TabBarScreen(app: app).tapOrderTab()

        let pharmacyNameLabel = ordersScreen.app.staticTexts["EU Apotheke Muster"].firstMatch
        expect(pharmacyNameLabel.waitForExistence(timeout: 5.0)).to(beTrue())
    }

    @MainActor
    func testManuallyRevokeAccessCode() {
        let ordersScreen = TabBarScreen(app: app).tapOrderTab()
        let orderDetails = ordersScreen.tapEUOrderDetails()

        let messageContainer = orderDetails.message(at: 0)

        expect(messageContainer.revokeAccessCodeButton().waitForExistence(timeout: 5.0)).to(beTrue())
        messageContainer.tapRevokeAccessCode()
            .tapRevokeButton()
            .tapCloseButton()
    }

    @MainActor
    func testShowAndRegenerateAccessCode() {
        let ordersScreen = TabBarScreen(app: app).tapOrderTab()
        let orderDetails = ordersScreen.tapEUOrderDetails()

        let messageContainer = orderDetails.message(at: 0)

        expect(messageContainer.showAccessCodeButton().waitForExistence(timeout: 5.0)).to(beTrue())
        _ = messageContainer.tapShowAccessCode()
            .generateNewCodeButton()
    }

    @MainActor
    func testTwoInvalidAccessCodes() {
        let ordersScreen = TabBarScreen(app: app).tapOrderTab()
        let orderDetails = ordersScreen.tapEUOrderDetails()

        let firstMessage = orderDetails.message(at: 0)
        let secondMessage = orderDetails.message(at: 1)

        expect(firstMessage.revokeAccessCodeButton().waitForExistence(timeout: 5.0)).to(beTrue())
        expect(secondMessage.revokeAccessCodeButton().waitForExistence(timeout: 5.0)).to(beFalse())
    }
}
