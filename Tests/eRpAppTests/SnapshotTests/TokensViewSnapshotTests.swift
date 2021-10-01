//
//  Copyright (c) 2021 gematik GmbH
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

import CombineSchedulers
@testable import eRpApp
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class TokensViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testTokensViewWithoutSsoTokenSnapshot() {
        let sut = IDPTokenView(
            token: IDPToken(
                accessToken: "some access token with missing SSO token",
                expires: Date(),
                idToken: "123456",
                ssoToken: nil,
                tokenType: "ended"
            )
        )

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testTokensViewWithAccessTokenAndSsoTokenSnapshot() {
        let sut = IDPTokenView(
            token: IDPToken(
                accessToken: "eyJhbGciOiJCUDI1NlIxIn0.eyJhY3IiOiJlaWRhcy1sb2EtaGlnaCIsImF1ZCI6Imh0dHBzOi8vZXJwLnRlbGVtYXRpay5kZS9sb2dpbiIsImV4cCI6MjUyNDYwODAwMCwiZmFtaWx5X25hbWUiOiJkZXIgTmFjaG5hbWUiLCJnaXZlbl9uYW1lIjoiZGVyIFZvcm5hbWUiLCJpYXQiOjE1ODUzMzY5NTYsImlkTnVtbWVyIjoiWDIzNDU2Nzg5MCIsImlycyI6Imh0dHBzOi8vaWRwMS50ZWxlbWF0aWsuZGUvand0IiwianRpIjoiPElEUD5fMDEyMzQ1Njc4OTAxMjM0NTY3ODkiLCJuYmYiOjE1ODUzMzY5NTYsIm5vbmNlIjoiZnV1IGJhciBiYXoiLCJvcmdhbml6YXRpb25OYW1lIjoiSW5zdGl0dXRpb25zLSBvZGVyIE9yZ2FuaXNhdGlvbnMtQmV6ZWljaG51bpciLCJwcm9mZXNzaW9uT0lEIjoiMS4yLjI3Ni4wLjc2LjQuNDkiLCJzdWIiOiJSYWJjVVN1dVdLS1pFRUhtcmNObV9rVURPVzEzdWFHVTVaazhPb0J3aU5rIn0.hV_gCPkPAHYRsrxwoARYSfQQlfJuJ198ys2aMf1XC2tOgDj-HXt0SUh15kWmFXoXVNOI7m6X4oqIRgLK4BHn3Q",
                // swiftlint:disable:previous line_length
                expires: Date(),
                idToken: "123456",
                ssoToken: "sso_tokens_are_very_long",
                tokenType: "ended"
            )
        )

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
