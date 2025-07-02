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

import XCTest

@MainActor
struct SettingsScreen: Screen {
    let app: XCUIApplication

    func tapMedicationReminder(fileID: String = #fileID, file: String = #filePath,
                               line: UInt = #line) -> MedicationReminderListScreen {
        button(by: A11y.settings.security.stgBtnMedicationReminder, fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    func tapLanguageSettingsButton(fileID: String = #fileID, file: String = #filePath,
                                   line: UInt = #line) -> XCUIElement {
        button(by: A11y.settings.security.stgBtnLanguageSettings, fileID: fileID, file: file, line: line).tap()

        return app.alerts.firstMatch
    }

    func tapAppSecuritySelection(fileID: String = #fileID, file: String = #filePath,
                                 line: UInt = #line) -> AppSecuritySelectionScreen {
        button(by: A11y.settings.security.stgBtnDeviceSecurity, fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    func tapDemoMode(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        switches(by: A11y.settings.demo.stgTxtDemoMode, fileID: fileID, file: file, line: line).tap()
    }
}
