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

import Combine
import Foundation
import OpenSSL

/// Signed (with eGK) version of `PairingData`.
/// [REQ:gemSpec_IDP_Dienst:A_21415:Signed_Pairing_Data]
public struct SignedPairingData {
    /// original
    public let originalPairingData: PairingData

    let signedPairingData: JWT

    /// Initialize a SignedChallenge
    ///
    /// - Parameters:
    ///   - originalPairingData: unsigned PairingData that is signed within this container.
    ///   - signedChallenge: signed PairingData as JWT representation.
    public init(originalPairingData: PairingData, signedPairingData: JWT) {
        self.originalPairingData = originalPairingData
        self.signedPairingData = signedPairingData
    }

    /// Serialize the signedChallenge
    ///
    /// - Returns: ASCII Encoded String
    public func serialize() -> String {
        signedPairingData.serialize()
    }

    /// Initializes with a given JWT String representing the `PairingData`.
    /// - Parameter string: String representation of JWT Container with the signed `PairingData`.
    public init(from string: String) throws {
        let signedPairingData = try JWT(from: string)
        originalPairingData = try signedPairingData.decodePayload(type: PairingData.self)
        self.signedPairingData = signedPairingData
    }
}
