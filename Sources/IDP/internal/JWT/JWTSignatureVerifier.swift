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

import Foundation
import OpenSSL

/// Types conforming should be able to verify a signature
public protocol JWTSignatureVerifier {
    /// Verify whether the `signature` is correct for the given `message`
    ///
    /// - Parameters:
    ///   - signature: raw signature bytes
    ///   - message: raw message bytes
    /// - Returns: true when the signature authenticates the message
    /// - Throws: `Swift.Error`
    func verify(signature: Data, message: Data) throws -> Bool
}

extension BrainpoolP256r1.Verify.PublicKey: JWTSignatureVerifier {
    // [REQ:gemSpec_Krypt:A_17207]
    public func verify(signature raw: Data, message: Data) throws -> Bool {
        let signature = try BrainpoolP256r1.Verify.Signature(rawRepresentation: raw)
        return try verify(signature: signature, message: message)
    }
}

extension X509: JWTSignatureVerifier {
    public func verify(signature: Data, message: Data) throws -> Bool {
        // [REQ:gemSpec_Krypt:A_17207]
        guard let key = brainpoolP256r1VerifyPublicKey() else {
            throw IDPError.unsupported("expected brainpool P256r1 key")
        }
        return try key.verify(signature: signature, message: message)
    }
}
