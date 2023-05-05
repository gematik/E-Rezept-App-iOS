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

import Combine
import CombineSchedulers
import CoreNFC
import Dependencies
import HealthCardControl
import NFCCardReaderProvider

protocol NFCHealthCardPasswordController {
    func resetEgkMrPinRetryCounter(can: String, puk: String, mode: NFCResetRetryCounterMode)
        -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>

    func changeReferenceData(can: String, old: String, new: String, mode: NFCChangeReferenceDataMode)
        -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError>
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

    var underlyingTagError: CoreNFCError? {
        switch self {
        case let .cardError(readerError):
            if case let .nfcTag(error: tagError) = readerError {
                return tagError
            }
        case let .openSecureSession(error),
             let .resetRetryCounter(error),
             let .changeReferenceData(error):
            if let cardError = error as? NFCCardError,
               case let .nfcTag(error: tagError) = cardError {
                return tagError
            } else if let readerError = error as? NFCTagReaderSession.Error,
                      case let .nfcTag(error: tagError) = readerError {
                return tagError
            }
        default: break
        }

        return nil
    }
}

struct DefaultNFCResetRetryCounterController: NFCHealthCardPasswordController {
    init(schedulers: Schedulers) {
        self.schedulers = schedulers
    }

    let schedulers: Schedulers
    private var uiScheduler: AnySchedulerOf<DispatchQueue> {
        schedulers.main
    }

    // swiftlint:disable:next function_body_length
    func resetEgkMrPinRetryCounter(
        can: String,
        puk: String,
        mode: NFCResetRetryCounterMode
    ) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        NFCTagReaderSession
            .publisher(messages: .defaultMessages)
            .mapError { NFCHealthCardPasswordControllerError.cardError($0) }
            .flatMap { session in
                session.card
                    .openSecureSession(can: can)
                    .mapError { error -> NFCHealthCardPasswordControllerError in
                        if let error = error as? HealthCardControl.KeyAgreement.Error,
                           case .macPcdVerificationFailedOnCard = error {
                            return NFCHealthCardPasswordControllerError.wrongCan
                        } else {
                            return NFCHealthCardPasswordControllerError.openSecureSession(error)
                        }
                    }
                    .userMessage(session: session, message: mode.nfcDialogStartUnlockCardMessage)
                    .flatMap { card -> AnyPublisher<ResetRetryCounterResponse, NFCHealthCardPasswordControllerError> in
                        switch mode {
                        case .resetEgkMrPinRetryCountWithoutNewSecret:
                            return card.resetRetryCounter(puk: puk, affectedPassWord: .mrPinHomeNoDfSpecific)
                                .mapError {
                                    NFCHealthCardPasswordControllerError.resetRetryCounter($0)
                                }
                                .eraseToAnyPublisher()
                        case let .resetEgkMrPinRetryCountWithNewSecret(newPin):
                            return card.resetRetryCounterAndSetNewPin(
                                puk: puk,
                                newPin: newPin,
                                affectedPassWord: .mrPinHomeNoDfSpecific
                            )
                            .mapError {
                                NFCHealthCardPasswordControllerError.resetRetryCounter($0)
                            }
                            .eraseToAnyPublisher()
                        }
                    }
                    .map(NFCHealthCardPasswordControllerResponse.from(resetRetryCounterResponse:))
                    .handleEvents(
                        receiveOutput: { resetRetryCounterResponse in
                            if case .success = resetRetryCounterResponse {
                                session.invalidateSession(with: nil)
                            } else {
                                session.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
                            }
                        },
                        receiveCancel: {
                            session.invalidateSession(with: EGKSignatureProvider.systemNFCDialogCancel)
                        }
                    )
                    .mapError { error -> NFCHealthCardPasswordControllerError in
                        session.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
                        return error
                    }
            }
            .eraseToAnyPublisher()
    }

    func changeReferenceData(
        can: String,
        old: String,
        new: String,
        mode: NFCChangeReferenceDataMode
    ) -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        NFCTagReaderSession
            .publisher(messages: .defaultMessages)
            .mapError { NFCHealthCardPasswordControllerError.cardError($0) }
            .flatMap { session in
                session.card
                    .openSecureSession(can: can)
                    .mapError { error -> NFCHealthCardPasswordControllerError in
                        if let error = error as? HealthCardControl.KeyAgreement.Error,
                           case .macPcdVerificationFailedOnCard = error {
                            return NFCHealthCardPasswordControllerError.wrongCan
                        } else {
                            return NFCHealthCardPasswordControllerError.openSecureSession(error)
                        }
                    }
                    .userMessage(session: session, message: mode.nfcDialogStartChangeReferenceDataMessage)
                    .flatMap { card ->
                        AnyPublisher<ChangeReferenceDataResponse, NFCHealthCardPasswordControllerError> in
                        switch mode {
                        case .changeEgkMrPinSecret:
                            return card.changeReferenceDataSetNewPin(
                                old: old,
                                new: new,
                                affectedPassword: .mrPinHomeNoDfSpecific
                            )
                            .mapError {
                                NFCHealthCardPasswordControllerError.changeReferenceData($0)
                            }
                            .eraseToAnyPublisher()
                        }
                    }
                    .map(NFCHealthCardPasswordControllerResponse.from(changeReferenceDataResponse:))
                    .handleEvents(
                        receiveOutput: { changeReferenceDataResponse in
                            if case .success = changeReferenceDataResponse {
                                session.invalidateSession(with: nil)
                            } else {
                                session.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
                            }
                        },
                        receiveCancel: {
                            session.invalidateSession(with: EGKSignatureProvider.systemNFCDialogCancel)
                        }
                    )
                    .mapError { error -> NFCHealthCardPasswordControllerError in
                        session.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
                        return error
                    }
            }
            .eraseToAnyPublisher()
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
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .cardError(error as LocalizedError),
             let .openSecureSession(error as LocalizedError),
             let .resetRetryCounter(error as LocalizedError),
             let .changeReferenceData(error as LocalizedError):
            return error.recoverySuggestion
        case .resetRetryCounter, .openSecureSession, .wrongCan, .changeReferenceData:
            return nil
        }
    }
}

struct DummyNFCHealthCardPasswordController: NFCHealthCardPasswordController {
    func resetEgkMrPinRetryCounter(can _: String, puk _: String, mode _: NFCResetRetryCounterMode)
        -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        Just(NFCHealthCardPasswordControllerResponse.success)
            .setFailureType(to: NFCHealthCardPasswordControllerError.self)
            .eraseToAnyPublisher()
    }

    func changeReferenceData(can _: String, old _: String, new _: String,
                             mode _: NFCChangeReferenceDataMode)
        -> AnyPublisher<NFCHealthCardPasswordControllerResponse, NFCHealthCardPasswordControllerError> {
        Just(NFCHealthCardPasswordControllerResponse.success)
            .setFailureType(to: NFCHealthCardPasswordControllerError.self)
            .eraseToAnyPublisher()
    }
}

// MARK: TCA Dependency

// swiftlint:disable:next type_name
struct NFCHealthCardPasswordControllerDependency: DependencyKey {
    static let liveValue: NFCHealthCardPasswordController =
        DefaultNFCResetRetryCounterController(schedulers: .liveValue)

    static let previewValue: NFCHealthCardPasswordController = DummyNFCHealthCardPasswordController()

    static let testValue: NFCHealthCardPasswordController = UnimplementedNFCHealthCardPasswordController()
}

extension DependencyValues {
    var nfcHealthCardPasswordController: NFCHealthCardPasswordController {
        get { self[NFCHealthCardPasswordControllerDependency.self] }
        set { self[NFCHealthCardPasswordControllerDependency.self] = newValue }
    }
}
