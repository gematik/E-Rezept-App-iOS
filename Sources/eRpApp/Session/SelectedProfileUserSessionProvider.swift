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
import eRpLocalStorage
import Foundation

class SelectedProfileUserSessionProvider {
    private(set) var userSession: UserSession

    private let currentValueSubject: CurrentValueSubject<UserSession, Never>

    private var disposeBag = Set<AnyCancellable>()

    private let userSessionProvider: UserSessionProviderControl
    var appConfiguration: AppConfiguration

    init(appConfiguration: AppConfiguration,
         initialUserSession: UserSession,
         userSessionProvider: UserSessionProviderControl,
         publisher: AnyPublisher<(profileId: UUID, appConfig: AppConfiguration), Never>) {
        currentValueSubject = CurrentValueSubject(initialUserSession)
        self.userSessionProvider = userSessionProvider
        self.appConfiguration = appConfiguration

        userSession = StreamWrappedUserSession(
            stream: currentValueSubject.eraseToAnyPublisher(),
            current: initialUserSession
        )

        publisher
            .sink { [weak currentValue = self.currentValueSubject, weak self] profileId, configuration in
                guard let self = self else {
                    return
                }

                if configuration != self.appConfiguration {
                    self.appConfiguration = configuration
                    userSessionProvider.resetSession(with: configuration)
                }

                let newProfile = self.userSessionProvider.userSession(for: profileId)

                currentValue?.send(newProfile)
            }
            .store(in: &disposeBag)
    }
}
