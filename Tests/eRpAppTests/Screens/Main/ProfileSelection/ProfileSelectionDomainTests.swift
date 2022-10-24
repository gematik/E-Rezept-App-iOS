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
import Nimble
import XCTest

final class ProfileSelectionDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        ProfileSelectionDomain.State,
        ProfileSelectionDomain.State,
        ProfileSelectionDomain.Action,
        ProfileSelectionDomain.Action,
        ProfileSelectionDomain.Environment
    >

    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserDataStore: MockUserDataStore!
    var mockUserProfileService: MockUserProfileService!
    var mockRouting: MockRouting!

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockUserDataStore = MockUserDataStore()
        mockUserProfileService = MockUserProfileService()
        mockRouting = MockRouting()
    }

    private func testStore(for state: ProfileSelectionDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: ProfileSelectionDomain.reducer,
            environment: ProfileSelectionDomain.Environment(
                schedulers: schedulers,
                userDataStore: mockUserDataStore,
                userProfileService: mockUserProfileService,
                router: mockRouting
            )
        )
    }

    func testSelectProfile() {
        let store = testStore(
            for: .init(
                profiles: [
                    Fixtures.profileA,
                    Fixtures.profileB,
                    Fixtures.profileC,
                ]
            )
        )

        store.send(.selectProfile(Fixtures.profileA)) { state in
            state.selectedProfileId = Fixtures.profileA.id
        }

        store.receive(.close)
    }

    func testUpdatedProfilesUpdateTheState() {
        let store = testStore(
            for: .init(
                profiles: []
            )
        )

        let expectedProfiles = [
            Fixtures.profileA,
            Fixtures.profileB,
            Fixtures.profileC,
        ]

        mockUserProfileService.userProfilesPublisherReturnValue = Just(expectedProfiles)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        mockUserDataStore.selectedProfileId = Just(Fixtures.profileA.id).eraseToAnyPublisher()

        store.send(.registerListener)

        testScheduler.run()

        store.receive(.loadReceived(.success(expectedProfiles))) { state in
            state.profiles = expectedProfiles
        }

        store.receive(.selectedProfileReceived(Fixtures.profileA.id)) { state in
            state.selectedProfileId = Fixtures.profileA.id
        }
    }

    func testEditProfiles() {
        let store = testStore(
            for: .init(
                profiles: [
                    Fixtures.profileA,
                    Fixtures.profileB,
                    Fixtures.profileC,
                ]
            )
        )

        store.send(.editProfiles)

        expect(self.mockRouting.routeToParameter).to(equal(Endpoint.settings))

        store.receive(.close)
    }

    func testLoadingFailure() {
        let store = testStore(
            for: .init(
                profiles: []
            )
        )

        store.send(.loadReceived(.failure(.localStoreError(.notImplemented)))) { state in
            state.route = .alert(
                ProfileSelectionDomain.AlertStates.for(
                    UserProfileServiceError.localStoreError(.notImplemented)
                )
            )
        }
    }
}

extension ProfileSelectionDomainTests {
    enum Fixtures {
        static let profileA = UserProfile(
            profile: Profile(name: "Profile A"),
            connectionStatus: .connected
        )

        static let profileB = UserProfile(
            profile: Profile(name: "Profile B"),
            connectionStatus: .connected
        )

        static let profileC = UserProfile(
            profile: Profile(name: "Profile C"),
            connectionStatus: .connected
        )
    }
}
