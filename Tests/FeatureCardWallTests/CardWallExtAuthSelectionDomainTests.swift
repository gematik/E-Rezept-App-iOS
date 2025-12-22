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

import Combine
import ComposableArchitecture
import eRpKit
@testable import FeatureCardWall
import FeatureHelpers
import IDP
import Nimble
import TestUtils
import XCTest

@MainActor
final class CardWallExtAuthSelectionDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CardWallExtAuthSelectionDomain>

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

    func testStore(
        for state: CardWallExtAuthSelectionDomain.State = .init(profileId: UUID()),
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    )
        -> TestStore {
        TestStore(initialState: state) {
            CardWallExtAuthSelectionDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers

            prepareDependencies(&dependencies)
        }
    }

    func testLoadingTriggerSucceeds() async {
        let sut = testStore { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
        }

        idpSessionMock.loadDirectoryKKApps_Publisher = Just(Self.testDirectory)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        await sut.send(.loadKKList)
        await uiScheduler.run()
        await sut.receive(.response(.loadKKList(.success(Self.testDirectory)))) { state in
            state.kkList = Self.testDirectory
        }
    }

    func testLoadingTriggerFails() async {
        let sut = testStore { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
        }

        idpSessionMock.loadDirectoryKKApps_Publisher = Fail(error: Self.testError)
            .eraseToAnyPublisher()

        await sut.send(.loadKKList)
        await uiScheduler.run()
        await sut.receive(.response(.loadKKList(.failure(Self.testError)))) { state in
            state.error = Self.testError
        }
    }

    func testSelectingAnEntrySucceeds() async {
        let sut = testStore { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
        }

        await sut.send(.selectKK(Self.testEntryA)) { state in
            state.destination = .confirmation(.init(profileId: state.profileId, selectedKK: Self.testEntryA))
        }
    }

    func testSearchListNoResult() async {
        let sut = testStore(for: .init(profileId: UUID(), kkList: Self.testDirectory))

        await sut.send(.filteredKKList(search: "NonExistentKK"))
    }

    func testSearchListResult() async {
        let sut = testStore(for: .init(profileId: UUID(), kkList: Self.testDirectory))

        await sut.send(.filteredKKList(search: "Test Entry A")) { state in
            state.filteredKKList = KKAppDirectory(apps: [Self.testEntryA])
        }
    }

    // TODO: while adding the next screen, test confirmKK to push it swiftlint:disable:this todo

    static let testError = IDPError.internal(error: .notImplemented)

    static let testEntryA = KKAppDirectory.Entry(name: "Test Entry A", identifier: "identifierA")
    static let testEntryB = KKAppDirectory.Entry(name: "Test Entry B", identifier: "identifierB")
    static let testEntryG = KKAppDirectory.Entry(name: "Generic BKK", identifier: "identifierG")

    static let testDirectory = KKAppDirectory(apps: [
        testEntryA,
        testEntryB,
        testEntryG,
    ])
}
