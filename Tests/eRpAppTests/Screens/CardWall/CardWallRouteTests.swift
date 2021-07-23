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

@testable import eRpApp
import Nimble
import XCTest

final class CardWallRouteTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testCardWallRoute_Nothing_Available_Device_Capable() {
        let viewModel = CardWallDomain.State(introAlreadyDisplayed: false,
                                             isNFCReady: true,
                                             isMinimalOS14: true,
                                             can: CardWallCANDomain.State(isDemoModus: false, can: ""),
                                             pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                                             loginOption: CardWallLoginOptionDomain.State(isDemoModus: false))
        var sut = CardWallRoute(with: viewModel)

        expect(sut).to(equal(CardWallRoute.intro))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.enterCAN))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.enterPIN))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.loginOption))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.readCard))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.none))
    }

    func testCardWallRoute_Nothing_Available_Device_Not_Capable() {
        let viewModel = CardWallDomain.State(introAlreadyDisplayed: false,
                                             isNFCReady: false,
                                             isMinimalOS14: false,
                                             can: CardWallCANDomain.State(isDemoModus: false, can: ""),
                                             pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                                             loginOption: CardWallLoginOptionDomain.State(isDemoModus: false))
        var sut = CardWallRoute(with: viewModel)

        expect(sut).to(equal(CardWallRoute.intro))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.capabilitiesMissing))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.none))
    }

    func testCardWallRoute_Intro_Done_CAN_not_Available_Device_Capable() {
        let viewModel = CardWallDomain.State(introAlreadyDisplayed: true,
                                             isNFCReady: true,
                                             isMinimalOS14: true,
                                             can: CardWallCANDomain.State(isDemoModus: false, can: ""),
                                             pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                                             loginOption: CardWallLoginOptionDomain.State(isDemoModus: false))
        var sut = CardWallRoute(with: viewModel)

        expect(sut).to(equal(CardWallRoute.enterCAN))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.enterPIN))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.loginOption))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.readCard))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.none))
    }

    func testCardWallRoute_Intro_Done_CAN_Available_Device_Capable() {
        let viewModel = CardWallDomain.State(introAlreadyDisplayed: true,
                                             isNFCReady: true,
                                             isMinimalOS14: true,
                                             can: nil,
                                             pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                                             loginOption: CardWallLoginOptionDomain.State(isDemoModus: false))
        var sut = CardWallRoute(with: viewModel)

        expect(sut).to(equal(CardWallRoute.enterPIN))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.loginOption))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.readCard))
        sut = sut.next(with: viewModel)
        expect(sut).to(equal(CardWallRoute.none))
    }
}
