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
        typealias Action = ChargeItemListDomain.Action

        static let grantConsentRequest: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtChargeItemListAlertGrantConsentTitle),
            message: .init(L10n.stgTxtChargeItemListAlertGrantConsentMessage),
            primaryButton: .default(
                .init(L10n.stgTxtChargeItemListAlertGrantConsentButtonActivate),
                action: .send(.grantConsentAlertGrantButtonTapped)
            ),
            secondaryButton: .cancel(
                .init(L10n.stgTxtChargeItemListAlertGrantConsentButtonCancel),
                action: .send(.grantConsentAlertDenyGrantButtonTapped)
            )
        )

        static let revokeConsentRequest: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtChargeItemListAlertGrantConsentTitle),
            message: .init(L10n.stgTxtChargeItemListAlertGrantConsentMessage),
            primaryButton: .destructive(
                .init(L10n.stgTxtChargeItemListAlertRevokeConsentButtonDeactivate),
                action: .send(.revokeConsentErrorAlertRetryButtonTapped)
            ),
            secondaryButton: .cancel(
                .init(L10n.stgTxtChargeItemListAlertRevokeConsentButtonCancel),
                action: .send(.revokeConsentErrorAlertOkayButtonTapped)
            )
        )

        static func fetchChargeItemsErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: .init(L10n.stgTxtChargeItemListErrorAlertFetchChargeItemListTitle),
                primaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry),
                    action: .send(.fetchChargeItemsErrorAlertRetryButtonTapped)
                ),
                secondaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay),
                    action: .send(.fetchChargeItemsErrorAlertOkayButtonTapped)
                )
            )
        }

        static func authenticateErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: .init(L10n.stgTxtChargeItemListErrorAlertAuthenticateTitle),
                primaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry),
                    action: .send(.authenticateErrorAlertRetryButtonTapped)
                ),
                secondaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay),
                    action: .send(.authenticateErrorAlertOkayButtonTapped)
                )
            )
        }

        static func grantConsentErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: .init(L10n.stgTxtChargeItemListErrorAlertGrantConsentTitle),
                primaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry),
                    action: .send(.grantConsentErrorAlertRetryButtonTapped)
                ),
                secondaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay),
                    action: .send(.grantConsentErrorAlertOkayButtonTapped)
                )
            )
        }

        static func revokeConsentErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: .init(L10n.stgTxtChargeItemListErrorAlertRevokeConsentTitle),
                primaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonRetry),
                    action: .send(.revokeConsentErrorAlertRetryButtonTapped)
                ),
                secondaryButton: .default(
                    .init(L10n.stgTxtChargeItemListErrorAlertButtonOkay),
                    action: .send(.revokeConsentErrorAlertOkayButtonTapped)
                )
            )
        }

        // to-do: consider this alert when implementing the delete feature
        static func deleteChargeItemsErrorFor(error: CodedError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: .init("Löschen fehlgeschlagen"),
                primaryButton: .default(
                    .init("Erneut versuchen"),
                    action: .send(.deleteChargeItemsErrorAlertRetryButtonTapped)
                ),
                secondaryButton: .default(
                    .init("Okay"),
                    action: .send(.deleteChargeItemsErrorAlertOkayButtonTapped)
                )
            )
        }
    }
}
