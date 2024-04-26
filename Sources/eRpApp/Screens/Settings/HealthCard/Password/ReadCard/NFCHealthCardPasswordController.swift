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

import Combine
import CombineSchedulers
import CoreNFC
import Dependencies
import HealthCardControl
import NFCCardReaderProvider

protocol NFCHealthCardPasswordController {
    func resetEgkMrPinRetryCounter(
        can: String,
        puk: String,
        mode: NFCResetRetryCounterMode
    ) async -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>

    func changeReferenceData(
        can: String,
        old: String,
        new: String,
        mode: NFCChangeReferenceDataMode
    ) async -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>
}

enum NFCResetRetryCounterMode: Equatable {
    case resetEgkMrPinRetryCountWithoutNewSecret
    case resetEgkMrPinRetryCountWithNewSecret(String)
}

enum NFCChangeReferenceDataMode: Equatable {
    case changeEgkMrPinSecret
}

enum NFCHealthCardPasswordControllerResponse: Equatable {
    case success
    case wrongSecretWarning(retryCount: Int)
    case securityStatusNotSatisfied
    case memoryFailure
    case commandBlocked
    case wrongPasswordLength
    case passwordNotFound
    case unknownFailure

    static func from(resetRetryCounterResponse: ResetRetryCounterResponse) -> Self {
        switch resetRetryCounterResponse {
        case .success: return .success
        case let .wrongSecretWarning(retryCount: retryCount): return .wrongSecretWarning(retryCount: retryCount)
        case .securityStatusNotSatisfied: return .securityStatusNotSatisfied
        case .memoryFailure: return .memoryFailure
        case .commandBlocked: return .commandBlocked
        case .wrongPasswordLength: return .wrongPasswordLength
        case .passwordNotFound: return .passwordNotFound
        case .unknownFailure: return .unknownFailure
        }
    }

    static func from(changeReferenceDataResponse: ChangeReferenceDataResponse) -> Self {
        switch changeReferenceDataResponse {
        case .success: return .success
        case let .wrongSecretWarning(retryCount: retryCount): return .wrongSecretWarning(retryCount: retryCount)
        case .securityStatusNotSatisfied: return .securityStatusNotSatisfied
        case .memoryFailure: return .memoryFailure
        case .commandBlocked: return .commandBlocked
        case .wrongPasswordLength: return .wrongPasswordLength
        case .passwordNotFound: return .passwordNotFound
        case .unknownFailure: return .unknownFailure
        }
    }
}

// sourcery: CodedError = "026"
enum NFCHealthCardPasswordControllerError: Swift.Error {
    // sourcery: errorCode = "01"
    case cardError(NFCTagReaderSession.Error)
    // sourcery: errorCode = "02"
    case openSecureSession(Swift.Error)
    // sourcery: errorCode = "03"
    case resetRetryCounter(Swift.Error)
    // sourcery: errorCode = "04"
    case wrongCan
    // sourcery: errorCode = "05"
    case changeReferenceData(Swift.Error)
    // sourcery: errorCode = "06"
    case couldNotInitializeSession
    // sourcery: errorCode = "07"
    /// Any error regarding the communication with the NFC health card itself
    /// or sending/receiving data (operation execution)
    case nfcHealthCardSession(NFCHealthCardSessionError)
}

struct DefaultNFCResetRetryCounterController: NFCHealthCardPasswordController {
    // swiftlint:disable:next function_body_length
    func resetEgkMrPinRetryCounter(
        can: String,
        puk: String,
        mode: NFCResetRetryCounterMode
    ) async
        -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        guard let nfcHealthCardSession = NFCHealthCardSession(
            messages: .defaultMessages,
            can: can,
            operation: { session in
                session.updateAlert(message: mode.nfcDialogStartUnlockCardMessage)
                let resetRetryCounterResponse: ResetRetryCounterResponse
                switch mode {
                case .resetEgkMrPinRetryCountWithoutNewSecret:
                    do {
                        resetRetryCounterResponse = try await session.card.resetRetryCounter(
                            puk: puk,
                            affectedPassWord: .mrPinHomeNoDfSpecific
                        )
                    } catch {
                        return .failure(.resetRetryCounter(error))
                    }
                case let .resetEgkMrPinRetryCountWithNewSecret(newPin):
                    do {
                        resetRetryCounterResponse = try await session.card.resetRetryCounterAndSetNewPinAsync(
                            puk: puk,
                            newPin: newPin,
                            affectedPassWord: .mrPinHomeNoDfSpecific
                        )
                    } catch {
                        return .failure(.resetRetryCounter(error))
                    }
                }

                let nfcHealthCardPasswordControllerResponse = NFCHealthCardPasswordControllerResponse
                    .from(resetRetryCounterResponse:
                        resetRetryCounterResponse)
                return .success(nfcHealthCardPasswordControllerResponse)
            }
        )
        else {
            return .failure(.couldNotInitializeSession)
        }

        let nfcHealthCardPasswordControllerResponse: Result<
            NFCHealthCardPasswordControllerResponse,
            NFCHealthCardPasswordControllerError
        >
        do {
            nfcHealthCardPasswordControllerResponse = try await nfcHealthCardSession.executeOperation()
        } catch let error as NFCHealthCardSessionError {
            let nfcHealthCardPasswordControllerError: NFCHealthCardPasswordControllerError
            if case .wrongCAN = error {
                nfcHealthCardPasswordControllerError = .wrongCan
            } else {
                nfcHealthCardPasswordControllerError = .nfcHealthCardSession(error)
            }
            nfcHealthCardPasswordControllerResponse = .failure(nfcHealthCardPasswordControllerError)
        } catch {
            nfcHealthCardPasswordControllerResponse = .failure(.resetRetryCounter(error))
        }

        if case .success(.success) = nfcHealthCardPasswordControllerResponse {
            nfcHealthCardSession.invalidateSession(with: nil)
        } else {
            nfcHealthCardSession.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
        }

        return nfcHealthCardPasswordControllerResponse
    }

    func changeReferenceData(
        can: String,
        old: String,
        new: String,
        mode: NFCChangeReferenceDataMode
    ) async -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        guard let nfcHealthCardSession = NFCHealthCardSession(
            messages: .defaultMessages,
            can: can,
            operation: { session in
                session.updateAlert(message: mode.nfcDialogStartChangeReferenceDataMessage)
                switch mode {
                case .changeEgkMrPinSecret:
                    do {
                        let changeReferenceDataResponse = try await session.card.changeReferenceDataSetNewPin(
                            old: old,
                            new: new,
                            affectedPassword: .mrPinHomeNoDfSpecific
                        )
                        let nfcHealthCardPasswordControllerResponse = NFCHealthCardPasswordControllerResponse
                            .from(changeReferenceDataResponse: changeReferenceDataResponse)
                        return .success(nfcHealthCardPasswordControllerResponse)
                    } catch {
                        let error = NFCHealthCardPasswordControllerError.changeReferenceData(error)
                        return .failure(error)
                    }
                }
            }
        )
        else {
            return .failure(.couldNotInitializeSession)
        }

        let nfcHealthCardPasswordControllerResponse: Result<
            NFCHealthCardPasswordControllerResponse,
            NFCHealthCardPasswordControllerError
        >
        do {
            nfcHealthCardPasswordControllerResponse = try await nfcHealthCardSession.executeOperation()
        } catch let error as NFCHealthCardSessionError {
            let nfcHealthCardPasswordControllerError: NFCHealthCardPasswordControllerError
            if case .wrongCAN = error {
                nfcHealthCardPasswordControllerError = .wrongCan
            } else {
                nfcHealthCardPasswordControllerError = .nfcHealthCardSession(error)
            }
            nfcHealthCardPasswordControllerResponse = .failure(nfcHealthCardPasswordControllerError)
        } catch {
            nfcHealthCardPasswordControllerResponse = .failure(.resetRetryCounter(error))
        }

        if case .success(.success) = nfcHealthCardPasswordControllerResponse {
            nfcHealthCardSession.invalidateSession(with: nil)
        } else {
            nfcHealthCardSession.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
        }

        return nfcHealthCardPasswordControllerResponse
    }
}

extension NFCResetRetryCounterMode {
    var nfcDialogStartUnlockCardMessage: String {
        switch self {
        case .resetEgkMrPinRetryCountWithoutNewSecret: return L10n.stgTxtCardResetRcNfcDialogUnlockCard.text
        case .resetEgkMrPinRetryCountWithNewSecret: return L10n.stgTxtCardResetRcNfcDialogUnlockCardWithPin.text
        }
    }
}

extension NFCChangeReferenceDataMode {
    var nfcDialogStartChangeReferenceDataMessage: String {
        switch self {
        case .changeEgkMrPinSecret: return L10n.stgTxtCardResetRcNfcDialogChangeReferenceData.text
        }
    }
}

extension NFCHealthCardSession<
    Result<
        NFCHealthCardPasswordControllerResponse,
        NFCHealthCardPasswordControllerError
    >
>.Messages {
    static let defaultMessages: Self = .init(
        discoveryMessage: L10n.cdwTxtRcNfcMessageDiscoveryMessage.text,
        connectMessage: L10n.cdwTxtRcNfcMessageConnectMessage.text,
        secureChannelMessage: L10n.cdwTxtRcNfcDialogOpenPace.text,
        noCardMessage: L10n.cdwTxtRcNfcMessageNoCardMessage.text,
        multipleCardsMessage: L10n.cdwTxtRcNfcMessageMultipleCardsMessage.text,
        unsupportedCardMessage: L10n.cdwTxtRcNfcMessageUnsupportedCardMessage.text,
        connectionErrorMessage: L10n.cdwTxtRcNfcMessageConnectionErrorMessage.text
    )
}

extension NFCHealthCardPasswordControllerError: Equatable {
    public static func ==(lhs: NFCHealthCardPasswordControllerError,
                          rhs: NFCHealthCardPasswordControllerError) -> Bool {
        switch (lhs, rhs) {
        case let (.cardError(lhsError), .cardError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.openSecureSession(lhsError), .openSecureSession(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.resetRetryCounter(lhsError), .resetRetryCounter(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.changeReferenceData(lhsError), .changeReferenceData(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.wrongCan, .wrongCan):
            return true
        case (.couldNotInitializeSession, .couldNotInitializeSession):
            return true
        case let (.nfcHealthCardSession(lhsError), .nfcHealthCardSession(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

extension NFCHealthCardPasswordControllerError: CustomStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case let .cardError(error):
            return "cardError: \(error.localizedDescription)"
        case let .openSecureSession(error):
            return "openSecureSessionError: \(error.localizedDescription)"
        case let .resetRetryCounter(error):
            return "resetRetryCounterError: \(error.localizedDescription)"
        case .wrongCan:
            return "wrongCANError"
        case let .changeReferenceData(error):
            return "changeReferenceDataError: \(error.localizedDescription)"
        case .couldNotInitializeSession:
            return "couldNotInitializeSession"
        case let .nfcHealthCardSession(error):
            return "nfcHealthCardSession: \(error.localizedDescription)"
        }
    }

    var errorDescription: String? {
        switch self {
        case let .cardError(error):
            return error.localizedDescription
        case let .openSecureSession(error):
            return error.localizedDescription
        case let .resetRetryCounter(error):
            return error.localizedDescription
        case .wrongCan:
            return nil
        case let .changeReferenceData(error):
            return error.localizedDescription
        case .couldNotInitializeSession:
            return nil
        case let .nfcHealthCardSession(error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .cardError(error as LocalizedError),
             let .openSecureSession(error as LocalizedError),
             let .resetRetryCounter(error as LocalizedError),
             let .changeReferenceData(error as LocalizedError),
             let .nfcHealthCardSession(error as LocalizedError):
            return error.recoverySuggestion
        case .resetRetryCounter, .openSecureSession, .wrongCan, .changeReferenceData, .couldNotInitializeSession,
             .nfcHealthCardSession:
            return nil
        }
    }
}

struct DummyNFCHealthCardPasswordController: NFCHealthCardPasswordController {
    func resetEgkMrPinRetryCounter(can _: String, puk _: String, mode _: NFCResetRetryCounterMode) async
        -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        .success(.success)
    }

    func changeReferenceData(can _: String, old _: String, new _: String, mode _: NFCChangeReferenceDataMode) async
        -> Result<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        .success(.success)
    }
}

// MARK: TCA Dependency

// swiftlint:disable:next type_name
struct NFCHealthCardPasswordControllerDependency: DependencyKey {
    static let liveValue: NFCHealthCardPasswordController =
        DefaultNFCResetRetryCounterController()

    static let previewValue: NFCHealthCardPasswordController = DummyNFCHealthCardPasswordController()

    static let testValue: NFCHealthCardPasswordController = UnimplementedNFCHealthCardPasswordController()
}

extension DependencyValues {
    var nfcHealthCardPasswordController: NFCHealthCardPasswordController {
        get { self[NFCHealthCardPasswordControllerDependency.self] }
        set { self[NFCHealthCardPasswordControllerDependency.self] = newValue }
    }
}
