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
struct MedicationReminderRepetitionDetailsScreen<Previous>: Screen where Previous: Screen {
    let app: XCUIApplication
    let previous: Previous

    init(app: XCUIApplication, previous: Previous) {
        self.app = app
        self.previous = previous
    }

    func infiniteCell(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.medicationReminder.medReminderBtnRepetitionInfinite, fileID: fileID, file: file, line: line)
    }

    func finiteCell(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.medicationReminder.medReminderBtnRepetitionFinite, fileID: fileID, file: file, line: line)
    }

    func startDatePicker(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        datePicker(
            by: A11y.medicationReminder.medReminderBtnRepetitionDateStart,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    func endDatePicker(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        datePicker(by: A11y.medicationReminder.medReminderBtnRepetitionDateEnd, fileID: fileID, file: file, line: line)
    }

    func setStartDate(
        _ date: Date,
        additionalValidation: ((DatePickerScreen) -> Void)? = nil,
        fileID: String = #fileID, file: String = #filePath,
        line: UInt = #line
    ) {
        setDate(
            date,
            for: startDatePicker(file: file, line: line),
            additionalValidation: additionalValidation,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    func setEndDate(
        _ date: Date,
        additionalValidation: ((DatePickerScreen) -> Void)? = nil,
        fileID: String = #fileID, file: String = #filePath,
        line: UInt = #line
    ) {
        setDate(
            date,
            for: endDatePicker(file: file, line: line),
            additionalValidation: additionalValidation,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    func setDate(
        _ date: Date,
        for element: XCUIElement,
        additionalValidation: ((DatePickerScreen) -> Void)? = nil,
        fileID _: String, file: String,
        line: UInt
    ) {
        // open date picker dialog
        element.buttons.firstMatch.tap()

        let datePickerScreen = DatePickerScreen(app: app, root: app.datePickers.firstMatch)
        let dateCell = datePickerScreen.cell(for: date, file: file, line: line)
        expect(file: file, line: line, dateCell)
            .to(exist("Cell for date '\(date.datePickerDialogAccessibiltyLabelFormatted())'"))

        if let additionalValidation {
            additionalValidation(datePickerScreen)
        }

        let cell = datePickerScreen.cell(for: date, file: file, line: line)
        if cell.exists {
            cell.tap()
        }

        // close date picker dialog
        element.coordinate(withNormalizedOffset: .zero).tap()
    }

    @discardableResult
    func tapBackButton(fileID _: String = #fileID, file _: String = #filePath, line _: UInt = #line) -> Previous {
        let button = app.navigationBars.buttons.firstMatch

        expect(button).to(exist("Back Button"))
        button.tap()

        return previous
    }

    @MainActor
    struct DatePickerScreen: Screen {
        var app: XCUIApplication
        var root: XCUIElement

        func cell(for date: Date, fileID _: String = #fileID, file _: String = #filePath,
                  line _: UInt = #line) -> XCUIElement {
            let monthSelection = app.buttons["Jahresauswahl einblenden"]

            if monthSelection.value as? String != date.datePickerDialogMonthLabelFormatted() {
                root.buttons["Nächster Monat"].tap()
            }
            if monthSelection.value as? String != date.datePickerDialogMonthLabelFormatted() {
                monthSelection.tap()

                // Month
                app.pickerWheels.allElementsBoundByIndex[0].adjust(
                    toPickerWheelValue: date.datePickerDialogMonthPickerWheelValue()
                )
                // Year
                app.pickerWheels.allElementsBoundByIndex[1].adjust(
                    toPickerWheelValue: date.datePickerDialogYearPickerWheelValue()
                )
                app.buttons["Jahresauswahl ausblenden"].tap()
            }

            let dialogFormatted = date.datePickerDialogAccessibiltyLabelFormatted()

            return root.buttons.element(matching: NSPredicate(format: "label LIKE %@", dialogFormatted))
        }
    }
}

extension XCUIElement {
    func setDate(_ date: Date, fileID _: String = #fileID, file _: String = #filePath, line _: UInt = #line) {
        let dateString = date.formatted(Date.FormatStyle().year(.defaultDigits).month(.twoDigits).day(.twoDigits))
        tap()
        typeText(dateString)
    }
}

extension Date {
    func datePickerDialogAccessibiltyLabelFormatted() -> String {
        let result = formatted(
            Date.FormatStyle()
                .weekday(.wide)
                .day(.defaultDigits)
                .month(.wide)
        )
        let today = Date().formatted(
            Date.FormatStyle()
                .weekday(.wide)
                .day(.defaultDigits)
                .month(.wide)
        )

        if result == today {
            return "Heute, \(result)"
        }
        return result
    }

    func datePickerLabelFormatted() -> String {
        formatted(
            Date.FormatStyle()
                .year(.defaultDigits)
                .month(.twoDigits)
                .day(.twoDigits)
        )
    }

    func datePickerDialogMonthLabelFormatted() -> String {
        formatted(
            Date.FormatStyle()
                .month(.wide)
                .year(.defaultDigits)
        )
    }

    func datePickerDialogMonthPickerWheelValue() -> String {
        formatted(
            Date.FormatStyle()
                .month(.wide)
        )
    }

    func datePickerDialogYearPickerWheelValue() -> String {
        formatted(
            Date.FormatStyle()
                .year(.defaultDigits)
        )
    }
}
