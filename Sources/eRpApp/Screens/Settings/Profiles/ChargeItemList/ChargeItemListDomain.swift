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
import ComposableArchitecture
import eRpKit
import eRpLocalStorage
import Foundation

// swiftlint:disable:next type_body_length
struct ChargeItemListDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case fetchChargeItemsLocal
        case fetchChargeItemsRemote
        case authenticate
        case grantConsent
        case revokeConsent
    }

    struct State: Equatable {
        enum AuthenticationState: Equatable {
            /// When the user is authenticated
            case authenticated
            /// When the user is not authenticated
            case notAuthenticated
            /// Ongoing interaction with the authentication service (e.g. loading)
            case loading
            /// When an error occurred
            case error
        }

        enum GrantConsentState: Equatable {
            /// When the service responded positive
            case granted
            /// When the service responded negative
            case notGranted
            /// When the user denied grant
            case userDeniedGrant
            /// Ongoing interaction with service
            case loading
            /// When there was no service interaction yet
            case unknown
            case error
        }

        let profileId: UUID

        var chargeItemGroups: [ChargeItemGroup] = []
        var authenticationState: AuthenticationState = .notAuthenticated
        var grantConsentState: GrantConsentState = .unknown

        var bottomBannerState: BottomBannerState?
        var destination: Destinations.State?

        var toolbarMenuState: ToolbarMenuState {
            let entries: [ToolbarMenuState.Entry]
            switch (authenticationState, grantConsentState) {
            case (.authenticated, .granted):
                entries = [
                    .connect.disabled,
                    .activate.disabled,
                    .deactivate,
                ]
            case (.authenticated, _):
                entries = [
                    .connect.disabled,
                    .activate,
                    .deactivate.disabled,
                ]
            case (_, _):
                entries = [
                    .connect,
                    .activate.disabled,
                    .deactivate.disabled,
                ]
            }
            return .init(entries: entries)
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = cardWall
            case idpCardWall(IDPCardWallDomain.State)
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<ChargeItemListDomain.Action>)
            // sourcery: AnalyticsScreen = chargeItemDetails
            case chargeItem(ChargeItemDomain.State)
        }

        enum Action: Equatable {
            case idpCardWallAction(IDPCardWallDomain.Action)
            case chargeItem(action: ChargeItemDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.idpCardWall,
                action: /Action.idpCardWallAction
            ) {
                IDPCardWallDomain()
            }

            Scope(
                state: /State.chargeItem,
                action: /Action.chargeItem
            ) {
                ChargeItemDomain()
            }
        }
    }

    enum Action: Equatable {
        case onAppear

        // swiftlint:disable identifier_name
        case fetchChargeItemsErrorAlertRetryButtonTapped
        case fetchChargeItemsErrorAlertOkayButtonTapped
        case authenticateErrorAlertRetryButtonTapped
        case authenticateErrorAlertOkayButtonTapped
        case authenticateBottomBannerButtonTapped
        case grantConsentAlertGrantButtonTapped
        case grantConsentAlertDenyGrantButtonTapped
        case grantConsentErrorAlertRetryButtonTapped
        case grantConsentErrorAlertOkayButtonTapped
        case grantConsentBottomBannerButtonTapped
        case connectMenuButtonTapped
        case activateMenuButtonTapped
        case deactivateMenuButtonTapped
        case revokeConsentAlertRevokeButtonTapped
        case revokeConsentAlertCancelButtonTapped
        case revokeConsentErrorAlertRetryButtonTapped
        case revokeConsentErrorAlertOkayButtonTapped
        case deleteChargeItemsErrorAlertRetryButtonTapped
        case deleteChargeItemsErrorAlertOkayButtonTapped
        // swiftlint:enable identifier_name

        case fetchChargeItems
        case authenticate
        case grantConsent
        case revokeConsent

        case select(ChargeItem)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)
        case nothing

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case fetchChargeItemsLocal(ChargeItemDomainServiceFetchResult)
            case fetchChargeItemsRemote(ChargeItemDomainServiceFetchResult)
            case authenticate(ChargeItemDomainServiceAuthenticateResult)
            case grantConsent(ChargeItemListDomainServiceGrantResult)
            case revokeConsent(ChargeItemListDomainServiceRevokeResult)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.chargeItemsDomainService) var chargeItemsService: ChargeItemListDomainService
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .task { .fetchChargeItems }
        case .fetchChargeItemsErrorAlertRetryButtonTapped:
            state.destination = nil
            return .task { .fetchChargeItems }
        case .fetchChargeItemsErrorAlertOkayButtonTapped:
            state.destination = nil
            return .none
        case .authenticateErrorAlertRetryButtonTapped:
            state.destination = nil
            return .task { .authenticate }
        case .authenticateErrorAlertOkayButtonTapped:
            state.destination = nil
            state.bottomBannerState = .authenticate
            return .none
        case .authenticateBottomBannerButtonTapped:
            state.bottomBannerState = nil
            return .task { .authenticate }
        case .grantConsentAlertGrantButtonTapped:
            state.destination = nil
            return .task { .grantConsent }
        case .grantConsentAlertDenyGrantButtonTapped:
            state.grantConsentState = .userDeniedGrant
            state.destination = nil
            state.bottomBannerState = .grantConsent
            return .none
        case .grantConsentErrorAlertRetryButtonTapped:
            state.destination = nil
            return .task { .grantConsent }
        case .grantConsentErrorAlertOkayButtonTapped:
            state.destination = nil
            state.bottomBannerState = .grantConsent
            return .none
        case .grantConsentBottomBannerButtonTapped:
            state.bottomBannerState = nil
            return .task { .grantConsent }
        case .connectMenuButtonTapped:
            state.bottomBannerState = nil
            return .task { .authenticate }
        case .activateMenuButtonTapped:
            state.bottomBannerState = nil
            return .task { .grantConsent }
        case .deactivateMenuButtonTapped:
            state.destination = .alert(AlertStates.revokeConsentRequest)
            return .none
        case .revokeConsentAlertRevokeButtonTapped:
            state.destination = nil
            return .task { .revokeConsent }
        case .revokeConsentAlertCancelButtonTapped:
            state.destination = nil
            return .none
        case .revokeConsentErrorAlertRetryButtonTapped:
            state.destination = nil
            return .task { .revokeConsent }
        case .revokeConsentErrorAlertOkayButtonTapped:
            state.destination = nil
            return .none
        case .deleteChargeItemsErrorAlertRetryButtonTapped:
            return .none // to-do: implement later
        case .deleteChargeItemsErrorAlertOkayButtonTapped:
            return .none
        case let .select(chargeItem):
            guard let fatChargeItem = chargeItem.original.chargeItem
            else { return .none }
            state.destination = .chargeItem(
                .init(
                    profileId: state.profileId,
                    chargeItem: fatChargeItem
                )
            )
            return .none
        case .fetchChargeItems:
            return .concatenate(
                chargeItemsService.fetchLocalChargeItems(for: state.profileId)
                    .first()
                    .receive(on: schedulers.main)
                    .eraseToEffect(Action.Response.fetchChargeItemsLocal)
                    .map(Action.response)
                    .cancellable(id: Token.fetchChargeItemsLocal),
                chargeItemsService.fetchRemoteChargeItemsAndSave(for: state.profileId)
                    .first()
                    .receive(on: schedulers.main)
                    .eraseToEffect(Action.Response.fetchChargeItemsRemote)
                    .map(Action.response)
                    .cancellable(id: Token.fetchChargeItemsRemote)
            )
        case let .response(.fetchChargeItemsLocal(result)):
            switch result {
            case let .success(chargeItems):
                state.chargeItemGroups = chargeItems.asChargeItemGroups()
                return .none
            case let .error(error):
                state.destination = .alert(AlertStates.fetchChargeItemsErrorFor(error: error))
                return .none
            case .consentNotGranted, .notAuthenticated: // not required for local response
                return .none
            }
        case let .response(.fetchChargeItemsRemote(result)):
            switch result {
            case let .success(chargeItems):
                state.authenticationState = .authenticated
                state.grantConsentState = .granted
                state.chargeItemGroups = chargeItems.asChargeItemGroups()
                return .none
            case .notAuthenticated:
                state.authenticationState = .notAuthenticated
                state.grantConsentState = .unknown
                state.bottomBannerState = .authenticate
                return .none
            case .consentNotGranted:
                state.authenticationState = .authenticated
                state.grantConsentState = .notGranted
                state.destination = .alert(AlertStates.grantConsentRequest)
                return .none
            case let .error(error):
                state.destination = .alert(AlertStates.fetchChargeItemsErrorFor(error: error))
                return .none
            }
        case .authenticate:
            state.authenticationState = .loading
            return chargeItemsService.authenticate(for: state.profileId)
                .eraseToEffect()
                .map(Action.Response.authenticate)
                .map(Action.response)
                .receive(on: schedulers.main)
                .eraseToEffect()
                .cancellable(id: Token.authenticate)
        case let .response(.authenticate(result)):
            switch result {
            case .success:
                state.authenticationState = .authenticated
                return chargeItemsService.fetchRemoteChargeItemsAndSave(for: state.profileId)
                    .receive(on: schedulers.main)
                    .eraseToEffect(Action.Response.fetchChargeItemsRemote)
                    .map(Action.response)
                    .cancellable(id: Token.fetchChargeItemsRemote)
            case .furtherAuthenticationRequired:
                state.authenticationState = .notAuthenticated
                state.grantConsentState = .unknown
                state.destination = .idpCardWall(
                    .init(
                        profileId: state.profileId,
                        can: .init(
                            isDemoModus: userSession.isDemoMode,
                            profileId: state.profileId,
                            can: ""
                        ),
                        pin: .init(
                            isDemoModus: userSession.isDemoMode,
                            pin: "",
                            transition: .fullScreenCover
                        )
                    )
                )
                return .none
            case let .error(error):
                state.authenticationState = .error
                state.grantConsentState = .unknown
                state.destination = .alert(AlertStates.authenticateErrorFor(error: error))
                return .none
            }

        case .grantConsent:
            state.grantConsentState = .loading
            return chargeItemsService.grantChargeItemsConsent(for: state.profileId)
                .first()
                .eraseToEffect()
                .map(Action.Response.grantConsent)
                .map(Action.response)
                .receive(on: schedulers.main)
                .eraseToEffect()
                .cancellable(id: Token.grantConsent)
        case let .response(.grantConsent(result)):
            switch result {
            case .success:
                state.authenticationState = .authenticated
                state.grantConsentState = .granted
                return chargeItemsService.fetchChargeItemsAssumingConsentGranted(for: state.profileId)
                    .eraseToEffect(Action.Response.fetchChargeItemsRemote)
                    .map(Action.response)
                    .receive(on: schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.fetchChargeItemsRemote)
            case .notAuthenticated:
                state.authenticationState = .notAuthenticated
                state.grantConsentState = .unknown
                state.bottomBannerState = .authenticate
                return .none
            case let .error(error):
                state.authenticationState = .authenticated
                state.grantConsentState = .error
                state.destination = .alert(AlertStates.grantConsentErrorFor(error: error))
                return .none
            }

        case .revokeConsent:
            return chargeItemsService.revokeChargeItemsConsent(for: state.profileId)
                .first()
                .eraseToEffect()
                .map(Action.Response.revokeConsent)
                .map(Action.response)
                .receive(on: schedulers.main)
                .eraseToEffect()
                .cancellable(id: Token.revokeConsent)
        case let .response(.revokeConsent(remoteResult)):
            switch remoteResult {
            case let .success(deleteLocalChargeItemsResult):
                state.authenticationState = .authenticated
                state.grantConsentState = .notGranted
                state.bottomBannerState = .grantConsent
                switch deleteLocalChargeItemsResult {
                case .success:
                    break // do-nothing
                case .notAuthenticated:
                    break // not required for local
                case let .error(error):
                    state.destination = .alert(AlertStates.deleteChargeItemsErrorFor(error: error))
                }
                return .none
            case .notAuthenticated:
                state.authenticationState = .notAuthenticated
                state.grantConsentState = .unknown
                state.bottomBannerState = .authenticate
                return .none
            case let .error(error):
                state.grantConsentState = .error
                state.destination = .alert(AlertStates.revokeConsentErrorFor(error: error))
                return .none
            }

        case .destination(.idpCardWallAction(.delegate(.close))):
            state.destination = nil
            return .concatenate(
                CardWallIntroductionDomain.cleanup(),
                .task { .fetchChargeItems }
            )

        case .destination(.idpCardWallAction),
             .destination(.chargeItem):
            return .none

        case .setNavigation(tag: .none):
            state.destination = nil
            return .none

        case .setNavigation,
             .delegate,
             .nothing:
            return .none
        }
    }
}

extension ChargeItemListDomain {
    enum Dummies {
        static let state = State(profileId: UUID())

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: ChargeItemListDomain()
            )
        }
    }
}
