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

import Combine
import CryptoKit
import DataKit
import Foundation
@testable import IDP
import Nimble
import OpenSSL
import XCTest

class JWEKDFTests: XCTestCase {
    func testPremadeJWE() throws {
        let publicKey = try! BrainpoolP256r1.KeyExchange.PublicKey(x962: Data(
            hex: "0440ba49fcba45c7eeb2261b1be0ebc7c14d6484b9ef8a23b060ebe67f97252bbc987ba49df364a0c9926f2b6de1baf46068a13a2c5c9812b2f3451f48b75719ee" // swiftlint:disable:this line_length
        ))

        let ephemeralPrivate = try BrainpoolP256r1.KeyExchange
            .PrivateKey(raw: Data(hex: "a1746e2e69305e90bce385965f82069be49ac9afe190e69f951cb214a8cb9475"))

        let algorithm = JWE.Algorithm.ecdh_es(.bpp256r1(publicKey, keyPairGenerator: { ephemeralPrivate }))
        let context = try algorithm.encryptionContext()

        let aesKey = try Data(hex: "D624C6F81B44CE7D26E98841BEB79652E9DEC79DFD8E2E6F6E706A105D37EC87")
        let expectedAESKey = SymmetricKey(data: aesKey)

        XCTAssertEqual(context.symmetricKey, expectedAESKey)
    }
}
