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
import DataKit
import Foundation
@testable import IDP
import Nimble
import OpenSSL
import XCTest

class IDPChallengeSessionTest: XCTestCase {
    func testSigningWithJWTSigner() {
        let signer = TestJWTSigner()
        signer.signature = Data([0x0, 0x1, 0x3, 0x4])
        let challenge = try! IDPChallenge(
            challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
        )
        let session = IDPChallengeSession(
            challenge: challenge,
            verifierCode: "1234567890",
            state: "random State",
            nonce: "random Nonce"
        )
        let certificates = [Data(repeating: 0x7F, count: 100)]
        let expectedHeaderAndPayload = try! JWT(
            header: JWT.Header(alg: .bp256r1, x5c: certificates, typ: "JWT", cty: "NJWT"),
            payload: IDPChallengeResponse(njwt: session.challenge.challenge)
        )
        let expectedSerialized = expectedHeaderAndPayload.serialize().data(using: .ascii)! + [0x2E] + signer
            .signature!
            .encodeBase64urlsafe()
        session.sign(with: signer, using: certificates) // swiftlint:disable:this trailing_closure
            .map { $0.serialize() }
            .test(expectations: { serialized in
                expect(serialized) == expectedSerialized.asciiString
            })
    }
}
