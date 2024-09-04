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

import Combine
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import TestUtils
import XCTest

@MainActor
final class CardWallIntroductionDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CardWallIntroductionDomain>

    var idpSessionMock: IDPSessionMock!
    var mockProfileDataStore: MockProfileDataStore!
    var resourceHandlerMock: MockResourceHandler!
    let uiScheduler = DispatchQueue.test

    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: uiScheduler.eraseToAnyScheduler(),
            networkScheduler: DispatchQueue.test.eraseToAnyScheduler(),
            ioScheduler: DispatchQueue.test.eraseToAnyScheduler(),
            computeScheduler: DispatchQueue.test.eraseToAnyScheduler()
        )
    }()

    override func setUp() {
        super.setUp()

        idpSessionMock = IDPSessionMock()
        mockProfileDataStore = MockProfileDataStore()
        resourceHandlerMock = MockResourceHandler()
    }

    func testStore() -> TestStore {
        testStore(for: CardWallIntroductionDomain.Dummies.state)
    }

    func testStore(for state: CardWallIntroductionDomain.State) -> TestStore {
        TestStore(initialState: state) {
            CardWallIntroductionDomain()
        } withDependencies: { dependencies in
            dependencies.userSession = MockUserSession()
            dependencies.userSessionProvider = MockUserSessionProvider()
            dependencies.schedulers = schedulers
            dependencies.idpSession = idpSessionMock
            dependencies.resourceHandler = resourceHandlerMock
            dependencies.profileDataStore = mockProfileDataStore
        }
    }

    func testExtAuthCloseActionShouldBeForwarded() async {
        let store =
            testStore(for: .init(isNFCReady: true, profileId: UUID(), destination: .extAuth(.init())))

        // when
        await store.send(.destination(.presented(.extAuth(.delegate(.close))))) { state in
            state.destination = nil
        }
        await uiScheduler.run()
        // then
        await store.receive(.delegate(.close))
    }

    func testCANCloseActionShouldBeForwarded() async {
        let store = testStore(for: .init(
            isNFCReady: true,
            profileId: UUID(),
            destination: .can(
                .init(isDemoModus: false, profileId: UUID(), can: "")
            )
        ))

        // when
        await store.send(.destination(.presented(.can(.delegate(.close))))) { state in
            state.destination = nil
        }
        await uiScheduler.run()
        // then
        await store.receive(.delegate(.close))
    }

    func testGIDRemember() async {
        let sut = testStore()
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)
        mockProfileDataStore.fetchProfileByReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        idpSessionMock.loadDirectoryKKApps_Publisher = Just(TestData.testDirectory)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        idpSessionMock.startExtAuth_Publisher = Just(TestData.urlFixture).setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        resourceHandlerMock.canOpenURLReturnValue = true

        await sut.send(.task)
        await uiScheduler.run()
        await sut.receive(.response(.profileReceived(.success(profile)))) { state in
            state.entry = profile.gIdEntry
        }
        await sut.send(.directExtAuthTapped) { state in
            state.loading = true
        }
        await uiScheduler.run()
        await sut.receive(.response(.checkKK(.success(TestData.testDirectory), TestData.testEntryG)))
        await uiScheduler.run()
        await sut.receive(.openURL(TestData.urlFixture))

        guard let receivedArgs = resourceHandlerMock.openOptionsCompletionHandlerReceivedArguments,
              let completion = receivedArgs.completion else {
            fail("did not receive arguments")
            return
        }
        completion(true)
        await uiScheduler.run()

        await sut.receive(.response(.openURL(true))) { state in
            state.loading = false
        }

        await sut.receive(.delegate(.close))
    }

    func testGIDRememberKKLNotFound() async {
        let sut = testStore()
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)
        mockProfileDataStore.fetchProfileByReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        idpSessionMock.loadDirectoryKKApps_Publisher = Just(TestData.testDirectoryMissing)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        await sut.send(.task)
        await uiScheduler.run()
        await sut.receive(.response(.profileReceived(.success(profile)))) { state in
            state.entry = profile.gIdEntry
        }
        await sut.send(.directExtAuthTapped) { state in
            state.loading = true
        }
        await uiScheduler.run()
        await sut.receive(.response(.checkKK(.success(TestData.testDirectoryMissing), TestData.testEntryG))) { state in
            state.loading = false
            state.destination = .alert(CardWallIntroductionDomain.AlertStates.kkNotFound)
        }
    }

    func testGIDRememberKKLoadingFailsWithIDPError() async {
        func testLoadingTriggerFails() async {
            let sut = testStore()
            let profile = Profile(name: "Test",
                                  identifier: UUID(),
                                  erxTasks: [],
                                  gIdEntry: TestData.testEntryG)
            mockProfileDataStore.fetchProfileByReturnValue = Just(profile)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
            let testError = IDPError.internal(error: .notImplemented)
            idpSessionMock.loadDirectoryKKApps_Publisher = Fail(error: testError)
                .eraseToAnyPublisher()

            await sut.send(.task)
            await uiScheduler.run()
            await sut.receive(.response(.profileReceived(.success(profile)))) { state in
                state.entry = profile.gIdEntry
            }
            await sut.send(.directExtAuthTapped) { state in
                state.loading = true
            }
            await uiScheduler.run()
            await sut.receive(.response(.checkKK(.failure(testError), TestData.testEntryG))) { state in
                state.loading = false
                state.destination = .alert(CardWallIntroductionDomain.AlertStates.alert(for: .idpError(testError)))
            }
        }
    }

    func testGIDRememberFailsWithIDPError() async {
        let sut = testStore()
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)
        mockProfileDataStore.fetchProfileByReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        idpSessionMock.loadDirectoryKKApps_Publisher = Just(TestData.testDirectory)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        let testError = IDPError.internal(error: .notImplemented)
        idpSessionMock.startExtAuth_Publisher = Fail(error: testError).eraseToAnyPublisher()

        await sut.send(.task)
        await uiScheduler.run()
        await sut.receive(.response(.profileReceived(.success(profile)))) { state in
            state.entry = profile.gIdEntry
        }
        await sut.send(.directExtAuthTapped) { state in
            state.loading = true
        }
        await uiScheduler.run()
        await sut.receive(.response(.checkKK(.success(TestData.testDirectory), TestData.testEntryG)))
        await uiScheduler.run()
        await sut.receive(.error(CardWallIntroductionDomain.Error.idpError(testError))) { state in
            state.loading = false
            state.destination = .alert(CardWallIntroductionDomain.AlertStates.alert(for: .idpError(testError)))
        }
    }

    func testGIDRememberFailsOpenURLError() async {
        let sut = testStore()
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)
        mockProfileDataStore.fetchProfileByReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        idpSessionMock.loadDirectoryKKApps_Publisher = Just(TestData.testDirectory)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        idpSessionMock.startExtAuth_Publisher = Just(TestData.urlFixture).setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        resourceHandlerMock.canOpenURLReturnValue = false

        await sut.send(.task)
        await uiScheduler.run()
        await sut.receive(.response(.profileReceived(.success(profile)))) { state in
            state.entry = profile.gIdEntry
        }
        await sut.send(.directExtAuthTapped) { state in
            state.loading = true
        }
        await uiScheduler.run()
        await sut.receive(.response(.checkKK(.success(TestData.testDirectory), TestData.testEntryG)))
        await uiScheduler.run()
        await sut.receive(.openURL(TestData.urlFixture))
        await uiScheduler.run()
        await sut.receive(.response(.openURL(false))) { state in
            state.loading = false
            state.destination = .alert(CardWallIntroductionDomain.AlertStates.alert(for: .universalLinkFailed))
        }
    }
}

extension CardWallIntroductionDomainTests {
    enum TestData {
        static let urlFixture = URL(string: "https://dummy.gematik.de")!

        static let testError = IDPError.internal(error: .notImplemented)

        static let testEntryA = KKAppDirectory.Entry(name: "Test Entry A", identifier: "identifierA")
        static let testEntryB = KKAppDirectory.Entry(name: "Test Entry B", identifier: "identifierB")
        static let testEntryG = KKAppDirectory.Entry(name: "Generic BKK", identifier: "identifierG")

        static let testDirectory = KKAppDirectory(apps: [
            testEntryA,
            testEntryB,
            testEntryG,
        ])

        static let testDirectoryMissing = KKAppDirectory(apps: [
            testEntryA,
            testEntryB,
        ])
    }
}
