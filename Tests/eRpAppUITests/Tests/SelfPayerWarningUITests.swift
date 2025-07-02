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
class SelfPayerWarningUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "SelfPayerWarningUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testSelfPayerWarningInMatrixCodeView() async throws {
        let matrixCodeScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemLocal()

        expect(matrixCodeScreen.selfPayerWarning().label).to(
            equal(
                "Für die Rezepte 'SelfPayer3' & 'SelfPayer2' & 'SelfPayer1' übernimmt Ihre Versicherung keine Kosten. "
            )
        )
    }

    @MainActor
    func testSelfPayerWarningInPrescriptionDetailView() async throws {
        let prescriptionDetailScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("SelfPayer1")

        expect(prescriptionDetailScreen.selfPayerHeadlineButton().exists).to(beTrue())
        expect(prescriptionDetailScreen.tapSelfPayerHeadlineButton().app.exists).to(beTrue())

        // Close Drawer
        prescriptionDetailScreen.app.swipeDown()

        let matrixCodeScreen = prescriptionDetailScreen.tapShowMatrixCodeButton()

        expect(matrixCodeScreen.selfPayerWarning().label)
            .to(equal("Für dieses Rezept übernimmt Ihre Versicherung keine Kosten."))
    }

    @MainActor
    func testSelfPayerWarningInRedeemView() async throws {
        let redeemScreen = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()
            .tapAddPharmacy()
            .pharmacyDetailsForPharmacy("ZoTI_04_TEST-ONLY")
            .tapRedeem()

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        // Check if All 3 Warning 231
        expect(redeemScreen.selfPayerWarning().label).to(
            equal(
                "Für die Rezepte 'SelfPayer3' & 'SelfPayer2' & 'SelfPayer1' übernimmt Ihre Versicherung keine Kosten. "
            )
        )

        // Delected 1 SEL -> 2 in Total
        let selectionScreen = redeemScreen.tapEditPrescriptions()
        selectionScreen.cellForPrescriptionNamed("SelfPayer1").tap()
        selectionScreen.tapSave()
        print(redeemScreen.selfPayerWarning().debugDescription)

        // Check Text 2 Waring
        expect(redeemScreen.selfPayerWarning().label)
            .to(equal("Für die Rezepte 'SelfPayer3' & 'SelfPayer2' übernimmt Ihre Versicherung keine Kosten. "))

        // Deselect 1 SEL (1 Normal)
        let selectionScreen2 = redeemScreen.tapEditPrescriptions()
        selectionScreen2.cellForPrescriptionNamed("SelfPayer2").tap()
        selectionScreen2.tapSave()

        // Check Multi but 1 SEL Text
        expect(redeemScreen.selfPayerWarning().label)
            .to(equal("Für das Rezept 'SelfPayer3' übernimmt Ihre Versicherung keine Kosten. "))

        // Deselect Normal Task
        let selectionScreen3 = redeemScreen.tapEditPrescriptions()
        selectionScreen3.cellForPrescriptionNamed("Ibuprofen 04").tap()
        selectionScreen3.tapSave()

        // Check Single SEL TOTAL Text
        expect(redeemScreen.selfPayerWarning().label)
            .to(equal("Für dieses Rezept übernimmt Ihre Versicherung keine Kosten."))
    }
}
