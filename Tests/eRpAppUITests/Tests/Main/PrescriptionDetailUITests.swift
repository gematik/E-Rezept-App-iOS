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
final class PrescriptionDetailUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "PrescriptionDetailUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testEditPrescriptionName_autidem() {
        let medicationName = "Adavomilproston"

        let tabBar = TabBarScreen(app: app)

        let details = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed(medicationName)

        let autIdemDrawer = details.tapAutIdemInfoButton()
        expect(details.autIdemHeadlineButton().exists).to(beFalse())

        expect(autIdemDrawer.title()).to(equal("Ersatzpräparat möglich"))
        expect(autIdemDrawer.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
    }

    @MainActor
    func testEditPrescriptionName_autidem_disabled() {
        let medicationName = "Bdavomilproston"

        let tabBar = TabBarScreen(app: app)

        let details = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed(medicationName)

        let autIdemDrawer = details.tapAutIdemInfoButton()
        expect(autIdemDrawer.title()).to(equal("Kein Ersatzpräparat möglich"))
        expect(autIdemDrawer.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer.close()

        expect(details.autIdemHeadlineButton().exists).to(beTrue())
        let autIdemDrawer2 = details.tapAutIdemHeadlineButton()
        expect(autIdemDrawer2.title()).to(equal("Kein Ersatzpräparat möglich"))
        expect(autIdemDrawer2.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer2.close()
    }

    @MainActor
    func testEditPrescriptionName_autidem_archive() {
        let medicationName = "Cdavomilproston"

        let tabBar = TabBarScreen(app: app)

        let details = tabBar
            .tapPrescriptionsTab()
            .tapArchive()
            .detailsForPrescriptionNamed(medicationName)

        let autIdemDrawer = details.tapAutIdemInfoButton()
        expect(details.autIdemHeadlineButton().exists).to(beFalse())

        expect(autIdemDrawer.title()).to(equal("Ersatzpräparat möglich"))
        expect(autIdemDrawer.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
    }

    @MainActor
    func testEditPrescriptionName_autidem_archive_disabled() {
        let medicationName = "Ddavomilproston"

        let tabBar = TabBarScreen(app: app)

        let details = tabBar
            .tapPrescriptionsTab()
            .tapArchive()
            .detailsForPrescriptionNamed(medicationName)

        let autIdemDrawer = details.tapAutIdemInfoButton()
        expect(autIdemDrawer.title()).to(equal("Kein Ersatzpräparat möglich"))
        expect(autIdemDrawer.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer.close()

        expect(details.autIdemHeadlineButton().exists).to(beTrue())
        let autIdemDrawer2 = details.tapAutIdemHeadlineButton()
        expect(autIdemDrawer2.title()).to(equal("Kein Ersatzpräparat möglich"))
        expect(autIdemDrawer2.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer2.close()
    }

    @MainActor
    func testMedicationReminderAvailableForScannedAndServerTasks() {
        let scannedTaskMedicationName = "Scanned Prescription"

        let tabBar = TabBarScreen(app: app)

        let firstMedicationReminderTest = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForScannedPrescription(scannedTaskMedicationName)
            .tapSetupMedicationReminder()

        expect(firstMedicationReminderTest.medicationNameLabel().label).to(equal(scannedTaskMedicationName))

        let remoteTaskMedicationName = "Bdavomilproston"

        let secondMedicationReminderTest = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed(remoteTaskMedicationName)
            .tapSetupMedicationReminder()

        expect(secondMedicationReminderTest.medicationNameLabel().label).to(equal(remoteTaskMedicationName))
    }

    override func tearDown() {
        super.tearDown()
    }
}
