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

import Foundation
import Nimble
import XCTest

@MainActor
final class MedicationReminderUITests: XCTestCase, Sendable {
    var app: XCUIApplication!

    override func tearDown() async throws {
        try await super.tearDown()

        notificationAlertMonitor.map { [self] in removeUIInterruptionMonitor($0) }
    }

    var notificationAlertMonitor: NSObjectProtocol?

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()

        // setup host application
        app.launchEnvironment["UITEST.DISABLE_ANIMATIONS"] = "YES"
        app.launchEnvironment["UITEST.DISABLE_AUTHENTICATION"] = "YES"

        app.launchEnvironment["UITEST.SCENARIO_NAME"] = "MedicationReminderUITests"
        app.launchEnvironment["UITEST.RESET"] = "1"

        let flags = ["enable_medication_schedule"]
        let flagsData = try! JSONEncoder().encode(flags)
        let flagsString = String(data: flagsData, encoding: .utf8)
        app.launchEnvironment["UITEST.FLAGS"] = flagsString

        app.launch()

        // Wait for the target app to enter .runningForeground state
        _ = app.wait(for: .runningForeground, timeout: 10.0)

        notificationAlertMonitor = addUIInterruptionMonitor(
            withDescription: "Location Permission Alert"
        ) { alert -> Bool in
            if alert.staticTexts["„E-Rezept“ möchte dir Mitteilungen senden"].exists {
                alert.buttons["Erlauben"].tap()
                return true
            }
            return false
        }

        // Interact somehow with the app, to trigger the registered `addUIInterruptionMonitor`
        // see https://stackoverflow.com/questions/39973904/handler-of-adduiinterruptionmonitor-is-not-called-for-alert-related-to-photos swiftlint:disable:this line_length
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01)).tap()
    }

    @MainActor
    func testParsableMedicationReminderSetupHappyPath() {
        let medicationName = "Adavomilproston"

        let tabBar = TabBarScreen(app: app)

        let details = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed(medicationName)

        // Check "Off"
        expect(details.medicationReminderCell().value as? String).to(equal("Aus"))
        // Abgabehinweise korrekt auf 1-1-1-1
        expect(details.dosageInstructionCell().label).to(beginWith("1-1-1-1"))

        let reminderSetup = details.tapSetupMedicationReminder()

        expect(reminderSetup.medicationNameLabel().label).to(equal(medicationName))
        reminderSetup.toggleActive()

        expect(reminderSetup.numberOfSetupTimes()).to(equal(4))
        expect(reminderSetup.timeSetupAtPosition(0).buttons.firstMatch.value as? String).to(equal("08:00"))
        expect(reminderSetup.timeSetupAtPosition(1).buttons.firstMatch.value as? String).to(equal("12:00"))
        expect(reminderSetup.timeSetupAtPosition(2).buttons.firstMatch.value as? String).to(equal("18:00"))
        expect(reminderSetup.timeSetupAtPosition(3).buttons.firstMatch.value as? String).to(equal("20:00"))

        // Assert Info text
        reminderSetup.toggleDosageDialog()

        let dialog = reminderSetup.dosageDialog()
        let title = dialog.staticTexts[A11y.medicationReminder.medReminderDrawerDosageInstructionInfoTitle]
        expect(title.exists).to(beTrue())

        let description = dialog.staticTexts[A11y.medicationReminder.medReminderDrawerDosageInstructionInfoDescription]
        expect(description.label).to(match(".*1 x morgens.*"))
        expect(description.label).to(match(".*1 x mittags.*"))
        expect(description.label).to(match(".*1 x abends.*"))
        expect(description.label).to(match(".*1 x nachts.*"))

        reminderSetup.toggleDosageDialog()

        // Speichern -> Back
        let details2 = reminderSetup.tapSave()

        // Check "On"
        expect(details2.medicationReminderCell().value as? String).to(equal("Ein"))

        // Settings -> Medication Plan
        let prescriptionList = tabBar
            .tapSettingsTab()
            .tapMedicationReminder()

        // 1 Plan existing
        let cell = prescriptionList.medicationReminderCellWithIndex(0)
        expect(cell.value as? String).to(equal("Ein"))
        expect(cell.label).to(equal(medicationName))

        // Details
        let reminderSetup2 = prescriptionList.tapMedicationReminderCellWithIndex(0)

        // Check times
        expect(reminderSetup.numberOfSetupTimes()).to(equal(4))
        expect(reminderSetup2.timeSetupAtPosition(0).buttons.firstMatch.value as? String).to(equal("08:00"))
        expect(reminderSetup2.timeSetupAtPosition(1).buttons.firstMatch.value as? String).to(equal("12:00"))
        expect(reminderSetup2.timeSetupAtPosition(2).buttons.firstMatch.value as? String).to(equal("18:00"))
        expect(reminderSetup2.timeSetupAtPosition(3).buttons.firstMatch.value as? String).to(equal("20:00"))
    }

    @MainActor
    func testMedicationReminderSetupHappyPath() {
        // Rezept Freitext | Unbegrenzt

        // create a Rezept (Freitext)
        let medicationName = "Ibuprofen"

        let tabBar = TabBarScreen(app: app)

        // Details screen->
        let prescriptionDetails = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed(medicationName)

        // Validate Meine Erinnerung (Aus)->
        expect(prescriptionDetails.medicationReminderCell().value as? String).to(equal("Aus"))

        // Validate info button text
        let instructions = prescriptionDetails.tapDosageInstructionCell()
        expect(instructions.title().label).to(equal("Einnahmehinweise"))
        expect(instructions.description().label)
            .to(
                equal(
                    "Ihr Arzt oder Ihre Ärztin hat Ihnen keine Informationen zur Einnahme des Medikaments mitgegeben."
                )
            )
        instructions.close()

        // -> Tap on Meine Erinnerung->
        let reminderSetup = prescriptionDetails.tapSetupMedicationReminder()

        // Validate Medicine name->
        expect(reminderSetup.medicationNameLabel().label).to(equal(medicationName))
        // Validate toggle is turned off->
        expect(reminderSetup.enabledSwitch().value as? String).to(equal("0"))
        // Turn on toggle->
        reminderSetup.toggleActive()

        // Validate Wiederholen is by default unbegrenzt->
        expect(reminderSetup.repetitionDetailsCell().value as? String).to(equal("Täglich"))

        // Validate no time is added by default->
        expect(reminderSetup.numberOfSetupTimes()).to(equal(0))

        // Speichern button is disabled->
        expect(reminderSetup.saveButton().isEnabled).to(equal(false))

        // Add a new time->
        reminderSetup.tapAddTimeButton()
        expect(reminderSetup.numberOfSetupTimes()).to(equal(1))

        // Speichern button is enabled->
        expect(reminderSetup.saveButton().isEnabled).to(equal(true))

        // Delete the time->
        reminderSetup.deleteAtPosition(0)
        expect(reminderSetup.numberOfSetupTimes()).to(equal(0))
        // Speichern button is disabled->
        expect(reminderSetup.saveButton().isEnabled).to(equal(false))

        // Add the time again->
        reminderSetup.tapAddTimeButton()
        expect(reminderSetup.numberOfSetupTimes()).to(equal(1))
        // Speichern button is enabled->
        expect(reminderSetup.saveButton().isEnabled).to(equal(true))

        // Tap on Speichern->
        // Validate that the details screen is displayed->
        let prescriptionDetails2 = reminderSetup.tapSave()
        // Validate Meine Erinnerung is Ein
        expect(prescriptionDetails2.medicationReminderCell().value as? String)
            .to(equal("Ein"))
    }

    // Rezept DJ | Begrenzt
    @MainActor
    func testMedicationReminderSetupLimited() {
        // create a Rezept (DJ)->
        let medicationName = "Ibuprofen"
        let tabBar = TabBarScreen(app: app)
        // Details screen->
        let prescriptionDetails = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed(medicationName)

        // Validate Meine Erinnerung (Aus)->
        expect(prescriptionDetails.medicationReminderCell().value as? String).to(equal("Aus"))
        // Validate info button text->
        let instructions = prescriptionDetails.tapDosageInstructionCell()
        expect(instructions.description().label)
            .to(
                equal(
                    "Ihr Arzt oder Ihre Ärztin hat Ihnen keine Informationen zur Einnahme des Medikaments mitgegeben."
                )
            )
        instructions.close()

        // Tap on Meine Erinnerung->
        let reminderSetup = prescriptionDetails.tapSetupMedicationReminder()
        // Validate Medicine name->
        expect(reminderSetup.medicationNameLabel().label).to(equal(medicationName))
        // Validate toggle is turned off->
        expect(reminderSetup.enabledSwitch().value as? String).to(equal("0"))
        // Turn on toggle->
        reminderSetup.toggleActive()

        // Validate Wiederholen is by default unbegrenzt->
        expect(reminderSetup.repetitionDetailsCell().value as? String).to(equal("Täglich"))

        // Validate no time is added by default->
        expect(reminderSetup.numberOfSetupTimes()).to(equal(0))
        // Speichern button is disabled->
        expect(reminderSetup.saveButton().isEnabled).to(equal(false))
        // Tap on Wiederholen->
        // Wiederholen screen is displayed->
        let repetitionSetup = reminderSetup.tapRepetitionDetailsCell()

        // Validate Unbegrenzt is selected->
        expect(repetitionSetup.infiniteCell().isSelected).to(equal(true))
        expect(repetitionSetup.finiteCell().isSelected).to(equal(false))
        // Tap on Bregrenzt->
        repetitionSetup.finiteCell().tap()
        expect(repetitionSetup.infiniteCell().isSelected).to(equal(false))
        expect(repetitionSetup.finiteCell().isSelected).to(equal(true))

        let today = Date().formatted(
            Date.FormatStyle()
                .year(.defaultDigits)
                .month(.twoDigits)
                .day(.twoDigits)
        )

        // Validate erster tag und letzter tag with {heute date} is selected by default->
        expect(repetitionSetup.startDatePicker().buttons.firstMatch.value as? String).to(equal(today))
        expect(repetitionSetup.endDatePicker().buttons.firstMatch.value as? String).to(equal(today))

        // Go back->
        repetitionSetup.tapBackButton()

        // Validate Zeit wiederholen is set to Begrenzt bis {heute date}->
        expect(reminderSetup.repetitionDetailsCell().value as? String).to(equal("Täglich"))

        reminderSetup.tapAddTimeButton()
        expect(reminderSetup.numberOfSetupTimes()).to(equal(1))

        // Speichern button is enabled->
        expect(reminderSetup.saveButton().isEnabled).to(equal(true))

        // Tap on Speichern->
        // Validate that the details screen is displayed->
        let details2 = reminderSetup.tapSave()

        // Validate Meine Erinnerung is Ein
        expect(details2.medicationReminderCell().value as? String).to(equal("Ein"))
    }

    // Rezept Keine Angabe | Begrenzt - start date in future
    @MainActor
    func testMedicationReminderSetupForFuture() {
        // create a Rezept (Keine Angabe)->
        let medicationName = "Ibuprofen"

        let tabBar = TabBarScreen(app: app)
        // Details screen->
        let prescriptionDetails = tabBar
            .tapPrescriptionsTab()
            .tapDetailsForPrescriptionNamed(medicationName)

        // Validate Meine Erinnerung (Aus)->
        expect(prescriptionDetails.medicationReminderCell().value as? String).to(equal("Aus"))

        // Validate info button text->
        let instructions = prescriptionDetails.tapDosageInstructionCell()
        expect(instructions.description().label)
            .to(
                equal(
                    "Ihr Arzt oder Ihre Ärztin hat Ihnen keine Informationen zur Einnahme des Medikaments mitgegeben."
                )
            )
        instructions.close()

        // Tap on Meine Erinnerung->
        let reminderSetup = prescriptionDetails.tapSetupMedicationReminder()

        // Validate Medicine name->
        expect(reminderSetup.medicationNameLabel().label).to(equal(medicationName))

        // Validate toggle is turned off->
        expect(reminderSetup.enabledSwitch().value as? String).to(equal("0"))

        // Turn on toggle->
        reminderSetup.toggleActive()

        // Validate Wiederholen is by default unbegrenzt->
        expect(reminderSetup.repetitionDetailsCell().value as? String).to(equal("Täglich"))

        // Validate no time is added by default->
        expect(reminderSetup.numberOfSetupTimes()).to(equal(0))

        // Speichern button is disabled->
        expect(reminderSetup.saveButton().isEnabled).to(equal(false))

        // Tap on Wiederholen->
        // Wiederholen screen is displayed->
        let repetitionSetup = reminderSetup.tapRepetitionDetailsCell()

        // Validate Unbegrenzt is selected->
        expect(repetitionSetup.infiniteCell().isSelected).to(equal(true))
        expect(repetitionSetup.finiteCell().isSelected).to(equal(false))

        // Tap on Bregrenzt->
        repetitionSetup.finiteCell().tap()

        // Validate erster tag und letzter tag with {heute date} is selected by default->
        let today = Date()
        let todayFormatted = today.datePickerLabelFormatted()

        expect(repetitionSetup.startDatePicker().buttons.firstMatch.value as? String).to(equal(todayFormatted))
        expect(repetitionSetup.endDatePicker().buttons.firstMatch.value as? String).to(equal(todayFormatted))

        // Change the erster tag to heute+3 ->
        let heutePlus3 = Date().addingTimeInterval(60 * 60 * 24 * 3)
        repetitionSetup.setStartDate(heutePlus3)

        // Validate that Letzter tag date is also set to heute+3 date automatically->
        expect(repetitionSetup.endDatePicker().buttons.firstMatch.value as? String)
            .to(equal(heutePlus3.datePickerLabelFormatted()))

        // setup end date
        let todayPlus2 = Date().addingTimeInterval(60 * 60 * 24 * 2)
        let todayPlus1 = Date().addingTimeInterval(60 * 60 * 24 * 1)
        let todayPlus10 = Date().addingTimeInterval(60 * 60 * 24 * 10)

        // Tap on date->
        // Select a date for heute +10->
        repetitionSetup.setEndDate(todayPlus10) { datePickerScreen in
            // Validate that all the dates older than heute+3 are greyed out and could not be selected->
            expect(datePickerScreen.cell(for: today))
                .to(isDisabledOrDoesNotExist("Cell for \(today.description)"))
            expect(datePickerScreen.cell(for: todayPlus1))
                .to(isDisabledOrDoesNotExist("Cell for \(todayPlus1.description)"))
            expect(datePickerScreen.cell(for: todayPlus2))
                .to(isDisabledOrDoesNotExist("Cell for \(todayPlus2.description)"))
        }

        // Go back->
        let repetitionSetup2 = repetitionSetup.tapBackButton()

        // Validate Zeit wiederholen is set to Begrenzt bis {heute +10 date}->
        expect(repetitionSetup2.repetitionDetailsCell().value as? String)
            .to(equal("Täglich"))

        // Add a new time->
        repetitionSetup2.tapAddTimeButton()
        // Speichern button is enabled->
        expect(repetitionSetup2.saveButton().isEnabled).to(equal(true))
        // Tap on Speichern->
        // Validate that the details screen is displayed->
        let details = repetitionSetup2.tapSave()

        // Validate Meine Erinnerung is Ein
        expect(details.medicationReminderCell().value as? String).to(equal("Ein"))
    }

    // Multiple Rezepts sorting | Settings screen
    @MainActor
    func testMedicationReminderSetupSortTest() {
        let medicationName1 = "Ibuprofen"
        let medicationName2 = "Paracetamol"
        let medicationName3 = "Adavomilproston"

        let tabBar = TabBarScreen(app: app)
        let mainView = tabBar.tapPrescriptionsTab()
        // create 3 Rezepts with different timestamps > Activate Push for all three->

        let medicationSetup1 = mainView
            .tapDetailsForPrescriptionNamed(medicationName1)
            .tapSetupMedicationReminder()

        medicationSetup1.toggleActive()
        medicationSetup1.tapAddTimeButton()
        _ = medicationSetup1.tapSave()
            .tapBackButton()

        let medicationSetup2 = mainView
            .tapDetailsForPrescriptionNamed(medicationName2)
            .tapSetupMedicationReminder()

        medicationSetup2.toggleActive()
        medicationSetup2.tapAddTimeButton()
        _ = medicationSetup2
            .tapSave()
            .tapBackButton()

        let medicationSetup3 = mainView
            .tapDetailsForPrescriptionNamed(medicationName3)
            .tapSetupMedicationReminder()

        medicationSetup3.toggleActive()
        _ = medicationSetup3.tapSave()
            .tapBackButton()

        // Go to settings screen->
        let settings = tabBar.tapSettingsTab()

        // Medication plan->
        let medicationList = settings.tapMedicationReminder()

        // Validate that the rezepts are sorted as per creation time with newest on top ->
        expect(medicationList.numberOfMedicationReminders()).to(equal(3))
        expect(medicationList.medicationReminderCellWithIndex(0).label).to(equal(medicationName2))
        expect(medicationList.medicationReminderCellWithIndex(1).label).to(equal(medicationName1))
        expect(medicationList.medicationReminderCellWithIndex(2).label).to(equal(medicationName3))

        // Validate that they all have status ein->
        expect(medicationList.medicationReminderCellWithIndex(0).value as? String).to(equal("Ein"))
        expect(medicationList.medicationReminderCellWithIndex(1).value as? String).to(equal("Ein"))
        expect(medicationList.medicationReminderCellWithIndex(2).value as? String).to(equal("Ein"))

        // Tap on the Rezept->
        // Validate Einnahmeerinnerung screen is displayed->
        let medicationReminderDetails = medicationList.tapMedicationReminderCellWithIndex(0)
        // Validate that the toggle is turned on->
        expect(medicationReminderDetails.enabledSwitch().value as? String).to(equal("1"))
        // Turn off the toggle->
        medicationReminderDetails.toggleActive()
        expect(medicationReminderDetails.enabledSwitch().value as? String).to(equal("0"))

        // Tap on speichern->
        let medicationList2 = medicationReminderDetails.tapSave()

        // Medication plan screen is displayed and the rezept status is set to aus->
        expect(medicationList2.medicationReminderCellWithIndex(0).value as? String).to(equal("Aus"))

        // go to main screen->
        let disabledMedicationDetails = tabBar
            .tapPrescriptionsTab()
            // Tap on the same rezept->
            .tapDetailsForPrescriptionNamed(medicationName2)
        // Validate Meine Erinnerung (Aus)
        expect(disabledMedicationDetails.medicationReminderCell().value as? String).to(equal("Aus"))
    }
}
