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

struct PharmacySearchMapScreen<Previous>: Screen where Previous: Screen {
    let app: XCUIApplication
    let previous: Previous

    init(app: XCUIApplication, previous: Previous) {
        self.app = app
        self.previous = previous
    }

    @discardableResult
    func tapCloseMap(file: StaticString = #file, line: UInt = #line) -> Previous {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnClose, file: file, line: line).tap()
        return previous
    }

    func tapSearchHere(file: StaticString = #file, line: UInt = #line) {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnSearchHere, file: file, line: line).tap()
    }

    func tapGoToUser(file: StaticString = #file, line: UInt = #line) {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnGoToUser, file: file, line: line).tap()
    }

    func tapFilter(file: StaticString = #file, line: UInt = #line) -> PharmacyFilterScreen<Self> {
        button(by: A11y.pharmacySearchMap.phaSearchMapBtnFilter, file: file, line: line).tap()
        return PharmacyFilterScreen(app: app, previous: self)
    }

    @discardableResult
    func tapOnAnnotation(id: String, file _: StaticString = #file, line _: UInt = #line) -> PharmacyDetailsScreen {
        app.otherElements.matching(identifier: "\(id)").firstMatch.tap()
        return PharmacyDetailsScreen(app: app)
    }

    func Annotations(file _: StaticString = #file, line _: UInt = #line) -> XCUIElement {
        app.otherElements.element(matching: .other, identifier: "AnnotationContainer")
    }
}
