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
@testable import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

final class CardWallExtAuthSelectionViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func store(for state: CardWallExtAuthSelectionDomain.State) -> CardWallExtAuthSelectionDomain.Store {
        .init(initialState: state,
              reducer: .empty,
              environment: CardWallExtAuthSelectionDomain.Environment(
                  idpSession: IDPSessionMock(),
                  schedulers: Schedulers()
              ))
    }

    func testList() {
        let sut = CardWallExtAuthSelectionView(
            store: store(for: .init(
                kkList: Self.testDirectory,
                error: nil,
                selectedKK: Self.testEntryB,
                orderEgkVisible: false
            ))
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testError() {
        let sut = CardWallExtAuthSelectionView(
            store: store(for: .init(
                kkList: Self.testDirectory,
                error: IDPError.internalError("internalError Test Error"),
                selectedKK: Self.testEntryB,
                orderEgkVisible: false
            ))
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    static let testError = IDPError.internalError("TestError")

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
