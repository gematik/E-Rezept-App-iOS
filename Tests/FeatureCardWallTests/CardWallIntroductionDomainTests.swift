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
import Profiles
import Synchronization
import TestUtils
import XCTest

@MainActor
final class CardWallIntroductionDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CardWallIntroductionDomain>

    var idpSessionMock: IDPSessionMock!
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
    }

    func testStore(
        for state: CardWallIntroductionDomain.State = CardWallIntroductionDomain.Dummies.state,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        TestStore(initialState: state) {
            CardWallIntroductionDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers

            prepareDependencies(&dependencies)
        }
    }

    func testExtAuthCloseActionShouldBeForwarded() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])

        let store = testStore(
            for: .init(isNFCReady: true, profileId: UUID(), destination: .extAuth(.init(profileId: UUID())))
        ) { dependencies in
            dependencies.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
        }

        // when
        await store.send(.destination(.presented(.extAuth(.delegate(.close)))))
        await uiScheduler.run()
        // then
        expect(isDismissInvoked.value).to(equal([true]))
    }

    func testCANCloseActionShouldBeForwarded() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])

        let store = testStore(for: .init(
            isNFCReady: true,
            profileId: UUID(),
            destination: .can(
                .init(profileId: UUID(), can: "")
            )
        )) { dependencies in
            dependencies.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
        }

        // when
        await store.send(.destination(.presented(.can(.delegate(.close)))))
        await uiScheduler.run()
        // then
        expect(isDismissInvoked.value).to(equal([true]))
    }

    @available(iOS 18.0, *)
    func testGIDRemember() async {
        let openedURL = Mutex<URL?>(nil)
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)

        let sut = testStore { dependencies in
            dependencies.openURLHandler.canOpenURL = { _ in true }
            dependencies.openURLHandler.open = { url in
                openedURL.withLock { $0 = url }
            }
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
            dependencies.profilesStore.fetchProfile = { _ in
                Just(profile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        }

        idpSessionMock.loadDirectoryKKApps_Publisher = Just(TestData.testDirectory)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()

        idpSessionMock.startExtAuth_Publisher = Just(TestData.urlFixture).setFailureType(to: IDPError.self)
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
        await sut.receive(.response(.checkKK(.success(TestData.testDirectory), TestData.testEntryG)))
        await uiScheduler.run()
        await sut.receive(.openURL(TestData.urlFixture))
        expect(openedURL.withLock { $0 }).to(equal(TestData.urlFixture))

        await uiScheduler.run()

        await sut.receive(.response(.openURL(true))) { state in
            state.loading = false
        }

        await sut.receive(.delegate(.close))
    }

    func testGIDRememberKKLNotFound() async {
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)

        let sut = testStore { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
            dependencies.profilesStore.fetchProfile = { _ in
                Just(profile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        }

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
            let profile = Profile(name: "Test",
                                  identifier: UUID(),
                                  erxTasks: [],
                                  gIdEntry: TestData.testEntryG)

            let sut = testStore { dependencies in
                dependencies.profilesStore.fetchProfile = { _ in
                    Just(profile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
                }
            }
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
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)

        let sut = testStore { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
            dependencies.profilesStore.fetchProfile = { _ in
                Just(profile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        }
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
        let profile = Profile(name: "Test",
                              identifier: UUID(),
                              erxTasks: [],
                              gIdEntry: TestData.testEntryG)

        let sut = testStore { dependencies in
            dependencies.openURLHandler.canOpenURL = { _ in false }
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
            dependencies.profilesStore.fetchProfile = { _ in
                Just(profile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        }
        idpSessionMock.loadDirectoryKKApps_Publisher = Just(TestData.testDirectory)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
        idpSessionMock.startExtAuth_Publisher = Just(TestData.urlFixture).setFailureType(to: IDPError.self)
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
