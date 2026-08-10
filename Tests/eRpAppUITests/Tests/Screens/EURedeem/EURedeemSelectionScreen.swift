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
struct EURedeemSelectionScreen: Screen {
    let app: XCUIApplication

    @discardableResult
    func tapPrescriptions(fileID: String = #fileID, file: String = #filePath,
                          line: UInt = #line) -> SelectEUPrescriptionsScreen {
        button(by: A11y.redeem.eu.selection.eurdmBtnSelectionPrescriptions, fileID: fileID, file: file, line: line)
            .tap()
        return SelectEUPrescriptionsScreen(app: app)
    }

    @discardableResult
    func tapCountry(fileID: String = #fileID, file: String = #filePath,
                    line: UInt = #line) -> CountrySelectionScreen {
        button(by: A11y.redeem.eu.selection.eurdmBtnSelectionCountry, fileID: fileID, file: file, line: line).tap()
        return CountrySelectionScreen(app: app)
    }

    @discardableResult
    func tapRedeem(fileID: String = #fileID, file: String = #filePath,
                   line: UInt = #line) -> EURedeemCodeScreen {
        button(by: A11y.redeem.eu.selection.eurdmBtnSelectionRedeem, fileID: fileID, file: file, line: line).tap()
        return EURedeemCodeScreen(app: app)
    }

    @discardableResult
    func tapRedeemToInstructions(fileID: String = #fileID, file: String = #filePath,
                                 line: UInt = #line) -> EURedeemInstructionsScreen {
        button(by: A11y.redeem.eu.selection.eurdmBtnSelectionRedeem, fileID: fileID, file: file, line: line).tap()
        return EURedeemInstructionsScreen(app: app)
    }

    @discardableResult
    func tapInstructionsLink(fileID _: String = #fileID, file: String = #filePath,
                             line: UInt = #line) -> EURedeemInstructionsScreen {
        let anleitungLink = app.links["Anleitung"].firstMatch
        expect(file: file, line: line, anleitungLink.waitForExistence(timeout: 5.0)).to(beTrue())
        anleitungLink.tap()
        return EURedeemInstructionsScreen(app: app)
    }

    func title(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(by: A11y.redeem.eu.selection.eurdmTxtSelectionTitle, fileID: fileID, file: file, line: line)
    }

    func redeemButton(fileID: String = #fileID, file: String = #filePath,
                      line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.redeem.eu.selection.eurdmBtnSelectionRedeem,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    func tapClose(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A11y.redeem.eu.selection.eurdmBtnSelectionClose, fileID: fileID, file: file, line: line).tap()
    }
}
