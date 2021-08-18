//
//  Copyright (c) 2021 gematik GmbH
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
import CombineSchedulers
import eRpKit
import Foundation
import GemCommonsKit
import HTTPClient
import Pharmacy

protocol AppContainerType {
    var serviceLocator: ServiceLocator { get }
    var uiDateFormatter: DateFormatter { get }
    var fhirDateFormatter: FHIRDateFormatter { get }
    /// Scheduler for doing UI related work. Use this within combine `receive(on:)`.
    var schedulers: Schedulers { get }

    var userSessionContainer: UsersSessionContainer { get }
}

class AppContainer: ObservableObject, AppContainerType {
    static var shared = AppContainer()
    let schedulers = Schedulers()

    private var disposeBag: Set<AnyCancellable> = []

    private init() {
        let userSession = UserMode.standard(StandardSessionContainer(schedulers: schedulers))
        userSessionSubject = userSession
        userSessionContainer = ChangeableUserSessionContainer(initialUserSession: userSession,
                                                              schedulers: schedulers)

        userSessionContainer.userSessionStream
            .assign(to: \.userSessionSubject, on: self)
            .store(in: &disposeBag)
    }

    var userSessionContainer: UsersSessionContainer

    let serviceLocator = ServiceLocator()

    @Published private(set) var userSessionSubject: UserSession

    lazy var uiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    lazy var fhirDateFormatter: FHIRDateFormatter = {
        FHIRDateFormatter.shared
    }()
}
