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

import CryptoKit
import Foundation
import Nimble
import OpenSSL
@testable import VAUClient
import XCTest

final class VAUCryptoTests: XCTestCase {
    func testVauCryptoEncrypt() throws {
        // given
        let message = "the message"
        let vauPublicKey = try BrainpoolP256r1.KeyExchange.generateKey().publicKey
        let bearerToken = "bearer token"
        let requestIdGenerator = { "abcdef" }
        let keyData = try Data(hex: "9656c2b4b3da81d0385f6a1ee60e93b91828fd90231c923d53ce7bbbcd58ceaa")
        let symmetricKeyGenerator = { SymmetricKey(data: keyData) }
        let eciesSpec = Ecies.Spec.v1

        let vauCrypto = try EciesVAUCrypto(
            message: message,
            vauPublicKey: vauPublicKey,
            bearerToken: bearerToken,
            requestIdGenerator: requestIdGenerator,
            symmetricKeyGenerator: symmetricKeyGenerator,
            eciesSpec: eciesSpec
        )

        // then
        expect(try vauCrypto.encrypt()).toNot(throwError())
    }

    func testEciesEncrypt() throws {
        // given
        let payload = "Hallo Test".data(using: .utf8)!
        let pubKeyRaw =
            try Data(
                hex: "048634212830DAD457CA05305E6687134166B9C21A65FFEBF555F4E75DFB04888866E4B6843624CBDA43C97EA89968BC41FD53576F82C03EFA7D601B9FACAC2B29" // swiftlint:disable:this line_length
            )
        let pubKey = try BrainpoolP256r1.KeyExchange.PublicKey(x962: pubKeyRaw)
        let spec = Ecies.Spec.v1
        let nonceDataGenMock = { try Data(hex: "257db4604af8ae0dfced37ce") }
        let privateKeyRaw = try Data(hex: "5bbba34d47502bd588ed680dfa2309ca375eb7a35ddbbd67cc7f8b6b687a1c1d")
        let keyPairGenMock = { try BrainpoolP256r1.KeyExchange.PrivateKey(raw: privateKeyRaw) }

        // when
        let ciphered = try Ecies.encrypt(
            payload: payload,
            vauPubKey: pubKey,
            spec: spec,
            nonceDataGenerator: nonceDataGenMock,
            keyPairGenerator: keyPairGenMock
        )

        // then
        let expected = [
            "01",
            "754e548941e5cd073fed6d734578a484be9f0bbfa1b6fa3168ed7ffb22878f0f",
            "9aef9bbd932a020d8828367bd080a3e72b36c41ee40c87253f9b1b0beb8371bf",
            "257db4604af8ae0dfced37ce",
            "86c2b491c7a8309e750b",
            "4e6e307219863938c204dfe85502ee0a",
        ].joined()
        expect(expected) == ciphered.hexString().lowercased()
    }
}
