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
struct MedicationReminderSetupScreen<Previous>: Screen where Previous: Screen {
    let app: XCUIApplication
    let previous: Previous

    init(app: XCUIApplication, previous: Previous) {
        self.app = app
        self.previous = previous
    }

    func saveButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.medicationReminder.medReminderBtnSaveSchedule, fileID: fileID, file: file, line: line)
    }

    func tapSave(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Previous {
        saveButton(fileID: fileID, file: file, line: line).tap()

        // Tap might trigger notification alert
        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()

        return previous
    }

    func medicationNameLabel(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(by: A11y.medicationReminder.medReminderTxtScheduleHeader, fileID: fileID, file: file, line: line)
    }

    func enabledSwitch(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        switches(by: A11y.medicationReminder.medReminderBtnActivationToggle, fileID: fileID, file: file, line: line)
            .switches.firstMatch
    }

    func toggleActive(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        enabledSwitch(fileID: fileID, file: file, line: line).tap()
    }

    func repetitionDetailsCell(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.medicationReminder.medReminderBtnRepetitionDetails, fileID: fileID, file: file, line: line)
    }

    func tapRepetitionDetailsCell(fileID _: String = #fileID, file: String = #filePath,
                                  line: UInt = #line) -> MedicationReminderRepetitionDetailsScreen<Self> {
        repetitionDetailsCell(file: file, line: line).tap()

        expect(file: file, line: line, app.navigationBars.firstMatch.identifier).to(equal("Wiederholen"))
        return .init(app: app, previous: self)
    }

    func numberOfSetupTimes(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Int {
        elementsByIndex(
            for: A11y.medicationReminder.medReminderBtnScheduleTimeList,
            fileID: fileID,
            file: file,
            line: line
        ).count
    }

    func timeSetupAtPosition(_ position: Int, fileID: String = #fileID, file: String = #filePath,
                             line: UInt = #line) -> XCUIElement {
        let elements = elementsByIndex(
            for: A11y.medicationReminder.medReminderBtnScheduleTimeList,
            fileID: fileID,
            file: file,
            line: line
        )
        expect(file: file, line: line, elements.count).to(beGreaterThan(position))
        guard elements.count > position else {
            fatalError("Element list to short, expected \(position + 1) elements, found \(elements.count)")
        }
        return elements[position]
    }

    func deleteAtPosition(_ position: Int, fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        let elements = elementsByIndex(
            for: A11y.medicationReminder.medReminderBtnScheduleTimeList,
            file: file,
            line: line
        )
        expect(file: file, line: line, elements.count).to(beGreaterThan(position))
        guard elements.count > position else {
            fatalError("Element list to short, expected \(position + 1) elements, found \(elements.count)")
        }
        elements[position].coordinate(withNormalizedOffset: .zero).withOffset(.init(dx: -30, dy: 10)).tap()
        staticText(by: "Löschen", fileID: fileID, file: file, line: line)
            .coordinate(withNormalizedOffset: .init(dx: 0.5, dy: 0.5))
            .tap()
    }

    func addTimeButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.medicationReminder.medReminderBtnScheduleTimeAddEntry, fileID: fileID, file: file, line: line)
    }

    func tapAddTimeButton(file _: StaticString = #file, line _: UInt = #line) {
        addTimeButton().tap()
    }

    func toggleDosageDialog(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A11y.medicationReminder.medReminderBtnDosageInstruction, fileID: fileID, file: file, line: line)
            .tap()
    }

    func dosageDialog(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        container(
            by: A11y.medicationReminder.medReminderDrawerDosageInstructionInfo,
            fileID: fileID,
            file: file,
            line: line
        )
    }
}
