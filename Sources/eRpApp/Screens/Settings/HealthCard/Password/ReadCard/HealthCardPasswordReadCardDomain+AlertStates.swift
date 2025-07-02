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

extension HealthCardPasswordReadCardDomain {
    enum AlertStates {
        // success
        static let cardUnlocked: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCardUnlockedTitle,
            actions: {
                ButtonState(action: .send(.settings)) {
                    TextState(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCardUnlockedMessage
        )

        static let cardUnlockedWithSetNewPin: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCardUnlockedWithPinTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCardUnlockedWithPinMessage
        )

        static let setNewPin: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCardSetNewPinTitle
        ) {
            ButtonState(action: .settings) {
                .init(L10n.stgBtnCardResetRcAlertOk)
            }
        }

        // error: blocked
        static let pukCounterExhausted: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCounterExhaustedTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCounterExhaustedMessage
        )

        // error: password not found
        static let passwordNotFound: ErpAlertState<Destination.Alert> = .init(
            title: L10n.cdwTxtRcErrorPasswordMissingDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorPasswordMissingRecovery
        )

        // error: security status not satisfied
        static let securityStatusNotSatisfied: ErpAlertState<Destination.Alert> = .init(
            title: L10n.cdwTxtRcErrorSecStatusDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorSecStatusRecovery
        )

        // error: memory failure
        static let memoryFailure: ErpAlertState<Destination.Alert> = .init(
            title: L10n.cdwTxtRcErrorMemoryFailureDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorMemoryFailureRecovery
        )

        // error: unknown failure
        static let unknownFailure: ErpAlertState<Destination.Alert> = .init(
            title: L10n.cdwTxtRcErrorUnknownFailureDescription,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.cdwTxtRcErrorUnknownFailureRecovery
        )

        static let pukCounterExhaustedWithSetNewPin: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinMessage
        )

        static let pinCounterExhausted: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertPinCounterExhaustedTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertPinCounterExhaustedMessage
        )

        // warning: retry counter
        static let pukIncorrectZeroRetriesLeft: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesTitle,
            actions: {
                ButtonState(action: .settings) {
                    .init(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesMessage
        )

        static func pukIncorrect(retriesLeft: Int) -> ErpAlertState<Destination.Alert> {
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
                            ButtonState(role: .cancel) {
                                .init(L10n.stgBtnCardResetRcAlertCancel)
                            }
                        },
                        message: L10n.stgTxtCardResetRcAlertWrongPukMessage(retriesLeft)
                    )
            }
        }

        static func pinIncorrect(retriesLeft: Int) -> ErpAlertState<Destination.Alert> {
            if retriesLeft == 0 {
                return Self.pinCounterExhausted
            } else {
                return .init(
                    title: L10n.stgTxtCardResetRcAlertWrongPinTitle,
                    actions: {
                        ButtonState(action: .amendPin) {
                            .init(L10n.stgBtnCardResetRcAlertAmend)
                        }
                        ButtonState(role: .cancel) {
                            .init(L10n.stgBtnCardResetRcAlertCancel)
                        }
                    },
                    message: L10n.stgTxtCardResetRcAlertWrongPinMessage(retriesLeft)
                )
            }
        }

        // error: others
        static let wrongCan: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertWrongCanTitle,
            actions: {
                ButtonState(action: .amendCan) {
                    .init(L10n.stgBtnCardResetRcAlertAmend)
                }
                ButtonState(role: .cancel) {
                    .init(L10n.stgBtnCardResetRcAlertCancel)
                }
            },
            message: L10n.stgTxtCardResetRcAlertWrongCanMessage
        )

        static let unknownError: ErpAlertState<Destination.Alert> = .init(
            title: L10n.stgTxtCardResetRcAlertUnknownErrorTitle,
            actions: {
                ButtonState(action: .send(.settings)) {
                    TextState(L10n.stgBtnCardResetRcAlertOk)
                }
            },
            message: L10n.stgTxtCardResetRcAlertUnknownErrorMessage
        )

        static func alertFor(_ error: NFCHealthCardPasswordControllerError)
            -> ErpAlertState<Destination.Alert> {
            .init(for: error)
        }

        static func alertFor(_ error: CodedError) -> AlertState<Destination.Alert> {
            .init(for: error)
        }
    }
}
