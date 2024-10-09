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
struct OrderHealthCardContactInsuranceCompanyScreen<PreviousScreen: Screen>: Screen {
    let app: XCUIApplication
    let previous: PreviousScreen

    func tapBackButton(file: StaticString = #file, line: UInt = #line) -> PreviousScreen {
        button(within: app.navigationBars, by: "Zurück", file: file, line: line).tap()

        return previous
    }

    func phoneBtn(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        button(by: A11y.orderEGK.ogkBtnPhone, file: file, line: line, checkExistence: false)
    }

    func webBtn(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        button(by: A11y.orderEGK.ogkBtnWeb, file: file, line: line, checkExistence: false)
    }

    func mailBtn(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        button(by: A11y.orderEGK.ogkBtnMail, file: file, line: line, checkExistence: false)
    }
}
