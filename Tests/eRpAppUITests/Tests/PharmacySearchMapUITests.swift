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
import MapKit
import Nimble
import XCTest

final class PharmacySearchMapUITests: XCTestCase {
    var app: XCUIApplication!

    override func tearDown() {
        super.tearDown()

        notificationAlertMonitor.map { [self] in removeUIInterruptionMonitor($0) }
    }

    var locationDialogInterruptAnswered = false

    var notificationAlertMonitor: NSObjectProtocol?

    override func setUp() {
        super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"
        app.resetAuthorizationStatus(for: .location)

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "PharmacySearchMapUITest"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)
    }

    func testPharmacySearchMapFilterOptions() {
        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForDenial()

        let mapScreen = tabBar
            .tapRedeemTab()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        mapScreen
            .tapFilter()
            .tapFilterOption("Aktuell geöffnet")
    }

    func testAllowLocation() throws {
        if #available(iOS 16.4, *) {
            XCUIDevice.shared.location = XCUILocation(location: .init(latitude: 52.52291, longitude: 13.38757))
        } else {
            throw XCTSkip("location cannot be set on old iOS simulator versions")
        }

        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForAcceptance()

        tabBar
            .tapRedeemTab()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        XCTAssertTrue(app.otherElements.element(matching: .init(format: "label like 'Mein Standort'"))
            .waitForExistence(timeout: 5))
    }

    func testDeniedLocation() {
        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForDenial()

        tabBar
            .tapRedeemTab()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        // Tap on Okay button of custom alert
        app.buttons["Okay"].tap()

        XCTAssertFalse(app.otherElements.element(matching: .init(format: "label like 'Mein Standort'"))
            .exists)
    }

    func testCloseFullMap() {
        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForDenial()

        let mapScreen = tabBar
            .tapPrescriptionsTab()
            .tapRedeem()
            .tapRedeemRemote()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        // Tap on Okay button of custom alert
        app.buttons["Okay"].tap()

        XCTAssertTrue(app.otherElements.matching(identifier: A11y.pharmacySearchMap.phaSearchMapMap).element
            .exists)

        mapScreen
            .tapCloseMap()
            .tapCancleButton()

        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like 'Rezepte'")).element.exists)
    }

    func testCloseMap() {
        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForDenial()

        let mapScreen = tabBar
            .tapRedeemTab()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        // Tap on Okay button of custom alert
        app.buttons["Okay"].tap()

        XCTAssertTrue(app.otherElements.matching(identifier: A11y.pharmacySearchMap.phaSearchMapMap).element.exists)

        mapScreen.tapCloseMap()

        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like 'Apothekensuche'")).element.exists)
    }

    func testTapOnAnnotation() {
        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForDenial()

        let pharmacyDetail = tabBar
            .tapRedeemTab()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        // Tap on Okay button of custom alert
        app.buttons["Okay"].tap()

        pharmacyDetail
            .tapSearchHere()

        pharmacyDetail
            .tapOnAnnotation(id: "3-01.2.2023001.16.102")

        XCTAssertTrue(pharmacyDetail.app.staticTexts.containing(NSPredicate(format: "label like 'ZoTI_02_TEST-ONLY'"))
            .element.waitForExistence(timeout: 5))
    }

    func testTapOnSearchHere() {
        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForDenial()

        let mapScreen = tabBar
            .tapRedeemTab()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        // Tap on Okay button of custom alert
        app.buttons["Okay"].tap()

        mapScreen.tapSearchHere()

        // Wait for the first Annotation to be visible and check for existing
        XCTAssertTrue(app.otherElements.matching(identifier: "pha_search_map_map")
            .children(matching: .other)
            .matching(NSPredicate(format: "identifier BEGINSWITH '3-01.2.2023001.16.'"))
            .firstMatch
            .waitForExistence(timeout: 5))

        // 4 "Apotheken" annotations should be visible
        XCTAssertTrue(app.otherElements.matching(identifier: "pha_search_map_map")
            .children(matching: .other)
            .matching(NSPredicate(format: "identifier BEGINSWITH '3-01.2.2023001.16.'"))
            .count == 4)
    }

    func testGoToUser() throws {
        if #available(iOS 16.4, *) {
            XCUIDevice.shared.location = XCUILocation(location: .init(latitude: 52.52291, longitude: 13.38757))
        } else {
            throw XCTSkip("location cannot be set on old iOS simulator versions")
        }

        let tabBar = TabBarScreen(app: app)

        setupLocationAlertForAcceptance()

        // navigate and open the map
        let mapScreen = tabBar
            .tapRedeemTab()
            .tapMapSearch()

        forceTriggerInterruptMonitors()

        // swipe the map to the left
        mapScreen.app.swipeDown(velocity: 2000)

        XCTAssertTrue(app.otherElements.element(matching: .init(format: "label like 'Mein Standort'"))
            .waitForExistence(timeout: 5))

        XCTAssertFalse(app.otherElements.matching(identifier: "AnnotationContainer").children(matching: .other)
            .firstMatch.isHittable)

        // press the button GoToUser button to go to the user location
        mapScreen.tapGoToUser()

        XCTAssertTrue(app.otherElements.matching(identifier: "AnnotationContainer").children(matching: .other)
            .firstMatch.isHittable)
    }

    private func setupLocationAlertForAcceptance() {
        notificationAlertMonitor = addUIInterruptionMonitor(
            withDescription: "Location Permission Alert"
        ) { alert -> Bool in
            if alert.label == "Darf „E-Rezept“ deinen Standort verwenden?" {
                alert.buttons["Beim Verwenden der App erlauben"].tap()
                self.locationDialogInterruptAnswered = true
                return true
            }
            if alert.label == "Allow “E-prescription” to use your location?" {
                alert.buttons["Allow While Using App"].tap()
                self.locationDialogInterruptAnswered = true
                return true
            }
            return false
        }
    }

    private func setupLocationAlertForDenial() {
        notificationAlertMonitor = addUIInterruptionMonitor(
            withDescription: "Location Permission Alert"
        ) { alert -> Bool in
            if alert.label == "Darf „E-Rezept“ deinen Standort verwenden?" {
                alert.buttons["Nicht erlauben"].tap()
                self.locationDialogInterruptAnswered = true
                return true
            }
            if alert.label == "Allow “E-prescription” to use your location?" {
                alert.buttons["Don’t Allow"].tap()
                self.locationDialogInterruptAnswered = true
                return true
            }
            return false
        }
    }

    private func forceTriggerInterruptMonitors(file: StaticString = #file, line: UInt = #line) {
        expect(file: file, line: line) {
            // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
            // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
            self.app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()

            return self.locationDialogInterruptAnswered
        }.toEventually(beTrue(), timeout: .seconds(5), pollInterval: .milliseconds(200))
    }
}
