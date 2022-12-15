//
//  Copyright (c) 2022 gematik GmbH
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

extension HealthCardPasswordReadCardDomain {
    enum AlertStates {
        typealias Action = HealthCardPasswordReadCardDomain.Action

        // success
        static let cardUnlocked: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCardUnlockedTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCardUnlockedMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        static let cardUnlockedWithSetNewPin: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCardUnlockedWithPinTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCardUnlockedWithPinMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        static let setNewPin: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCardSetNewPinTitle),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        // error: blocked
        static let pukCounterExhausted: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        // error: password not found
        static let passwordNotFound: ErpAlertState<Action> = .init(
            title: .init(L10n.cdwTxtRcErrorPasswordMissingDescription),
            message: .init(L10n.cdwTxtRcErrorPasswordMissingRecovery),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        // error: security status not satisfied
        static let securityStatusNotSatisfied: ErpAlertState<Action> = .init(
            title: .init(L10n.cdwTxtRcErrorSecStatusDescription),
            message: .init(L10n.cdwTxtRcErrorSecStatusRecovery),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        // error: memory failure
        static let memoryFailure: ErpAlertState<Action> = .init(
            title: .init(L10n.cdwTxtRcErrorMemoryFailureDescription),
            message: .init(L10n.cdwTxtRcErrorMemoryFailureRecovery),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        // error: unknown failure
        static let unknownFailure: ErpAlertState<Action> = .init(
            title: .init(L10n.cdwTxtRcErrorUnknownFailureDescription),
            message: .init(L10n.cdwTxtRcErrorUnknownFailureRecovery),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        static let pukCounterExhaustedWithSetNewPin: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        static let pinCounterExhausted: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertPinCounterExhaustedTitle),
            message: .init(L10n.stgTxtCardResetRcAlertPinCounterExhaustedMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        // warning: retry counter
        static let pukIncorrectZeroRetriesLeft: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesTitle),
            message: .init(L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        static func pukIncorrect(retriesLeft: Int) -> ErpAlertState<Action> {
            if retriesLeft == 0 {
                return Self.pukIncorrectZeroRetriesLeft
            } else {
                return .init(
                    title: .init(L10n.stgTxtCardResetRcAlertWrongPukTitle),
                    message: .init(L10n.stgTxtCardResetRcAlertWrongPukMessage(retriesLeft)),
                    primaryButton: .default(
                        .init(L10n.stgBtnCardResetRcAlertAmend),
                        action: .send(.alertAmendPukButtonTapped)
                    ),
                    secondaryButton: .cancel(
                        .init(L10n.stgBtnCardResetRcAlertCancel),
                        action: .send(.alertCancelButtonTapped)
                    )
                )
            }
        }

        static func pinIncorrect(retriesLeft: Int) -> ErpAlertState<Action> {
            if retriesLeft == 0 {
                return Self.pinCounterExhausted
            } else {
                return .init(
                    title: .init(L10n.stgTxtCardResetRcAlertWrongPinTitle),
                    message: .init(L10n.stgTxtCardResetRcAlertWrongPinMessage(retriesLeft)),
                    primaryButton: .default(
                        .init(L10n.stgBtnCardResetRcAlertAmend),
                        action: .send(.alertAmendPinButtonTapped)
                    ),
                    secondaryButton: .cancel(
                        .init(L10n.stgBtnCardResetRcAlertCancel),
                        action: .send(.alertCancelButtonTapped)
                    )
                )
            }
        }

        // error: others
        static let wrongCan: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertWrongCanTitle),
            message: .init(L10n.stgTxtCardResetRcAlertWrongCanMessage),
            primaryButton: .default(
                .init(L10n.stgBtnCardResetRcAlertAmend),
                action: .send(.alertAmendCanButtonTapped)
            ),
            secondaryButton: .cancel(
                .init(L10n.stgBtnCardResetRcAlertCancel),
                action: .send(.alertCancelButtonTapped)
            )
        )

        static let unknownError: ErpAlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertUnknownErrorTitle),
            message: .init(L10n.stgTxtCardResetRcAlertUnknownErrorMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.alertOkButtonTapped)
            )
        )

        static func alertFor(_ error: NFCHealthCardPasswordControllerError) -> ErpAlertState<Action> {
            .init(for: error)
        }

        static func alertFor(_ error: CodedError) -> AlertState<Action> {
            .init(for: error)
        }
    }
}
