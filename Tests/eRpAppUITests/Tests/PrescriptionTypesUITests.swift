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

class PrescriptionTypesUITests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUp() {
        super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "PrescriptionTypesUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testStatus() {
        let tabBar = TabBarScreen(app: app)

        let mainView = tabBar.tapPrescriptionsTab()

        // [TEST:NOCTU001,AUTIDEM001]
        let details1 = mainView.tapDetailsForPrescriptionNamed("No Substitution|No Emergency Fee")

        expect(details1.autIdemHeadlineButton().exists).to(beTrue())
        expect(details1.autIdemInfoButton().label as String?)
            .to(equal("Kein Ersatzpräparat möglich, Ersatzpräparat (Aut idem)"))
        let autIdemDrawer1 = details1.tapAutIdemHeadlineButton()
        expect(autIdemDrawer1.title()).to(equal("Kein Ersatzpräparat möglich"))
        expect(autIdemDrawer1.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer1.close()

        expect(details1.emergencyFeeButton().label as String?).to(equal("Gebührenpflichtig, Notdienstgebühr"))
        let emergencyFeeDrawer1 = details1.tapEmergencyFeeButton()
        expect(emergencyFeeDrawer1.title()).to(equal("Notdienstgebühr"))
        expect(emergencyFeeDrawer1.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        emergencyFeeDrawer1.close()

        _ = details1.tapBackButton()

        // [TEST:NOCTU001,AUTIDEM002]
        let details2 = mainView.tapDetailsForPrescriptionNamed("Substitution|No Emergency Fee")
        expect(details2.autIdemHeadlineButton().exists).to(beFalse())
        expect(details2.autIdemInfoButton().label as String?)
            .to(equal("Ersatzpräparat möglich, Ersatzpräparat (Aut idem)"))
        let autIdemDrawer2 = details1.tapAutIdemInfoButton()
        expect(autIdemDrawer2.title()).to(equal("Ersatzpräparat möglich"))
        expect(autIdemDrawer2.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer2.close()

        expect(details2.emergencyFeeButton().label as String?).to(equal("Gebührenpflichtig, Notdienstgebühr"))
        let emergencyFeeDrawer2 = details2.tapEmergencyFeeButton()
        expect(emergencyFeeDrawer2.title()).to(equal("Notdienstgebühr"))
        expect(emergencyFeeDrawer2.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        emergencyFeeDrawer2.close()

        _ = details2.tapBackButton()

        // [TEST:NOCTU002,AUTIDEM001]
        let details3 = mainView.tapDetailsForPrescriptionNamed("No Substitution|Emergency Fee")

        expect(details3.autIdemHeadlineButton().exists).to(beTrue())
        expect(details3.autIdemInfoButton().label as String?)
            .to(equal("Kein Ersatzpräparat möglich, Ersatzpräparat (Aut idem)"))
        let autIdemDrawer3 = details3.tapAutIdemHeadlineButton()
        expect(autIdemDrawer3.title()).to(equal("Kein Ersatzpräparat möglich"))
        expect(autIdemDrawer3.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer3.close()
        expect(details3.emergencyFeeButton().label as String?).to(equal("Übernimmt Versicherung, Notdienstgebühr"))
        let emergencyFeeDrawer3 = details1.tapEmergencyFeeButton()
        expect(emergencyFeeDrawer3.title()).to(equal("Notdienstgebühr"))
        expect(emergencyFeeDrawer3.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        emergencyFeeDrawer3.close()

        _ = details3.tapBackButton()

        // [TEST:NOCTU002,AUTIDEM002]
        let details4 = mainView.tapDetailsForPrescriptionNamed("Substitution|Emergency Fee")
        expect(details4.autIdemHeadlineButton().exists).to(beFalse())
        expect(details4.emergencyFeeButton().label as String?).to(equal("Übernimmt Versicherung, Notdienstgebühr"))
        expect(details4.autIdemInfoButton().label as String?)
            .to(equal("Ersatzpräparat möglich, Ersatzpräparat (Aut idem)"))
        let autIdemDrawer4 = details4.tapAutIdemInfoButton()
        expect(autIdemDrawer4.title()).to(equal("Ersatzpräparat möglich"))
        expect(autIdemDrawer4.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        autIdemDrawer4.close()

        let emergencyFeeDrawer4 = details1.tapEmergencyFeeButton()
        expect(emergencyFeeDrawer4.title()).to(equal("Notdienstgebühr"))
        expect(emergencyFeeDrawer4.description()?.lengthOfBytes(using: .utf8)).to(beGreaterThan(50))
        emergencyFeeDrawer4.close()
        _ = details4.tapBackButton()
    }
}
