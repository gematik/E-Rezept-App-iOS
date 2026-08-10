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
import Nimble
import XCTest

@MainActor
struct CountrySelectionScreen: Screen {
    let app: XCUIApplication

    func title(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(by: A11y.redeem.eu.countrySelection.eurdmTxtCountryTitle, fileID: fileID, file: file, line: line)
    }

    func subtitle(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(by: A11y.redeem.eu.countrySelection.eurdmTxtCountrySubtitle, fileID: fileID, file: file, line: line)
    }

    func locationButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.redeem.eu.countrySelection.eurdmBtnCountryLocation,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func emptyTitle(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(
            by: A11y.redeem.eu.countrySelection.eurdmTxtCountryEmptyTitle,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func emptySubtitle(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(
            by: A11y.redeem.eu.countrySelection.eurdmTxtCountryEmptySubtitle,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    @discardableResult
    func selectCountryNamed(_ name: String, fileID _: String = #fileID, file: String = #filePath,
                            line: UInt = #line) -> EURedeemSelectionScreen {
        let countryCell = app.cells.buttons
            .matching(NSPredicate(format: "label CONTAINS %@", name))
            .firstMatch
        expect(file: file, line: line, countryCell.waitForExistence(timeout: 5.0)).to(beTrue())
        countryCell.tap()
        return EURedeemSelectionScreen(app: app)
    }

    @discardableResult
    func selectFirstCountry(fileID _: String = #fileID, file: String = #filePath,
                            line: UInt = #line) -> EURedeemSelectionScreen {
        let firstCell = app.cells.buttons.firstMatch
        expect(file: file, line: line, firstCell.waitForExistence(timeout: 5.0)).to(beTrue())
        firstCell.tap()
        return EURedeemSelectionScreen(app: app)
    }
}
