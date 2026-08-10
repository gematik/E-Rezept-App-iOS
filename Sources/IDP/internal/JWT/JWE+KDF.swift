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

import Combine
import CryptoKit
import Foundation

extension JWE {
    /// Container for the derived symmetric key and the ephemeral public key used for encryption
    public struct EncryptionContext {
        let symmetricKey: SymmetricKey

        let ephemeralPublicKey: JWK

        /// Initializes a new EncryptionContext with the given symmetric key and ephemeral public key
        public init(
            symmetricKey: SymmetricKey,
            ephemeralPublicKey: JWK
        ) {
            self.symmetricKey = symmetricKey
            self.ephemeralPublicKey = ephemeralPublicKey
        }
    }
}
