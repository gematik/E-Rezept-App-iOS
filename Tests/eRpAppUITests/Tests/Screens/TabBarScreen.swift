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
struct TabBarScreen: Screen {
    let app: XCUIApplication

    func tapPrescriptionsTab(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> MainScreen {
        button(within: app.tabBars, by: "Rezepte", fileID: fileID, file: file, line: line)
            .tap()

        return .init(app: app)
    }

    func tapSettingsTab(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> SettingsScreen {
        button(within: app.tabBars, by: "Einstellungen", fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    @discardableResult
    func tapRedeemTab(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> PharmacySearchScreen {
        button(within: app.tabBars, by: "Apothekensuche", fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    @discardableResult
    func tapOrderTab(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> OrdersScreen {
        button(within: app.tabBars, by: "Nachrichten", fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }
}
