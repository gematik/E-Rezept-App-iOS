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
import Helper
import NFCCardReaderProvider

// swiftlint:disable trailing_closure
extension CardWallReadCardDomain {
    enum AlertStates {
        typealias Action = CardWallReadCardDomain.Destination.Alert
        typealias Error = CardWallReadCardDomain.State.Error

        static var saveProfile: ErpAlertState<Action> = .info(
            AlertState(
                title: { TextState(L10n.cdwTxtRcAlertTitleSaveProfile) },
                actions: {
                    ButtonState(role: .cancel, action: .send(.none)) {
                        TextState(L10n.cdwBtnRcAlertSaveProfile)
                    }
                },
                message: { TextState(L10n.cdwTxtRcAlertMessageSaveProfile) }
            )
        )

        static func wrongCAN(_ error: State.Error) -> ErpAlertState<Action> {
            .init(for: error, actions: {
                ButtonState(action: .wrongCAN) {
                    .init(L10n.cdwBtnRcCorrectCan)
                }
            })
        }

        static var tagConnectionLostCount = 0
        static func tagConnectionLost(_ error: CoreNFCError) -> ErpAlertState<Action> {
            Self.tagConnectionLostCount += 1
            if tagConnectionLostCount <= 3 {
                return .init(for: error, actions: {
                    ButtonState(action: .openHelpView) {
                        .init(L10n.cdwBtnRcHelp)
                    }
                    ButtonState(role: .cancel, action: .signChallenge) {
                        .init(L10n.cdwBtnRcRetry)
                    }
                })
            } else {
                let report = createNfcReadingReport(with: error, commands: CommandLogger.commands)
                return .init(for: error, actions: {
                    ButtonState(action: .openMail(report)) {
                        .init(L10n.cdwBtnRcAlertReport)
                    }
                    ButtonState(role: .cancel, action: .signChallenge) {
                        .init(L10n.cdwBtnRcRetry)
                    }
                })
            }
        }

        static func wrongPIN(_ error: Error) -> ErpAlertState<Action> {
            .init(for: error, actions: {
                ButtonState(action: .wrongPIN) {
                    .init(L10n.cdwBtnRcCorrectPin)
                }
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.cdwBtnRcAlertCancel)
                }
            })
        }

        static func alertFor(_ error: CodedError) -> ErpAlertState<Action> {
            .init(for: error, actions: {
                ButtonState(action: .dismiss) {
                    .init(L10n.cdwBtnRcAlertClose)
                }
            })
        }

        static func alertBlockedCard(_ error: CodedError) -> ErpAlertState<Action> {
            .init(for: error, actions: {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.cdwBtnRcAlertClose)
                }
                ButtonState(action: .unlockCard) {
                    .init(L10n.cdwBtnRcAlertUnlockcard)
                }
            })
        }

        static func alertWithReportButton(error: CodedError) -> ErpAlertState<Action> {
            let report = createNfcReadingReport(with: error, commands: CommandLogger.commands)
            return .init(for: error, actions: {
                ButtonState(action: .openMail(report)) {
                    .init(L10n.cdwBtnRcAlertReport)
                }
                ButtonState(role: .cancel, action: .signChallenge) {
                    .init(L10n.cdwBtnRcRetry)
                }
            })
        }

        static func alert(for tagError: CoreNFCError) -> ErpAlertState<Action>? {
            switch tagError {
            case .tagConnectionLost:
                return CardWallReadCardDomain.AlertStates.tagConnectionLost(tagError)
            case .sessionTimeout, .sessionInvalidated, .other, .unknown:
                return CardWallReadCardDomain.AlertStates.alertWithReportButton(error: tagError)
            case .unsupportedFeature:
                return CardWallReadCardDomain.AlertStates.alertFor(tagError)
            default: return nil
            }
        }
    }
}

// swiftlint:enable trailing_closure
