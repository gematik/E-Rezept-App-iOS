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

import XCTest

@MainActor
struct MedicationReminderListScreen: Screen {
    let app: XCUIApplication

    func medicationReminderCellWithIndex(_ position: Int, file _: StaticString = #file,
                                         line _: UInt = #line) -> XCUIElement {
        let elements = app.buttons.matching(
            .button,
            identifier: A11y.medicationReminderList.medReminderListCell
        ).allElementsBoundByIndex
        guard elements.count > position else {
            fatalError("Element list to short, expected \(position + 1) elements, found \(elements.count)")
        }
        return elements[position]
    }

    func tapMedicationReminderCellWithIndex(_ position: Int, file _: StaticString = #file,
                                            line _: UInt = #line) -> MedicationReminderSetupScreen<Self> {
        medicationReminderCellWithIndex(position)
            .tap()

        return .init(app: app, previous: self)
    }

    func numberOfMedicationReminders(file _: StaticString = #file, line _: UInt = #line) -> Int {
        app.buttons.matching(
            .button,
            identifier: A11y.medicationReminderList.medReminderListCell
        ).allElementsBoundByIndex.count
    }
}
