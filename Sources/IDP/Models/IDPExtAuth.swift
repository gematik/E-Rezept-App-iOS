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

/// Stores login information needed for external authentication (a.k.a. FastTrack).
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
    public let authType: AuthType

    /// Authentication type stating the method of authentication
    public enum AuthType {
        /// Using fasttrack
        case fasttrack
        /// Using "Gesundheits ID"
        case gid
    }
}
