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

import ComposableArchitecture
import eRpKit
import Foundation

enum AuditEventsDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case loadEvents
    }

    struct State: Equatable {
        var profileUUID: UUID
        var entries: IdentifiedArrayOf<State.AuditEvent>?

        var lastUpdated: String?

        struct AuditEvent: Equatable, Identifiable {
            let id: String // swiftlint:disable:this identifier_name
            let title: String?
            let description: String?
            let date: String?
        }
    }

    enum Action: Equatable {
        case load
        case eventsReceived(Result<Profile?, LocalStoreError>)
        case close
    }

    struct Environment {
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        var fhirDateFormatter = FHIRDateFormatter.shared
        var dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            return dateFormatter
        }()
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .load:
            return environment.profileDataStore.fetchProfile(by: state.profileUUID)
                .first()
                .catchToEffect()
                .map(Action.eventsReceived)
                .cancellable(id: Token.loadEvents, cancelInFlight: true)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case .eventsReceived(.failure):
            return .none
        case let .eventsReceived(.success(events)):
            if let lastAuthenticated = events?.lastAuthenticated {
                state.lastUpdated = environment.dateFormatter.string(from: lastAuthenticated)
            } else {
                state.lastUpdated = nil
            }
            if let events = events?.erxAuditEvents {
                let mapped: [State.AuditEvent] = events
                    .sorted { $0.timestamp ?? "" < $1.timestamp ?? "" }
                    .map {
                        let date: String?
                        if let inputDateString = $0.timestamp,
                           let inputDate = environment.fhirDateFormatter.date(from: inputDateString) {
                            date = environment.dateFormatter.string(from: inputDate)
                        } else {
                            date = nil
                        }

                        return State.AuditEvent(
                            id: $0.id,
                            title: $0.title,
                            description: $0.text?.trimmed(),
                            date: date
                        )
                    }
                state.entries = IdentifiedArrayOf(uniqueElements: mapped)
            }
            return .none
        case .close:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension AuditEventsDomain {
    enum Dummies {
        static let state = State(profileUUID: UUID())
        static let environment = Environment(
            schedulers: Schedulers(),
            profileDataStore: DemoProfileDataStore()
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
