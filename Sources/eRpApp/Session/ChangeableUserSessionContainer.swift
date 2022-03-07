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
import GemCommonsKit
import IDP

protocol UsersSessionContainer {
    var userSession: UserSession { get }

    var isDemoMode: AnyPublisher<Bool, Never> { get }

    func switchToDemoMode()
    func switchToStandardMode()
}

class ChangeableUserSessionContainer: UsersSessionContainer {
    var isDemoMode: AnyPublisher<Bool, Never> {
        currentSession.map(\.isDemoMode).eraseToAnyPublisher()
    }

    private var currentSession: CurrentValueSubject<UserSession, Never>
    private(set) var userSession: UserSession

    private var currentProfileUserSession: SelectedProfileUserSessionProvider

    private let userStore: UserDataStore

    init(initialUserSession: UserSession? = nil,
         profileId: UUID,
         schedulers: Schedulers,
         coreDataControllerFactory: CoreDataControllerFactory,
         profileDataStore: ProfileDataStore,
         userDataStore: UserDataStore) {
        userStore = userDataStore
        let session: UserSession
        if let initialUserSession = initialUserSession {
            session = initialUserSession
        } else {
            session = StandardSessionContainer(
                for: profileId,
                schedulers: schedulers,
                erxTaskCoreDataStore: ErxTaskCoreDataStore(
                    profileId: profileId,
                    coreDataControllerFactory: coreDataControllerFactory
                ),
                profileDataStore: profileDataStore,
                appConfiguration: userStore.appConfiguration
            )
        }

        currentProfileUserSession = SelectedProfileUserSessionProvider(
            initialUserSession: session,
            schedulers: schedulers,
            coreDataControllerFactory: coreDataControllerFactory,
            profileDataStore: profileDataStore,
            publisher: userStore.selectedProfileId
                .combineLatest(userStore.configuration)
                .dropFirst()
                .compactMap { uuid, config in
                    guard let uuid = uuid else {
                        return nil
                    }
                    return (uuid, config)
                }
                .eraseToAnyPublisher()
        )

        currentSession = CurrentValueSubject(currentProfileUserSession.userSession)

        userSession = StreamWrappedUserSession(
            stream: currentSession.eraseToAnyPublisher(),
            current: session
        )
    }

    func switchToDemoMode() {
        DLog("will switch to demo mode")
        currentSession.send(UserMode.demo(DemoSessionContainer()))
    }

    func switchToStandardMode() {
        DLog("will switch to standard mode")
        currentSession.send(currentProfileUserSession.userSession)
    }
}

class DummyUserSessionContainer: UsersSessionContainer {
    var userSession: UserSession = DemoSessionContainer()

    var isDemoMode: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    func switchToDemoMode() {}

    func switchToStandardMode() {}
}
