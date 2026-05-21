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

import CodedError
import eRpKit
import eRpStyleKit
import ErxTaskRepository
import FeatureCardWall
import Foundation

@CodedError("047")
public enum EuRedeemServiceError: Swift.Error, Equatable, LocalizedError {
    /// When redeeming a task via Fachdienst
    @ErrorCode("01")
    case eRxRepository(ErxRepositoryError)
    /// When persisting/extracting information from the store went wrong
    @ErrorCode("02")
    case localStoreError(LocalStoreError)
    /// When the eu accessCode generation fails
    @ErrorCode("03")
    case euCodeGeneration(EuCodeGenerationError)
    /// When error conversion into `EuRedeemServiceError` fails
    @ErrorCode("04")
    case unspecified(error: Swift.Error)
    /// When the user has no valid token available while trying to redeem via Fachdienst
    @ErrorCode("05")
    case noTokenAvailable
    /// When receiving an error while doing a login
    @ErrorCode("06")
    case loginHandler(error: LoginHandlerError)

    public static func ==(lhs: EuRedeemServiceError, rhs: EuRedeemServiceError) -> Bool {
        switch (lhs, rhs) {
        case let (.eRxRepository(lhsError), .eRxRepository(rhsError)): return lhsError == rhsError
        case let (.localStoreError(lhsError), .localStoreError(rhsError)): return lhsError == rhsError
        case let (.euCodeGeneration(lhsError), .euCodeGeneration(rhsError)): return lhsError == rhsError
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.noTokenAvailable, .noTokenAvailable): return true
        case let (.loginHandler(error: lhsError), .loginHandler(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .eRxRepository(error):
            return error.localizedDescription
        case let .localStoreError(error):
            return error.localizedDescription
        case let .euCodeGeneration(error):
            return error.localizedDescription
        case let .unspecified(error: error):
            return error.localizedDescription
        case .noTokenAvailable:
            return L10n.phaRedeemTxtNotLoggedInTitle.text
        case let .loginHandler(error: error):
            return error.localizedDescription
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .eRxRepository(error):
            return error.recoverySuggestion
        case let .localStoreError(error):
            return error.recoverySuggestion
        case let .euCodeGeneration(error):
            return error.recoverySuggestion
        case let .unspecified(error: error):
            if let localizedError = error as? LocalizedError,
               let recovery = localizedError.recoverySuggestion {
                return recovery
            } else {
                return L10n.phaRedeemTxtInternalErrRecovery.text
            }
        case .noTokenAvailable:
            return L10n.phaRedeemTxtNotLoggedIn.text
        case let .loginHandler(error: error):
            return error.recoverySuggestion
        }
    }

    public static func from(_ error: Swift.Error) -> EuRedeemServiceError {
        if let repositoryError = error as? ErxRepositoryError {
            return .eRxRepository(repositoryError)
        } else if let localStoreError = error as? LocalStoreError {
            return .localStoreError(localStoreError)
        } else if let euCodeGenerationError = error as? EuCodeGenerationError {
            return .euCodeGeneration(euCodeGenerationError)
        } else if let serviceError = error as? EuRedeemServiceError {
            return serviceError
        } else {
            return .unspecified(error: error)
        }
    }
}
