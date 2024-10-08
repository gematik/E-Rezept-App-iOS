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

extension Screen {
    func button(within query: XCUIElementQuery? = nil, by identifier: String, file: StaticString,
                line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.buttons ?? app.buttons,
            identifier: identifier,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    func textField(within query: XCUIElementQuery? = nil, by identifier: String, file: StaticString,
                   line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.textFields ?? app.textFields,
            identifier: identifier,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    func secureTextField(within query: XCUIElementQuery? = nil, by identifier: String, file: StaticString,
                         line: UInt) -> XCUIElement {
        elements(
            query: query?.secureTextFields ?? app.secureTextFields,
            identifier: identifier,
            file: file,
            line: line
        )
    }

    func staticText(within query: XCUIElementQuery? = nil, by identifier: String, file: StaticString,
                    line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.staticTexts ?? app.staticTexts,
            identifier: identifier,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    func switches(within query: XCUIElementQuery? = nil, by identifier: String, file: StaticString,
                  line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.switches ?? app.switches,
            identifier: identifier,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    func container(within query: XCUIElementQuery? = nil, by identifier: String, file: StaticString,
                   line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.otherElements ?? app.otherElements,
            identifier: identifier,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    func datePicker(within query: XCUIElementQuery? = nil, by identifier: String, file: StaticString,
                    line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.datePickers ?? app.datePickers,
            identifier: identifier,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    func elements(
        query: XCUIElementQuery,
        identifier: String,
        file: StaticString,
        line: UInt,
        checkExistence: Bool = true
    ) -> XCUIElement {
        let element = query[identifier]

        // additional if instead of direct `waitForExistens` speeds up the UI-Tests
        if checkExistence, !element.exists {
            expect(file: file, line: line, element.waitForExistence(timeout: 5.0)).to(beTrue())
        }

        return element
    }

    func elementsByIndex(for identifier: String, file _: StaticString, line _: UInt) -> [XCUIElement] {
        app.otherElements.matching(.any, identifier: identifier).allElementsBoundByIndex
    }
}
