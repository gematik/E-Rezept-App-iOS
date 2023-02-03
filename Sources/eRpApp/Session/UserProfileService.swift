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
import eRpKit
import Foundation
import IDP

protocol UserProfileService {
    var selectedProfileId: AnyPublisher<UUID?, Never> { get }

    func set(selectedProfileId: UUID)

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError>

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError>

    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError>
}

class DummyUserProfileService: UserProfileService {
    var selectedProfileId: AnyPublisher<UUID?, Never> {
        Just(Self.dummyProfile.id).eraseToAnyPublisher()
    }

    func set(selectedProfileId _: UUID) {
        // do nothing
    }

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        Just([]).setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()
    }

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        Just(UserProfile(from: Self.dummyProfile, isAuthenticated: true))
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()
    }

    func save(profiles _: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError> {
        Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()
    }

    static let dummyProfile = Profile(name: "Dummy Profile")
}

// sourcery: CodedError = "022"
enum UserProfileServiceError: Error, Equatable {
    // sourcery: errorCode = "01"
    case localStoreError(LocalStoreError)
}

extension UserProfileServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .localStoreError(error):
            return error.errorDescription
        }
    }

    var failureReason: String? {
        switch self {
        case let .localStoreError(error):
            return error.failureReason
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .localStoreError(error):
            return error.recoverySuggestion
        }
    }

    var helpAnchor: String? {
        switch self {
        case let .localStoreError(error):
            return error.helpAnchor
        }
    }
}

struct DefaultUserProfileService: UserProfileService {
    private let profileDataStore: ProfileDataStore
    private let profileOnlineChecker: ProfileOnlineChecker

    private let userSession: UserSession
    private let userSessionProvider: UserSessionProvider

    internal init(profileDataStore: ProfileDataStore,
                  profileOnlineChecker: ProfileOnlineChecker,
                  userSession: UserSession,
                  userSessionProvider: UserSessionProvider) {
        self.profileDataStore = profileDataStore
        self.profileOnlineChecker = profileOnlineChecker
        self.userSession = userSession
        self.userSessionProvider = userSessionProvider
    }

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        userSession.localUserStore.selectedProfileId
    }

    func set(selectedProfileId: UUID) {
        userSession.localUserStore.set(selectedProfileId: selectedProfileId)
    }

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        profileDataStore.listAllProfiles() // == AnyPublisher<[Profile], Never>
            .mapError(UserProfileServiceError.localStoreError)
            .map { (profiles: [Profile]) -> [AnyPublisher<UserProfile, Never>] in
                profiles
                    .map { (profile: Profile) -> AnyPublisher<UserProfile, Never> in
                        Just(profile)
                            .combineLatest(
                                profileOnlineChecker.token(for: profile),
                                userSessionProvider.userSession(for: profile.id).activityIndicating.isActive
                            )
                            .map(UserProfile.init)
                            .removeDuplicates()
                            .eraseToAnyPublisher()
                    }
            } // == AnyPublisher<[AnyPublisher<UserProfile, Never>], UserProfileServiceError>
            .map { (userProfilePubs: [AnyPublisher<UserProfile, Never>]) -> AnyPublisher<[UserProfile], Never> in
                userProfilePubs.combineLatest()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
        // == AnyPublisher<[UserProfile], Never>
    }

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        userSession.profile()
            .mapError(UserProfileServiceError.localStoreError)
            .combineLatest(
                userSession.isAuthenticated
                    .catch { _ in
                        Just(false)
                    }
                    .setFailureType(to: UserProfileServiceError.self)
                    .eraseToAnyPublisher(),
                userSession.activityIndicating.isActive
                    .setFailureType(to: UserProfileServiceError.self)
                    .eraseToAnyPublisher()
            )
            .map(UserProfile.init)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError> {
        profileDataStore.save(profiles: profiles)
            .mapError { .localStoreError($0) }
            .eraseToAnyPublisher()
    }
}

protocol ProfileOnlineChecker {
    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never>
}

struct DefaultProfileOnlineChecker: ProfileOnlineChecker {
    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never> {
        KeychainStorage(profileId: profile.id).token
    }
}
