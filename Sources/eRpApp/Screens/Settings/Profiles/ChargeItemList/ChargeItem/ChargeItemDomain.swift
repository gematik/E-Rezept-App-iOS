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
import Foundation

struct ChargeItemDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case authenticate
        case deleteChargeItem
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

        let profileId: UUID

        let chargeItem: ErxChargeItem
        var authenticationState: AuthenticationState = .notAuthenticated

        var destination: Destinations.State?
    }

    enum Action: Equatable {
        // swiftlint:disable identifier_name
        case deleteButtonTapped
        case alertDeleteConfirmButtonTapped
        case alertDeleteCancelButtonTapped
        case alertDeleteAuthenticateConnectButtonTapped
        case alertDeleteAuthenticateCancelButtonTapped
        case alertAuthenticateRetryButtonTapped
        case alertAuthenticateOkayButtonTapped
        case alertDeleteChargeItemsErrorRetryButtonTapped
        case alertDeleteChargeItemsErrorOkayButtonTapped
        // swiftlint:enable identifier_name

        case redeem
        case authenticate

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)
        case nothing

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case authenticate(ChargeItemDomainServiceAuthenticateResult)
            case deleteChargeItem(ChargeItemDomainServiceDeleteResult)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case shareSheet([URL])
            case idpCardWall(IDPCardWallDomain.State)
            case alert(ErpAlertState<ChargeItemDomain.Action>)
        }

        enum Action: Equatable {
            case idpCardWallAction(IDPCardWallDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.idpCardWall,
                action: /Action.idpCardWallAction
            ) {
                IDPCardWallDomain()
            }
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.chargeItemsDomainService) var chargeItemsService: ChargeItemListDomainService
    @Dependency(\.chargeItemPDFService) var pdfService: ChargeItemPDFService
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .redeem:
            do {
                let url = try pdfService.loadPDFOrGenerate(for: state.chargeItem)
                state.destination = .shareSheet([url])
                return .none
            } catch let error as CodedError {
                state.destination = .alert(.init(for: error, title: nil))
                return .none
            } catch {
                return .none
            }
        case .deleteButtonTapped:
            state.destination = .alert(AlertStates.deleteConfirm)
            return .none
        case .alertDeleteConfirmButtonTapped:
            state.destination = nil

            return chargeItemsService.delete(
                chargeItem: state.chargeItem,
                for: state.profileId
            )
            .first()
            .receive(on: schedulers.main)
            .eraseToEffect(Action.Response.deleteChargeItem)
            .map(Action.response)
            .cancellable(id: Token.deleteChargeItem)
        case let .response(.deleteChargeItem(result)):
            switch result {
            case .success:
                state.authenticationState = .authenticated
                return .send(.delegate(.close))
            case .notAuthenticated:
                state.authenticationState = .notAuthenticated
                state.destination = .alert(AlertStates.deleteNotAuthenticated)
                return .none
            case let .error(error):
                state.destination = .alert(AlertStates.deleteErrorFor(error: error))
                return .none
            }
        case .alertDeleteCancelButtonTapped:
            state.destination = nil
            return .none
        case .alertAuthenticateRetryButtonTapped:
            state.destination = nil
            return .task { .authenticate }
        case .alertAuthenticateOkayButtonTapped:
            state.destination = nil
            return .none
        case .alertDeleteChargeItemsErrorRetryButtonTapped:
            state.destination = nil
            return .task { .alertDeleteConfirmButtonTapped }
        case .alertDeleteChargeItemsErrorOkayButtonTapped:
            state.destination = nil
            return .none
        case .alertDeleteAuthenticateConnectButtonTapped:
            let userSession = userSessionProvider.userSession(for: state.profileId)
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
        case .alertDeleteAuthenticateCancelButtonTapped:
            state.destination = nil
            return .none
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
                return .none
            case .furtherAuthenticationRequired:
                state.authenticationState = .notAuthenticated
                return .none
            case let .error(error):
                state.authenticationState = .error
                state.destination = .alert(AlertStates.authenticateErrorFor(error: error))
                return .none
            }
        case let .delegate(delegate):
            switch delegate {
            case .close:
                return Self.cleanup()
            }
        case .destination(.idpCardWallAction(.delegate(.close))):
            state.destination = nil
            return CardWallIntroductionDomain.cleanup()
        case .destination(.idpCardWallAction):
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .setNavigation,
             .destination,
             .nothing:
            return .none
        }
    }
}

extension ChargeItemDomain {
    enum AlertStates {
        typealias Action = ChargeItemDomain.Action

        static let deleteConfirm: ErpAlertState<Action> = .init(
            title: L10n.stgTxtChargeItemAlertDeleteConfirmTitle,
            actions: {
                ButtonState(role: .destructive, action: .alertDeleteConfirmButtonTapped) {
                    .init(L10n.stgBtnChargeItemAlertDeleteConfirmDelete)
                }
                ButtonState(role: .cancel, action: .alertDeleteCancelButtonTapped) {
                    .init(L10n.stgBtnChargeItemAlertErrorCancel)
                }
            },
            message: L10n.stgTxtChargeItemAlertDeleteConfirmMessage
        )

        static let deleteNotAuthenticated: ErpAlertState<Action> = .init(
            title: L10n.stgTxtChargeItemAlertDeleteNotAuthTitle,
            actions: {
                ButtonState(action: .alertDeleteAuthenticateConnectButtonTapped) {
                    .init(L10n.stgBtnChargeItemAlertDeleteNotAuthConnect)
                }
                ButtonState(role: .cancel, action: .alertDeleteAuthenticateCancelButtonTapped) {
                    .init(L10n.stgBtnChargeItemAlertErrorCancel)
                }
            },
            message: L10n.stgTxtChargeItemAlertDeleteNotAuthMessage
        )

        static func authenticateErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemListErrorAlertAuthenticateTitle
            ) {
                ButtonState(action: .alertAuthenticateRetryButtonTapped) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(role: .cancel, action: .alertAuthenticateOkayButtonTapped) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }

        static func deleteErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemAlertErrorTitle
            ) {
                ButtonState(action: .alertDeleteChargeItemsErrorRetryButtonTapped) {
                    .init(L10n.stgBtnChargeItemAlertErrorRetry)
                }
                ButtonState(role: .cancel, action: .alertDeleteChargeItemsErrorOkayButtonTapped) {
                    .init(L10n.stgBtnChargeItemAlertErrorOkay)
                }
            }
        }
    }
}

extension ErxChargeItem {
    var totalGrossPrice: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "EUR"
        currencyFormatter.locale = Locale(identifier: "DE")

        guard let totalGross = invoice?.totalGross.doubleValue,
              let price = currencyFormatter.string(for: totalGross) else {
            return "-"
        }
        return price
    }
}
