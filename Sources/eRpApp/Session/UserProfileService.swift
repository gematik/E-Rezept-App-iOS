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
import Dependencies
import eRpKit
import Foundation
import IDP

protocol UserProfileService {
    var selectedProfileId: AnyPublisher<UUID?, Never> { get }

    func set(selectedProfileId: UUID)

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError>

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError>

    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError>

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void)
        -> AnyPublisher<Bool, UserProfileServiceError>
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

    func update(profileId _: UUID,
                mutating _: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, UserProfileServiceError> {
        Just(true)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()
    }

    static let dummyProfile = Profile(name: "Dummy Profile")
}

// sourcery: CodedError = "022"
@CasePathable
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
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func save(profiles: [Profile]) -> AnyPublisher<Bool, UserProfileServiceError> {
        profileDataStore.save(profiles: profiles)
            .mapError { .localStoreError($0) }
            .eraseToAnyPublisher()
    }

    func update(profileId: UUID,
                mutating: @escaping (inout eRpKit.Profile) -> Void) -> AnyPublisher<Bool, UserProfileServiceError> {
        profileDataStore.update(profileId: profileId, mutating: mutating)
            .mapError { .localStoreError($0) }
            .eraseToAnyPublisher()
    }
}

protocol ProfileOnlineChecker {
    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never>
}

struct DefaultProfileOnlineChecker: ProfileOnlineChecker {
    func token(for profile: Profile) -> AnyPublisher<IDPToken?, Never> {
        @Dependency(\.userSessionProvider) var userSessionProvider
        return userSessionProvider.userSession(for: profile.id).secureUserStore.token
    }
}

// MARK: TCA Dependency

extension DefaultUserProfileService {}

struct UserProfileServiceDependency: DependencyKey {
    static var live: DefaultUserProfileService {
        @Dependency(\.userSession) var userSession: UserSession
        @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore
        @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider

        return .init(
            profileDataStore: profileDataStore,
            profileOnlineChecker: ProfileOnlineCheckerDependency.liveValue,
            userSession: userSession,
            userSessionProvider: userSessionProvider
        )
    }

    static let liveValue: UserProfileService = Self.live
    static let previewValue: UserProfileService = DummyUserProfileService()
    static let testValue: UserProfileService = UnimplementedUserProfileService()
}

extension DependencyValues {
    var userProfileService: UserProfileService {
        get { self[UserProfileServiceDependency.self] }
        set { self[UserProfileServiceDependency.self] = newValue }
    }
}

struct ProfileOnlineCheckerDependency: DependencyKey {
    static let liveValue: ProfileOnlineChecker = DefaultProfileOnlineChecker()
    static let previewValue: ProfileOnlineChecker = DefaultProfileOnlineChecker()
    static let testValue: ProfileOnlineChecker = UnimplementedProfileOnlineChecker()
}

extension DependencyValues {
    var profileOnlineChecker: ProfileOnlineChecker {
        get { self[ProfileOnlineCheckerDependency.self] }
        set { self[ProfileOnlineCheckerDependency.self] = newValue }
    }
}
