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

import Combine
import ComposableArchitecture
@testable import eRpApp
import IDP
import Nimble
import TestUtils
import XCTest

final class CardWallExtAuthSelectionDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallExtAuthSelectionDomain.State,
        CardWallExtAuthSelectionDomain.State,
        CardWallExtAuthSelectionDomain.Action,
        CardWallExtAuthSelectionDomain.Action,
        CardWallExtAuthSelectionDomain.Environment
    >

    var idpSessionMock: IDPSessionMock!

    let networkScheduler = DispatchQueue.test
    let uiScheduler = DispatchQueue.test

    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: uiScheduler.eraseToAnyScheduler(),
            networkScheduler: networkScheduler.eraseToAnyScheduler(),
            ioScheduler: DispatchQueue.test.eraseToAnyScheduler(),
            computeScheduler: DispatchQueue.test.eraseToAnyScheduler()
        )
    }()

    override func setUp() {
        super.setUp()

        idpSessionMock = IDPSessionMock()
    }

    func testStore(for state: CardWallExtAuthSelectionDomain.State)
        -> TestStore {
        TestStore(
            initialState: state,
            reducer: CardWallExtAuthSelectionDomain.reducer,
            environment: .init(idpSession: idpSessionMock,
                               schedulers: schedulers)
        )
    }

    func testStore()
        -> TestStore {
        testStore(for: .init())
    }

    func testLoadingTriggerSucceeds() {
        let sut = testStore()

        idpSessionMock.loadDirectoryKKApps_Publisher = Just(Self.testDirectory)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        sut.send(.loadKKList) { _ in
        }
        uiScheduler.run()
        sut.receive(.loadKKListReceived(.success(Self.testDirectory))) { state in
            state.kkList = Self.testDirectory
        }
    }

    func testLoadingTriggerFails() {
        let sut = testStore()

        idpSessionMock.loadDirectoryKKApps_Publisher = Fail(error: Self.testError)
            .eraseToAnyPublisher()

        sut.send(.loadKKList) { _ in
        }
        uiScheduler.run()
        sut.receive(.loadKKListReceived(.failure(Self.testError))) { state in
            state.error = Self.testError
        }
    }

    func testSelectingAnEntrySucceeds() {
        let sut = testStore()

        sut.send(.selectKK(Self.testEntryA)) { state in
            state.selectedKK = Self.testEntryA
        }
    }

    // TODO: while adding the next screen, test confirmKK to push it swiftlint:disable:this todo

    static let testError = IDPError.internal(error: .notImplemented)

    static let testEntryA = KKAppDirectory.Entry(name: "Test Entry A", identifier: "identifierA")
    static let testEntryB = KKAppDirectory.Entry(name: "Test Entry B", identifier: "identifierB")

    static let testDirectory = KKAppDirectory(apps: [
        testEntryA,
        testEntryB,
    ])
}
