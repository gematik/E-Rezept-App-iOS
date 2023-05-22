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

@MainActor
final class ProfilesDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        ProfilesDomain.State,
        ProfilesDomain.Action,
        ProfilesDomain.State,
        ProfilesDomain.Action,
        Void
    >

    func testStore(for state: ProfilesDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: ProfilesDomain()
        ) { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.router = DummyRouter()
        }
    }

    let mainQueue = DispatchQueue.test

    var mockAppSecurityManager: MockAppSecurityManager!
    var mockUserProfileService: MockUserProfileService!

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockUserProfileService = MockUserProfileService()
    }

    func testLoadProfiles() {
        let expectedProfiles = [
            Fixtures.profileA,
            Fixtures.profileB,
        ]

        let profilesPublisher = CurrentValueSubject<[UserProfile], UserProfileServiceError>(expectedProfiles)

        mockUserProfileService.userProfilesPublisherReturnValue = profilesPublisher.eraseToAnyPublisher()
        mockUserProfileService.selectedProfileId = Just(Fixtures.profileA.id).eraseToAnyPublisher()

        let sut = testStore(for: .init(profiles: [],
                                       selectedProfileId: nil))

        sut.send(.registerListener)

        mainQueue.advance()

        sut.receive(.response(.loadReceived(.success(expectedProfiles)))) { state in
            state.profiles = expectedProfiles
        }

        sut.receive(.response(.selectedProfileReceived(Fixtures.profileA.id))) { state in
            state.selectedProfileId = Fixtures.profileA.id
        }

        mainQueue.run()

        sut.send(.unregisterListener)
    }

    func testEditProfile() async {
        let sut = testStore(for: .init(profiles: [Fixtures.profileA, Fixtures.profileB],
                                       selectedProfileId: nil))

        await sut.send(.editProfile(Fixtures.profileA))

        await sut.receive(.delegate(.showEditProfile(.init(profile: Fixtures.profileA))))
    }
}

extension ProfilesDomainTests {
    enum Fixtures {
        static let uuidA = UUID()
        static let uuidB = UUID()
        static let createdA = Date()
        static let createdB = Date()
        static let erxProfileA = Profile(
            name: "Profile A",
            identifier: uuidA,
            created: createdA,
            insuranceId: nil,
            color: .blue,
            lastAuthenticated: nil,
            erxTasks: []
        )
        static let erxProfileB = Profile(
            name: "Profile B",
            identifier: uuidB,
            created: createdB,
            insuranceId: nil,
            color: .grey,
            lastAuthenticated: nil,
            erxTasks: []
        )
        static let profileA = UserProfile(
            from: erxProfileA,
            isAuthenticated: false
        )
        static let profileB = UserProfile(
            from: erxProfileB,
            isAuthenticated: false
        )
    }
}
