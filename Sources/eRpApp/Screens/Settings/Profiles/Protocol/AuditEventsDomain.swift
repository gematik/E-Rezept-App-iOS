//
//  Copyright (c) 2024 gematik GmbH
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
import ComposableArchitecture
import eRpKit
import Foundation

@Reducer
struct AuditEventsDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall
        case cardWall(CardWallIntroductionDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = errorAlert
        case alert(ErpAlertState<Alert>)

        enum Alert: Equatable {
            case cardWall
        }
    }

    enum CancelID: CaseIterable, Hashable {
        case loadNextAuditEvents
    }

    @ObservableState
    struct State: Equatable {
        var profileUUID: UUID
        var entries: IdentifiedArrayOf<State.AuditEvent>?
        var nextPageUrl: URL?
        var needsAuthentication = false

        @Presents var destination: Destination.State?

        struct AuditEvent: Equatable, Identifiable {
            let id: String
            let title: String?
            let description: String?
            let date: String?
        }
    }

    enum Action: Equatable {
        case task
        case loadNextPage
        case close
        case showCardWall
        case destination(PresentationAction<Destination.Action>)

        case response(Response)

        enum Response: Equatable {
            case loadNextPageReceived(Result<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>)
            case taskReceived(Result<PagedContent<[ErxAuditEvent]>, AuditEventsServiceError>)
        }
    }

    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.auditEventsService) var auditEventsService: AuditEventsService
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.uiDateFormatter.compactDateAndTimeFormatter) var dateFormatter: DateFormatter
    var currentLanguageCode = Locale.current.language.languageCode?.identifier ?? "de"

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .publisher(
                auditEventsService
                    .loadAuditEvents(for: state.profileUUID, locale: currentLanguageCode)
                    .map { .response(.taskReceived(.success($0))) }
                    .catch { error in
                        Just(error)
                            .map { Action.response(.taskReceived(.failure($0))) }
                    }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.taskReceived(result)):
            switch result {
            case let .success(pagedContent):
                let auditEvents = IdentifiedArrayOf(
                    uniqueElements: pagedContent.content.asAuditEventStates(
                        dateFormatter: dateFormatter,
                        fhirDateFormatter: fhirDateFormatter
                    )
                )
                state.entries = auditEvents
                state.nextPageUrl = pagedContent.next
            case let .failure(error):
                if error == .missingAuthentication {
                    state.needsAuthentication = true
                } else {
                    state.destination = .alert(.init(for: error))
                }
                state.entries = []
                state.nextPageUrl = nil
            }
            return .none
        case .loadNextPage:
            guard let url = state.nextPageUrl else {
                // nothing more to load
                return .none
            }
            return .publisher(
                auditEventsService.loadNextAuditEvents(for: state.profileUUID, url: url, locale: currentLanguageCode)
                    .map { .response(.loadNextPageReceived((.success($0)))) }
                    .catch { error in
                        Just(error)
                            .map { Action.response(.loadNextPageReceived(.failure($0))) }
                    }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
            .cancellable(id: CancelID.loadNextAuditEvents)
        case let .response(.loadNextPageReceived(result)):
            switch result {
            case let .success(pagedContent):
                let auditEvents = IdentifiedArrayOf(
                    uniqueElements: pagedContent.content.asAuditEventStates(
                        dateFormatter: dateFormatter,
                        fhirDateFormatter: fhirDateFormatter
                    )
                )
                state.entries?.append(contentsOf: auditEvents)
                state.nextPageUrl = pagedContent.next
                return .none
            case let .failure(error):
                if error == .missingAuthentication {
                    state.needsAuthentication = true
                } else {
                    state.destination = .alert(.init(for: error))
                }
            }

            return .none
        case .destination(.presented(.cardWall(.delegate(.close)))):
            state.destination = nil
            state.entries = nil
            state.needsAuthentication = false
            state.nextPageUrl = nil
            return Effect.send(.task)
        case .close:
            return .none
        case .showCardWall:
            state.destination = .cardWall(CardWallIntroductionDomain.State(
                isNFCReady: serviceLocator.deviceCapabilities.isNFCReady,
                profileId: state.profileUUID
            ))
            return .none
        case .destination:
            return .none
        }
    }
}

extension Collection where Element == ErxAuditEvent {
    func asAuditEventStates(
        dateFormatter: DateFormatter,
        fhirDateFormatter: FHIRDateFormatter
    ) -> [AuditEventsDomain.State.AuditEvent] {
        map {
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
}

extension AuditEventsDomain {
    var environment: Environment {
        .init(
            schedulers: schedulers,
            fhirDateFormatter: fhirDateFormatter,
            dateFormatter: dateFormatter
        )
    }

    struct Environment {
        let schedulers: Schedulers
        let fhirDateFormatter: FHIRDateFormatter
        let dateFormatter: DateFormatter
    }
}

extension AuditEventsDomain {
    enum Dummies {
        static let state = State(profileUUID: DemoProfileDataStore.anna.id)

        static let store = StoreOf<AuditEventsDomain>(initialState: state) {
            AuditEventsDomain(currentLanguageCode: Locale.current.language.languageCode?.identifier ?? "de")
        }
    }
}
