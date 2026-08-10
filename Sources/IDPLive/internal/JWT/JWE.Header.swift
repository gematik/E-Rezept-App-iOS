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
import IDP

extension JWE.Header {
    /// Initializes a JWE.Header with the given parameters, deriving the encryption context from the provided algorithm.
    public init(
        algorithm: JWE.EncryptionContext.Algorithm,
        encryption: JWE.Encryption,
        expiry: Date? = nil,
        contentType: String,
        type: String? = nil
    ) throws {
        let encryption = encryption
        let encryptionContext = try algorithm.encryptionContext()
        let exp = expiry
        let cty = contentType
        let typ = type
        let algo: String
        switch algorithm {
        case .ecdh_es:
            algo = "ECDH-ES"
        }
        self.init(
            encryptionContext: encryptionContext,
            alg: algo,
            encryption: encryption,
            expiry: exp,
            contentType: cty,
            type: typ
        )
    }
}
