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
import XCTest

@MainActor
struct PrescriptionDetailsScreen<Previous>: Screen where Previous: Screen {
    let app: XCUIApplication
    let previous: Previous

    init(app: XCUIApplication, previous: Previous) {
        self.app = app
        self.previous = previous
    }

    func medicationReminderCell(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.prescriptionDetails.prscDtlBtnMedicationReminder, fileID: fileID, file: file, line: line)
    }

    func dosageInstructionCell(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.prescriptionDetails.prscDtlTxtDosageInstructions, fileID: fileID, file: file, line: line)
    }

    func tapDosageInstructionCell(fileID: String = #fileID, file: String = #filePath,
                                  line: UInt = #line) -> DosageInstructionsScreen {
        dosageInstructionCell(file: file, line: line).tap()

        let container = container(
            by: A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfo,
            fileID: fileID,
            file: file,
            line: line
        )
        return DosageInstructionsScreen(app: app, rootElement: container)
    }

    func tapSetupMedicationReminder(fileID: String = #fileID, file: String = #filePath,
                                    line: UInt = #line) -> MedicationReminderSetupScreen<Self> {
        medicationReminderCell(fileID: fileID, file: file, line: line).tap()

        return .init(app: app, previous: self)
    }

    func tapBackButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> MainScreen {
        button(within: app.navigationBars, by: "Rezepte", fileID: fileID, file: file, line: line).tap()

        return MainScreen(app: app)
    }

    func tapRedeemPharmacyButton(fileID: String = #fileID, file: String = #filePath,
                                 line: UInt = #line) -> RedeemScreen {
        button(by: A11y.prescriptionDetails.prscDtlBtnRedeem, fileID: fileID, file: file, line: line).tap()

        return RedeemScreen(app: app)
    }

    func tapShowMatrixCodeButton(fileID: String = #fileID, file: String = #filePath,
                                 line: UInt = #line) -> RedeemMatrixCodeScreen<Self> {
        button(by: A11y.prescriptionDetails.prscDtlBtnShowMatrixCode, fileID: fileID, file: file, line: line).tap()

        return RedeemMatrixCodeScreen(app: app, previous: self)
    }

    func autIdemHeadlineButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.prescriptionDetails.prscDtlBtnHeadlineSubstitutionInfo,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func tapAutIdemHeadlineButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Drawer {
        button(by: A11y.prescriptionDetails.prscDtlBtnHeadlineSubstitutionInfo, fileID: fileID, file: file, line: line)
            .tap()

        return Drawer(
            app: app,
            identifier: A11y.prescriptionDetails.prscDtlDrawerSubstitutionInfo,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    func autIdemInfoButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.prescriptionDetails.prscDtlBtnSubstitutionInfo,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func tapAutIdemInfoButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Drawer {
        button(by: A11y.prescriptionDetails.prscDtlBtnSubstitutionInfo, fileID: fileID, file: file, line: line).tap()

        return Drawer(
            app: app,
            identifier: A11y.prescriptionDetails.prscDtlDrawerSubstitutionInfo,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    func medicationButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.prescriptionDetails.prscDtlBtnMedication,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func tapMedicationButton(fileID: String = #fileID, file: String = #filePath,
                             line: UInt = #line) -> MedicationDetailsScreen<Self> {
        button(by: A11y.prescriptionDetails.prscDtlBtnMedication, fileID: fileID, file: file, line: line).tap()

        return MedicationDetailsScreen(
            app: app,
            previous: self
        )
    }

    func emergencyFeeButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.prescriptionDetails.prscDtlBtnEmergencyServiceFee, fileID: fileID, file: file, line: line)
    }

    func tapEmergencyFeeButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Drawer {
        button(by: A11y.prescriptionDetails.prscDtlBtnEmergencyServiceFee, fileID: fileID, file: file, line: line).tap()

        return Drawer(
            app: app,
            identifier: A11y.prescriptionDetails.prscDtlDrawerEmergencyServiceFeeInfo,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    func selfPayerHeadlineButton(fileID: String = #fileID, file: String = #filePath,
                                 line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.prescriptionDetails.prscDtlBtnSelfPayerInfo,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func tapSelfPayerHeadlineButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Drawer {
        button(
            by: A11y.prescriptionDetails.prscDtlBtnSelfPayerInfo,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
        .tap()

        return Drawer(
            app: app,
            identifier: A11y.prescriptionDetails.prscDtlDrawerSelfPayerInfo,
            fileID: fileID,
            file: file,
            line: line
        )
    }

    @MainActor
    struct Drawer: Screen {
        let app: XCUIApplication
        let container: XCUIElement

        init(
            app: XCUIApplication,
            identifier: String,
            fileID _: String = #fileID,
            file _: String = #filePath,
            line _: UInt = #line
        ) {
            self.app = app
            container = app.otherElements[identifier]
        }

        func title(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> String? {
            staticText(by: A11y.prescriptionDetails.prscDtlDrawerTitle, fileID: fileID, file: file, line: line).label
        }

        func description(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> String? {
            staticText(by: A11y.prescriptionDetails.prscDtlDrawerDescription, fileID: fileID, file: file, line: line)
                .label
        }

        func close(file _: StaticString = #file, line _: UInt = #line) {
            container.coordinate(withNormalizedOffset: .zero).tap()
        }
    }

    @MainActor
    struct DosageInstructionsScreen: Screen {
        let app: XCUIApplication

        let rootElement: XCUIElement

        func title(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
            staticText(
                by: A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfoTitle,
                fileID: fileID,
                file: file,
                line: line
            )
        }

        func description(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
            staticText(
                by: A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfoDescription,
                fileID: fileID,
                file: file,
                line: line
            )
        }

        func close(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
            button(by: A11y.prescriptionDetails.prscDtlTxtDosageInstructions, fileID: fileID, file: file, line: line)
                .coordinate(withNormalizedOffset: .zero)
                .tap()
        }
    }
}
