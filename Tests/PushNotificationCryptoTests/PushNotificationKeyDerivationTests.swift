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
@testable import PushNotificationCrypto
import Testing

@Suite("HKDF Key Derivation")
struct PushNotificationKeyDerivationTests {
    let specISS = Data(hexEncoded: "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2")

    @Test("Derive from ISS for October 2023 matches spec vector")
    func deriveKeyPairFromISS_October2023() {
        let keyPair = PushNotificationKeyDerivation.deriveKeyPair(from: specISS, info: "2023-10")

        #expect(keyPair.sharedSecret.hexEncodedString
            == "185fed66ea5cabbe00147bbd298b5dab0ed41b57ab254d35897b3a4504306e3b")
        #expect(keyPair.aesGCMKey.hexEncodedString
            == "3b4adcd58dea98db8e9cb0f5763fcd04fe932d67926cc04b20ba2a2f304ffff9")
    }

    @Test("Derive from October secret for November 2023 matches spec vector")
    func deriveKeyPairFromOctoberSecret_November2023() {
        let octoberSecret = Data(
            hexEncoded: "185fed66ea5cabbe00147bbd298b5dab0ed41b57ab254d35897b3a4504306e3b"
        )

        let keyPair = PushNotificationKeyDerivation.deriveKeyPair(from: octoberSecret, info: "2023-11")

        #expect(keyPair.sharedSecret.hexEncodedString
            == "0c8662d90b04818afb317406fe7fcfcf8d103cd9bc6ad7847890d28620e85ec3")
        #expect(keyPair.aesGCMKey.hexEncodedString
            == "39aa5dacd538f53f4b956d84c9b8f2e26933274d160b9fd1a263a27681c6331b")
    }

    @Test("Produces 32-byte shared secret and 32-byte AES key")
    func deriveKeyPairProduces64ByteOutput() {
        let secret = Data(repeating: 0xAB, count: 32)
        let keyPair = PushNotificationKeyDerivation.deriveKeyPair(from: secret, info: "2025-01")

        #expect(keyPair.sharedSecret.count == 32)
        #expect(keyPair.aesGCMKey.count == 32)
    }

    @Test("Derivation is deterministic")
    func deriveKeyPairIsDeterministic() {
        let secret = Data(hexEncoded: "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2")
        let result1 = PushNotificationKeyDerivation.deriveKeyPair(from: secret, info: "2024-06")
        let result2 = PushNotificationKeyDerivation.deriveKeyPair(from: secret, info: "2024-06")

        #expect(result1 == result2)
    }

    @Test("Different info produces different keys")
    func deriveKeyPairDifferentInfoProducesDifferentKeys() {
        let secret = Data(hexEncoded: "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2")
        let result1 = PushNotificationKeyDerivation.deriveKeyPair(from: secret, info: "2024-06")
        let result2 = PushNotificationKeyDerivation.deriveKeyPair(from: secret, info: "2024-07")

        #expect(result1.sharedSecret != result2.sharedSecret)
        #expect(result1.aesGCMKey != result2.aesGCMKey)
    }
}
