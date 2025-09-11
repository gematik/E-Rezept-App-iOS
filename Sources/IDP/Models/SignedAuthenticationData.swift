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

/// Signed (with `PrK_SE_AUT`) representation of `AuthenticationData`.
public struct SignedAuthenticationData {
    /// Original idp challenge session that is signed within the authentication data
    public let originalChallenge: IDPChallengeSession
    /// Signed authentication data that is encrypted and sent to the server
    public let signedAuthenticationData: JWT

    /// Initialize SignedAuthenticationData with challenge and signed data
    /// - Parameters:
    ///   - originalChallenge: Original IDP challenge session
    ///   - signedAuthenticationData: JWT containing signed authentication data
    public init(
        originalChallenge: IDPChallengeSession,
        signedAuthenticationData: JWT
    ) {
        self.originalChallenge = originalChallenge
        self.signedAuthenticationData = signedAuthenticationData
    }

    /// Serialize the signedChallenge
    ///
    /// - Returns: ASCII Encoded String
    public func serialize() -> String {
        signedAuthenticationData.serialize()
    }
}
