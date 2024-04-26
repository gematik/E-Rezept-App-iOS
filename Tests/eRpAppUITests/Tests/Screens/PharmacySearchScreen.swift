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

struct PharmacySearchScreen: Screen {
    let app: XCUIApplication

    func pharmacyDetailsForPharmacy(_ name: String, file: StaticString = #file,
                                    line: UInt = #line) -> PharmacyDetailsScreen {
        app.navigationBars["Apothekensuche"].searchFields.firstMatch.tap()
        app.typeText("A")

        XCUIApplication().keyboards.buttons["Suchen"].tap()

        let pharmacyCell = container(by: A11y.pharmacySearch.phaSearchTxtResultList, file: file, line: line)
            .children(matching: .button)
            .containing(NSPredicate(format: "label like '\(name)'"))
            .element

        expect(file: file, line: line, pharmacyCell.exists).to(beTrue())
        pharmacyCell.tap()

        return PharmacyDetailsScreen(app: app)
    }
}
