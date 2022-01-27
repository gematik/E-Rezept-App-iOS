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
import eRpKit
import Foundation
import IDP

protocol UserProfileService {
    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError>

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError>
}

class DummyUserProfileService: UserProfileService {
    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        Just([]).setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()
    }

    func activeUserProfilePublisher() -> AnyPublisher<UserProfile, UserProfileServiceError> {
        Just(UserProfile(from: Self.dummyProfile, isAuthenticated: true))
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()
    }

    static let dummyProfile = Profile(name: "Dummy Profile")
}

enum UserProfileServiceError: Error, Equatable {
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

    internal init(profileDataStore: ProfileDataStore,
                  profileOnlineChecker: ProfileOnlineChecker,
                  userSession: UserSession) {
        self.profileDataStore = profileDataStore
        self.profileOnlineChecker = profileOnlineChecker
        self.userSession = userSession
    }

    func userProfilesPublisher() -> AnyPublisher<[UserProfile], UserProfileServiceError> {
        profileDataStore.listAllProfiles()
            .flatMap { profiles -> AnyPublisher<[UserProfile], LocalStoreError> in
                let publishers = profiles.map { profile in
                    profileOnlineChecker.token(for: profile)
                        .first()
                        .map { token in
                            UserProfile(from: profile, token: token)
                        }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(publishers)
                    .collect(publishers.count)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            }
            .mapError(UserProfileServiceError.localStoreError)
            .eraseToAnyPublisher()
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
                    .eraseToAnyPublisher()
            )
            .map(UserProfile.init)
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
