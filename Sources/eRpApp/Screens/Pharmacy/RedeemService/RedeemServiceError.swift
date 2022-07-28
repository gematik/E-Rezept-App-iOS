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

import AVS
import eRpKit
import Foundation

// sourcery: CodedError = "024"
enum RedeemServiceError: Swift.Error, Equatable, LocalizedError {
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

    static func ==(lhs: RedeemServiceError, rhs: RedeemServiceError) -> Bool {
        switch (lhs, rhs) {
        case let (.eRxRepository(lhsError), .eRxRepository(rhsError)): return lhsError == rhsError
        case let (.avs(lhsError), .avs(rhsError)): return lhsError == rhsError
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.internalError(lhsError), .internalError(rhsError)): return lhsError == rhsError
        case (.noTokenAvailable, .noTokenAvailable): return true
        default:
            return false
        }
    }
}
