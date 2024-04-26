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

struct RedeemScreen: Screen {
    let app: XCUIApplication

    func tapRedeem(file: StaticString = #file, line: UInt = #line) -> SuccessScreen {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnRedeem, file: file, line: line).tap()

        return SuccessScreen(app: app)
    }

    func tapEditAddress(file: StaticString = #file, line: UInt = #line) -> RedeemEditAddress {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnEditAddress, file: file, line: line).tap()

        return RedeemEditAddress(app: app)
    }

    func tapEditPrescriptions(file: StaticString = #file, line: UInt = #line) -> RedeemEditPrescriptionListScreen {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnEditPrescription, file: file, line: line).tap()

        return RedeemEditPrescriptionListScreen(app: app)
    }
}
