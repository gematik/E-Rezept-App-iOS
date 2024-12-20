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

import Nimble
import XCTest

@MainActor
struct RedeemEditAddress: Screen {
    let app: XCUIApplication

    func setPLZ(_ plz: String, fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        let textField = textField(by: A11y.pharmacyContact.phaContactAddressZip, fileID: fileID, file: file, line: line)
        textField
            .coordinate(withNormalizedOffset: .init(dx: 0.5, dy: 0.1)) // offset to accomodate for label spacing
            .tap()
        textField.typeText(plz)
    }

    func setPhoneNumber(_ phoneNumber: String, fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        let textField = textField(
            by: A11y.pharmacyContact.phaContactAddressPhone,
            fileID: fileID,
            file: file,
            line: line
        )
        textField
            .coordinate(withNormalizedOffset: .init(dx: 0.5, dy: 0.1)) // offset to accomodate for label spacing
            .tap()
        textField.typeText(phoneNumber)
    }

    @discardableResult
    @MainActor
    func tapSave(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) async throws -> RedeemScreen {
        button(by: A11y.pharmacyContact.phaContactBtnSave, fileID: fileID, file: file, line: line).tap()

        // closing the edit address screen takes some time to finish animations
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)

        return RedeemScreen(app: app, file: file, line: line)
    }
}
