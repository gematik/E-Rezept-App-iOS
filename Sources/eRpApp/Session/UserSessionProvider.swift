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

import CodedError
import Combine
import Dependencies
import eRpKit
import eRpLocalStorage
import FeatureHelpers
import Foundation
import Settings

protocol UserSessionProvider {
    func userSession(for uuid: UUID) -> UserSession
}

protocol UserSessionProviderControl: UserSessionProvider {
    func resetSession(with config: AppConfiguration)
}

@CodedError("007")
enum UserSessionProviderError: Error {
    @ErrorCode("01")
    case unavailable
}

class DummyUserSessionProvider: UserSessionProvider {
    func userSession(for _: UUID) -> UserSession {
        DummySessionContainer()
    }
}

class DefaultUserSessionProvider: UserSessionProvider, UserSessionProviderControl {
    var userSessions: [UUID: UserSession] = [:]
    var appConfiguration: AppConfiguration

    var disposeBag: Set<AnyCancellable> = []

    let schedulers: Schedulers
    let profileDataStore: ProfileDataStore

    init(initialUserSession: UserSession,
         schedulers: Schedulers,
         profileDataStore: ProfileDataStore,
         appConfiguration: AppConfiguration) {
        self.schedulers = schedulers
        self.profileDataStore = profileDataStore
        self.appConfiguration = appConfiguration

        userSessions[initialUserSession.profileId] = initialUserSession
    }

    func userSession(for uuid: UUID) -> UserSession {
        if let session = userSessions[uuid] {
            return session
        }

        @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory: CoreDataControllerFactory

        let session = StandardSessionContainer(
            for: uuid,
            schedulers: schedulers,
            profileDataStore: profileDataStore,
            shipmentInfoDataStore: ShipmentInfoCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
            avsTransactionDataStore: AVSTransactionCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
            appConfiguration: appConfiguration
        )
        userSessions[uuid] = session
        return session
    }

    func resetSession(with config: AppConfiguration) {
        userSessions = [:]
        appConfiguration = config
    }
}

// MARK: TCA Dependency

extension DefaultUserSessionProvider {
    static let liveValue = DefaultUserSessionProvider(
        initialUserSession: UserSessionDependency.initialValue,
        schedulers: Schedulers.liveValue,
        profileDataStore: ProfileDataStoreDependency.initialValue,
        appConfiguration: UserDataStoreDependency.liveValue.appConfiguration
    )
}

struct UserSessionProviderDependency: DependencyKey {
    static let liveValue: UserSessionProvider = DefaultUserSessionProvider.liveValue

    static let testValue: UserSessionProvider = UnimplementedUserSessionProvider()
}

extension DependencyValues {
    var userSessionProvider: UserSessionProvider {
        get { self[UserSessionProviderDependency.self] }
        set { self[UserSessionProviderDependency.self] = newValue }
    }
}

struct UserSessionProviderControlDependency: DependencyKey {
    static let liveValue: UserSessionProviderControl = DefaultUserSessionProvider.liveValue

    static let testValue: UserSessionProviderControl = UnimplementedUserSessionProviderControl()
}

extension DependencyValues {
    var userSessionProviderControl: UserSessionProviderControl {
        get { self[UserSessionProviderControlDependency.self] }
        set { self[UserSessionProviderControlDependency.self] = newValue }
    }
}
