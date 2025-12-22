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

import ASN1Kit
import CodedError
import Combine
import Foundation
import IDP

public class BiometricsSHA256Signer: JWTSigner {
    let privateKeyContainer: PrivateKeyContainer

    public init(privateKeyContainer: PrivateKeyContainer) {
        self.privateKeyContainer = privateKeyContainer
    }

    var certificates: [Data] {
        [Data()]
    }

    @CodedError("102")
    public enum Error: Swift.Error {
        @ErrorCode("01")
        case sessionClosed
        @ErrorCode("02")
        case signatureFailed
    }

    public func sign(message: Data) async throws -> Data {
        do {
            // Data in concat format containing the Signature `r` | `s`.
            return try privateKeyContainer.sign(data: message).derToConcat()
        } catch {
            throw Error.signatureFailed
        }
    }
}

@CodedError("107")
public enum ConversionError: Swift.Error {
    @ErrorCode("01")
    case generic(String?)
}

extension Data {
    // From jose4j EcdsaUsingShaAlgorithm.java
    func derToConcat() throws -> Data {
        let wholeASN1 = try ASN1Decoder.decode(asn1: self)
        let sequence = try Array(from: wholeASN1)

        guard sequence.count == 2 else {
            throw ConversionError.generic("Error converting EC signature. Expected 2 elements, found \(sequence.count)")
        }

        let signatureR = try Data(from: sequence[0]).dropLeadingZeroByte.padWithLeadingZeroes(totalLength: 32)
        let signatureS = try Data(from: sequence[1]).dropLeadingZeroByte.padWithLeadingZeroes(totalLength: 32)

        return signatureR + signatureS
    }
}

extension Data {
    var dropLeadingZeroByte: Data {
        if first == 0x0 {
            return dropFirst()
        } else {
            return self
        }
    }

    func padWithLeadingZeroes(totalLength: Int) -> Data {
        if count >= totalLength {
            return self
        } else {
            return Data(count: totalLength - count) + self
        }
    }
}
