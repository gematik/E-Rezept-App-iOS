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
struct PharmacySearchScreen: Screen {
    let app: XCUIApplication

    func pharmacyDetailsForPharmacy(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                    line: UInt = #line) -> PharmacyDetailsScreen {
        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")

        XCUIApplication().keyboards.buttons["Suchen"].tap()

        let pharmacyCell = container(
            by: A11y.pharmacySearch.phaSearchTxtResultList,
            fileID: fileID,
            file: file,
            line: line
        )
        .children(matching: .button)
        .containing(NSPredicate(format: "label like '\(name)'"))
        .element

        expect(file: file, line: line, pharmacyCell.exists).to(beTrue())
        pharmacyCell.tap()

        return PharmacyDetailsScreen(app: app)
    }

    func searchFor(_ searchText: String, file _: StaticString = #file, line _: UInt = #line) {
        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText(searchText)

        XCUIApplication().keyboards.buttons["Suchen"].tap()
    }

    func tapFilter(fileID: String = #fileID, file: String = #filePath,
                   line: UInt = #line) -> PharmacyFilterScreen<Self> {
        button(by: A11y.pharmacySearch.phaFilterOpenFilter, fileID: fileID, file: file, line: line).tap()
        return PharmacyFilterScreen(app: app, previous: self)
    }

    @discardableResult
    func tapMapSearch(file _: StaticString = #file, line _: UInt = #line) -> PharmacySearchMapScreen<Self> {
        app.maps.firstMatch.tap()
        return .init(app: app, previous: self)
    }

    @discardableResult
    func tapCancelButton(fileID: String = #fileID, file: String = #filePath,
                         line: UInt = #line) -> RedeemSelectionScreen {
        print(app.debugDescription)
        button(within: app.navigationBars, by: "Abbrechen", fileID: fileID, file: file, line: line).tap()

        return RedeemSelectionScreen(app: app)
    }
}
