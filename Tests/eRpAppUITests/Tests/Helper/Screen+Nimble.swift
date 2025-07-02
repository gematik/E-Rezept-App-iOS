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

import Nimble
import XCTest

extension Screen {
    @MainActor
    func button(within query: XCUIElementQuery? = nil, by identifier: String, fileID: String, file: FileString,
                line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.buttons ?? app.buttons,
            identifier: identifier,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    @MainActor
    func textField(within query: XCUIElementQuery? = nil, by identifier: String, fileID: String, file: FileString,
                   line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.textFields ?? app.textFields,
            identifier: identifier,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    @MainActor
    func secureTextField(within query: XCUIElementQuery? = nil, by identifier: String, fileID: String, file: FileString,
                         line: UInt) -> XCUIElement {
        elements(
            query: query?.secureTextFields ?? app.secureTextFields,
            identifier: identifier,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    @MainActor
    func staticText(within query: XCUIElementQuery? = nil, by identifier: String, fileID: String, file: FileString,
                    line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.staticTexts ?? app.staticTexts,
            identifier: identifier,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    @MainActor
    func switches(within query: XCUIElementQuery? = nil, by identifier: String, fileID: String, file: FileString,
                  line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.switches ?? app.switches,
            identifier: identifier,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    @MainActor
    func container(within query: XCUIElementQuery? = nil, by identifier: String, fileID: String, file: FileString,
                   line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.otherElements ?? app.otherElements,
            identifier: identifier,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    @MainActor
    func datePicker(within query: XCUIElementQuery? = nil, by identifier: String, fileID: String, file: FileString,
                    line: UInt, checkExistence: Bool = true) -> XCUIElement {
        elements(
            query: query?.datePickers ?? app.datePickers,
            identifier: identifier,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: checkExistence
        )
    }

    @MainActor
    func elements(
        query: XCUIElementQuery,
        identifier: String,
        fileID: String = #fileID,
        file: FileString = #filePath,
        line: UInt,
        checkExistence: Bool = true
    ) -> XCUIElement {
        let element = query[identifier]

        // additional if instead of direct `waitForExistence` speeds up the UI-Tests
        if checkExistence, !element.exists {
            expect(fileID: fileID, file: file, line: line, element.waitForExistence(timeout: 5.0)).to(beTrue())
        }

        return element
    }

    @MainActor
    func elementsByIndex(for identifier: String, fileID _: String = #fileID, file _: FileString = #filePath,
                         line _: UInt) -> [XCUIElement] {
        app.otherElements.matching(.any, identifier: identifier).allElementsBoundByIndex
    }
}
