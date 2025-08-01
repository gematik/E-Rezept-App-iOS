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

import Foundation

/// Stores login information needed for external authentication (a.k.a. gID).
public struct IDPExtAuth {
    /// The user selected identifier of the application to use for the authentication.
    public let kkAppId: String

    /// OAuth parameter state of high entropy.
    public let state: String

    /// SHA256 hashed verifier code
    public let codeChallenge: String

    /// codeChallenge hashing method. Must be S256 to indicate SHA256 hashed value.
    public let codeChallengeMethod: IDPCodeChallengeMode

    /// OpenID parameter nonce of high entropy.
    public let nonce: String

    /// Authentication type
    public let authType: AuthType = .gid

    /// Authentication type stating the method of authentication
    public enum AuthType {
        /// Using "Gesundheits ID"
        case gid
    }

    /// Initialize IDPExtAuth with authentication parameters
    /// - Parameters:
    ///   - kkAppId: User selected identifier of the application
    ///   - state: OAuth parameter state of high entropy
    ///   - codeChallenge: SHA256 hashed verifier code
    ///   - codeChallengeMethod: Code challenge hashing method
    ///   - nonce: OpenID parameter nonce of high entropy
    public init(
        kkAppId: String,
        state: String,
        codeChallenge: String,
        codeChallengeMethod: IDPCodeChallengeMode,
        nonce: String
    ) {
        self.kkAppId = kkAppId
        self.state = state
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
        self.nonce = nonce
    }
}
