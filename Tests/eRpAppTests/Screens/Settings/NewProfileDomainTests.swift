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
import XCTest

@MainActor
final class NewProfileDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<NewProfileDomain>

    func testStore(for state: NewProfileDomain.State) -> TestStore {
        TestStore(initialState: state) {
            NewProfileDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userDataStore = MockUserDataStore()
            dependencies.profileDataStore = mockProfileDataStore
            dependencies.changeableUserSessionContainer = mockUsersSessionContainer
        }
    }

    let mainQueue = DispatchQueue.test

    var mockProfileDataStore: MockProfileDataStore!
    var mockUsersSessionContainer: MockUsersSessionContainer!
    var mockUserSession: MockUserSession!
    var mockUserDataStore: MockUserDataStore!

    override func setUp() {
        super.setUp()

        mockProfileDataStore = MockProfileDataStore()
        mockUserDataStore = MockUserDataStore()
        mockUsersSessionContainer = MockUsersSessionContainer()
        mockUserSession = MockUserSession()
    }

    func testSavingAnEmptyNameDisplaysError() async {
        let sut = testStore(for: .init(name: "", color: .red))

        await sut.send(.save) { state in
            state.destination = .alert(.info(NewProfileDomain.AlertStates.emptyName))
        }
    }

    func testSavingSucceeds() async {
        mockUsersSessionContainer.userSession = mockUserSession
        mockUserSession.mockUserDataStore = mockUserDataStore

        let sut = testStore(for: .init(name: "Bob", color: .red))

        mockProfileDataStore.saveProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(.save)

        await mainQueue.run()
        let newProfile = mockProfileDataStore.saveProfilesReceivedProfiles!.first!
        await sut.receive(.response(.saveReceived(.success(newProfile.id))))

        await sut.receive(.delegate(.close))
    }

    func testSetName() async {
        let sut = testStore(for: .init(name: "", color: .red))

        await sut.send(\.binding.name, "Test") { state in
            state.name = "Test"
        }
    }
}
