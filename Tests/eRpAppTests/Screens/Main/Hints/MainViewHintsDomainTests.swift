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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class MainViewHintsDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    func testMainViewHintsDomainReducer() {
        let fakeHintProvider = FakeMainViewHintsProvider()
        let fakeHintEventsStore = FakeHintEventsStore()
        let mockRouter = MockRouting()
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let store = TestStore<
            MainViewHintsDomain.State,
            MainViewHintsDomain.Action,
            MainViewHintsDomain.State,
            MainViewHintsDomain.Action,
            MainViewHintsDomain.Environment
        >(
            initialState: MainViewHintsDomain.State(),
            reducer: MainViewHintsDomain.reducer,
            environment: MainViewHintsDomain.Environment(
                router: mockRouter,
                userSession: MockUserSession(),
                schedulers: schedulers,
                hintEventsStore: fakeHintEventsStore,
                hintProvider: fakeHintProvider
            )
        )

        let expectedHint = fakeHintProvider.currentHintReturn

        store.send(.subscribeToHintChanges)
        testScheduler.advance()
        store.receive(.hintChangeReceived(expectedHint)) { state in
            state.hint = expectedHint
        }
        store.send(.routeTo(.settings))
        store.send(.hideHint)
        testScheduler.advance()
        store.receive(.hintChangeReceived(nil)) { state in
            state.hint = nil
        }
        store.send(.removeSubscription)
    }
}
