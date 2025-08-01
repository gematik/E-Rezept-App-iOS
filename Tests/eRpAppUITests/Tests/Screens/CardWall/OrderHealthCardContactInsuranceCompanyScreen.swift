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
import Nimble
import XCTest

@MainActor
struct OrderHealthCardContactInsuranceCompanyScreen<PreviousScreen: Screen>: Screen {
    let app: XCUIApplication
    let previous: PreviousScreen

    func tapBackButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> PreviousScreen {
        button(within: app.navigationBars, by: "Zurück", fileID: fileID, file: file, line: line).tap()

        return previous
    }

    func phoneBtn(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.orderEGK.ogkBtnPhone, fileID: fileID, file: file, line: line, checkExistence: false)
    }

    func webBtn(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.orderEGK.ogkBtnWeb, fileID: fileID, file: file, line: line, checkExistence: false)
    }

    func mailBtn(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.orderEGK.ogkBtnMail, fileID: fileID, file: file, line: line, checkExistence: false)
    }
}
