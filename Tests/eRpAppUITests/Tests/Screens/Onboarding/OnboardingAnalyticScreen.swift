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
struct OnboardingAnalyticScreen: Screen {
    let app: XCUIApplication

    func tapAnalyticButton(_ screen: (AnalyticsDetailScren) async -> Void,
                           fileID _: String = #fileID,
                           file _: String = #filePath,
                           line _: UInt = #line) async {
        app.links["Analyse der Appverwendung"].coordinate(withNormalizedOffset: .init(dx: 1.0, dy: 0.1)).tap()

        let analyticsDetailScren = AnalyticsDetailScren(app: app)
        await screen(analyticsDetailScren)
    }

    func tapAcceptAnalyticsButton(fileID: String = #fileID, file: String = #filePath,
                                  line: UInt = #line) {
        button(by: A11y.onboarding.analytics.onbAnaBtnAllow, fileID: fileID, file: file, line: line).tap()
    }
}

@MainActor
struct AnalyticsDetailScren: Screen {
    let app: XCUIApplication

    func tapBackButton(fileID _: String = #fileID, file _: String = #filePath,
                       line _: UInt = #line) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func analyticsDetailHeader(fileID _: String = #fileID, file _: String = #filePath,
                               line _: UInt = #line) -> XCUIElement {
        app.staticTexts["Warum ist die Analyse wichtig?"].firstMatch
    }
}
