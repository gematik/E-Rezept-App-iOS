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
struct OrdersScreen: Screen {
    let app: XCUIApplication

    func tapOrderDetailsForPharmacyNamed(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                         line: UInt = #line) -> OrderDetailsScreen {
        let staticText = staticText(by: name, fileID: fileID, file: file, line: line)
        expect(staticText.waitForExistence(timeout: 3)).to(beTrue())
        staticText.tap()
        return OrderDetailsScreen(app: app)
    }

    func navigationTitle(fileID: String = #fileID, file: String = #file, line: UInt = #line) -> XCUIElement {
        staticText(
            within: app.navigationBars,
            by: "Nachrichten",
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }
}
