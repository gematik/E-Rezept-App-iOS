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
@testable import eRpFeatures
import eRpKit
import Nimble
import TestUtils
import XCTest

final class DefaultUserProfileServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()

        mockProfileDataStore = MockProfileDataStore()
        mockProfileOnlineChecker = MockProfileOnlineChecker()
        mockUserSession = MockUserSession()
        mockUserSessionProvider = MockUserSessionProvider()
    }

    var mockProfileDataStore: MockProfileDataStore!
    var mockProfileOnlineChecker: MockProfileOnlineChecker!
    var mockUserSession: MockUserSession!
    var mockUserSessionProvider: MockUserSessionProvider!

    func testUserProfilesPublisher_ActivityIndicator() {
        // given
        let sut = DefaultUserProfileService(
            profileDataStore: mockProfileDataStore,
            profileOnlineChecker: mockProfileOnlineChecker,
            userSession: mockUserSession,
            userSessionProvider: mockUserSessionProvider
        )

        mockProfileOnlineChecker.tokenForClosure = { profile in
            switch profile.id {
            case UserProfile.Fixtures.olafOffline.profile.id:
                return Just(nil).eraseToAnyPublisher()
            case UserProfile.Fixtures.theo.profile.id:
                return Just(IDPToken.Fixtures.valid).eraseToAnyPublisher()
            default:
                fatalError("unknown uuid")
            }
        }

        mockProfileDataStore.listAllProfilesReturnValue = Just(
            [
                UserProfile.Fixtures.olafOffline.profile,
                UserProfile.Fixtures.theo.profile,
            ]
        )
        .setFailureType(to: LocalStoreError.self)
        .eraseToAnyPublisher()

        let theoIsActivePublisher = CurrentValueSubject<Bool, Never>(false)
        let theoMockActivityIndicatingPublishing = MockActivityIndicating()
        theoMockActivityIndicatingPublishing.isActive = theoIsActivePublisher.eraseToAnyPublisher()
        let theoMockUserSession = MockUserSession()
        theoMockUserSession.activityIndicating = theoMockActivityIndicatingPublishing

        let olafIsActivePublisher = CurrentValueSubject<Bool, Never>(false)
        let olafMockActivityIndicatingPublishing = MockActivityIndicating()
        olafMockActivityIndicatingPublishing.isActive = olafIsActivePublisher.eraseToAnyPublisher()
        let olafMockUserSession = MockUserSession()
        olafMockUserSession.activityIndicating = olafMockActivityIndicatingPublishing

        mockUserSessionProvider.userSessionForClosure = { uuid in
            switch uuid {
            case UserProfile.Fixtures.olafOffline.profile.id:
                return olafMockUserSession
            case UserProfile.Fixtures.theo.profile.id:
                return theoMockUserSession
            default:
                fatalError("unknown uuid")
            }
        }

        var userProfilesReceived = [[UserProfile]]()

        // when
        let cancelable = sut.userProfilesPublisher()
            .sink(
                receiveCompletion: { output in
                    print(output)
                },
                receiveValue: { output in
                    userProfilesReceived.append(output)
                }
            )

        // then
        // Initial state
        expect(userProfilesReceived.simplify()) ==
            [[.init("Olaf Offline", .never, false), .init("Theo Testprofil", .connected, false)]]

        userProfilesReceived = []
        theoIsActivePublisher.send(true)
        theoIsActivePublisher.send(false)
        theoIsActivePublisher.send(true)
        olafIsActivePublisher.send(true)
        expect(userProfilesReceived.simplify()) ==
            [
                [.init("Olaf Offline", .never, false), .init("Theo Testprofil", .connected, true)],
                [.init("Olaf Offline", .never, false), .init("Theo Testprofil", .connected, false)],
                [.init("Olaf Offline", .never, false), .init("Theo Testprofil", .connected, true)],
                [.init("Olaf Offline", .never, true), .init("Theo Testprofil", .connected, true)],
            ]

        // Receiving duplicate activity indication does not emit new values
        userProfilesReceived = []
        theoIsActivePublisher.send(true)
        theoIsActivePublisher.send(true)
        olafIsActivePublisher.send(true)
        expect(userProfilesReceived).to(beEmpty())

        cancelable.cancel()
    }

    func testActiveUserProfilePublisher() {
        // given
        let sut = DefaultUserProfileService(
            profileDataStore: mockProfileDataStore,
            profileOnlineChecker: mockProfileOnlineChecker,
            userSession: mockUserSession,
            userSessionProvider: mockUserSessionProvider
        )

        mockUserSession.profileReturnValue = Just(UserProfile.Fixtures.theo.profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let isAuthenticatedPublisher = CurrentValueSubject<Bool, Never>(true)
        mockUserSession.isAuthenticated = isAuthenticatedPublisher
            .setFailureType(to: UserSessionError.self)
            .eraseToAnyPublisher()

        let isActivePublisher = CurrentValueSubject<Bool, Never>(false)
        let mockActivityIndicating = MockActivityIndicating()
        mockActivityIndicating.isActive = isActivePublisher.eraseToAnyPublisher()
        mockUserSession.activityIndicating = mockActivityIndicating

        var userProfilesReceived = [UserProfile]()

        // when
        let cancelable = sut.activeUserProfilePublisher()
            .sink(
                receiveCompletion: { output in
                    print(output)
                },
                receiveValue: { output in
                    userProfilesReceived.append(output)
                }
            )

        // then
        // Initial state
        expect(userProfilesReceived.simplify()) == [.init("Theo Testprofil", .connected, false)]

        userProfilesReceived = []
        isActivePublisher.send(true)
        isAuthenticatedPublisher.send(false)
        isActivePublisher.send(false)
        expect(userProfilesReceived.simplify()) ==
            [
                .init("Theo Testprofil", .connected, true),
                .init("Theo Testprofil", .never, true),
                .init("Theo Testprofil", .never, false),
            ]

        // Receiving duplicate activity indication does not emit new values
        userProfilesReceived = []
        isActivePublisher.send(false)
        expect(userProfilesReceived).to(beEmpty())

        cancelable.cancel()
    }
}

import IDP

extension IDPToken {
    enum Fixtures {
        static let valid = IDPToken(
            accessToken: "",
            expires: Date().addingTimeInterval(10 * 60 * 60),
            idToken: "",
            ssoToken: "",
            tokenType: "",
            redirect: ""
        )
    }
}

struct UserProfileSimplify: Equatable {
    let name: String
    let connectionStatus: ProfileConnectionStatus
    let activityIndicating: Bool

    init(_ name: String, _ connectionStatus: ProfileConnectionStatus, _ activityIndicating: Bool = false) {
        self.name = name
        self.connectionStatus = connectionStatus
        self.activityIndicating = activityIndicating
    }
}

extension UserProfile {
    func simplify() -> UserProfileSimplify {
        .init(name, connectionStatus, activityIndicating)
    }
}

extension Array where Element == UserProfile {
    func simplify() -> [UserProfileSimplify] {
        map { $0.simplify() }
    }
}

extension Array where Element == [UserProfile] {
    func simplify() -> [[UserProfileSimplify]] {
        map { $0.simplify() }
    }
}
