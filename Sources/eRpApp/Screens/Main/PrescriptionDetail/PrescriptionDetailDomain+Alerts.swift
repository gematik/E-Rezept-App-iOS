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

import ComposableArchitecture
import eRpKit
import FHIRClient
import SwiftUI

extension ChargeItemConsentService.AlertState {
    var prescriptionDetailDomainErpAlertState: ErpAlertState<PrescriptionDetailDomain.Destination.Alert> {
        erpAlertState(
            actionForOkay: PrescriptionDetailDomain.Destination.Alert.consentServiceErrorOkay,
            actionForRetry: PrescriptionDetailDomain.Destination.Alert.consentServiceErrorRetry,
            actionForLogin: PrescriptionDetailDomain.Destination.Alert.consentServiceErrorAuthenticate
        )
    }
}

extension PrescriptionDetailDomain {
    enum Alerts {
        /// Creates the handoff action for sharing the url between devices
        static func createHandoffActivity(with task: ErxTask) -> NSUserActivity? {
            guard let url = task.shareUrl() else {
                return nil
            }

            let activity = NSUserActivity(activityType: "de.gematik.erp4ios.eRezept.Share")
            activity.title = "Share with other stuff"
            activity.isEligibleForHandoff = true
            activity.webpageURL = url
            activity.becomeCurrent()

            return activity
        }

        static var confirmDeleteAlertState: ErpAlertState<Destination.Alert> = {
            .init(
                title: L10n.dtlTxtDeleteAlertTitle,
                actions: {
                    ButtonState(role: .destructive, action: .confirmedDelete) {
                        .init(L10n.dtlTxtDeleteYes)
                    }
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.dtlTxtDeleteNo)
                    }
                },
                message: L10n.dtlTxtDeleteAlertMessage
            )
        }()

        static var confirmDeleteWithChargeItemAlertState: ErpAlertState<Destination.Alert> = {
            .init(
                title: L10n.dtlTxtDeleteWithChargeItemAlertTitle,
                actions: {
                    ButtonState(role: .destructive, action: .confirmedDeleteWithChargeItem) {
                        .init(L10n.dtlTxtDeleteYes)
                    }
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.dtlTxtDeleteNo)
                    }
                },
                message: L10n.dtlTxtDeleteWithChargeItemAlertMessage
            )
        }()

        static func deletionNotAllowedAlertState(_ prescription: Prescription)
            -> ErpAlertState<Destination.Alert> {
            var title = L10n.prscDtlAlertTitleDeleteNotAllowed
            if prescription.type == .directAssignment {
                title = L10n.prscDeleteNoteDirectAssignment
            } else if !prescription.isDeletable {
                title = L10n.dtlBtnDeleteDisabledNote
            } else {
                assertionFailure("check prescription.isDeletable state for more reasons")
            }

            return .init(title: title) {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.alertBtnOk)
                }
            }
        }

        static func deleteFailedAlertState(
            error: CodedError,
            localizedError: String
        ) -> ErpAlertState<Destination.Alert> {
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

        static func missingTokenAlertState() -> ErpAlertState<Destination.Alert> {
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

        static func changeNameReceivedAlertState(error: CodedError) -> ErpAlertState<Destination.Alert> {
            // swiftlint:disable:next trailing_closure
            .init(for: error, actions: {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.alertBtnOk)
                }
            })
        }

        static let grantConsentRequest: ErpAlertState<Destination.Alert> = {
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
    }

    enum ToastStates {
        typealias Action = PrescriptionDetailDomain.Destination.Toast

        static let conflictToast: ToastState<Action> =
            .init(style: .simple(ChargeItemConsentService.ToastState.conflict.message))
    }
}
