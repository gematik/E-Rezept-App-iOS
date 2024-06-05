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

struct CardWallExtAuthHelpScreen: Screen {
    let app: XCUIApplication

    func tapBackButton(file: StaticString = #file, line: UInt = #line) -> CardWallExtAuthSelectionScreen {
        button(within: app.navigationBars, by: "Zurück", file: file, line: line).tap()

        return .init(app: app)
    }

    func navigationTitle(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        staticText(within: app.navigationBars, by: "Hilfe", file: file, line: line, checkExistence: false)
    }
}
