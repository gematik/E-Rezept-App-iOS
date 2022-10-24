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

final class ProfilesDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        ProfilesDomain.State,
        ProfilesDomain.State,
        ProfilesDomain.Action,
        ProfilesDomain.Action,
        ProfilesDomain.Environment
    >

    func testStore(for state: ProfilesDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: ProfilesDomain.reducer,
            environment: ProfilesDomain.Environment(
                appSecurityManager: mockAppSecurityManager,
                schedulers: Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler()),
                profileDataStore: mockProfileDataStore,
                userDataStore: mockUserDataStore,
                userProfileService: mockUserProfileService,
                profileSecureDataWiper: MockProfileSecureDataWiper(),
                router: MockRouting(),
                secureEnclaveSignatureProvider: DummySecureEnclaveSignatureProvider(),
                userSessionProvider: MockUserSessionProvider(),
                nfcSignatureProvider: NFCSignatureProviderMock(),
                userSession: MockUserSession(),
                signatureProvider: DummySecureEnclaveSignatureProvider(),
                accessibilityAnnouncementReceiver: { _ in }
            )
        )
    }

    let mainQueue = DispatchQueue.test

    var mockAppSecurityManager: MockAppSecurityManager!
    var mockProfileDataStore: MockProfileDataStore!
    var mockUserDataStore: MockUserDataStore!
    var mockUserProfileService: MockUserProfileService!

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockProfileDataStore = MockProfileDataStore()
        mockUserDataStore = MockUserDataStore()
        mockUserProfileService = MockUserProfileService()
    }

    func testLoadProfiles() {
        let expectedProfiles = [
            Fixtures.profileA,
            Fixtures.profileB,
        ]

        let profilesPublisher = CurrentValueSubject<[UserProfile], UserProfileServiceError>(expectedProfiles)

        mockUserProfileService.userProfilesPublisherReturnValue = profilesPublisher.eraseToAnyPublisher()
        mockUserDataStore.selectedProfileId = Just(Fixtures.profileA.id).eraseToAnyPublisher()

        let sut = testStore(for: .init(profiles: [],
                                       selectedProfileId: nil,
                                       route: nil))

        sut.send(.registerListener)

        mainQueue.advance()

        sut.receive(.loadReceived(.success(expectedProfiles))) { state in
            state.profiles = expectedProfiles
        }

        sut.receive(.selectedProfileReceived(Fixtures.profileA.id)) { state in
            state.selectedProfileId = Fixtures.profileA.id
        }

        mainQueue.run()

        sut.send(.unregisterListener)
    }

    func testEditProfile() {
        let sut = testStore(for: .init(profiles: [Fixtures.profileA, Fixtures.profileB],
                                       selectedProfileId: nil,
                                       route: nil))

        sut.send(.editProfile(Fixtures.profileA)) { state in
            state.route = .editProfile(.init(profile: Fixtures.profileA))
        }
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
            emoji: nil,
            lastAuthenticated: nil,
            erxTasks: []
        )
        static let erxProfileB = Profile(
            name: "Profile B",
            identifier: uuidB,
            created: createdB,
            insuranceId: nil,
            color: .grey,
            emoji: nil,
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
