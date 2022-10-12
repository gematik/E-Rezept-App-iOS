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
        static let cardUnlocked: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCardUnlockedTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCardUnlockedMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        static let cardUnlockedWithSetNewPin: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCardUnlockedWithPinTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCardUnlockedWithPinMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        static let setNewPin: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCardSetNewPinTitle),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        // error: blocked
        static let pukCounterExhausted: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        static let pukCounterExhaustedWithSetNewPin: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinTitle),
            message: .init(L10n.stgTxtCardResetRcAlertCounterExhaustedWithPinMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        static let pinCounterExhausted: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertPinCounterExhaustedTitle),
            message: .init(L10n.stgTxtCardResetRcAlertPinCounterExhaustedMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        // warning: retry counter
        static let pukIncorrectZeroRetriesLeft: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesTitle),
            message: .init(L10n.stgTxtCardResetRcAlertWrongPukZeroRetriesMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        static func pukIncorrect(retriesLeft: Int) -> AlertState<Action> {
            if retriesLeft == 0 {
                return Self.pukIncorrectZeroRetriesLeft
            } else {
                return .init(
                    title: .init(L10n.stgTxtCardResetRcAlertWrongPukTitle),
                    message: .init(L10n.stgTxtCardResetRcAlertWrongPukMessage(retriesLeft)),
                    dismissButton: .default(
                        .init(L10n.stgBtnCardResetRcAlertOk),
                        action: .send(.okButtonTapped)
                    )
                )
            }
        }

        static func pinIncorrect(retriesLeft: Int) -> AlertState<Action> {
            if retriesLeft == 0 {
                return Self.pinCounterExhausted
            } else {
                return .init(
                    title: .init(L10n.stgTxtCardResetRcAlertWrongPinTitle),
                    message: .init(L10n.stgTxtCardResetRcAlertWrongPinMessage(retriesLeft)),
                    dismissButton: .default(
                        .init(L10n.stgBtnCardResetRcAlertOk),
                        action: .send(.okButtonTapped)
                    )
                )
            }
        }

        // error: others
        static let wrongCan: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertWrongCanTitle),
            message: .init(L10n.stgTxtCardResetRcAlertWrongCanMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        static let unknownError: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetRcAlertUnknownErrorTitle),
            message: .init(L10n.stgTxtCardResetRcAlertUnknownErrorMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetRcAlertOk),
                action: .send(.okButtonTapped)
            )
        )

        static func alertFor(_ error: NFCHealthCardPasswordControllerError) -> AlertState<Action> {
            AlertState(
                title: .init(L10n.stgTxtCardResetRcAlertUnknownErrorTitle),
                message: .init(error.localizedDescriptionWithErrorList),
                dismissButton: .default(TextState(L10n.cdwBtnRcAlertClose), action: .send(.setNavigation(tag: .none)))
            )
        }

        static func alertFor(_ error: CodedError) -> AlertState<Action> {
            AlertState(
                title: .init(error.localizedDescription),
                message: .init(error.recoverySuggestionWithErrorList),
                dismissButton: .default(TextState(L10n.cdwBtnRcAlertClose), action: .send(.setNavigation(tag: .none)))
            )
        }
    }
}
