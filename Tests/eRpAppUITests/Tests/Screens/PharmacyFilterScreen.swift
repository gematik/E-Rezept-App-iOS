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
struct PharmacyFilterScreen<Previous>: Screen where Previous: Screen {
    let app: XCUIApplication
    let previous: Previous

    init(app: XCUIApplication, previous: Previous) {
        self.app = app
        self.previous = previous
    }

    func tapFilterOption(_ filterName: String, file _: StaticString = #file, line _: UInt = #line) {
        app.buttons.element(matching: .init(format: "label == %@", "\(filterName)")).tap()
    }

    @discardableResult
    func closeFilter(file _: StaticString = #file, line _: UInt = #line) -> Previous {
        app.scrollViews.firstMatch.swipeDown(velocity: 2000.0)
        return previous
    }
}
