//
//  Copyright (c) 2025 gematik GmbH
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

extension DiGaDetailDomain {
    enum AlertStates {
        typealias Action = DiGaDetailDomain.Destination.Alert

        static func alertFor(_ error: ErxRepositoryError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.digaDtlAlertTxtErrorTitle
            ) {
                ButtonState(action: .dismiss) {
                    .init(L10n.cdwBtnIntroAlertClose)
                }
            }
        }

        static var confirmDeleteAlertState: ErpAlertState<Action> = {
            .init(
                title: L10n.digaDtlTxtDeleteAlertTitle,
                actions: {
                    ButtonState(role: .destructive, action: .confirmedDelete) {
                        .init(L10n.dtlTxtDeleteYes)
                    }
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.dtlTxtDeleteNo)
                    }
                },
                message: L10n.digaDtlTxtDeleteAlertMessage
            )
        }()

        static func missingTokenAlertState() -> ErpAlertState<Action> {
            .init(
                title: L10n.dtlTxtDeleteMissingTokenAlertTitle,
                actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                },
                message: L10n.dtlTxtDeleteMissingTokenAlertMessage
            )
        }

        static func deleteFailedAlertState(
            error: CodedError,
            localizedError: String
        ) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.dtlTxtDeleteMissingTokenAlertTitle
            ) {
                ButtonState(action: .openEmailClient(body: localizedError)) {
                    .init(L10n.prscFdBtnErrorBanner)
                }
                ButtonState(role: .cancel, action: .send(.dismiss)) {
                    .init(L10n.alertBtnOk)
                }
            }
        }

        static func deletionNotAllowedAlertState(isDeletable: Bool)
            -> ErpAlertState<Action> {
            var title = L10n.prscDtlAlertTitleDeleteNotAllowed
            if !isDeletable {
                title = L10n.digaDtlBtnDeleteDisabledNote
            } else {
                assertionFailure("check prescription.isDeletable state for more reasons")
            }

            return .init(title: title) {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.alertBtnOk)
                }
            }
        }

        static func failingRequest(count: Int) -> ErpAlertState<Action> {
            .init(
                title: { TextState(L10n.phaRedeemAlertTitleFailure(count)) },
                actions: {
                    ButtonState(role: .cancel) {
                        TextState(L10n.alertBtnOk)
                    }
                },
                message: { TextState(L10n.digaDtlRedeemAlertMessageFailure) }
            )
        }

        static func telematikIdEmpty() -> ErpAlertState<Action> {
            .init(
                title: { TextState(L10n.digaDtlAlertTxtTelematikidEmptyTitle) },
                actions: {
                    ButtonState(role: .cancel) {
                        TextState(L10n.alertBtnOk)
                    }
                },
                message: { TextState(L10n.digaDtlAlertTxtTelematikidEmpty) }
            )
        }
    }
}
