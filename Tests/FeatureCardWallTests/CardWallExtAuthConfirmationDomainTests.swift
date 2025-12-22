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
@testable import FeatureCardWall
import FeatureHelpers
import IDP
import Nimble
import Synchronization
import TestUtils
import XCTest

@MainActor
final class CardWallExtAuthConfirmationDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CardWallExtAuthConfirmationDomain>

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

    @MainActor
    func testStore(
        for state: CardWallExtAuthConfirmationDomain.State? = nil,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    )
        -> TestStore {
        let state = state ?? .init(profileId: UUID(), selectedKK: Self.testEntry)

        return TestStore(initialState: state) {
            CardWallExtAuthConfirmationDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers

            prepareDependencies(&dependencies)
        }
    }

    @available(iOS 18.0, *)
    func testConfirmationHappyPath() async {
        let openedURL = Mutex<URL?>(nil)

        let sut = testStore { dependencies in
            dependencies.openURLHandler.canOpenURL = { _ in true }
            dependencies.openURLHandler.openWithOptions = { url, _ in
                openedURL.withLock { $0 = url }
            }
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
        }

        let urlFixture = URL(string: "https://dummy.gematik.de")!

        idpSessionMock.startExtAuth_Publisher = Just(urlFixture).setFailureType(to: IDPError.self).eraseToAnyPublisher()

        await sut.send(.confirmKK) { state in
            state.loading = true
        }
        await uiScheduler.run()
        await sut.receive(.openURL(urlFixture))

        await sut.receive(.response(.openURL(true))) { state in
            state.loading = false
        }
        expect(openedURL.withLock { $0 }).to(equal(urlFixture))

        await sut.receive(.delegate(.close))
    }

    func testConfirmationFailsWithIDPError() async {
        let sut = testStore { dependencies in
            dependencies.profileBasedSessionProvider.idpSession = { _ in self.idpSessionMock }
        }

        idpSessionMock.startExtAuth_Publisher = Fail(error: Self.testError).eraseToAnyPublisher()

        await sut.send(.confirmKK) { state in
            state.loading = true
        }
        await uiScheduler.run()
        await sut.receive(.error(CardWallExtAuthConfirmationDomain.Error.idpError(Self.testError))) { state in
            state.loading = false
            state.error = CardWallExtAuthConfirmationDomain.Error.idpError(Self.testError)
        }
    }

    func testConfirmationFailsOpenURLError() async {
        let sut = testStore(for: .init(
            profileId: UUID(),
            selectedKK: Self.testEntry,
            loading: true,
            error: nil,
            contactActionSheet: nil
        )) { dependencies in
            dependencies.openURLHandler.canOpenURL = { _ in false }
        }

        let urlFixture = URL(string: "https://dummy.gematik.de")!

        await sut.send(.openURL(urlFixture))
        await uiScheduler.run()

        await sut.receive(.response(.openURL(false))) { state in
            state.loading = false
            state.error = CardWallExtAuthConfirmationDomain.Error.universalLinkFailed
        }
    }

    static let testError = IDPError.internal(error: .notImplemented)

    static let testEntry = KKAppDirectory.Entry(name: "Test Entry A", identifier: "identifierA")
}
