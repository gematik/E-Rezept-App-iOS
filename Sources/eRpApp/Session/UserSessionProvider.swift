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
import Dependencies
import eRpKit
import eRpLocalStorage
import Foundation

protocol UserSessionProvider {
    func userSession(for uuid: UUID) -> UserSession
}

protocol UserSessionProviderControl: UserSessionProvider {
    func resetSession(with config: AppConfiguration)
}

// sourcery: CodedError = "007"
enum UserSessionProviderError: Error {
    // sourcery: errorCode = "01"
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
    let coreDataControllerFactory: CoreDataControllerFactory
    let profileDataStore: ProfileDataStore

    init(initialUserSession: UserSession,
         schedulers: Schedulers,
         coreDataControllerFactory: CoreDataControllerFactory,
         profileDataStore: ProfileDataStore,
         appConfiguration: AppConfiguration) {
        self.schedulers = schedulers
        self.coreDataControllerFactory = coreDataControllerFactory
        self.profileDataStore = profileDataStore
        self.appConfiguration = appConfiguration

        userSessions[initialUserSession.profileId] = initialUserSession
    }

    func userSession(for uuid: UUID) -> UserSession {
        if let session = userSessions[uuid] {
            return session
        }
        let session = StandardSessionContainer(
            for: uuid,
            schedulers: schedulers,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(
                profileId: uuid,
                coreDataControllerFactory: coreDataControllerFactory
            ),
            pharmacyCoreDataStore: PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
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
        coreDataControllerFactory: CoreDataControllerFactoryDependency.liveValue,
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
