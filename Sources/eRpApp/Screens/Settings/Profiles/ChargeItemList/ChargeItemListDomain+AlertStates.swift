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
import Foundation

extension ChargeItemListDomain {
    enum AlertStates {
        typealias Action = ChargeItemListDomain.Destinations.Action.Alert

        static let grantConsentRequest: ErpAlertState<Action> = {
            .init(
                title: L10n.stgTxtChargeItemListAlertGrantConsentTitle,
                actions: {
                    ButtonState(action: .grantConsent) {
                        .init(L10n.stgTxtChargeItemListAlertGrantConsentButtonActivate)
                    }
                    ButtonState(role: .cancel, action: .grantConsentDeny) {
                        .init(L10n.stgTxtChargeItemListAlertGrantConsentButtonCancel)
                    }
                },
                message: L10n.stgTxtChargeItemListAlertGrantConsentMessage
            )
        }()

        static let revokeConsentRequest: ErpAlertState<Action> = {
            .init(
                title: L10n.stgTxtChargeItemListAlertGrantConsentTitle,
                actions: {
                    ButtonState(role: .destructive, action: .revokeConsentErrorRetry) {
                        .init(L10n.stgTxtChargeItemListAlertRevokeConsentButtonDeactivate)
                    }
                    ButtonState(role: .cancel, action: .revokeConsentErrorOkay) {
                        .init(L10n.stgTxtChargeItemListAlertRevokeConsentButtonCancel)
                    }
                },
                message: L10n.stgTxtChargeItemListAlertGrantConsentMessage
            )
        }()

        static func fetchChargeItemsErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemListErrorAlertFetchChargeItemListTitle
            ) {
                ButtonState(action: .fetchChargeItemsErrorRetry) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(action: .fetchChargeItemsErrorOkay) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }

        static func authenticateErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemListErrorAlertAuthenticateTitle
            ) {
                ButtonState(action: .authenticateErrorRetry) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(action: .authenticateErrorOkay) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }

        static func grantConsentErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemListErrorAlertGrantConsentTitle
            ) {
                ButtonState(action: .grantConsentErrorRetry) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(action: .grantConsentErrorOkay) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }

        static func revokeConsentErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtChargeItemListErrorAlertRevokeConsentTitle
            ) {
                ButtonState(action: .revokeConsentErrorRetry) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(action: .revokeConsentErrorOkay) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }

        // to-do: consider this alert when implementing the delete feature
        static func deleteChargeItemsErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: .init("Löschen fehlgeschlagen")
            ) {
                ButtonState(action: .deleteChargeItemsErrorRetry) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry)
                }
                ButtonState(action: .deleteChargeItemsErrorOkay) {
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay)
                }
            }
        }
    }
}
