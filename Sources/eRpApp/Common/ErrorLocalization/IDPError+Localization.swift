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

import Foundation
import IDP
import TrustStore

extension IDPError: LocalizedError {
    public var errorDescription: String? {
        // [REQ:gemSpec_IDP_Frontend:A_20085] Error localization is not done yet, this is the place to localize
        // accordingly.
        switch self {
        case let .network(error: error): return error.localizedDescription
        case let .validation(error: error): return error.localizedDescription
        case .tokenUnavailable: return "IDPError.tokenUnavailable"
        case let .unspecified(error: error): return error.localizedDescription
        case let .decoding(error: error): return error.localizedDescription
        case .noCertificateFound: return "IDPError.noCertificateFound"
        case .invalidDiscoveryDocument: return "IDPError.invalidDiscoveryDocument"
        case let .unsupported(string): return "IDPError.unsupported method \(String(describing: string))"
        // [REQ:gemSpec_IDP_Frontend:A_19937#1,A_20605,A_20085] Localized description of server errors
        case let .internal(error: error): return error.localizedDescription
        case let .serverError(error): return "IDPError.serverError '\(error)'"
        case .invalidStateParameter:
            return "IDPError.invalidStateParameter"
        case let .invalidSignature(text):
            return "IDPError.invalidSignature \(text)"
        case .invalidNonce:
            return "IDPError.invalidNonce"
        case .encryption:
            return "IDPError.encryption"
        case .decryption:
            return "IDPError.decryption"
        case let .trustStore(error: error):
            return "Trust store error: \(error)"
        case let .pairing(error):
            return "Pairing error: \(error)"
        case .biometrics where contains(PrivateKeyContainer.Error.canceledByUser):
            return L10n.errSpecificI10808Description.text
        case .biometrics:
            return L10n.errSpecificI10018Description.text
        case .extAuthOriginalRequestMissing:
            return "Error while processing external authentication: original request not found."
        case .notAvailableInDemoMode:
            return L10n.idpErrNotAvailableInDemoModeText.text
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notAvailableInDemoMode:
            return L10n.idpErrNotAvailableInDemoModeRecovery.text
        default:
            return "Try again later"
        }
    }
}
