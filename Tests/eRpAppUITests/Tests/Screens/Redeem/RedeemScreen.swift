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
struct RedeemScreen: Screen {
    let app: XCUIApplication

    init(app: XCUIApplication, fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        self.app = app

        if !app.staticTexts["Meine Bestellung"].exists {
            expect(
                fileID: fileID,
                file: file,
                line: line,
                app.staticTexts["Meine Bestellung"].waitForExistence(timeout: 5)
            )
            .to(beTrue())
        }
    }

    func redeemButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnRedeem, fileID: fileID, file: file, line: line)
    }

    func editPrescriptionButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnEditPrescription, fileID: fileID, file: file, line: line)
    }

    func addPrescriptionButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnAddPrescription, fileID: fileID, file: file, line: line)
    }

    func editPharmacyButton(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnEditPharmacy, fileID: fileID, file: file, line: line)
    }

    func tapServiceOption(
        _ service: PharmacyDetailsScreen.Service = .shipment,
        fileID: String = #fileID, file: String = #filePath, line: UInt = #line
    ) -> RedeemScreen {
        button(by: service.buttonId, fileID: fileID, file: file, line: line).tap()
        return RedeemScreen(app: app)
    }

    func tapRedeem(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> SuccessScreen {
        let button = button(by: A11y.pharmacyRedeem.phaRedeemBtnRedeem, fileID: fileID, file: file, line: line)

        button.tap()

        return SuccessScreen(app: app, file: file, line: line)
    }

    func tapAddPharmacy(fileID: String = #fileID, file: String = #filePath,
                        line: UInt = #line) -> PharmacySearchScreen {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnAddPharmacy, fileID: fileID, file: file, line: line).tap()

        return PharmacySearchScreen(app: app)
    }

    func tapEditPharmacy(fileID: String = #fileID, file: String = #filePath,
                         line: UInt = #line) -> PharmacySearchScreen {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnEditPharmacy, fileID: fileID, file: file, line: line).tap()

        return PharmacySearchScreen(app: app)
    }

    func tapEditAddress(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> RedeemEditAddress {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnEditAddress, fileID: fileID, file: file, line: line).tap()

        return RedeemEditAddress(app: app)
    }

    func tapEditPrescriptions(fileID: String = #fileID, file: String = #filePath,
                              line: UInt = #line) -> RedeemEditPrescriptionListScreen {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnEditPrescription, fileID: fileID, file: file, line: line).tap()

        return RedeemEditPrescriptionListScreen(app: app)
    }

    func selfPayerWarning(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> XCUIElement {
        staticText(by: A11y.selfPayerWarning.selfPayerWarningTxtMessage, fileID: fileID, file: file, line: line)
    }
}
