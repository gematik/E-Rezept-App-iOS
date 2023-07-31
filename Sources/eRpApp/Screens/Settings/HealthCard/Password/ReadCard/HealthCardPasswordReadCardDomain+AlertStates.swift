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

extension HealthCardPasswordReadCardDomain {
    enum AlertStates {
        typealias Action = HealthCardPasswordReadCardDomain.Action

        // success
        static let cardUnlocked: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertCardUnlockedTitle,
            actions: {
                .default(
                    .init(L10n.stgBtnCardResetRcAlertOk),
                    action: .send(.alertOkButtonTapped)
                )
            },
            message: L10n.stgTxtCardResetRcAlertCardUnlockedMessage
        )

        static let cardUnlockedWithSetNewPin: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertCardUnlockedWithPinTitle,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCardUnlockedWithPinMessage
        )

        static let setNewPin: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertCardSetNewPinTitle
        ) {
            ButtonState(action: .alertOkButtonTapped) {
                .init(L10n.stgBtnCardResetRcAlertOk)
            }
        }

        // error: blocked
        static let pukCounterExhausted: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertCounterExhaustedTitle,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCounterExhaustedMessage
        )

        // error: password not found
        static let passwordNotFound: ErpAlertState<Action> = .init(
            title: L10n.cdwTxtRcErrorPasswordMissingDescription,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorPasswordMissingRecovery
        )

        // error: security status not satisfied
        static let securityStatusNotSatisfied: ErpAlertState<Action> = .init(
            title: L10n.cdwTxtRcErrorSecStatusDescription,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorSecStatusRecovery
        )

        // error: memory failure
        static let memoryFailure: ErpAlertState<Action> = .init(
            title: L10n.cdwTxtRcErrorMemoryFailureDescription,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorMemoryFailureRecovery
        )

        // error: unknown failure
        static let unknownFailure: ErpAlertState<Action> = .init(
            title: L10n.cdwTxtRcErrorUnknownFailureDescription,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorUnknownFailureRecovery
        )

        static let pukCounterExhaustedWithSetNewPin: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinTitle,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinMessage
        )

        static let pinCounterExhausted: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertPinCounterExhaustedTitle,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertPinCounterExhaustedMessage
        )

        // warning: retry counter
        static let pukIncorrectZeroRetriesLeft: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesTitle,
            actions: {
                ButtonState(action: .alertOkButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesMessage
        )

        static func pukIncorrect(retriesLeft: Int) -> ErpAlertState<Action> {
            if retriesLeft == 0 {
                return Self.pukIncorrectZeroRetriesLeft
            } else {
                return
                    .init(
                        title: L10n.stgTxtCardResetRcAlertWrongPukTitle,
                        actions: {
                            ButtonState(action: .alertAmendPukButtonTapped) {
                                .init(L10n.stgBtnCardResetRcAlertAmend)
                            }
                            ButtonState(role: .cancel, action: .alertCancelButtonTapped) {
                                .init(L10n.stgBtnCardResetRcAlertCancel)
                            }
                        },
                        message: L10n.stgTxtCardResetRcAlertWrongPukMessage(retriesLeft)
                    )
            }
        }

        static func pinIncorrect(retriesLeft: Int) -> ErpAlertState<Action> {
            if retriesLeft == 0 {
                return Self.pinCounterExhausted
            } else {
                return .init(
                    title: L10n.stgTxtCardResetRcAlertWrongPinTitle,
                    actions: {
                        ButtonState(action: .alertAmendPinButtonTapped) {
                            .init(L10n.stgBtnCardResetRcAlertAmend)
                        }
                        ButtonState(role: .cancel, action: .alertCancelButtonTapped) {
                            .init(L10n.stgBtnCardResetRcAlertCancel)
                        }
                    },
                    message: L10n.stgTxtCardResetRcAlertWrongPinMessage(retriesLeft)
                )
            }
        }

        // error: others
        static let wrongCan: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertWrongCanTitle,
            actions: {
                ButtonState(action: .alertAmendCanButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertAmend)
                }
                ButtonState(role: .cancel, action: .alertCancelButtonTapped) {
                    .init(L10n.stgBtnCardResetRcAlertCancel)
                }
            },
            message: L10n.stgTxtCardResetRcAlertWrongCanMessage
        )

        static let unknownError: ErpAlertState<Action> = .init(
            title: L10n.stgTxtCardResetRcAlertUnknownErrorTitle,
            actions: {
                .default(
                    .init(L10n.stgBtnCardResetRcAlertOk),
                    action: .send(.alertOkButtonTapped)
                )
            },
            message: L10n.stgTxtCardResetRcAlertUnknownErrorMessage
        )

        static func alertFor(_ error: NFCHealthCardPasswordControllerError) -> ErpAlertState<Action> {
            .init(for: error)
        }

        static func alertFor(_ error: CodedError) -> AlertState<Action> {
            .init(for: error)
        }
    }
}
