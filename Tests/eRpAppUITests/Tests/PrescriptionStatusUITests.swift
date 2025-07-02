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
class PrescriptionStatusUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "PrescriptionStatusUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        let flags = ["enable_medication_schedule"]
        let flagsData = try! JSONEncoder().encode(flags)
        let flagsString = String(data: flagsData, encoding: .utf8)
        app.launchEnvironment["UITEST.FLAGS"] = flagsString

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testStatus() {
        struct MedicationNameAndStatus {
            let name: String
            let status: String
        }

        let medicationStatusMapping: [MedicationNameAndStatus] = [
            .init(name: "Ibuprofen Broken", status: "Fehlerhaftes Rezept"),
            .init(name: "Ibuprofen 01", status: "Einlösbar"),
            .init(name: "Ibuprofen 02", status: "Warte auf Antwort"),
            .init(name: "Ibuprofen 03", status: "Einlösbar"),
            .init(name: "Ibuprofen 04", status: "Wird bearbeitet"),
            .init(name: "Ibuprofen 05", status: "Einlösbar"),
            .init(name: "Ibuprofen 06", status: "Warte auf Antwort"),
            .init(name: "Ibuprofen 08", status: "Wird bearbeitet"),
            .init(name: "Ibuprofen 10", status: "Wird bearbeitet"),
            .init(name: "Ibuprofen 11", status: "Ware steht bereit"),
        ]

        let archiveMedicationStatusMapping: [MedicationNameAndStatus] = [
            .init(name: "Ibuprofen 07", status: "Nicht mehr gültig"),
            .init(name: "Ibuprofen 09", status: "Eingelöst"),
        ]

        let tabBar = TabBarScreen(app: app)

        let mainView = tabBar.tapPrescriptionsTab()

        for mapping in medicationStatusMapping {
            let cell = mainView.prescriptionCellByName(mapping.name)
            expect(cell.staticTexts["erx_detailed_status"].label)
                .to(equal(mapping.status), description: "Status for \(mapping.name)")
        }

        let archiveView = mainView.tapArchive()

        for mapping in archiveMedicationStatusMapping {
            let cell = archiveView.prescriptionCellByName(mapping.name)
            expect(cell.staticTexts["erx_detailed_status"].label)
                .to(equal(mapping.status), description: "Status for \(mapping.name)")
        }
    }

    @MainActor
    func testProvidedStatus() {
        let details = TabBarScreen(app: app)
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed("Ibuprofen 11")

        expect(details.medicationButton()).to(exist("Ibuprofen 11"))
        let medicationDetails = details.tapMedicationButton()

        expect(medicationDetails.tradingName()).to(equal("Ibuprofen 11"))
    }
}
