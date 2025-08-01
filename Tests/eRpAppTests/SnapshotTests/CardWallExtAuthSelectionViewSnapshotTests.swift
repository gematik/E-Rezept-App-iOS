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

final class CardWallExtAuthSelectionViewSnapshotTests: ERPSnapshotTestCase {
    func store(for state: CardWallExtAuthSelectionDomain.State) -> StoreOf<CardWallExtAuthSelectionDomain> {
        .init(initialState: state) {
            EmptyReducer()
        }
    }

    func testList() {
        let sut = CardWallExtAuthSelectionView(
            store: store(for: .init(
                kkList: Self.testDirectory,
                filteredKKList: Self.testDirectory,
                error: nil
            ))
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testError() {
        let sut = CardWallExtAuthSelectionView(
            store: store(for: .init(
                kkList: Self.testDirectory,
                error: IDPError.internal(error: .notImplemented)
            ))
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testNoResult() {
        let sut = CardWallExtAuthSelectionView(
            store: store(for: .init(
                kkList: Self.testDirectory,
                error: nil,
                searchText: "Not existing KK"
            ))
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    static let testError = IDPError.internal(error: .notImplemented)

    static let testEntryA = KKAppDirectory.Entry(name: "Test Entry A", identifier: "identifierA")
    static let testEntryB = KKAppDirectory.Entry(name: "Test Entry B", identifier: "identifierB")
    static let testEntryC = KKAppDirectory.Entry(name: "Test Entry C", identifier: "identifierC")
    static let testEntryD = KKAppDirectory.Entry(name: "Test Entry D", identifier: "identifierD")
    static let testEntryE = KKAppDirectory.Entry(name: "Test Entry E", identifier: "identifierE")

    static let testDirectory = KKAppDirectory(apps: [
        testEntryA,
        testEntryB,
        testEntryC,
        testEntryD,
        testEntryE,
    ])
}
