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

struct TabBarScreen: Screen {
    let app: XCUIApplication

    func tapPrescriptionsTab(file: StaticString = #file, line: UInt = #line) -> MainScreen {
        button(within: app.tabBars, by: "Rezepte", file: file, line: line)
            .tap()

        return .init(app: app)
    }

    func tapSettingsTab(file: StaticString = #file, line: UInt = #line) -> SettingsScreen {
        button(within: app.tabBars, by: "Einstellungen", file: file, line: line).tap()

        return .init(app: app)
    }

    @discardableResult
    func tapRedeemTab(file: StaticString = #file, line: UInt = #line) -> PharmacySearchScreen {
        button(within: app.tabBars, by: "Apothekensuche", file: file, line: line).tap()

        return .init(app: app)
    }
}
