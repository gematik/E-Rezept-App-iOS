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
struct DiGaDetailsScreen<Previous>: Screen where Previous: Screen {
    let app: XCUIApplication
    let previous: Previous

    init(app: XCUIApplication, previous: Previous) {
        self.app = app
        self.previous = previous
    }

    func mainButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.digaDetail.digaDtlBtnMainAction, fileID: fileID, file: file, line: line)
    }

    func tapMainButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        mainButton(fileID: fileID, file: file, line: line).tap()
    }

    func tapRefreshButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A11y.digaDetail.digaDtlBtnRefresh, fileID: fileID, file: file, line: line).tap()
    }

    func tapBackButton(fileID _: String = #fileID, file _: String = #filePath,
                       line _: UInt = #line) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
//        button(within: app.navigationBars, by: "Rezepte", fileID: fileID, file: file, line: line).tap()
    }

    func tapMenu(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> Menu {
        button(by: A11y.digaDetail.digaDtlBtnToolbarItem, fileID: fileID, file: file, line: line).buttons.firstMatch
            .descendants(matching: .any).firstMatch.tap()
        return Menu(app: app)
    }

    func tapInsuranceNotFoundAlert(fileID _: String = #fileID, file _: String = #filePath, line _: UInt = #line) {
        app.alerts["Versicherung nicht gefunden."].buttons["Okay"].tap()
    }

    func tapSelectInsurance(
        _ screen: (DiGaInsuranceListScreen) async -> Void,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) async {
        button(by: A11y.digaDetail.digaDtlBtnMainSelectInsurance, fileID: fileID, file: file, line: line).tap()

        let diGaInsuranceListScreen = DiGaInsuranceListScreen(app: app)
        await screen(diGaInsuranceListScreen)
    }

    func tapSelectedInsurance(
        _ screen: (DiGaInsuranceListScreen) async -> Void,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) async {
        button(by: A11y.digaDetail.digaDtlBtnMainSelectedInsurance, fileID: fileID, file: file, line: line).tap()

        let diGaInsuranceListScreen = DiGaInsuranceListScreen(app: app)
        await screen(diGaInsuranceListScreen)
    }

    @MainActor
    struct Menu: Screen {
        let app: XCUIApplication

        init(app: XCUIApplication) {
            self.app = app
        }

        func close(fileID _: String = #fileID, file _: String = #filePath, line _: UInt = #line) {}

        func tapDelete(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
            button(by: A11y.digaDetail.digaDtlBtnDeleteToolbar, fileID: fileID, file: file, line: line).tap()
        }
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
