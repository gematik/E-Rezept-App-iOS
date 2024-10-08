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

final class ScannedPrescriptionUITests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUp() {
        super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "ScannedPrescriptionUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testEditPrescriptionName_canEditScannedTaskName() {
        app.buttons.element(matching: .init(format: "label == %@", "Rezepte")).tap()

        let name = "Medicine 223"
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like '\(name)'")).element.exists)

        app.staticTexts.containing(NSPredicate(format: "label like '\(name)'")).element.tap()

        XCTAssertTrue(app.buttons[A11y.prescriptionDetails.prscDtlBtnEditTitle].exists)
    }

    func testEditPrescriptionTitle_editName() {
        // given
        app.buttons.element(matching: .init(format: "label == %@", "Rezepte")).tap()
        let medicine223 = "Medicine 223"
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like '\(medicine223)'")).element.exists)

        // when editing a prescription's name 1st time
        app.staticTexts.containing(NSPredicate(format: "label like '\(medicine223)'")).element.tap()
        app.buttons[A11y.prescriptionDetails.prscDtlBtnEditTitle].tap()
        for _ in 1 ..< "Medicine 223".count {
            app.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        let emtriva200 = "EMTRIVA 200 mg Hartkapseln :)"
        app.typeText(XCUIKeyboardKey.delete.rawValue + emtriva200)
        app.typeText(XCUIKeyboardKey.enter.rawValue)

        // (go back)
        app.navigationBars.buttons.firstMatch.tap()

        // then
        XCTAssertFalse(app.staticTexts.containing(NSPredicate(format: "label like '\(medicine223)'")).element.exists)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like '\(emtriva200)'")).element.exists)

        // when edit same prescription's name 2nd time
        app.staticTexts.containing(NSPredicate(format: "label like '\(emtriva200)'")).element.tap()
        app.buttons[A11y.prescriptionDetails.prscDtlBtnEditTitle].tap()
        for _ in 0 ..< 20 {
            app.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        let emtriva250 = "EMTRIVA 250 mg Hartkapseln :)"
        app.typeText("50 mg Hartkapseln :)")
        app.typeText(XCUIKeyboardKey.enter.rawValue)

        // (go back)
        app.navigationBars.buttons.firstMatch.tap()

        // then
        XCTAssertFalse(app.staticTexts.containing(NSPredicate(format: "label like '\(emtriva200)'")).element.exists)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like '\(emtriva250)'")).element.exists)

        // when marking prescription as redeemed
        app.staticTexts.containing(NSPredicate(format: "label like '\(emtriva250)'")).element.tap()

        app.buttons.containing(NSPredicate(format: "label like 'Als eingelöst markieren'")).element.tap()

        // (go to archive)
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons[A11y.mainScreen.erxBtnArcPrescription].tap()

        // then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like '\(emtriva250)'")).element.exists)

        // when edit same prescription's name 3rd time (in archive)
        app.staticTexts.containing(NSPredicate(format: "label like '\(emtriva250)'")).element.tap()

        app.buttons[A11y.prescriptionDetails.prscDtlBtnEditTitle].tap()
        for _ in 1 ..< emtriva250.count {
            app.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        let noName250 = "250 mg Hartkapseln :)"
        app.typeText(XCUIKeyboardKey.delete.rawValue + noName250)

        // (go back)
        app.navigationBars.buttons.firstMatch.tap()

        // then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label like '\(noName250)'")).element.exists)
    }

    override func tearDown() {
        super.tearDown()
    }
}
