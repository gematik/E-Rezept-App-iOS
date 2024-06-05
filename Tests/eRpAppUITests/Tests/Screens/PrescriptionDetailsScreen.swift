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

struct PrescriptionDetailsScreen: Screen {
    let app: XCUIApplication

    func medicationReminderCell(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        button(by: A11y.prescriptionDetails.prscDtlBtnMedicationReminder, file: file, line: line)
    }

    func dosageInstructionCell(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        button(by: A11y.prescriptionDetails.prscDtlTxtDosageInstructions, file: file, line: line)
    }

    func tapDosageInstructionCell(file: StaticString = #file, line: UInt = #line) -> DosageInstructionsScreen {
        dosageInstructionCell(file: file, line: line).tap()

        let container = container(
            by: A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfo,
            file: file,
            line: line
        )
        return DosageInstructionsScreen(app: app, rootElement: container)
    }

    func tapSetupMedicationReminder(file: StaticString = #file,
                                    line: UInt = #line) -> MedicationReminderSetupScreen<Self> {
        medicationReminderCell(file: file, line: line).tap()

        return .init(app: app, previous: self)
    }

    func tapBackButton(file: StaticString = #file, line: UInt = #line) -> MainScreen {
        button(within: app.navigationBars, by: "Rezepte", file: file, line: line).tap()

        return MainScreen(app: app)
    }

    func tapRedeemPharmacyButton(file: StaticString = #file, line: UInt = #line) -> PharmacySearchScreen {
        button(by: A11y.prescriptionDetails.prscDtlBtnRedeem, file: file, line: line).tap()

        return PharmacySearchScreen(app: app)
    }

    func tapShowMatrixCodeButton(file: StaticString = #file, line: UInt = #line) -> RedeemMatrixCodeScreen<Self> {
        button(by: A11y.prescriptionDetails.prscDtlBtnShowMatrixCode, file: file, line: line).tap()

        return RedeemMatrixCodeScreen(app: app, previous: self)
    }

    func autIdemHeadlineButton(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.prescriptionDetails.prscDtlBtnHeadlineSubstitutionInfo,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func tapAutIdemHeadlineButton(file: StaticString = #file, line: UInt = #line) -> Drawer {
        button(by: A11y.prescriptionDetails.prscDtlBtnHeadlineSubstitutionInfo, file: file, line: line).tap()

        return Drawer(
            app: app,
            identifier: A11y.prescriptionDetails.prscDtlDrawerSubstitutionInfo,
            file: file,
            line: line
        )
    }

    func tapAutIdemInfoButton(file: StaticString = #file, line: UInt = #line) -> Drawer {
        button(by: A11y.prescriptionDetails.prscDtlBtnSubstitutionInfo, file: file, line: line).tap()

        return Drawer(
            app: app,
            identifier: A11y.prescriptionDetails.prscDtlDrawerSubstitutionInfo,
            file: file,
            line: line
        )
    }

    struct Drawer: Screen {
        let app: XCUIApplication
        let container: XCUIElement

        init(app: XCUIApplication, identifier: String, file _: StaticString = #file, line _: UInt = #line) {
            self.app = app
            container = app.otherElements[identifier]
        }

        func title(file: StaticString = #file, line: UInt = #line) -> String? {
            staticText(by: A11y.prescriptionDetails.prscDtlDrawerTitle, file: file, line: line).label
        }

        func description(file: StaticString = #file, line: UInt = #line) -> String? {
            staticText(by: A11y.prescriptionDetails.prscDtlDrawerDescription, file: file, line: line).label
        }

        func close(file _: StaticString = #file, line _: UInt = #line) {
            container.coordinate(withNormalizedOffset: .zero).tap()
        }
    }

    struct DosageInstructionsScreen: Screen {
        let app: XCUIApplication

        let rootElement: XCUIElement

        func title(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
            staticText(by: A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfoTitle, file: file, line: line)
        }

        func description(file: StaticString = #file, line: UInt = #line) -> XCUIElement {
            staticText(
                by: A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfoDescription,
                file: file,
                line: line
            )
        }

        func close(file: StaticString = #file, line: UInt = #line) {
            button(by: A11y.prescriptionDetails.prscDtlTxtDosageInstructions, file: file, line: line)
                .coordinate(withNormalizedOffset: .zero)
                .tap()
        }
    }
}
