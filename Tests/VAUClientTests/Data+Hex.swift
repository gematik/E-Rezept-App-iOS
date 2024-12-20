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

extension DataProtocol {
    var data: Data { .init(self) }
    var hexa: String { map { .init(format: "%02X", $0) }.joined() }
}

struct HexaError: Error {}

extension StringProtocol {
    func hexa() throws -> [UInt8] {
        var startIndex = self.startIndex
        return try (0 ..< count / 2).map { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            guard let byte = UInt8(self[startIndex ... endIndex], radix: 16)
            else { throw HexaError() }
            return byte
        }
    }
}

extension Data {
    /// Helping function to init Data from `hex` String
    init(hex hexString: String) throws {
        try self.init(hexString.hexa().data)
    }
}

extension Data {
    /// Helping function to output a hexadecimal representation of `self`
    func hexString() -> String {
        hexa
    }
}
