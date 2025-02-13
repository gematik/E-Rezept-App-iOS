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
struct RedeemEditPrescriptionListScreen: Screen {
    let app: XCUIApplication

    @discardableResult
    func cellForPrescriptionNamed(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                  line: UInt = #line) -> XCUIElement {
        button(by: name, fileID: fileID, file: file, line: line)
    }

    func tapSave(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
        button(by: A11y.pharmacyPrescriptionList.phaPrescriptionListBtnSave, fileID: fileID, file: file, line: line)
            .tap()
    }
}
