//
//  Copyright (c) 2023 gematik GmbH
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

final class CardWallExtAuthConfirmationDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallExtAuthConfirmationDomain.State,
        CardWallExtAuthConfirmationDomain.Action,
        CardWallExtAuthConfirmationDomain.State,
        CardWallExtAuthConfirmationDomain.Action,
        Void
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

    var resourceHandlerMock: MockResourceHandler!

    override func setUp() {
        super.setUp()

        idpSessionMock = IDPSessionMock()
        resourceHandlerMock = MockResourceHandler()
    }

    func testStore(for state: CardWallExtAuthConfirmationDomain.State)
        -> TestStore {
        TestStore(
            initialState: state,
            reducer: CardWallExtAuthConfirmationDomain()
        ) { dependencies in
            dependencies.idpSession = idpSessionMock
            dependencies.schedulers = schedulers
            dependencies.resourceHandler = resourceHandlerMock
        }
    }

    func testStore()
        -> TestStore {
        testStore(for: .init(selectedKK: Self.testEntry))
    }

    func testConfirmationHappyPath() {
        let sut = testStore()

        let urlFixture = URL(string: "https://dummy.gematik.de")!

        idpSessionMock.startExtAuth_Publisher = Just(urlFixture).setFailureType(to: IDPError.self).eraseToAnyPublisher()
        resourceHandlerMock.canOpenURLReturnValue = true

        sut.send(.confirmKK) { state in
            state.loading = true
        }
        uiScheduler.run()
        sut.receive(.openURL(urlFixture))

        guard let receivedArgs = resourceHandlerMock.openOptionsCompletionHandlerReceivedArguments,
              let completion = receivedArgs.completion else {
            fail("did not receive arguments")
            return
        }
        completion(true)
        uiScheduler.run()

        sut.receive(.response(.openURL(true))) { state in
            state.loading = false
        }

        sut.receive(.delegate(.close))
    }

    func testConfirmationFailsWithIDPError() {
        let sut = testStore()

        idpSessionMock.startExtAuth_Publisher = Fail(error: Self.testError).eraseToAnyPublisher()

        sut.send(.confirmKK) { state in
            state.loading = true
        }
        uiScheduler.run()
        sut.receive(.error(CardWallExtAuthConfirmationDomain.Error.idpError(Self.testError))) { state in
            state.loading = false
            state.error = CardWallExtAuthConfirmationDomain.Error.idpError(Self.testError)
        }
    }

    func testConfirmationFailsOpenURLError() {
        let sut = testStore(for: .init(
            selectedKK: Self.testEntry,
            loading: true,
            error: nil,
            contactActionSheet: nil
        ))

        let urlFixture = URL(string: "https://dummy.gematik.de")!

        resourceHandlerMock.canOpenURLReturnValue = false

        sut.send(.openURL(urlFixture))
        uiScheduler.run()

        sut.receive(.response(.openURL(false))) { state in
            state.loading = false
            state.error = CardWallExtAuthConfirmationDomain.Error.universalLinkFailed
        }
    }

    static let testError = IDPError.internal(error: .notImplemented)

    static let testEntry = KKAppDirectory.Entry(name: "Test Entry A", identifier: "identifierA")
}
