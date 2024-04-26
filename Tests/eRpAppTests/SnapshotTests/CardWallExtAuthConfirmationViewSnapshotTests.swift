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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import IDP
@testable import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

final class CardWallExtAuthConfirmationViewSnapshotTests: ERPSnapshotTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func store(for state: CardWallExtAuthConfirmationDomain.State) -> CardWallExtAuthConfirmationDomain.Store {
        .init(initialState: state) {
            EmptyReducer()
        }
    }

    func testPlainDialog() {
        let sut = CardWallExtAuthConfirmationView(
            store: store(for: .init(selectedKK: Self.testEntry))
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testLoading() {
        let sut = CardWallExtAuthConfirmationView(
            store: store(for: .init(
                selectedKK: Self.testEntry,
                loading: true,
                error: nil,
                contactActionSheet: nil
            ))
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testError() {
        let sut = CardWallExtAuthConfirmationView(
            store: store(for: .init(
                selectedKK: Self.testEntry,
                loading: false,
                error: CardWallExtAuthConfirmationDomain.Error.idpError(Self.testError),
                contactActionSheet: nil
            ))
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    static let testError = IDPError.internal(error: .notImplemented)

    static let testEntry = KKAppDirectory.Entry(name: "Dummy KK", identifier: "dummy_identifier")
}
