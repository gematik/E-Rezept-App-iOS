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
struct SuccessScreen: Screen {
    let app: XCUIApplication

    init(app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        self.app = app

        if !app.navigationBars["Geschafft! 🎉"].exists {
            expect(file: file, line: line, app.navigationBars["Geschafft! 🎉"].waitForExistence(timeout: 5))
                .to(beTrue())
        }
    }

    @MainActor
    func tapClose(file: StaticString = #file, line: UInt = #line) async throws {
        button(by: A11y.pharmacyRedeem.phaRedeemBtnRedeem, file: file, line: line).tap()

        // closing the redeem screen takes some time to finish animations
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
    }
}
