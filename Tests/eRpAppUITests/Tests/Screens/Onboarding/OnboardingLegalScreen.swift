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
struct OnboardingLegalScreen: Screen {
    let app: XCUIApplication

    func tapDataButton(_ screen: (OnboardingLegalDataScreen) async -> Void,
                       fileID: String = #fileID,
                       file: String = #filePath,
                       line: UInt = #line) async {
        button(by: A11y.onboarding.legalInfo.onbTxtTermsOfPrivacy, fileID: fileID, file: file, line: line).tap()

        let onboardingLegalDataScreen = OnboardingLegalDataScreen(app: app)
        await screen(onboardingLegalDataScreen)
    }

    func tapUsageButton(_ screen: (OnboardingLegalUsageScreen) async -> Void,
                        fileID: String = #fileID,
                        file: String = #filePath,
                        line: UInt = #line) async {
        button(by: A11y.onboarding.legalInfo.onbTxtTermsOfUse, fileID: fileID, file: file, line: line).tap()

        let onboardingLegalUsageScreen = OnboardingLegalUsageScreen(app: app)
        await screen(onboardingLegalUsageScreen)
    }

    func tapNextButton(fileID: String = #fileID, file: String = #filePath,
                       line: UInt = #line) -> OnboardingAuthScreen {
        button(by: A11y.onboarding.legalInfo.onbBtnNext, fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }
}

@MainActor
struct OnboardingLegalUsageScreen: Screen {
    let app: XCUIApplication

    func tapCloseUsageButton(fileID: String = #fileID, file: String = #filePath,
                             line: UInt = #line) {
        button(by: A11y.settings.termsOfUse.stgBtnTermsOfUseClose, fileID: fileID, file: file, line: line).tap()
    }

    func webViewUsageHeader(fileID _: String = #fileID, file _: String = #filePath,
                            line _: UInt = #line) -> XCUIElement {
        let predicate = NSPredicate(
            format: "label == %@ AND value == %@",
            "Nutzungsbedingungen E-Rezept-App",
            "Nutzungsbedingungen E-Rezept-App"
        )
        return app.staticTexts.containing(predicate).firstMatch
    }
}

@MainActor
struct OnboardingLegalDataScreen: Screen {
    let app: XCUIApplication

    func tapCloseDataButton(fileID: String = #fileID, file: String = #filePath,
                            line: UInt = #line) {
        button(by: A11y.settings.dataPrivacy.stgBtnDataPrivacyClose, fileID: fileID, file: file, line: line).tap()
    }

    func webViewDataHeader(fileID _: String = #fileID, file _: String = #filePath,
                           line _: UInt = #line) -> XCUIElement {
        let predicate = NSPredicate(
            format: "label == %@ AND value == %@",
            "Datenschutzerklärung für die E-Rezept-App",
            "Datenschutzerklärung für die E-Rezept-App"
        )
        return app.staticTexts.containing(predicate).firstMatch
    }
}
