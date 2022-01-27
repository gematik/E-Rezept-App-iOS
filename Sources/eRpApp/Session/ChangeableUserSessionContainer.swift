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

    // TODO: Remove `userSessionStream` as soon as AppContainer is removed swiftlint:disable:this todo
    var userSessionStream: AnyPublisher<UserSession, Never> { get }
    var isDemoMode: AnyPublisher<Bool, Never> { get }

    func switchToDemoMode()
    func switchToStandardMode()
}

class ChangeableUserSessionContainer: UsersSessionContainer {
    var isDemoMode: AnyPublisher<Bool, Never> {
        currentSession.map(\.isDemoMode).eraseToAnyPublisher()
    }

    var userSessionStream: AnyPublisher<UserSession, Never> {
        currentSession.eraseToAnyPublisher()
    }

    private var currentSession: CurrentValueSubject<UserSession, Never>
    private(set) var userSession: UserSession
    private var schedulers: Schedulers
    private var erxTaskCoreDataStore: ErxTaskCoreDataStore

    init(initialUserSession: UserSession, schedulers: Schedulers, erxTaskCoreDataStore: ErxTaskCoreDataStore) {
        self.schedulers = schedulers
        self.erxTaskCoreDataStore = erxTaskCoreDataStore
        currentSession = CurrentValueSubject(initialUserSession)
        userSession = StreamWrappedUserSession(
            stream: currentSession.eraseToAnyPublisher(),
            current: initialUserSession
        )
    }

    func switchToDemoMode() {
        DLog("will switch to demo mode")
        currentSession.send(UserMode.demo(DemoSessionContainer()))
    }

    func switchToStandardMode() {
        DLog("will switch to standard mode")
        // TODO: load current selected profile and pass profileId // swiftlint:disable:this todo
        let sessionContainer = StandardSessionContainer(
            schedulers: schedulers,
            erxTaskCoreDataStore: erxTaskCoreDataStore
        )
        currentSession.send(UserMode.standard(sessionContainer))
    }
}

class DummyUserSessionContainer: UsersSessionContainer {
    var userSession: UserSession = DemoSessionContainer()

    var userSessionStream: AnyPublisher<UserSession, Never> = Just(DemoSessionContainer()).eraseToAnyPublisher()

    var isDemoMode: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    func switchToDemoMode() {}

    func switchToStandardMode() {}
}
