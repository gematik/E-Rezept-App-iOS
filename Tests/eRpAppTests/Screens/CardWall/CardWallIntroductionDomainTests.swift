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

import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class CardWallIntroductionDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallIntroductionDomain.State,
        CardWallIntroductionDomain.Action,
        CardWallIntroductionDomain.State,
        CardWallIntroductionDomain.Action,
        Void
    >

    func testStore() -> TestStore {
        testStore(for: CardWallIntroductionDomain.Dummies.state)
    }

    func testStore(for state: CardWallIntroductionDomain.State) -> TestStore {
        TestStore(initialState: state,
                  reducer: CardWallIntroductionDomain(),
                  prepareDependencies: { dependencies in
                      dependencies.userSession = MockUserSession()
                      dependencies.userSessionProvider = MockUserSessionProvider()
                      dependencies.schedulers = schedulers
                  })
    }

    let uiScheduler = DispatchQueue.test

    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: uiScheduler.eraseToAnyScheduler(),
            networkScheduler: DispatchQueue.test.eraseToAnyScheduler(),
            ioScheduler: DispatchQueue.test.eraseToAnyScheduler(),
            computeScheduler: DispatchQueue.test.eraseToAnyScheduler()
        )
    }()

    func testFastTrackCloseActionShouldBeForwarded() {
        let store = testStore(for: .init(isNFCReady: true, profileId: UUID(), destination: .fasttrack(.init())))

        // when
        store.send(.destination(.fasttrack(action: .delegate(.close)))) { state in
            state.destination = nil
        }
        uiScheduler.run()
        // then
        store.receive(.delegate(.close))
    }

    func testCANCloseActionShouldBeForwarded() {
        let store = testStore(for: .init(
            isNFCReady: true,
            profileId: UUID(),
            destination: .can(
                .init(isDemoModus: false, profileId: UUID(), can: "")
            )
        ))

        // when
        store.send(.destination(.canAction(action: .delegate(.close)))) { state in
            state.destination = nil
        }
        uiScheduler.run()
        // then
        store.receive(.delegate(.close))
    }
}
