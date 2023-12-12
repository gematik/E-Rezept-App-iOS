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
        static let cardUnlocked: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCardUnlockedTitle,
            actions: {
                .default(
                    .init(L10n.stgBtnCardResetRcAlertOk),
                    action: .send(.settings)
                )
            },
            message: L10n.stgTxtCardResetRcAlertCardUnlockedMessage
        )

        static let cardUnlockedWithSetNewPin: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCardUnlockedWithPinTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCardUnlockedWithPinMessage
        )

        static let setNewPin: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCardSetNewPinTitle
        ) {
            ButtonState(action: .settings) {
                .init(L10n.stgBtnCardResetRcAlertOk)
            }
        }

        // error: blocked
        static let pukCounterExhausted: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCounterExhaustedTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCounterExhaustedMessage
        )

        // error: password not found
        static let passwordNotFound: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.cdwTxtRcErrorPasswordMissingDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorPasswordMissingRecovery
        )

        // error: security status not satisfied
        static let securityStatusNotSatisfied: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.cdwTxtRcErrorSecStatusDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorSecStatusRecovery
        )

        // error: memory failure
        static let memoryFailure: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.cdwTxtRcErrorMemoryFailureDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorMemoryFailureRecovery
        )

        // error: unknown failure
        static let unknownFailure: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.cdwTxtRcErrorUnknownFailureDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorUnknownFailureRecovery
        )

        static let pukCounterExhaustedWithSetNewPin: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinMessage
        )

        static let pinCounterExhausted: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertPinCounterExhaustedTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertPinCounterExhaustedMessage
        )

        // warning: retry counter
        static let pukIncorrectZeroRetriesLeft: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesMessage
        )

        static func pukIncorrect(retriesLeft: Int) -> ErpAlertState<Destinations.Action.Alert> {
            if retriesLeft == 0 {
                return Self.pukIncorrectZeroRetriesLeft
            } else {
                return
                    .init(
                        title: L10n.stgTxtCardResetRcAlertWrongPukTitle,
                        actions: {
                            ButtonState(action: .amendPuk) {
                                .init(L10n.stgBtnCardResetRcAlertAmend)
                            }
                            ButtonState(role: .cancel, action: .dismiss) {
                                .init(L10n.stgBtnCardResetRcAlertCancel)
                            }
                        },
                        message: L10n.stgTxtCardResetRcAlertWrongPukMessage(retriesLeft)
                    )
            }
        }

        static func pinIncorrect(retriesLeft: Int) -> ErpAlertState<Destinations.Action.Alert> {
            if retriesLeft == 0 {
                return Self.pinCounterExhausted
            } else {
                return .init(
                    title: L10n.stgTxtCardResetRcAlertWrongPinTitle,
                    actions: {
                        ButtonState(action: .amendPin) {
                            .init(L10n.stgBtnCardResetRcAlertAmend)
                        }
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.stgBtnCardResetRcAlertCancel)
                        }
                    },
                    message: L10n.stgTxtCardResetRcAlertWrongPinMessage(retriesLeft)
                )
            }
        }

        // error: others
        static let wrongCan: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertWrongCanTitle,
            actions: {
                ButtonState(action: .amendCan) {
                    .init(L10n.stgBtnCardResetRcAlertAmend)
                }
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.stgBtnCardResetRcAlertCancel)
                }
            },
            message: L10n.stgTxtCardResetRcAlertWrongCanMessage
        )

        static let unknownError: ErpAlertState<Destinations.Action.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertUnknownErrorTitle,
            actions: {
                .default(
                    .init(L10n.stgBtnCardResetRcAlertOk),
                    action: .send(.settings)
                )
            },
            message: L10n.stgTxtCardResetRcAlertUnknownErrorMessage
        )

        static func alertFor(_ error: NFCHealthCardPasswordControllerError)
            -> ErpAlertState<Destinations.Action.Alert> {
            .init(for: error)
        }

        static func alertFor(_ error: CodedError) -> AlertState<Destinations.Action.Alert> {
            .init(for: error)
        }
    }
}
