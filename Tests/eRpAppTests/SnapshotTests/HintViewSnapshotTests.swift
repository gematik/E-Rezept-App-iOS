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
import SnapshotTesting
import SwiftUI
import XCTest

final class HintViewSnapshotTests: XCTestCase {
    func testHintViewNeutral() {
        let sut = HintView(
            hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .neutral),
            textAction: {},
            closeAction: {}
        )
        .frame(width: 380, height: 500)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testHintViewAwareness() {
        let sut = HintView(
            hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .awareness),
            textAction: {},
            closeAction: {}
        )
        .frame(width: 380, height: 500)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testHintViewImportant() {
        let sut = HintView(
            hint: MainViewHintsDomain.Dummies.hintBottomAligned(with: .important),
            textAction: {},
            closeAction: {}
        )
        .frame(width: 380, height: 500)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testHintViewNeutralTopAligned() {
        let sut = HintView(
            hint: MainViewHintsDomain.Dummies.hintTopAligned(with: .neutral),
            textAction: {},
            closeAction: {}
        )
        .frame(width: 380, height: 500)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testHintViewAwarenessTopAligned() {
        let sut = HintView(
            hint: MainViewHintsDomain.Dummies.hintTopAligned(with: .awareness),
            textAction: {},
            closeAction: {}
        )
        .frame(width: 380, height: 500)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testHintViewImportantTopAligned() {
        let sut = HintView(
            hint: MainViewHintsDomain.Dummies.hintTopAligned(with: .important),
            textAction: {},
            closeAction: {}
        )
        .frame(width: 380, height: 500)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testDemoModeTourHintView() {
        let sut = HintView(
            hint: MainViewHintsProvider.demoModeTourHint,
            textAction: {},
            closeAction: {}
        )
        .padding()
        .frame(width: 500, height: 900)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testDemoModeWelcomeHintView() {
        let sut = HintView(
            hint: MainViewHintsProvider.demoModeWelcomeHint,
            textAction: {},
            closeAction: {}
        )
        .padding()
        .frame(width: 500, height: 1000)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testOpenScannerHintView() {
        let sut = HintView(
            hint: MainViewHintsProvider.openScannerHint,
            textAction: {},
            closeAction: {}
        )
        .padding()
        .frame(width: 400, height: 900)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testUnreadMessagesHintView() {
        let sut = HintView(
            hint: MainViewHintsProvider.unreadMessagesHint,
            textAction: {},
            closeAction: {}
        )
        .padding()
        .frame(width: 400, height: 900)

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
