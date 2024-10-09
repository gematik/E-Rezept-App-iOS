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

import Nimble
import XCTest

@MainActor
struct MainScreen: Screen {
    let app: XCUIApplication

    func prescriptionCellByName(_ name: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        let cell = app.buttons.containing(.staticText, identifier: name).element
        expect(file: file, line: line, cell).to(exist(name))
        return cell
    }

    func tapDetailsForPrescriptionNamed(_ name: String, file: StaticString = #file,
                                        line: UInt = #line) -> PrescriptionDetailsScreen<MainScreen> {
        staticText(by: name, file: file, line: line).tap()

        // assert label exists that contains the prescription name as a label
        let title = staticText(by: A11y.prescriptionDetails.prscDtlTxtTitle, file: file, line: line)
        expect(file: file, line: line, title.label).to(equal(name))

        return PrescriptionDetailsScreen(app: app, previous: self)
    }

    func tapDetailsForScannedPrescription(_ name: String, file: StaticString = #file,
                                          line: UInt = #line) -> PrescriptionDetailsScreen<MainScreen> {
        staticText(by: name, file: file, line: line).tap()

        // assert label exists that contains the prescription name as a label
        let title = textField(by: A11y.prescriptionDetails.prscDtlTxtTitleInput, file: file, line: line)
        if let titleValue = title.value as? String {
            expect(file: file, line: line, titleValue).to(equal(name))
        } else {
            Nimble.fail("expect to have a title in prescription detail view")
        }

        return PrescriptionDetailsScreen(app: app, previous: self)
    }

    func tapRedeem(file: StaticString = #file, line: UInt = #line) -> RedeemSelectionScreen {
        button(by: A11y.mainScreen.erxBtnRedeemPrescriptions, file: file, line: line).tap()

        return RedeemSelectionScreen(app: app)
    }

    func tapOpenCardwall(file: StaticString = #file, line: UInt = #line) -> CardWallIntroductionScreen {
        button(by: A11y.mainScreen.erxBtnLogin, file: file, line: line).tap()

        return .init(app: app)
    }

    func tapArchive(file: StaticString = #file, line: UInt = #line) -> ArchiveScreen {
        app.scrollViews.firstMatch.swipeUp(velocity: 2000.0)

        button(by: A11y.mainScreen.erxBtnArcPrescription, file: file, line: line).tap()

        return ArchiveScreen(app: app)
    }

    @MainActor
    struct ArchiveScreen: Screen {
        var app: XCUIApplication

        func prescriptionCellByName(_ name: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
            let cell = app.buttons.containing(.staticText, identifier: name).element
            expect(file: file, line: line, cell).to(exist(name))
            return cell
        }

        func detailsForPrescriptionNamed(_ name: String, file: StaticString = #file,
                                         line: UInt = #line) -> PrescriptionDetailsScreen<ArchiveScreen> {
            staticText(by: name, file: file, line: line).tap()

            // assert label exists that contains the prescription name as a label
            let title = staticText(by: A11y.prescriptionDetails.prscDtlTxtTitle, file: file, line: line)
            expect(file: file, line: line, title.label).to(equal(name))

            return PrescriptionDetailsScreen(app: app, previous: self)
        }
    }
}
