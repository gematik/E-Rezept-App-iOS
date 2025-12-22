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
import OpenSSL

extension IDPDirectoryKKApps {
    /// Verify the JWT signature with the provided certificate
    /// - Parameter certificate: X.509 certificate used for verification
    /// - Returns: Boolean indicating if verification was successful
    /// - Throws: If verification fails
    public func verify(with certificate: X509) throws -> Bool {
        try jwt.verify(with: certificate)
    }
}

extension X509: JWTSignatureVerifier {
    public func verify(signature: Data, message: Data) throws -> Bool {
        // [REQ:gemSpec_Krypt:A_17207]
        // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02] Assure that brainpoolP256r1 is used
        guard let key = brainpoolP256r1VerifyPublicKey() else {
            throw IDPError.unsupported("expected brainpool P256r1 key")
        }
        return try key.verify(signature: signature, message: message)
    }
}

extension BrainpoolP256r1.Verify.PublicKey: JWTSignatureVerifier {
    // [REQ:gemSpec_Krypt:A_17207]
    // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02]
    public func verify(signature raw: Data, message: Data) throws -> Bool {
        let signature = try BrainpoolP256r1.Verify.Signature(rawRepresentation: raw)
        return try verify(signature: signature, message: message)
    }
}
