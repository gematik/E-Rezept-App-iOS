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

import ComposableArchitecture
import eRpKit
import Foundation

struct AuditEventsDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
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
            let id: String
            let title: String?
            let description: String?
            let date: String?
        }
    }

    enum Action: Equatable {
        case loadPageList
        case loadPage(Page)
        case close

        case response(Response)

        enum Response: Equatable {
            case profileReceived(Result<Profile?, LocalStoreError>)
            case loadPageReceived(Result<[State.AuditEvent], LocalStoreError>)
        }

        enum Delegate: Equatable {}
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadPageList:
            state
                .pages = (try? profileDataStore
                    .pagedAuditEventsController(for: state.profileUUID, with: nil).getPageContainer())
                .map { IdentifiedArrayOf(uniqueElements: $0.pages) }

            if let firstPage = state.pages?.first {
                return .concatenate(
                    profileDataStore.fetchProfile(by: state.profileUUID)
                        .first()
                        .catchToEffect()
                        .map(Action.Response.profileReceived)
                        .map(Action.response)
                        .cancellable(id: Token.loadEvents, cancelInFlight: true)
                        .receive(on: schedulers.main)
                        .eraseToEffect(),
                    Effect(value: .loadPage(firstPage))
                )
            }

            return profileDataStore.fetchProfile(by: state.profileUUID)
                .first()
                .catchToEffect()
                .map(Action.Response.profileReceived)
                .map(Action.response)
                .cancellable(id: Token.loadEvents, cancelInFlight: true)
                .receive(on: schedulers.main)
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

            return (try? profileDataStore.pagedAuditEventsController(for: state.profileUUID, with: nil))
                .map {
                    $0
                        .getPage(page)
                        .first()
                        .map {
                            $0
                                .map {
                                    let date: String?
                                    if let inputDateString = $0.timestamp,
                                       let inputDate = fhirDateFormatter.date(from: inputDateString) {
                                        date = dateFormatter.string(from: inputDate)
                                    } else {
                                        date = dateFormatter.string(from: Date()) // nil
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
                        .map(Action.Response.loadPageReceived)
                        .map(Action.response)
                } ?? .none
        case let .response(.loadPageReceived(.success(page))):
            state.entries = IdentifiedArrayOf(uniqueElements: page)
            return .none
        case .response(.loadPageReceived(.failure)):
            return .none
        case .response(.profileReceived(.failure)):
            return .none
        case let .response(.profileReceived(.success(events))):
            if let lastAuthenticated = events?.lastAuthenticated {
                state.lastUpdated = dateFormatter.string(from: lastAuthenticated)
            } else {
                state.lastUpdated = nil
            }
            return .none
        case .close:
            return .none
        }
    }
}

extension AuditEventsDomain {
    var environment: Environment {
        .init(
            schedulers: schedulers,
            profileDataStore: profileDataStore,
            fhirDateFormatter: fhirDateFormatter,
            dateFormatter: dateFormatter
        )
    }

    struct Environment {
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let fhirDateFormatter: FHIRDateFormatter
        let dateFormatter: DateFormatter

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
                .map(Action.Response.loadPageReceived)
                .map(Action.response)
        }
    }
}

extension AuditEventsDomain {
    enum Dummies {
        static let state = State(profileUUID: DemoProfileDataStore.anna.id)

        static let store = Store(
            initialState: state,
            reducer: AuditEventsDomain()
        )
    }
}
