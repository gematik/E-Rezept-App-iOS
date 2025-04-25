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
@testable import IDP
import Nimble
import OpenSSL
import XCTest

class JWTTests: XCTestCase {
    private let verifyingKey = try! BrainpoolP256r1.Verify.PublicKey(x962: Data(
        hex: "049650AC6D4D5B1201DE4CFFE99DB3A2396426A377BC95D9DC466727A2574D7C39643159E578F05A6B607E89AFDD5395EEACC8E72714489CAC3160C4BB79AA45C6" // swiftlint:disable:this line_length
    ))

    let document = try! Bundle.module
        .testResourceFilePath(in: "Resources/JWT", for: "discovery-doc.jwt")
        .readFileContents()

    func testParsingAndValidatingJWT() {
        // Check header vor correct algorithm
        let jwt = try! JWT(from: document)
        expect(jwt.header.alg) == .bp256r1

        // Check payload
        let payload = try! jwt.decodePayload(type: DiscoveryDocumentPayload.self)
        expect(payload.exp.timeIntervalSince1970) == 1_616_143_876
        expect(payload.iat.timeIntervalSince1970) == 1_616_057_476
        expect(payload.token) == URL(string: "http://localhost:8888/token")
        expect(payload.authentication) == URL(string: "http://localhost:8888/sign_response")

        // Check signature
        let data = try! Data(
            hex: "9334442839a3318ede0569f28c97a08a3e2cac57083b31f2790b3f080cf8038a73a1b3254c30bd40d3744b5cbe6f8113c7a382872a7f3ae1420bfe20e1c9686d" // swiftlint:disable:this line_length
        )
        expect(jwt.signature) == data

        guard let x5cData = jwt.header.x5c?.first,
              let x509 = try? X509(der: x5cData) else {
            fail("no valid x5c found")
            return
        }
        expect(x509.brainpoolP256r1VerifyPublicKey()).toNot(beNil())
        expect(try jwt.verify(with: x509.brainpoolP256r1VerifyPublicKey()!)).to(beTrue())
    }

    func testParsingInvalidJWT() {
        expect(try JWT(from: "invalid. payload without signature")).to(throwError(JWT.Error.malformedJWT))
    }

    func testParsingInvalidJWTNoPayload() {
        expect(try JWT(from: "eyAiYWxnIjogIm5vbmUiIH0..eyJwYXlsb2FkIjoidGV4dCJ9"))
            .to(throwError(JWT.Error.malformedJWT))
    }

    func testParsingInvalidJWTHeaderOnly() {
        expect(try JWT(from: "eyAiYWxnIjogIm5vbmUiIH0..")).to(throwError(JWT.Error.malformedJWT))
        expect(try JWT(from: "eyAiYWxnIjogIm5vbmUiIH0.")).to(throwError(JWT.Error.malformedJWT))
        expect(try JWT(from: "eyAiYWxnIjogIm5vbmUiIH0")).to(throwError(JWT.Error.malformedJWT))
    }

    func testParsingUnsignedJWT() {
        struct Payload: Claims {
            let payload: String
        }
        let jwt = try! JWT(from: "eyAiYWxnIjogIm5vbmUiIH0.eyJwYXlsb2FkIjoidGV4dCJ9")

        expect(jwt.header.alg) == JWT.Algorithm.none

        let payload = try! jwt.decodePayload(type: Payload.self)
        expect(payload.payload) == "text"

        expect(try jwt.verify(with: self.verifyingKey)).to(throwError(JWT.Error.noSignature))
    }

    func testSerialize() {
        let jwt = try! JWT(from: document)
        let data = jwt.serialize()
        expect(data.data(using: .ascii)) == document
    }

    func testSerializingAndSigningJWT() {
        let jwtParts = String(data: document, encoding: .ascii)!.split(separator: ".")
        let jwt = try! JWT(from: document)
        let signer = TestJWTSigner()
        let signature = "signature".data(using: .ascii)!
        signer.signature = signature

        let expectedSerializedJWT = "\(jwtParts[0]).\(jwtParts[1]).".data(using: .ascii)! + signature
            .encodeBase64UrlSafe()!

        jwt.sign(with: signer) // swiftlint:disable:this trailing_closure
            .test(expectations: { signedJWT in
                expect(signedJWT.signature) == signature
                expect(signedJWT.serialize().data(using: .ascii)) == expectedSerializedJWT
            })
        expect(signer.messages.count) == 1
        expect(signer.messages[0]) == "\(jwtParts[0]).\(jwtParts[1])".data(using: .ascii)
    }
}

class TestJWTSigner: JWTSigner {
    var messages = [Data]()
    var signature: Data?

    func sign(message: Data) async throws -> Data {
        messages.append(message)
        guard let signature = signature else {
            throw IDPError.unsupported("No signature set in TestJWTSigner")
        }
        return signature
    }
}
