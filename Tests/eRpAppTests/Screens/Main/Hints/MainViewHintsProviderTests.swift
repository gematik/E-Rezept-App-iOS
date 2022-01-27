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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class MainViewHintsProviderTests: XCTestCase {
    // MARK: - tests for DemoModeAdvertiseHint

    func testOpenScannerHintWhenItShouldBePresented() {
        let sut = MainViewHintsProvider()

        let hint = sut.currentHint(for: HintState(), isDemoMode: false)

        expect(hint).to(equal(MainViewHintsProvider.openScannerHint))
    }

    func testOpenScannerHintWhenItShouldNotBePresented() {
        let sut = MainViewHintsProvider()

        let hint = sut.currentHint(for: HintState(hasScannedPrescriptionsBefore: true), isDemoMode: false)

        expect(hint).notTo(be(MainViewHintsProvider.openScannerHint))
    }

    func testDemoModeAdvertiseHintWhenItShouldBePresented() {
        let sut = MainViewHintsProvider()

        var hintState = HintState()
        hintState.hasScannedPrescriptionsBefore = true
        let hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint).to(equal(MainViewHintsProvider.demoModeTourHint))
    }

    func testDemoModeAdvertiseHintWhenItShouldNotAppear() {
        let sut = MainViewHintsProvider()

        // when there are tasks in local store
        var hintState = HintState(hasTasksInLocalStore: true)
        hintState.hasScannedPrescriptionsBefore = true
        var hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint).to(beNil())

        // when demo mode has been toggled
        hintState = HintState(hasDemoModeBeenToggledBefore: true)
        hintState.hasScannedPrescriptionsBefore = true
        hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint).to(beNil())

        // when hint has been dismissed
        hintState = HintState(hiddenHintIDs: [A18n.mainScreen.erxHntDemoModeTour])
        hintState.hasScannedPrescriptionsBefore = true
        hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint).to(beNil())

        // when hint has been dismissed, demoMode was toggled and there are tasks in local store
        hintState = HintState(
            hasScannedPrescriptionsBefore: true,
            hasTasksInLocalStore: true,
            hasDemoModeBeenToggledBefore: true,
            hiddenHintIDs: [A18n.mainScreen.erxHntDemoModeTour]
        )
        hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint).to(beNil())

        // when in demo mode
        hintState = HintState()
        hint = sut.currentHint(for: hintState, isDemoMode: true)

        expect(hint) != MainViewHintsProvider.demoModeTourHint
        expect(hint) == MainViewHintsProvider.demoModeWelcomeHint
    }

    func testAppSequrityAdvertiseHintWhenItShouldNotBePresented() {
        let sut = MainViewHintsProvider()

        var hintState = HintState(hasScannedPrescriptionsBefore: true)
        hintState.hasDemoModeBeenToggledBefore = true
        let hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint).to(beNil())
    }

    func testUnreadMessagesHintTests() {
        let sut = MainViewHintsProvider()

        // when unread messages are there
        let hintState = HintState(hasUnreadMessages: true)
        let hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint) == MainViewHintsProvider.unreadMessagesHint
    }

    // MARK: - tests for DemoModeHint

    func testDemoModeHintWithInitialState() {
        let sut = MainViewHintsProvider()

        let hintState = HintState(hasScannedPrescriptionsBefore: true)
        let hint = sut.currentHint(for: hintState, isDemoMode: true)

        expect(hint).to(equal(MainViewHintsProvider.demoModeWelcomeHint))
    }

    func testDemoModeHintWhenItShouldNotAppear() {
        let sut = MainViewHintsProvider()

        // when card wall has been used
        var hintState = HintState(hasScannedPrescriptionsBefore: true,
                                  hasCardWallBeenPresentedInDemoMode: true)
        var hint = sut.currentHint(for: hintState, isDemoMode: true)

        expect(hint).to(beNil())

        // when hint has been dismissed
        hintState = HintState(hiddenHintIDs: [A18n.mainScreen.erxHntDemoModeWelcome])
        hint = sut.currentHint(for: hintState, isDemoMode: true)

        expect(hint).to(beNil())

        // when not in demo mode
        hintState = HintState(hasScannedPrescriptionsBefore: true)
        hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint) != MainViewHintsProvider.demoModeWelcomeHint
        expect(hint) == MainViewHintsProvider.demoModeTourHint
    }
}
