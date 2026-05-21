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

import eRpResources
import Nimble
import XCTest

@MainActor
struct PharmacyFilterScreen<Previous: Screen>: Screen {
    let app: XCUIApplication
    let previous: Previous

    func tapFilterOption(_ filterName: String, file _: StaticString = #file, line _: UInt = #line) {
        app.switches.element(matching: .init(format: "label == %@", "\(filterName)")).tap()
    }

    func tapResetFilters(file _: StaticString = #file, line _: UInt = #line) {
        app.buttons.element(matching: .init(format: "label CONTAINS %@", "Zurücksetzen")).tap()
    }

    func tapExplainToggle(file _: StaticString = #file, line _: UInt = #line) {
        // The toggle label alternates between "Erklären" and "Nicht erklären"
        let toggle = app.buttons.element(matching: .init(
            format: "label == %@ OR label == %@", "Erklären", "Nicht erklären"
        ))
        toggle.tap()
    }

    func tapServiceOption(_ serviceName: String, file _: StaticString = #file, line _: UInt = #line) {
        app.switches.element(matching: .init(format: "label CONTAINS %@", serviceName)).tap()
    }

    @discardableResult
    func closeFilter(file _: StaticString = #file, line _: UInt = #line) -> Previous {
        app.buttons[A11y.pharmacySearchFilter.psfBtnClose].tap()
        return previous
    }
}
