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

import eRpResources
import Foundation
import XCTest

@MainActor
final class PharmacyUITests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "PharmacyUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos
        // swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func assertPharmacyServices(
        pharmacyName: String,
        services: [PharmacyDetailsScreen.Service],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        app
            .otherElements[A11y.pharmacySearch.phaSearchTxtResultList]
            .children(matching: .button)
            .containing(NSPredicate(format: "label like '\(pharmacyName)'"))
            .element
            .tap()

        XCTAssertTrue(app.staticTexts[A11y.pharmacyDetail.phaDetailTxtSubtitle].exists, file: file, line: line)
        XCTAssertEqual(
            app.staticTexts[A11y.pharmacyDetail.phaDetailTxtSubtitle].label,
            pharmacyName,
            file: file,
            line: line
        )

        for serviceType in PharmacyDetailsScreen.Service.allCases {
            XCTAssertEqual(
                services.contains(serviceType),
                app.buttons[serviceType.buttonId].exists,
                "expected '.\(serviceType.rawValue)' to \(services.contains(serviceType) ? "not " : "")be" +
                    " present within '\(pharmacyName)'",
                file: file,
                line: line
            )
        }

        // Back
        app.navigationBars.buttons.firstMatch.tap()
    }

    @MainActor
    func assertFilterOptionExists(
        _ filterLabel: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let option = app.switches.element(matching: .init(format: "label == %@", filterLabel))
        XCTAssertTrue(
            option.waitForExistence(timeout: 2),
            "Expected filter option '\(filterLabel)' to be present in the filter view",
            file: file,
            line: line
        )
        option.tap()
        XCTAssertEqual(
            option.value as? String,
            "1",
            "Expected filter option '\(filterLabel)' to be selected after tapping",
            file: file,
            line: line
        )
    }

    @MainActor
    func assertServiceFilterOptionExists(
        _ serviceLabel: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let option = app.switches.element(matching: .init(format: "label CONTAINS %@", serviceLabel))
        XCTAssertTrue(
            option.waitForExistence(timeout: 2),
            "Expected service filter option '\(serviceLabel)' to be present in the filter view",
            file: file,
            line: line
        )
        option.tap()
        XCTAssertTrue(
            option.waitForExistence(timeout: 2),
            "Expected service filter option '\(serviceLabel)' to still exist after tapping",
            file: file,
            line: line
        )
    }

    @MainActor
    func assertFilterChipExists(
        _ chipIdentifier: String,
        shouldExist: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let chip = app.otherElements[A11y.pharmacySearch.phaFilterFilterList]
            .children(matching: .button)
            .matching(identifier: chipIdentifier)
            .element

        if shouldExist {
            XCTAssertTrue(
                chip.waitForExistence(timeout: 2),
                "Expected filter chip with identifier '\(chipIdentifier)' to exist",
                file: file,
                line: line
            )
        } else {
            XCTAssertTrue(
                chip.waitForNonExistence(timeout: 2),
                "Expected filter chip with identifier '\(chipIdentifier)' to not exist",
                file: file,
                line: line
            )
        }
    }

    @MainActor
    func testPharmacyServiceButtons() async throws {
        app.buttons.element(matching: .init(format: "label == %@", "Apothekensuche")).tap()
        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")

        XCUIApplication().keyboards.buttons["Suchen"].tap()

        try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 500)

        assertPharmacyServices(pharmacyName: "ZoTI_01_TEST-ONLY", services: [])
        assertPharmacyServices(pharmacyName: "ZoTI_05_TEST-ONLY", services: [.pickupViaLogin])
        assertPharmacyServices(pharmacyName: "ZoTI_06_TEST-ONLY", services: [.deliveryViaLogin])
        assertPharmacyServices(pharmacyName: "ZoTI_07_TEST-ONLY", services: [.shipmentViaLogin])
        assertPharmacyServices(
            pharmacyName: "ZoTI_12_TEST-ONLY",
            services: [.pickupViaLogin, .deliveryViaLogin, .shipmentViaLogin]
        )
        assertPharmacyServices(pharmacyName: "ZoTI_20_TEST-ONLY", services: [.pickupViaLogin, .shipmentViaLogin])

        // Back
        app.navigationBars.buttons.firstMatch.tap()
    }

    @MainActor
    func testSwitchToMap() {
        app.buttons.element(matching: .init(format: "label == %@", "Apothekensuche")).tap()
        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")

        XCUIApplication().keyboards.buttons["Suchen"].tap()

        // SwitchToMap Button
        app.buttons.element(matching: .init(format: "identifier == %@", "pha_search_switch_result_map")).tap()

        XCTAssertTrue(app.otherElements.matching(identifier: "pha_search_map_map")
            .children(matching: .other)
            .matching(NSPredicate(format: "label like '+5 weitere'"))
            .element.waitForExistence(timeout: 5))
    }

    @MainActor
    func testStartViewQuickFilter() {
        let pharmacySearchScreen = TabBarScreen(app: app).tapPharmacySearchTab()

        // Tap the "Botendienst" quick filter chip on the search start view
        pharmacySearchScreen.tapQuickFilterDelivery()

        // Result list should appear and contain at least one pharmacy entry
        assertPharmacyServices(pharmacyName: "ZoTI_06_TEST-ONLY", services: [.deliveryViaLogin])
        assertPharmacyServices(
            pharmacyName: "ZoTI_12_TEST-ONLY",
            services: [.shipmentViaLogin, .deliveryViaLogin, .pickupViaLogin]
        )
    }

    @MainActor
    func testSearchFilter() {
        let tabBar = TabBarScreen(app: app)

        let resultScreen = tabBar.tapPharmacySearchTab()

        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")
        XCUIApplication().keyboards.buttons["Suchen"].tap()

        let filterScreen = resultScreen.tapFilter()

        // Check that all expected filter options are present
        // Preferences
        assertFilterOptionExists("Aktuell geöffnet")
        // assertFilterOptionExists("In meiner Nähe")
        assertFilterOptionExists("Zuletzt genutzt")
        // Redeem method
        assertFilterOptionExists("Abholung")
        assertFilterOptionExists("Botendienst")
        assertFilterOptionExists("Versand")
        // Physical features
        assertFilterOptionExists("ÖPNV in der Nähe")
        assertFilterOptionExists("Parkmöglichkeit")
        assertFilterOptionExists("Barrierefreier Zugang")
        assertFilterOptionExists("Abholautomat")
        // Services
        assertServiceFilterOptionExists("Allergietest erwerben")
        assertServiceFilterOptionExists("Beratung bei Organtransplantation")
        assertServiceFilterOptionExists("Beratung bei Polymedikation")
        assertServiceFilterOptionExists("Betreuung oraler Krebstherapie")
        assertServiceFilterOptionExists("Bluthochdruck kontrollieren")
        assertServiceFilterOptionExists("Impfen lassen")
        assertServiceFilterOptionExists("Inhalationsschulung")
        assertServiceFilterOptionExists("Körperwerte messen")
        assertServiceFilterOptionExists("Reisemedizinberatung")
        assertServiceFilterOptionExists("Sterilherstellung")

        // All options have been tapped above -> reset before the specific filter scenario below
        filterScreen.tapResetFilters()

        filterScreen.tapFilterOption("Versand")

        filterScreen.closeFilter()

        assertFilterChipExists("shipment")

        let redeemSearchScreen = tabBar.tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()
            .tapAddPharmacy()

        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")
        XCUIApplication().keyboards.buttons["Suchen"].tap()

        assertFilterChipExists("shipment")
        assertFilterChipExists("delivery", shouldExist: false)

        let filterScreen2 = redeemSearchScreen.tapFilter()

        filterScreen2.tapFilterOption("Botendienst")

        filterScreen2.closeFilter()

        assertFilterChipExists("shipment")
        assertFilterChipExists("delivery")
        assertFilterChipExists("pickupAutomat", shouldExist: false)

        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")
        XCUIApplication().keyboards.buttons["Suchen"].tap()

        let filterScreen3 = redeemSearchScreen.tapFilter()

        filterScreen3.tapFilterOption("Abholautomat")

        filterScreen3.closeFilter()

        assertFilterChipExists("shipment")
        assertFilterChipExists("delivery")
        assertFilterChipExists("pickupAutomat")

        redeemSearchScreen.tapSearchCancelButton()
        redeemSearchScreen.tapCancelButton()

        tabBar.tapPharmacySearchTab()

        // Check for filter Botendienst & Open + neue Suche
        assertFilterChipExists("shipment")
        assertFilterChipExists("delivery")
        assertFilterChipExists("pickupAutomat")

        // Tap the shipment chip to remove it
        resultScreen.tapTopBarFilterChip("shipment")

        assertFilterChipExists("shipment", shouldExist: false)
        assertFilterChipExists("delivery")
        assertFilterChipExists("pickupAutomat")

        // Open filter view and reset all filters
        let filterScreen4 = resultScreen.tapFilter()

        filterScreen4.tapResetFilters()

        filterScreen4.closeFilter()

        // All filter chips should be gone after reset
        assertFilterChipExists("shipment", shouldExist: false)
        assertFilterChipExists("delivery", shouldExist: false)
        assertFilterChipExists("pickupAutomat", shouldExist: false)

        assertFilterChipExists("allergyTest", shouldExist: false)

        // Open filter view again for service section tests
        let filterScreen5 = resultScreen.tapFilter()

        // Tap "Erklären" — descriptions should become visible
        filterScreen5.tapExplainToggle()
        XCTAssertTrue(app.buttons
            .element(matching: .init(format: "label == %@", "Nicht erklären"))
            .waitForExistence(timeout: 2))

        // Tap "Nicht erklären" — descriptions should hide again
        filterScreen5.tapExplainToggle()
        XCTAssertTrue(app.buttons
            .element(matching: .init(format: "label == %@", "Erklären"))
            .waitForExistence(timeout: 2))

        // Select "Allergietest erwerben" service
        filterScreen5.tapServiceOption("Allergietest erwerben")

        filterScreen5.closeFilter()

        // Verify allergyTest chip appears in the filter list
        assertFilterChipExists("allergyTest")
    }

    @MainActor
    func testRedeemWithShipmentSuccess() async throws {
        let pharmacySearchScreen = TabBarScreen(app: app)
            .tapPharmacySearchTab()

        let redeemScreen = pharmacySearchScreen
            .pharmacyDetailsForPharmacy("ZoTI_07_TEST-ONLY")
            .tapRedeem(.shipmentViaLogin)

        redeemScreen.editPrescriptionButton().tap()
        app.buttons["Adavomilproston, Noch 19 Tage einlösbar"].tap()
        app.buttons["Speichern"].tap()

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testRedeemWithPickupSuccess() async throws {
        let pharmacySearchScreen = TabBarScreen(app: app)
            .tapPharmacySearchTab()

        let redeemScreen = pharmacySearchScreen
            .pharmacyDetailsForPharmacy("ZoTI_05_TEST-ONLY")
            .tapRedeem(.pickupViaLogin)

        redeemScreen.editPrescriptionButton().tap()
        app.buttons["Adavomilproston, Noch 19 Tage einlösbar"].tap()
        app.buttons["Speichern"].tap()

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testRedeemWithDeliverySuccess() async throws {
        let pharmacySearchScreen = TabBarScreen(app: app)
            .tapPharmacySearchTab()

        let redeemScreen = pharmacySearchScreen
            .pharmacyDetailsForPharmacy("ZoTI_06_TEST-ONLY")
            .tapRedeem(.deliveryViaLogin)

        redeemScreen.editPrescriptionButton().tap()
        app.buttons["Adavomilproston, Noch 19 Tage einlösbar"].tap()
        app.buttons["Speichern"].tap()

        let editAdressScreen = redeemScreen
            .tapEditAddress()

        editAdressScreen.setPhoneNumber("1234567890")
        try await editAdressScreen.tapSave()

        try await redeemScreen
            .tapRedeem()
            .tapClose()
    }

    @MainActor
    func testAllServicesAreShownOnPharmacyDetailView() {
        let pharmacySearchScreen = TabBarScreen(app: app).tapPharmacySearchTab()
        _ = pharmacySearchScreen.pharmacyDetailsForPharmacy("ZoTI_20_TEST-ONLY")

        // Physical features ("Vor Ort" section)
        let expectedPhysicalFeatures = [
            "Parkmöglichkeit",
            "ÖPNV in der Nähe",
            "Barrierefreier Zugang",
            "Abholautomat",
        ]
        for feature in expectedPhysicalFeatures {
            XCTAssertTrue(
                app.staticTexts[feature].waitForExistence(timeout: 2),
                "Expected physical feature '\(feature)' to be visible on pharmacy detail"
            )
        }

        // Specialities ("Services" section)
        let expectedSpecialities = [
            "Allergietest erwerben",
            "Beratung bei Organtransplantation",
            "Beratung bei Polymedikation",
            "Betreuung oraler Krebstherapie",
            "Bluthochdruck kontrollieren",
            "Impfen lassen",
            "Inhalationsschulung",
            "Körperwerte messen",
            "Reisemedizinberatung",
            "Sterilherstellung",
        ]
        for speciality in expectedSpecialities {
            XCTAssertTrue(
                app.staticTexts[speciality].waitForExistence(timeout: 2),
                "Expected speciality '\(speciality)' to be visible on pharmacy detail"
            )
        }
    }

    override func tearDown() {
        super.tearDown()
    }
}
