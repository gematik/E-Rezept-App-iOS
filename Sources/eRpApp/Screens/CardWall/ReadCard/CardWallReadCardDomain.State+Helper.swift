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
import IDP
import SwiftUI

extension CardWallReadCardDomain.State {
    // sourcery: CodedError = "010"
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        /// `IDPError` thrown within the `CardWallReadCardDomain`
        case idpError(IDPError)
        // sourcery: errorCode = "02"
        /// Possible user input errors thrown within the `CardWallReadCardDomain`
        case inputError(InputError)
        // sourcery: errorCode = "03"
        /// NFC signature errors thrown within the `CardWallReadCardDomain`
        case signChallengeError(NFCSignatureProviderError)
        // sourcery: errorCode = "04"
        /// Error that can occur during authentication with biometry
        case biometrieError(Swift.Error)
        // sourcery: errorCode = "05"
        /// Error when `Profile` validation with the given authentication fails.
        /// Error is produces within the `IDPError.unspecified` error before saving the IDPToken
        case profileValidation(IDTokenValidatorError)

        // sourcery: CodedError = "011"
        /// User input error
        enum InputError: Swift.Error {
            // sourcery: errorCode = "01"
            /// User input for PIN is incorrect
            case missingPIN
            // sourcery: errorCode = "02"
            /// User input for CAN is incorrect
            case missingCAN
        }

        static func ==(lhs: CardWallReadCardDomain.State.Error, rhs: CardWallReadCardDomain.State.Error) -> Bool {
            switch (lhs, rhs) {
            case let (.idpError(lhsError), .idpError(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case let (.inputError(lhsError), .inputError(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case let (.signChallengeError(lhsError), .signChallengeError(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case let (.biometrieError(lhsError), .biometrieError(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case let (.profileValidation(lhsError), .profileValidation(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }

    enum Output: Equatable {
        case idle
        case retrievingChallenge(StepState)
        case challengeLoaded(IDPChallengeSession)
        case signingChallenge(StepState)
        case verifying(StepState)
        case loggedIn(IDPToken)

        var nextAction: CardWallReadCardDomain.Action {
            if case .loggedIn = self {
                return .close
            }
            // Pop to correct screen if we have a card error a.k.a. wrong pin or wrong can
            if case let .signingChallenge(signingState) = self,
               case let .error(error) = signingState {
                switch error {
                case .signChallengeError(.wrongPin(0)):
                    return .close // TODO: call action for correcting pin here // swiftlint:disable:this todo
                case .signChallengeError(.wrongPin),
                     .inputError(.missingPIN):
                    return .wrongPIN
                case .signChallengeError(.wrongCAN),
                     .inputError(.missingCAN):
                    return .wrongCAN
                default: break
                }
            }
            if case let .challengeLoaded(challenge) = self {
                return .signChallenge(challenge)
            }
            return .getChallenge
        }

        var buttonTitle: LocalizedStringKey {
            switch self {
            case .loggedIn,
                 .signingChallenge(.error(.signChallengeError(.wrongPin(0)))):
                return L10n.cdwBtnRcClose.key
            case .signingChallenge(.error(.inputError(.missingCAN))),
                 .signingChallenge(.error(.signChallengeError(.wrongCAN))):
                return L10n.cdwBtnRcCorrectCan.key
            case .signingChallenge(.error(.inputError(.missingPIN))),
                 .signingChallenge(.error(.signChallengeError(.wrongPin))):
                return L10n.cdwBtnRcCorrectPin.key
            case .retrievingChallenge(.error), .signingChallenge(.error), .verifying(.error):
                return L10n.cdwBtnRcRetry.key
            case .retrievingChallenge(.loading), .signingChallenge(.loading), .verifying(.loading):
                return L10n.cdwBtnRcLoading.key
            default:
                return L10n.cdwBtnRcNext.key
            }
        }

        var nextButtonEnabled: Bool {
            switch self {
            case .idle, // Continue with process
                 .challengeLoaded:
                return true
            case .signingChallenge(.error(.inputError(.missingCAN))),
                 .signingChallenge(.error(.inputError(.missingPIN))),
                 .signingChallenge(.error(.signChallengeError(.wrongCAN))),
                 .signingChallenge(.error(.signChallengeError(.wrongPin))):
                return true
            case .retrievingChallenge(.error), // enable button for retry
                 .verifying(.error),
                 .signingChallenge(.error):
                return true
            case .loggedIn:
                return true // close button
            case .retrievingChallenge(.loading),
                 .signingChallenge(.loading),
                 .verifying(.loading):
                return false
            }
        }

        enum StepState: Equatable {
            // swiftlint:disable:next operator_whitespace
            static func ==(
                lhs: CardWallReadCardDomain.State.Output.StepState,
                rhs: CardWallReadCardDomain.State.Output.StepState
            ) -> Bool {
                switch (lhs, rhs) {
                case (.loading, .loading): return true
                case let (.error(lhsError), .error(rhsError)):
                    return lhsError == rhsError
                default:
                    return false
                }
            }

            case loading
            case error(Error)
        }
    }
}

extension CardWallReadCardDomain.State.Error: CustomStringConvertible, LocalizedError {
    var description: String {
        switch self {
        case let .idpError(error):
            return "idpError: \(error.localizedDescription)"
        case let .signChallengeError(error):
            return "cardError: \(error.localizedDescription)"
        case let .inputError(error):
            return error.localizedDescription
        case let .biometrieError(error as LocalizedError):
            return error.localizedDescription
        case let .biometrieError(error):
            return "biometrie error \(error)"
        case let .profileValidation(error):
            return "validation error: \(error.localizedDescription)"
        }
    }

    var errorDescription: String? {
        switch self {
        case let .idpError(error):
            return error.localizedDescription
        case let .signChallengeError(error):
            return error.localizedDescription
        case let .inputError(error):
            return error.localizedDescription
        case let .biometrieError(error as LocalizedError):
            return error.localizedDescription
        case let .biometrieError(error):
            return "biometrie error \(error)"
        case let .profileValidation(error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .idpError(error as LocalizedError),
             let .signChallengeError(error as LocalizedError),
             let .inputError(error as LocalizedError),
             let .biometrieError(error as LocalizedError),
             let .profileValidation(error as LocalizedError):
            return error.recoverySuggestion
        case let .biometrieError(error):
            return "biometrie error \(error)"
        }
    }
}

// TODO: localization for keys is missing   swiftlint:disable:this todo
extension CardWallReadCardDomain.State.Error.InputError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingCAN:
            return NSLocalizedString("cdw_btn_rc_error_missing_can_error_description", comment: "")
        case .missingPIN:
            return NSLocalizedString("cdw_btn_rc_error_missing_pin_error_description", comment: "")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingCAN:
            return NSLocalizedString("cdw_btn_rc_error_missing_can_recovery_suggestion", comment: "")
        case .missingPIN:
            return NSLocalizedString("cdw_btn_rc_error_missing_pin_recovery_suggestion", comment: "")
        }
    }
}
