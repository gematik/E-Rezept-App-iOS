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

        var pages: IdentifiedArrayOf<Page>?

        var selectedPage: Page?
        var previousPage: Page?
        var nextPage: Page?

        var lastUpdated: String?

        struct AuditEvent: Equatable, Identifiable {
            let id: String // swiftlint:disable:this identifier_name
            let title: String?
            let description: String?
            let date: String?
        }
    }

    enum Action: Equatable {
        case loadPageList
        case profileReceived(Result<Profile?, LocalStoreError>)
        case loadPage(Page)
        case loadPageReceived(Result<[State.AuditEvent], LocalStoreError>)
        case close
    }

    struct Environment {
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        var fhirDateFormatter = FHIRDateFormatter.shared
        var dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter
        }()
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadPageList:
            state
                .pages = (try? environment.profileDataStore
                    .pagedAuditEventsController(for: state.profileUUID, with: nil).getPageContainer())
                .map { IdentifiedArrayOf(uniqueElements: $0.pages) }

            if let firstPage = state.pages?.first {
                return .concatenate(
                    environment.profileDataStore.fetchProfile(by: state.profileUUID)
                        .first()
                        .catchToEffect()
                        .map(Action.profileReceived)
                        .cancellable(id: Token.loadEvents, cancelInFlight: true)
                        .receive(on: environment.schedulers.main)
                        .eraseToEffect(),
                    Effect(value: .loadPage(firstPage))
                )
            }

            return environment.profileDataStore.fetchProfile(by: state.profileUUID)
                .first()
                .catchToEffect()
                .map(Action.profileReceived)
                .cancellable(id: Token.loadEvents, cancelInFlight: true)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .loadPage(page):
            guard let pages = state.pages,
                  let index = pages.index(id: page.id) else {
                return .none
            }

            state.selectedPage = page
            if index > pages.startIndex {
                let before = pages.index(before: index)
                let page = pages[before]
                state.previousPage = page
            } else {
                state.previousPage = nil
            }

            if index < pages.endIndex - 1 {
                let after = pages.index(after: index)
                let page = pages[after]
                state.nextPage = page
            } else {
                state.nextPage = nil
            }

            return (try? environment.profileDataStore.pagedAuditEventsController(for: state.profileUUID, with: nil))
                .map {
                    $0
                        .getPage(page)
                        .first()
                        .map {
                            $0
                                .map {
                                    let date: String?
                                    if let inputDateString = $0.timestamp,
                                       let inputDate = environment.fhirDateFormatter.date(from: inputDateString) {
                                        date = environment.dateFormatter.string(from: inputDate)
                                    } else {
                                        date = environment.dateFormatter.string(from: Date()) // nil
                                    }

                                    return State.AuditEvent(
                                        id: $0.id,
                                        title: $0.title,
                                        description: $0.text?.trimmed(),
                                        date: date
                                    )
                                }
                        }
                        .catchToEffect()
                        .map(Action.loadPageReceived)
                } ?? .none
        case let .loadPageReceived(.success(page)):
            state.entries = IdentifiedArrayOf(uniqueElements: page)
            return .none
        case let .loadPageReceived(.failure(error)):
            return .none
        case .profileReceived(.failure):
            return .none
        case let .profileReceived(.success(events)):
            if let lastAuthenticated = events?.lastAuthenticated {
                state.lastUpdated = environment.dateFormatter.string(from: lastAuthenticated)
            } else {
                state.lastUpdated = nil
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

extension AuditEventsDomain.Environment {
    func loadAuditEventsPage(_ page: Page, ofProfile profile: UUID) -> Effect<AuditEventsDomain.Action, Never> {
        guard let pageController = try? profileDataStore.pagedAuditEventsController(for: profile, with: nil) else {
            return .none
        }

        return pageController.getPage(page)
            .map { auditEvents in
                auditEvents.map { // Map Array Elements
                    let date: String?
                    if let inputDateString = $0.timestamp,
                       let inputDate = fhirDateFormatter.date(from: inputDateString) {
                        date = dateFormatter.string(from: inputDate)
                    } else {
                        date = dateFormatter.string(from: Date()) // nil
                    }

                    return AuditEventsDomain.State.AuditEvent(
                        id: $0.id,
                        title: $0.title,
                        description: $0.text?.trimmed(),
                        date: date
                    )
                }
            }
            .catchToEffect()
            .map(AuditEventsDomain.Action.loadPageReceived)
    }
}

extension AuditEventsDomain {
    enum Dummies {
        static let state = State(profileUUID: DemoProfileDataStore.anna.id)
        static let environment = Environment(
            schedulers: Schedulers(),
            profileDataStore: DemoProfileDataStore()
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
