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
struct PharmacySearchMapScreen<Previous>: Screen where Previous: Screen {
    let app: XCUIApplication
    let previous: Previous

    init(app: XCUIApplication, previous: Previous) {
        self.app = app
        self.previous = previous
    }

    @discardableResult
    func tapCloseMap(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Previous {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnClose, fileID: fileID, file: file, line: line).tap()
        return previous
    }

    func tapSearchHere(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnSearchHere, fileID: fileID, file: file, line: line).tap()
    }

    func tapGoToUser(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnGoToUser, fileID: fileID, file: file, line: line).tap()
    }

    func tapFilter(fileID: String = #fileID, file: String = #filePath,
                   line: UInt = #line) -> PharmacyFilterScreen<Self> {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnFilter, fileID: fileID, file: file, line: line).tap()
        return PharmacyFilterScreen(app: app, previous: self)
    }

    @discardableResult
    func tapOnAnnotation(id: String, file _: StaticString = #file, line _: UInt = #line) -> PharmacyDetailsScreen {
        let annotation = app.otherElements.matching(identifier: "\(id)").firstMatch
        _ = annotation.waitForExistence(timeout: 2)
        annotation.tap()
        return PharmacyDetailsScreen(app: app)
    }

    func Annotations(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.otherElements.element(matching: .other, identifier: "AnnotationContainer")
    }
}
