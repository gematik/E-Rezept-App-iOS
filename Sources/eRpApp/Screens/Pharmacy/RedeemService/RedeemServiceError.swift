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

import AVS
import eRpKit
import Foundation

// sourcery: CodedError = "024"
enum RedeemServiceError: Swift.Error, Equatable, LocalizedError, Codable {
    // sourcery: errorCode = "01"
    /// When redeeming a task via Fachdienst
    case eRxRepository(ErxRepositoryError)
    // sourcery: errorCode = "02"
    /// When redeeming a task via AVS
    case avs(AVSError)
    // sourcery: errorCode = "03"
    /// When an internal error occurs which most likely is a programming error
    case internalError(InternalError)
    // sourcery: errorCode = "04"
    /// When error conversion into `RedeemServiceError` fails
    case unspecified(error: Swift.Error)
    // sourcery: errorCode = "05"
    /// When the user has no valid token available while trying to redeem via Fachdienst
    case noTokenAvailable
    // sourcery: errorCode = "06"
    /// When receiving an error while doing a login
    case loginHandler(error: LoginHandlerError)
    // sourcery: errorCode = "07"
    /// When the prescription has already been redeemed
    case prescriptionAlreadyRedeemed([Prescription])

    static func ==(lhs: RedeemServiceError, rhs: RedeemServiceError) -> Bool {
        switch (lhs, rhs) {
        case let (.eRxRepository(lhsError), .eRxRepository(rhsError)): return lhsError == rhsError
        case let (.avs(lhsError), .avs(rhsError)): return lhsError == rhsError
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.internalError(lhsError), .internalError(rhsError)): return lhsError == rhsError
        case (.noTokenAvailable, .noTokenAvailable): return true
        case let (.loginHandler(error: lhsError), .loginHandler(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.prescriptionAlreadyRedeemed(lhsPrescription), .prescriptionAlreadyRedeemed(rhsPrescription)):
            return lhsPrescription == rhsPrescription
        default:
            return false
        }
    }

    // sourcery: CodedError = "025"
    enum InternalError: Swift.Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        /// When the AVS endpoint for the selected redeem option is missing
        case missingAVSEndpoint
        // sourcery: errorCode = "02"
        /// When the required AVS certificates for redeeming via AVS are missing
        case missingAVSCertificate
        // sourcery: errorCode = "03"
        /// When the Telematik-ID of the pharmacy to redeem in is missing
        case missingTelematikId
        // sourcery: errorCode = "04"
        /// When converting AVS Version number
        case conversionVersionNumber
        // sourcery: errorCode = "05"
        /// When no order can be found to the received response
        case idMissmatch
        // sourcery: errorCode = "06"
        /// When no service can be found for the selected pharmacy
        case noService
        // sourcery: errorCode = "07"
        /// When the status code is not in [200..<300] but the service did not return an error beforehand
        case unexpectedHTTPStatusCode
        // sourcery: errorCode = "08"
        /// When persisting/extracting information from the store went wrong
        case localStoreError(LocalStoreError)

        var errorDescription: String? {
            // TODO: pass error ID instead describing self // swiftlint:disable:this todo
            L10n.phaRedeemTxtInternalErr(String(describing: self)).text
        }

        var recoverySuggestion: String? {
            L10n.phaRedeemTxtInternalErrRecovery.text
        }
    }

    var errorDescription: String? {
        switch self {
        case let .eRxRepository(error):
            return error.localizedDescription
        case let .avs(error):
            return error.localizedDescription
        case let .internalError(error):
            return error.localizedDescription
        case .noTokenAvailable:
            return L10n.phaRedeemTxtNotLoggedInTitle.text
        case let .unspecified(error: error):
            return error.localizedDescription
        case let .loginHandler(error: error):
            return error.localizedDescription
        case let .prescriptionAlreadyRedeemed(prescriptions):
            return L10n.phaRedeemTxtPrescriptionAlreadyRedeemedError(prescriptions.count).text
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .eRxRepository(error):
            return error.recoverySuggestion
        case let .avs(error):
            return error.recoverySuggestion
        case let .internalError(error):
            return error.recoverySuggestion
        case .noTokenAvailable:
            return L10n.phaRedeemTxtNotLoggedIn.text
        case let .unspecified(error: error):
            if let localizedError = error as? LocalizedError,
               let recovery = localizedError.recoverySuggestion {
                return recovery
            } else {
                return L10n.phaRedeemTxtInternalErrRecovery.text
            }
        case let .loginHandler(error: error):
            return error.recoverySuggestion
        case let .prescriptionAlreadyRedeemed(prescriptions):
            let count = prescriptions.count
            let prescriptionList = prescriptions.map(\.title).map { "\"\($0)\"" }.joined(separator: " & ")
            return String(
                format: L10n.phaRedeemTxtPrescriptionAlreadyRedeemedErrorSuggestionFormat(count).text,
                prescriptionList
            )
        }
    }

    static func from(_ error: Swift.Error) -> RedeemServiceError {
        if let avsError = error as? AVSError {
            return .avs(avsError)
        } else if let repositoryError = error as? ErxRepositoryError {
            return .eRxRepository(repositoryError)
        } else if let internalError = error as? RedeemServiceError.InternalError {
            return .internalError(internalError)
        } else if let serviceError = error as? RedeemServiceError {
            return serviceError
        } else {
            return .unspecified(error: error)
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(String.self, forKey: .type)
        _ = try? container.decode(String.self, forKey: .value)

        self = .internalError(.noService)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .eRxRepository:
            try container.encode("eRxRepository", forKey: .type)
        case .avs:
            try container.encode("avs", forKey: .type)
        case .internalError:
            try container.encode("internalError", forKey: .type)
        case .unspecified:
            try container.encode("unspecified", forKey: .type)
        case .noTokenAvailable:
            try container.encode("noTokenAvailable", forKey: .type)
        case .loginHandler:
            try container.encode("loginHandler", forKey: .type)
        case .prescriptionAlreadyRedeemed:
            try container.encode("prescriptionAlreadyRedeemed", forKey: .type)
        }
    }
}
