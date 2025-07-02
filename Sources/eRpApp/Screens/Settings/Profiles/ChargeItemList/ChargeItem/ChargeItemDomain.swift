//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import ComposableArchitecture
import eRpKit
import Foundation

@Reducer
struct ChargeItemDomain {
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

        let profileId: UUID
        let chargeItem: ErxChargeItem
        var showRouteToChargeItemListButton = false
        var authenticationState: AuthenticationState = .notAuthenticated

        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case deleteButtonTapped

        case redeem
        case authenticate
        // Needs to be enhanced if chargeItem can be altered inApp
        case alterChargeItem
        case routeToChargeItemList
        case resetNavigation
        case destination(PresentationAction<Destination.Action>)
        case showAlert(ShareSheetDomain.Error)

        case response(Response)

        enum Response: Equatable {
            case authenticate(ChargeItemDomainServiceAuthenticateResult)
            case deleteChargeItem(ChargeItemDomainServiceDeleteResult)
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case shareSheet(ShareSheetDomain)
        case idpCardWall(IDPCardWallDomain)
        case alterChargeItem(MatrixCodeDomain)
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

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

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.chargeItemsDomainService) var chargeItemsService: ChargeItemListDomainService
    @Dependency(\.chargeItemPDFService) var pdfService: ChargeItemPDFService
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.router) var router: Routing
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .redeem:
            do {
                let url = try pdfService.loadPDFOrGenerate(for: state.chargeItem)
                state.destination = .shareSheet(.init(url: url, dataMatrixCodeImage: nil))
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

        case let .destination(.presented(.shareSheet(.delegate(.close(error))))):
            state.destination = nil
            if let shareError = error {
                return .run { send in
                    // Delay for closing share sheet
                    try await schedulers.main.sleep(for: 0.05)
                    await send(.showAlert(shareError))
                }
            }
            return .none
        case let .showAlert(error):
            state.destination = .alert(
                ErpAlertState(
                    for: error,
                    title: L10n.dmcAlertTitle,
                    actions: {
                        ButtonState(role: .cancel) {
                            .init(L10n.alertBtnOk)
                        }
                    }
                )
            )
            return .none
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
            state.destination = .idpCardWall(.init(profileId: state.profileId))
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
        case .resetNavigation:
            state.destination = nil
            return .none
        case .destination(.presented(.idpCardWall)):
            return .none
        case .destination:
            return .none
        }
    }
}

extension ChargeItemDomain {
    enum AlertStates {
        typealias Action = ChargeItemDomain.Destination.Alert

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
