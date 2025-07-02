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

extension JWK {
    /// Creates a `x962` representation of the x and y values of the JWK.  The format follows the ANSI X9.62 standard
    /// using a byte string of 04 || X || Y . Hexadecimal representation should start with 0x04.
    /// see: https://www.secg.org/SEC1-Ver-1.0.pdf 2.3.3 EllipticCurvePoint-to-OctetString Conversion
    func publicKeyX962UncompressedRepresentation(padToByteCount: Int = 32) -> Data? {
        if let xBase64Decoded = x?.decodeBase64URLEncoded(),
           let yBase64Decoded = y?.decodeBase64URLEncoded() {
            return Data([0x04] +
                xBase64Decoded.dropLeadingZeroByte.padWithLeadingZeroes(totalLength: padToByteCount) +
                yBase64Decoded.dropLeadingZeroByte.padWithLeadingZeroes(totalLength: padToByteCount))
        } else {
            return nil
        }
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
