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
// swiftlint:disable file_length

import Combine
import ComposableArchitecture
import eRpKit
import eRpLocalStorage
import Foundation

// swiftlint:disable type_body_length
@Reducer
struct ChargeItemListDomain {
    @ObservableState
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
        @Presents var destination: Destination.State?

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

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall
        case idpCardWall(IDPCardWallDomain)
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        // sourcery: AnalyticsScreen = chargeItemDetails
        case chargeItem(ChargeItemDomain)
        // sourcery: AnalyticsScreen = chargeItemList_toast
        @ReducerCaseEphemeral
        case toast(ToastState<Toast>)

        enum Alert: Equatable {
            case fetchChargeItemsErrorRetry
            case fetchChargeItemsErrorOkay
            case authenticateErrorRetry
            case authenticateErrorOkay
            case grantConsent
            case grantConsentDeny
            case grantConsentErrorRetry
            case grantConsentErrorOkay
            case revokeConsent
            case revokeConsentCancel
            case revokeConsentErrorRetry
            case revokeConsentErrorOkay
            case deleteChargeItemsErrorRetry
            case deleteChargeItemsErrorOkay
            case consentServiceErrorOkay
            case consentServiceErrorAuthenticate
            case consentServiceErrorRetry
        }

        enum Toast: Equatable {}
    }

    enum Action: Equatable {
        case task

        case authenticateBottomBannerButtonTapped
        case grantConsentBottomBannerButtonTapped
        case connectMenuButtonTapped
        case activateMenuButtonTapped
        case deactivateMenuButtonTapped

        case fetchChargeItems
        case authenticate
        case grantConsent
        case revokeConsent

        case select(ChargeItem)

        case destination(PresentationAction<Destination.Action>)
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

    var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .run { send in
                await send(.fetchChargeItems)
            }
        case .destination(.presented(.alert(.fetchChargeItemsErrorRetry))):
            state.destination = nil
            return .run { send in
                await send(.fetchChargeItems)
            }
        case .destination(.presented(.alert(.fetchChargeItemsErrorOkay))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.authenticateErrorRetry))):
            state.destination = nil
            return .run { send in
                await send(.authenticate)
            }
        case .destination(.presented(.alert(.authenticateErrorOkay))):
            state.destination = nil
            state.bottomBannerState = .authenticate
            return .none
        case .authenticateBottomBannerButtonTapped:
            state.bottomBannerState = nil
            return .run { send in
                await send(.authenticate)
            }
        case .destination(.presented(.alert(.grantConsent))):
            state.destination = nil
            return .run { send in
                await send(.grantConsent)
            }
        case .destination(.presented(.alert(.grantConsentDeny))):
            state.grantConsentState = .userDeniedGrant
            state.destination = nil
            state.bottomBannerState = .grantConsent
            return .none
        case .destination(.presented(.alert(.grantConsentErrorRetry))):
            state.destination = nil
            return .run { send in
                await send(.grantConsent)
            }
        case .destination(.presented(.alert(.grantConsentErrorOkay))):
            state.destination = nil
            state.bottomBannerState = .grantConsent
            return .none
        case .grantConsentBottomBannerButtonTapped:
            state.bottomBannerState = nil
            return .run { send in
                await send(.grantConsent)
            }
        case .connectMenuButtonTapped:
            state.bottomBannerState = nil
            return .run { send in
                await send(.authenticate)
            }
        case .activateMenuButtonTapped:
            state.bottomBannerState = nil
            return .run { send in
                await send(.grantConsent)
            }
        case .deactivateMenuButtonTapped:
            state.destination = .alert(AlertStates.revokeConsentRequest)
            return .none
        case .destination(.presented(.alert(.revokeConsent))):
            state.destination = nil
            return .run { send in
                await send(.revokeConsent)
            }
        case .destination(.presented(.alert(.revokeConsentCancel))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.revokeConsentErrorRetry))):
            state.destination = nil
            return .run { send in
                await send(.revokeConsent)
            }
        case .destination(.presented(.alert(.revokeConsentErrorOkay))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.deleteChargeItemsErrorRetry))):
            return .none // to-do: implement later
        case .destination(.presented(.alert(.deleteChargeItemsErrorOkay))):
            return .none
        case .destination(.presented(.alert(.consentServiceErrorOkay))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.consentServiceErrorRetry))):
            state.bottomBannerState = nil
            return .run { send in
                await send(.grantConsent)
            }
        case .destination(.presented(.alert(.consentServiceErrorAuthenticate))):
            state.bottomBannerState = nil
            return .run { send in
                await send(.authenticate)
            }
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
                .publisher(
                    chargeItemsService.fetchLocalChargeItems(for: state.profileId)
                        .first()
                        .receive(on: schedulers.main)
                        .map { Action.response(Action.Response.fetchChargeItemsLocal($0)) }
                        .eraseToAnyPublisher
                ),
                .publisher(
                    chargeItemsService.fetchRemoteChargeItemsAndSave(for: state.profileId)
                        .first()
                        .receive(on: schedulers.main)
                        .map { Action.response(Action.Response.fetchChargeItemsRemote($0)) }
                        .eraseToAnyPublisher
                )
            )
        case let .response(.fetchChargeItemsLocal(result)):
            switch result {
            case let .success(chargeItems):
                state.chargeItemGroups = chargeItems.asChargeItemGroups()
                return .none
            case let .error(error):
                state.destination = .alert(AlertStates.fetchChargeItemsErrorFor(error: error))
                return .none
            case .consentNotGranted, // not required for local response
                 .notAuthenticated:

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
                state.grantConsentState = .error
                if case let .chargeItemConsentService(chargeItemConsentServiceError) = error {
                    if case .loginHandler = chargeItemConsentServiceError {
                        state.authenticationState = .error
                        state.bottomBannerState = .authenticate
                        state.destination = nil
                    } else if let alertState = chargeItemConsentServiceError.alertState {
                        // in case of an expected (specified) http error
                        state.authenticationState = .authenticated
                        state.destination = .alert(alertState.chargeItemListDomainErpAlertState)
                    }
                } else {
                    // in case of an unexpected (not specified) error
                    state.authenticationState = .notAuthenticated
                    state.bottomBannerState = .authenticate
                    state.destination = .alert(AlertStates.grantConsentErrorFor(error: error))
                }
                return .none
            }
        case .authenticate:
            state.authenticationState = .loading
            return .publisher(
                chargeItemsService.authenticate(for: state.profileId)
                    .map(Action.Response.authenticate)
                    .map(Action.response)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.authenticate(result)):
            switch result {
            case .success:
                state.authenticationState = .authenticated
                return .publisher(
                    chargeItemsService.fetchRemoteChargeItemsAndSave(for: state.profileId)
                        .receive(on: schedulers.main)
                        .map(Action.Response.fetchChargeItemsRemote)
                        .map(Action.response)
                        .eraseToAnyPublisher
                )
            case .furtherAuthenticationRequired:
                state.authenticationState = .notAuthenticated
                state.grantConsentState = .unknown
                state.destination = .idpCardWall(.init(profileId: state.profileId))
                return .none
            case let .error(error):
                state.authenticationState = .error
                state.grantConsentState = .unknown
                state.destination = .alert(AlertStates.authenticateErrorFor(error: error))
                return .none
            }

        case .grantConsent:
            state.grantConsentState = .loading
            return .publisher(
                chargeItemsService.grantChargeItemsConsent(for: state.profileId)
                    .first()
                    .map(Action.Response.grantConsent)
                    .map(Action.response)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.grantConsent(result)):
            switch result {
            case .success:
                state.authenticationState = .authenticated
                state.grantConsentState = .granted
                return .publisher(
                    chargeItemsService.fetchChargeItemsAssumingConsentGranted(for: state.profileId)
                        .map(Action.Response.fetchChargeItemsRemote)
                        .map(Action.response)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )
            case .conflict:
                state.authenticationState = .authenticated
                state.grantConsentState = .granted
                state.destination = .toast(ToastStates.conflictToast)
                return .none
            case .notAuthenticated:
                state.authenticationState = .notAuthenticated
                state.grantConsentState = .unknown
                state.bottomBannerState = .authenticate
                return .none
            case let .error(error):
                state.grantConsentState = .error
                if case let .chargeItemConsentService(chargeItemConsentServiceError) = error {
                    if case .loginHandler = chargeItemConsentServiceError {
                        state.authenticationState = .error
                        state.bottomBannerState = .authenticate
                        state.destination = nil
                    } else if let alertState = chargeItemConsentServiceError.alertState {
                        // in case of an expected (specified) http error
                        state.authenticationState = .authenticated
                        state.destination = .alert(alertState.chargeItemListDomainErpAlertState)
                    }
                } else {
                    // in case of an unexpected (not specified) error
                    state.authenticationState = .notAuthenticated
                    state.bottomBannerState = .authenticate
                    state.destination = .alert(AlertStates.grantConsentErrorFor(error: error))
                }
                return .none
            }

        case .revokeConsent:
            return .publisher(
                chargeItemsService.revokeChargeItemsConsent(for: state.profileId)
                    .first()
                    .map(Action.Response.revokeConsent)
                    .map(Action.response)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
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
            case .conflict:
                state.authenticationState = .notAuthenticated
                state.grantConsentState = .unknown
                state.bottomBannerState = .authenticate
                return .none
            }
        case .destination(.presented(.idpCardWall(.delegate(.close)))),
             .destination(.presented(.idpCardWall(.delegate(.finished)))):
            state.destination = nil
            return .send(.fetchChargeItems)
        case .destination(.presented(.idpCardWall)),
             .destination(.presented(.chargeItem)):
            return .none
        case .delegate,
             .destination,
             .nothing:
            return .none
        }
    }
}

extension ChargeItemListDomain {
    enum Dummies {
        static let state = State(profileId: UUID())

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<ChargeItemListDomain> {
            Store(
                initialState: state
            ) {
                ChargeItemListDomain()
            }
        }
    }
}

// swiftlint:enable type_body_length
