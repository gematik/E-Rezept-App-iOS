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
import eRpKit
import XCTest

final class NewProfileDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        NewProfileDomain.State,
        NewProfileDomain.Action,
        NewProfileDomain.State,
        NewProfileDomain.Action,
        Void
    >

    func testStore(for state: NewProfileDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: NewProfileDomain()
        ) { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userDataStore = MockUserDataStore()
            dependencies.profileDataStore = mockProfileDataStore
        }
    }

    let mainQueue = DispatchQueue.test

    var mockProfileDataStore: MockProfileDataStore!

    override func setUp() {
        super.setUp()

        mockProfileDataStore = MockProfileDataStore()
    }

    func testSavingAnEmptyNameDisplaysError() {
        let sut = testStore(for: .init(name: "", acronym: "", color: .red, alertState: nil))

        sut.send(.save) { state in
            state.alertState = NewProfileDomain.AlertStates.emptyName
        }
    }

    func testSavingSucceeds() {
        let sut = testStore(for: .init(name: "Bob", acronym: "B", color: .red, alertState: nil))

        mockProfileDataStore.saveProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.save)

        mainQueue.run()
        let newProfile = mockProfileDataStore.saveProfilesReceivedProfiles!.first!
        sut.receive(.response(.saveReceived(.success(newProfile.id))))

        sut.receive(.delegate(.close))
    }

    func testSetName() {
        let sut = testStore(for: .init(name: "", acronym: "", color: .red, alertState: nil))

        sut.send(.setName("Test")) { state in
            state.name = "Test"
            state.acronym = "T"
        }
    }

    func testSetColor() {
        let sut = testStore(for: .init(name: "", acronym: "", color: .red, alertState: nil))

        sut.send(.setColor(.green)) { state in
            state.color = .green
        }
    }
}
