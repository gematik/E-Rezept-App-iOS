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
struct RedeemSelectionScreen: Screen {
    let app: XCUIApplication

    func tapRedeemRemote(fileID: String = #fileID, file: String = #filePath,
                         line: UInt = #line) -> PharmacySearchScreen {
        button(by: A11y.redeem.overview.rdmBtnDeliveryTile, fileID: fileID, file: file, line: line).tap()

        return PharmacySearchScreen(app: app)
    }

    func tapRedeemLocal(fileID: String = #fileID, file: String = #filePath,
                        line: UInt = #line) -> RedeemMatrixCodeScreen<Self> {
        button(by: A11y.redeem.overview.rdmBtnPharmacyTile, fileID: fileID, file: file, line: line).tap()

        return RedeemMatrixCodeScreen(app: app, previous: self)
    }
}
