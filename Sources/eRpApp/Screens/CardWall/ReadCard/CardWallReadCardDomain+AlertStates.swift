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
import Helper
import NFCCardReaderProvider

extension CardWallReadCardDomain {
    enum AlertStates {
        typealias Action = CardWallReadCardDomain.Action
        typealias Error = CardWallReadCardDomain.State.Error

        static var saveProfile: ErpAlertState<Action> = .info(
            AlertState(
                title: TextState(L10n.cdwTxtRcAlertTitleSaveProfile),
                message: TextState(L10n.cdwTxtRcAlertMessageSaveProfile),
                dismissButton: .cancel(TextState(L10n.cdwBtnRcAlertSaveProfile))
            )
        )

        static func wrongCAN(_ error: State.Error) -> ErpAlertState<Action> {
            ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcCorrectCan), action: .send(.delegate(.wrongCAN)))
            )
        }

        static var tagConnectionLostCount = 0
        static func tagConnectionLost(_ error: CoreNFCError) -> ErpAlertState<Action> {
            Self.tagConnectionLostCount += 1
            if tagConnectionLostCount <= 3 {
                return ErpAlertState(
                    for: error,
                    primaryButton: .default(TextState(L10n.cdwBtnRcHelp), action: .send(.openHelpViewScreen)),
                    secondaryButton: .cancel(.init(L10n.cdwBtnRcRetry), action: .send(.getChallenge))
                )
            } else {
                let report = createNfcReadingReport(with: error, commands: CommandLogger.commands)
                return ErpAlertState(
                    for: error,
                    primaryButton: .default(TextState(L10n.cdwBtnRcAlertReport), action: .send(.openMail(report))),
                    secondaryButton: .cancel(.init(L10n.cdwBtnRcRetry), action: .send(.getChallenge))
                )
            }
        }

        static func wrongPIN(_ error: Error) -> ErpAlertState<Action> {
            ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcCorrectPin), action: .send(.delegate(.wrongPIN))),
                secondaryButton: .cancel(TextState(L10n.cdwBtnRcAlertCancel), action: .send(.setNavigation(tag: .none)))
            )
        }

        static func alertFor(_ error: CodedError) -> ErpAlertState<Action> {
            ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcAlertClose), action: .send(.setNavigation(tag: .none)))
            )
        }

        static func alertWithReportButton(error: CodedError) -> ErpAlertState<Action> {
            let report = createNfcReadingReport(with: error, commands: CommandLogger.commands)
            return ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcAlertReport), action: .send(.openMail(report))),
                secondaryButton: .cancel(.init(L10n.cdwBtnRcRetry), action: .send(.getChallenge))
            )
        }

        static func alert(for tagError: CoreNFCError) -> ErpAlertState<CardWallReadCardDomain.Action>? {
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
