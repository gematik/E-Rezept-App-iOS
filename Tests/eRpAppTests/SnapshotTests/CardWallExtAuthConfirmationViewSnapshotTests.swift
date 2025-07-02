//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
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
    func store(for state: CardWallExtAuthConfirmationDomain.State) -> StoreOf<CardWallExtAuthConfirmationDomain> {
        .init(initialState: state) {
            EmptyReducer()
        }
    }

    func testPlainDialog() {
        let sut = CardWallExtAuthConfirmationView(
            store: store(for: .init(selectedKK: Self.testEntry))
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
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

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
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

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    static let testError = IDPError.internal(error: .notImplemented)

    static let testEntry = KKAppDirectory.Entry(name: "Dummy KK", identifier: "dummy_identifier")
}
