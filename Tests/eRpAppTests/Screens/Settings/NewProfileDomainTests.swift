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
import eRpKit
import XCTest

final class NewProfileDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        NewProfileDomain.State,
        NewProfileDomain.State,
        NewProfileDomain.Action,
        NewProfileDomain.Action,
        NewProfileDomain.Environment
    >

    func testStore(for state: NewProfileDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: NewProfileDomain.reducer,
            environment: NewProfileDomain.Environment(
                schedulers: Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler()),
                userDataStore: MockUserDataStore(),
                profileDataStore: mockProfileDataStore
            )
        )
    }

    let mainQueue = DispatchQueue.test

    var mockProfileDataStore: MockProfileDataStore!

    override func setUp() {
        super.setUp()

        mockProfileDataStore = MockProfileDataStore()
    }

    func testSavingAnEmptyNameDisplaysError() {
        let sut = testStore(for: .init(name: "", acronym: "", emoji: nil, color: .red, alertState: nil))

        sut.send(.save) { state in
            state.alertState = NewProfileDomain.AlertStates.emptyName
        }
    }

    func testSavingSucceeds() {
        let sut = testStore(for: .init(name: "Bob", acronym: "B", emoji: nil, color: .red, alertState: nil))

        mockProfileDataStore.saveProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.save)

        mainQueue.run()
        let newProfile = mockProfileDataStore.saveProfilesReceivedProfiles!.first!
        sut.receive(.saveReceived(.success(newProfile.id)))

        sut.receive(.close)
    }

    func testSetName() {
        let sut = testStore(for: .init(name: "", acronym: "", emoji: nil, color: .red, alertState: nil))

        sut.send(.setName("Test")) { state in
            state.name = "Test"
            state.acronym = "T"
        }
    }

    func testSetEmoji() {
        let sut = testStore(for: .init(name: "", acronym: "", emoji: nil, color: .red, alertState: nil))

        sut.send(.setEmoji("🎃")) { state in
            state.emoji = "🎃"
        }
    }

    func testSetColor() {
        let sut = testStore(for: .init(name: "", acronym: "", emoji: nil, color: .red, alertState: nil))

        sut.send(.setColor(.green)) { state in
            state.color = .green
        }
    }
}
