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
import Security

enum VAURandom {
    /// Generate random Data with given length
    ///
    /// [REQ:gemSpec_Krypt:GS-A_4367]
    /// [REQ:BSI-eRp-ePA:O.Rand_1#3] Secure Random generator.
    ///
    /// - Parameters:
    ///   - length: the number of bytes to generate
    ///   - randomizer: the randomizer to be used. Default: kSecRandomDefault
    /// - Returns: the random initialized Data
    /// - Throws: `VAUError`
    static func generateSecureRandom(length: Int, randomizer: SecRandomRef? = kSecRandomDefault) throws -> Data {
        var randomBytesBuffer = [UInt8](repeating: 0x0, count: length)
        let rcStatus: OSStatus = try randomBytesBuffer
            .withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
                guard let ptr = buffer.baseAddress else {
                    throw VAUError.internalError("Invalid byte buffer")
                }
                return SecRandomCopyBytes(randomizer, length, ptr)
            }
        guard rcStatus == errSecSuccess else {
            throw VAUError.internalError("Could not generate Random bytes. [Count: \(length)]")
        }
        return Data(randomBytesBuffer)
    }
}
