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
@testable import eRpFeatures
import eRpKit
import XCTest

@MainActor
final class ProfilesDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<ProfilesDomain>

    func testStore(for state: ProfilesDomain.State) -> TestStore {
        TestStore(
            initialState: state
        ) {
            ProfilesDomain()
        } withDependencies: { dependencies in
            dependencies.userProfileService = mockUserProfileService
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.router = DummyRouter()
        }
    }

    let testScheduler = DispatchQueue.test

    var mockAppSecurityManager: MockAppSecurityManager!
    var mockUserProfileService: MockUserProfileService!

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockUserProfileService = MockUserProfileService()
    }

    func testLoadProfiles() async {
        let expectedProfiles = [
            Fixtures.profileA,
            Fixtures.profileB,
        ]

        let profilesPublisher = Just<[UserProfile]>(expectedProfiles)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        mockUserProfileService.userProfilesPublisherReturnValue = profilesPublisher.eraseToAnyPublisher()
        mockUserProfileService.selectedProfileId = Just(Fixtures.profileA.id).eraseToAnyPublisher()

        let sut = testStore(for: .init(profiles: [],
                                       selectedProfileId: nil))

        await sut.send(.registerListener)
        await testScheduler.advance()

        await sut.receive(.response(.loadReceived(.success(expectedProfiles)))) { state in
            state.profiles = expectedProfiles
        }

        await sut.receive(.response(.selectedProfileReceived(Fixtures.profileA.id))) { state in
            state.selectedProfileId = Fixtures.profileA.id
        }

        await testScheduler.run()
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
