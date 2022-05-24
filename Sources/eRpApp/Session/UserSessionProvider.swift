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
import eRpLocalStorage
import Foundation

protocol UserSessionProvider {
    func userSession(for uuid: UUID) -> UserSession
}

protocol UserSessionProviderControl: UserSessionProvider {
    func resetSession(with config: AppConfiguration)
}

enum UserSessionProviderError: Error {
    case unavailable
}

class DummyUserSessionProvider: UserSessionProvider {
    func userSession(for _: UUID) -> UserSession {
        DemoSessionContainer()
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
            profileDataStore: profileDataStore,
            shipmentInfoDataStore: ShipmentInfoCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
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
