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

import ComposableArchitecture
import Foundation

extension ChargeItemConsentService.AlertState {
    var mainDomainErpAlertState: ErpAlertState<MainDomain.Destination.Alert> {
        erpAlertState(
            actionForOkay: MainDomain.Destination.Alert.consentServiceErrorOkay,
            actionForRetry: MainDomain.Destination.Alert.consentServiceErrorRetry,
            actionForLogin: MainDomain.Destination.Alert.consentServiceErrorAuthenticate
        )
    }
}

extension MainDomain {
    enum AlertStates {
        static func loginNecessaryAlert(for error: LoginHandlerError) -> ErpAlertState<Destination.Alert> {
            .init(
                for: error,
                title: L10n.errTitleLoginNecessary
            ) {
                ButtonState(action: .cardWall) {
                    .init(L10n.erxBtnAlertLogin)
                }
            }
        }

        static func devicePairingInvalid() -> ErpAlertState<Destination.Alert> {
            .init(
                title: L10n.errTitlePairingInvalid,
                actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.erxBtnAlertOk)
                    }
                    ButtonState(action: .cardWall) {
                        .init(L10n.erxBtnAlertLogin)
                    }
                },
                message: L10n.errMessagePairingInvalid
            )
        }

        static let grantConsentServiceNotAuthenticated = ErpAlertState<Destination.Alert>(
            title: L10n.mainTxtConsentServiceErrorNotLoggedInTitle,
            actions: {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.erxBtnAlertOk)
                }
                ButtonState(action: .cardWall) {
                    .init(L10n.erxBtnAlertLogin)
                }
            },
            message: L10n.mainTxtConsentServiceErrorNotLoggedInMessage
        )

        static func grantConsentErrorFor(error: CodedError) -> ErpAlertState<Destination.Alert> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemListErrorAlertGrantConsentTitle
            ) {
                ButtonState(action: .retryGrantChargeItemConsent) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(role: .cancel, action: .dismissGrantChargeItemConsent) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }

        static func forcedUpdateAlert() -> ErpAlertState<Destination.Alert> {
            .init(
                title: L10n.erxTxtForcedUpdateAlertTitle,
                actions: {
                    ButtonState(role: .cancel, action: .send(.dismiss)) {
                        TextState(L10n.erxTxtForcedUpdateAlertIgnore)
                    }
                    ButtonState(action: .send(.goToAppStore)) {
                        TextState(L10n.erxTxtForcedUpdateAlertUpdate)
                    }
                },
                message: L10n.erxTxtForcedUpdateAlertDescription
            )
        }
    }

    enum ToastStates {
        typealias Action = MainDomain.Destination.Toast

        static let conflictToast
            = ToastState<Action>(
                style: .action(
                    ChargeItemConsentService.ToastState.conflict.message,
                    .init(action: .routeToChargeItemsList) {
                        TextState(ChargeItemConsentService.ToastState.routeToChargeItemsListMessage)
                    }
                )
            )

        static let grantConsentSuccess = ToastState<Destination.Toast>(
            style: .action(
                ChargeItemConsentService.ToastState.successfullyGranted.message,
                .init(action: .routeToChargeItemsList) {
                    TextState(ChargeItemConsentService.ToastState.routeToChargeItemsListMessage)
                }
            )
        )
    }
}
