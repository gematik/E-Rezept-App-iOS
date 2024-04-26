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

struct MainScreen: Screen {
    let app: XCUIApplication

    func prescriptionCellByName(_ name: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        let cell = app.buttons.containing(.staticText, identifier: name).element
        expect(file: file, line: line, cell).to(exist(name))
        return cell
    }

    func detailsForPrescriptionNamed(_ name: String, file: StaticString = #file,
                                     line: UInt = #line) -> PrescriptionDetailsScreen {
        staticText(by: name, file: file, line: line).tap()

        // assert label exists that contains the prescription name as a label
        let title = staticText(by: A11y.prescriptionDetails.prscDtlTxtTitle, file: file, line: line)
        expect(file: file, line: line, title.label).to(equal(name))

        return PrescriptionDetailsScreen(app: app)
    }

    func tapArchive(file: StaticString = #file, line: UInt = #line) -> ArchiveScreen {
        app.scrollViews.firstMatch.swipeUp(velocity: 2000.0)

        button(by: A11y.mainScreen.erxBtnArcPrescription, file: file, line: line).tap()

        return ArchiveScreen(app: app)
    }

    struct ArchiveScreen: Screen {
        var app: XCUIApplication

        func prescriptionCellByName(_ name: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
            let cell = app.buttons.containing(.staticText, identifier: name).element
            expect(file: file, line: line, cell).to(exist(name))
            return cell
        }
    }
}
