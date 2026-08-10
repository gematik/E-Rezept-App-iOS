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
struct RedeemSelectionScreen: Screen {
    let app: XCUIApplication

    func tapRedeemRemote(fileID: String = #fileID, file: String = #filePath,
                         line: UInt = #line) -> RedeemScreen {
        button(by: A11y.redeem.overview.rdmBtnDeliveryTile, fileID: fileID, file: file, line: line).tap()

        return RedeemScreen(app: app)
    }

    func tapRedeemLocal(fileID: String = #fileID, file: String = #filePath,
                        line: UInt = #line) -> RedeemMatrixCodeScreen<Self> {
        button(by: A11y.redeem.overview.rdmBtnPharmacyTile, fileID: fileID, file: file, line: line).tap()

        return RedeemMatrixCodeScreen(app: app, previous: self)
    }

    func redeemEUButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(
            by: A11y.redeem.overview.rdmBtnRedeemEuPrsc,
            fileID: fileID,
            file: file,
            line: line,
            checkExistence: false
        )
    }

    @discardableResult
    func tapRedeemEUToConsent(fileID: String = #fileID, file: String = #filePath,
                              line: UInt = #line) -> EURedeemConsentScreen {
        button(by: A11y.redeem.overview.rdmBtnRedeemEuPrsc, fileID: fileID, file: file, line: line).tap()
        return EURedeemConsentScreen(app: app)
    }

    @discardableResult
    func tapRedeemEU(fileID: String = #fileID, file: String = #filePath,
                     line: UInt = #line) -> EURedeemSelectionScreen {
        button(by: A11y.redeem.overview.rdmBtnRedeemEuPrsc, fileID: fileID, file: file, line: line).tap()
        return EURedeemSelectionScreen(app: app)
    }

    func tapClose(fileID: String = #fileID, file: String = #filePath,
                  line: UInt = #line) -> MainScreen {
        button(by: A11y.redeem.overview.rdmBtnCloseButton, fileID: fileID, file: file, line: line).tap()
        return MainScreen(app: app)
    }
}
