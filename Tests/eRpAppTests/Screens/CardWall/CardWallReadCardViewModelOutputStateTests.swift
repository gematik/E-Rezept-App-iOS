//
//  Copyright (c) 2022 gematik GmbH
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

@testable import eRpApp
import HTTPClient
@testable import IDP
import Nimble
import SwiftUI
import XCTest

final class CardWallReadCardViewModelOutputStateTests: XCTestCase {
    enum GenericErrorMock: Error {
        case generic
    }

    let titleNext: LocalizedStringKey = "cdw_btn_rc_next"
    let titleRetry: LocalizedStringKey = "cdw_btn_rc_retry"
    let titleClose: LocalizedStringKey = "cdw_btn_rc_close"
    let titleLoading: LocalizedStringKey = "cdw_btn_rc_loading"
    let titleBackToCan: LocalizedStringKey = "cdw_btn_rc_correct_can"
    let titleBackToPin: LocalizedStringKey = "cdw_btn_rc_correct_pin"

    func testCorrectButtonState() {
        var sut = CardWallReadCardDomain.State.Output.idle
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleNext))

        sut = CardWallReadCardDomain.State.Output.retrievingChallenge(.loading)
        expect(sut.nextButtonEnabled).to(beFalse())
        expect(sut.buttonTitle).to(equal(titleLoading))
        let challenge = try! IDPChallengeSession(
            challenge: IDPChallenge(
                challenge: try! JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
            ),
            verifierCode: "verifier",
            state: "123456789",
            nonce: "1234567890"
        )
        sut = CardWallReadCardDomain.State.Output.challengeLoaded(challenge)
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleNext))
        sut = CardWallReadCardDomain.State.Output.retrievingChallenge(.error(.idpError(
            IDPError.network(error: HTTPError.networkError("timeout"))
        )))
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleRetry))

        sut = CardWallReadCardDomain.State.Output.signingChallenge(.loading)
        expect(sut.nextButtonEnabled).to(beFalse())
        expect(sut.buttonTitle).to(equal(titleLoading))
        sut = CardWallReadCardDomain.State.Output.signingChallenge(.error(.idpError(
            IDPError.network(error: HTTPError.networkError("timeout"))
        )))
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleRetry))
        sut = CardWallReadCardDomain.State.Output
            .signingChallenge(.error(.signChallengeError(.wrongCAN(GenericErrorMock.generic))))
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleBackToCan))
        expect(sut.nextAction).to(equal(.wrongCAN))
        sut = CardWallReadCardDomain.State.Output
            .signingChallenge(.error(.signChallengeError(.wrongPin(retryCount: 5))))
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleBackToPin))
        expect(sut.nextAction).to(equal(.wrongPIN))

        sut = CardWallReadCardDomain.State.Output.verifying(.loading)
        expect(sut.nextButtonEnabled).to(beFalse())
        expect(sut.buttonTitle).to(equal(titleLoading))
        sut = CardWallReadCardDomain.State.Output.verifying(.error(.idpError(
            IDPError.network(error: HTTPError.networkError("timeout"))
        )))
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleRetry))

        let idpToken = IDPToken(accessToken: "", expires: Date(), idToken: "")
        sut = CardWallReadCardDomain.State.Output.loggedIn(idpToken)
        expect(sut.nextButtonEnabled).to(beTrue())
        expect(sut.buttonTitle).to(equal(titleClose))
    }
}

extension ProgressTile.State {
    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}
