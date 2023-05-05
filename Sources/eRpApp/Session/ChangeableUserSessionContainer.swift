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

    private let schedulers: Schedulers

    init(
        initialUserSession: UserSession,
        userDataStore: UserDataStore,
        userSessionProvider: UserSessionProviderControl,
        schedulers: Schedulers
    ) {
        userStore = userDataStore
        let session: UserSession = initialUserSession

        currentProfileUserSession = SelectedProfileUserSessionProvider(
            appConfiguration: userDataStore.appConfiguration,
            initialUserSession: session,
            userSessionProvider: userSessionProvider,
            publisher: userStore.selectedProfileId
                .removeDuplicates()
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

        self.schedulers = schedulers
        currentSession = CurrentValueSubject(currentProfileUserSession.userSession)

        userSession = StreamWrappedUserSession(
            stream: currentSession.eraseToAnyPublisher(),
            current: session
        )
    }

    func switchToDemoMode() {
        DLog("will switch to demo mode")
        currentSession.send(UserMode.demo(DemoSessionContainer(schedulers: schedulers)))
    }

    func switchToStandardMode() {
        DLog("will switch to standard mode")
        currentSession.send(currentProfileUserSession.userSession)
    }
}

// MARK: TCA Dependency

struct UsersSessionContainerDependency: DependencyKey {
    static let liveValue: UsersSessionContainer = ChangeableUserSessionContainer(
        initialUserSession: UserSessionDependency.initialValue,
        userDataStore: UserDataStoreDependency.liveValue,
        userSessionProvider: DefaultUserSessionProvider.liveValue,
        schedulers: Schedulers.liveValue
    )

    static let previewValue: UsersSessionContainer = DummyUserSessionContainer()

    static let testValue: UsersSessionContainer = UnimplementedUsersSessionContainer()
}

extension DependencyValues {
    var changeableUserSessionContainer: UsersSessionContainer {
        get { self[UsersSessionContainerDependency.self] }
        set { self[UsersSessionContainerDependency.self] = newValue }
    }
}

// MARK: Dummies

class DummyUserSessionContainer: UsersSessionContainer {
    var userSession: UserSession = DummySessionContainer()

    var isDemoMode: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    func switchToDemoMode() {}

    func switchToStandardMode() {}
}
