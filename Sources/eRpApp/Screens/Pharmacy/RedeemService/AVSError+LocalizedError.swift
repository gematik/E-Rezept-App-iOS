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

import AVS
import Foundation

extension AVSError: @retroactive
LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .network(error: error):
            return error.localizedDescription
        case .invalidAVSMessageInput:
            return L10n.avsErrInvalidInput.text
        case .invalidX509Input:
            return L10n.avsErrInvalidCert.text
        case let .unspecified(error: error):
            return error.localizedDescription
        case let .internal(error: error):
            return error.localizedDescription
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case let .network(error: error):
            return error.recoverySuggestion
        case .invalidAVSMessageInput:
            return L10n.avsErrRecoveryInvalidInput.text
        case .invalidX509Input:
            return L10n.avsErrRecoveryInvalidCert.text
        case let .unspecified(error: error):
            if let localizedError = error as? LocalizedError,
               let recovery = localizedError.recoverySuggestion {
                return recovery
            } else {
                return L10n.avsErrRecoveryInternal.text
            }
        case let .internal(error: error):
            return error.recoverySuggestion
        }
    }
}

extension AVSError.InternalError: @retroactive LocalizedError {
    public var errorDescription: String? {
        L10n.avsErrInternal(String(describing: self)).text // TODO: pass error ID // swiftlint:disable:this todo
    }

    public var recoverySuggestion: String? {
        L10n.avsErrRecoveryInternal.text
    }
}
