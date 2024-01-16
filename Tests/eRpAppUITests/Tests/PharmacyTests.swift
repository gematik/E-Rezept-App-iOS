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
import XCTest

final class PharmacyTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

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

    func assertPharmacyServices(
        pharmacyName: String,
        services: [Service],
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

        for serviceType in Service.allCases {
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

    enum Service: String, CaseIterable {
        case pickup
        case pickupViaLogin
        case delivery
        case deliveryViaLogin
        case shipment
        case shipmentViaLogin

        var buttonId: String {
            switch self {
            case .pickup:
                return A11y.pharmacyDetail.phaDetailBtnPickup
            case .pickupViaLogin:
                return A11y.pharmacyDetail.phaDetailBtnPickupViaLogin
            case .delivery:
                return A11y.pharmacyDetail.phaDetailBtnDelivery
            case .deliveryViaLogin:
                return A11y.pharmacyDetail.phaDetailBtnDeliveryViaLogin
            case .shipment:
                return A11y.pharmacyDetail.phaDetailBtnShipment
            case .shipmentViaLogin:
                return A11y.pharmacyDetail.phaDetailBtnShipmentViaLogin
            }
        }
    }

    func testPharmacyServiceButtons() {
        app.buttons.element(matching: .init(format: "label == %@", "Apothekensuche")).tap()
        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")

        XCUIApplication().keyboards.buttons["Suchen"].tap()

        assertPharmacyServices(pharmacyName: "ZoTI_01_TEST-ONLY", services: [])
        assertPharmacyServices(pharmacyName: "ZoTI_02_TEST-ONLY", services: [.pickup])
        assertPharmacyServices(pharmacyName: "ZoTI_03_TEST-ONLY", services: [.delivery])
        assertPharmacyServices(pharmacyName: "ZoTI_04_TEST-ONLY", services: [.shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_05_TEST-ONLY", services: [.pickupViaLogin])
        assertPharmacyServices(pharmacyName: "ZoTI_06_TEST-ONLY", services: [.deliveryViaLogin])
        assertPharmacyServices(pharmacyName: "ZoTI_07_TEST-ONLY", services: [.shipmentViaLogin])
        assertPharmacyServices(pharmacyName: "ZoTI_08_TEST-ONLY", services: [.pickup, .delivery, .shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_09_TEST-ONLY", services: [.pickup, .delivery, .shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_10_TEST-ONLY", services: [.pickup, .delivery, .shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_11_TEST-ONLY", services: [.pickup, .delivery, .shipment])
        assertPharmacyServices(
            pharmacyName: "ZoTI_12_TEST-ONLY",
            services: [.pickupViaLogin, .deliveryViaLogin, .shipmentViaLogin]
        )
        assertPharmacyServices(pharmacyName: "ZoTI_13_TEST-ONLY", services: [.pickup, .delivery])
        assertPharmacyServices(pharmacyName: "ZoTI_14_TEST-ONLY", services: [.pickup, .shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_15_TEST-ONLY", services: [.pickup, .shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_16_TEST-ONLY", services: [.shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_17_TEST-ONLY", services: [.pickup, .delivery])
        assertPharmacyServices(pharmacyName: "ZoTI_18_TEST-ONLY", services: [.pickup, .delivery, .shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_19_TEST-ONLY", services: [.delivery, .shipment])
        assertPharmacyServices(pharmacyName: "ZoTI_20_TEST-ONLY", services: [.pickupViaLogin, .shipmentViaLogin])

        // Back
        app.navigationBars.buttons.firstMatch.tap()
    }

    override func tearDown() {
        super.tearDown()
    }
}
