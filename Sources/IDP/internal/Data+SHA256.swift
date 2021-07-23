//
//  Copyright (c) 2021 gematik GmbH
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

import CommonCrypto
import Foundation

/**
 Data extension Data+Secure
 */
extension Data {
    /// The 256-bit Secure Hash (SHA256) of `self` (Data)
    /// - Returns: SHA256 hash
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress!, CC_LONG(self.count), &hash) // swiftlint:disable:this force_unwrapping
        }
        return Data(hash)
    }
}

extension String {
    /// The 256-bit Secure Hash (SHA256) of `self` (String) when contiguous storage is available
    func sha256() -> Data? {
        utf8.withContiguousStorageIfAvailable { buffer in
            Data(buffer).sha256()
        }
    }
}
