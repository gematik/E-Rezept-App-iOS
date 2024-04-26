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

struct ChargeItemDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

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
        var showRouteToChargeItemListButton = false
        var authenticationState: AuthenticationState = .notAuthenticated

        @PresentationState var destination: Destinations.State?
    }

    enum Action: Equatable {
        case deleteButtonTapped

        case redeem
        case authenticate
        // Needs to be enhanced if chargeItem can be altered inApp
        case alterChargeItem
        case routeToChargeItemList

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        case response(Response)

        enum Response: Equatable {
            case authenticate(ChargeItemDomainServiceAuthenticateResult)
            case deleteChargeItem(ChargeItemDomainServiceDeleteResult)
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case shareSheet([URL])
            case idpCardWall(IDPCardWallDomain.State)
            case alterChargeItem(MatrixCodeDomain.State)
            case alert(ErpAlertState<Action.Alert>)
        }

        enum Action: Equatable {
            case shareSheet(Sheet)
            case idpCardWallAction(IDPCardWallDomain.Action)
            case alterChargeItem(MatrixCodeDomain.Action)
            case alert(Alert)

            enum Sheet: Equatable {}

            enum Alert: Equatable {
                case deleteConfirm
                case deleteCancel
                case deleteAuthenticateConnect
                case deleteAuthenticateCancel
                case authenticateRetry
                case authenticateOkay
                case deleteChargeItemsErrorRetry
                case deleteChargeItemsErrorOkay
            }
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.idpCardWall,
                action: /Action.idpCardWallAction
            ) {
                IDPCardWallDomain()
            }
            Scope(
                state: /State.alterChargeItem,
                action: /Action.alterChargeItem
            ) {
                MatrixCodeDomain()
            }
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.chargeItemsDomainService) var chargeItemsService: ChargeItemListDomainService
    @Dependency(\.chargeItemPDFService) var pdfService: ChargeItemPDFService
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.router) var router: Routing
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: /Action.destination) {
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
        case .alterChargeItem:
            state.destination = .alterChargeItem(.init(
                type: .erxChargeItem,
                erxChargeItem: state.chargeItem
            ))
            return .none
        case .routeToChargeItemList:
            return .run { [profileId = state.profileId] _ in

                await dismiss()
                await router.routeTo(.settings(.editProfile(.chargeItemListFor(profileId))))
            }
        case .destination(.presented(.alert(.deleteConfirm))):
            state.destination = nil
            return .publisher(chargeItemsService.delete(
                chargeItem: state.chargeItem,
                for: state.profileId
            )
            .first()
            .receive(on: schedulers.main)
            .eraseToAnyPublisher()
            .map(Action.Response.deleteChargeItem)
            .map(Action.response)
            .eraseToAnyPublisher)
        case let .response(.deleteChargeItem(result)):
            switch result {
            case .success:
                state.authenticationState = .authenticated
                return .run { _ in await dismiss() }
            case .notAuthenticated:
                state.authenticationState = .notAuthenticated
                state.destination = .alert(AlertStates.deleteNotAuthenticated)
                return .none
            case let .error(error):
                state.destination = .alert(AlertStates.deleteErrorFor(error: error))
                return .none
            }
        case .destination(.presented(.alert(.authenticateRetry))):
            state.destination = nil
            return .run { send in
                await send(.authenticate)
            }
        case .destination(.presented(.alert(.deleteChargeItemsErrorRetry))):
            state.destination = nil
            return .send(.destination(.presented(.alert(.deleteConfirm))))
        case .destination(.presented(.alert(.deleteChargeItemsErrorOkay))):
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
                        profileId: state.profileId,
                        pin: "",
                        transition: .fullScreenCover
                    )
                )
            )
            return .none
        case .destination(.presented(.alert(.deleteAuthenticateCancel))):
            state.destination = nil
            return .none
        case .authenticate:
            state.authenticationState = .loading
            return .publisher(
                chargeItemsService.authenticate(for: state.profileId)
                    .eraseToAnyPublisher()
                    .map(Action.Response.authenticate)
                    .map(Action.response)
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
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
        case .destination(.presented(.idpCardWallAction)):
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .setNavigation,
             .destination:
            return .none
        }
    }
}

extension ChargeItemDomain {
    enum AlertStates {
        typealias Action = ChargeItemDomain.Destinations.Action.Alert

        static let deleteConfirm: ErpAlertState<Action> = .init(
            title: L10n.stgTxtChargeItemAlertDeleteConfirmTitle,
            actions: {
                ButtonState(role: .destructive, action: .deleteConfirm) {
                    .init(L10n.stgBtnChargeItemAlertDeleteConfirmDelete)
                }
                ButtonState(role: .cancel, action: .deleteCancel) {
                    .init(L10n.stgBtnChargeItemAlertErrorCancel)
                }
            },
            message: L10n.stgTxtChargeItemAlertDeleteConfirmMessage
        )

        static let deleteNotAuthenticated: ErpAlertState<Action> = .init(
            title: L10n.stgTxtChargeItemAlertDeleteNotAuthTitle,
            actions: {
                ButtonState(action: .deleteAuthenticateConnect) {
                    .init(L10n.stgBtnChargeItemAlertDeleteNotAuthConnect)
                }
                ButtonState(role: .cancel, action: .deleteAuthenticateCancel) {
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
                ButtonState(action: .authenticateRetry) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(role: .cancel, action: .authenticateOkay) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }

        static func deleteErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemAlertErrorTitle
            ) {
                ButtonState(action: .deleteChargeItemsErrorRetry) {
                    .init(L10n.stgBtnChargeItemAlertErrorRetry)
                }
                ButtonState(role: .cancel, action: .deleteChargeItemsErrorOkay) {
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
