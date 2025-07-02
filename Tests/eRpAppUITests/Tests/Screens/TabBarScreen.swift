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
struct TabBarScreen: Screen {
    let app: XCUIApplication

    func tapPrescriptionsTab(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> MainScreen {
        button(within: app.tabBars, by: "Rezepte", fileID: fileID, file: file, line: line)
            .tap()

        return .init(app: app)
    }

    func tapPrescriptionsTab(
        _ screen: (MainScreen) async -> Void,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) async {
        button(within: app.tabBars, by: "Rezepte", fileID: fileID, file: file, line: line)
            .tap()

        await screen(MainScreen(app: app))
    }

    func tapSettingsTab(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> SettingsScreen {
        button(within: app.tabBars, by: "Einstellungen", fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    func tapSettingsTab(
        _ screen: (SettingsScreen) async -> Void,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) async {
        button(within: app.tabBars, by: "Einstellungen", fileID: fileID, file: file, line: line).tap()

        await screen(SettingsScreen(app: app))
    }

    @discardableResult
    func tapPharmacySearchTab(fileID: String = #fileID, file: String = #filePath,
                              line: UInt = #line) -> PharmacySearchScreen {
        button(within: app.tabBars, by: "Apothekensuche", fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    @discardableResult
    func tapOrderTab(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> OrdersScreen {
        button(within: app.tabBars, by: "Nachrichten", fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    func tapOrderTab(
        _ screen: (OrdersScreen) -> Void,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) {
        button(within: app.tabBars, by: "Nachrichten", fileID: fileID, file: file, line: line).tap()

        screen(OrdersScreen(app: app))
    }
}
