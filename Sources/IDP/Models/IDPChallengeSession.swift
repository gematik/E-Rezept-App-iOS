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

import Combine
import DataKit
import Foundation

/// Protocol for challenge sessions that need to be verified at some point in the process.
public protocol ChallengeSession {
    /// The verifier code used to request the `challenge`
    var verifierCode: VerifierCode { get }

    /// Validate the session with the given id token
    func validateNonce(with idToken: String) throws -> Bool
}

public struct ExtAuthChallengeSession: ChallengeSession {
    public var verifierCode: VerifierCode
    public let nonce: String

    public init(verifierCode: VerifierCode, nonce: String) {
        self.verifierCode = verifierCode
        self.nonce = nonce
    }

    public func validateNonce(with idToken: String) throws -> Bool {
        let idTokenJWT = try JWT(from: idToken)
        let idTokenPayload = try idTokenJWT.decodePayload(type: TokenPayload.IDTokenPayload.self)
        return idTokenPayload.nonce == nonce
    }
}

public protocol ExtAuthRequestStorage: AnyObject {
    func setExtAuthRequest(_ request: ExtAuthChallengeSession, for state: String)
    func getExtAuthRequest(for state: String) -> ExtAuthChallengeSession?
}

/// All relevant constraints needed for a successful challenge exchange
public struct IDPChallengeSession: ChallengeSession {
    /// The verified challenge
    public let challenge: IDPChallenge
    /// The verifier code used to request the `challenge`
    public let verifierCode: VerifierCode
    /// The state used for request the challenge
    public let state: String
    /// A random string used for requesting the challenge
    public let nonce: String

    /// Initialize an IDP Challenge session
    ///
    /// - Parameters:
    ///   - challenge: The challenge that should have been verified before
    ///   - verifierCode: The verifier code used to start the challenge session
    ///   - state: State used for requesting the challenge
    ///   - nonce: Nonce used for requesting the challenge
    public init(challenge: IDPChallenge, verifierCode: VerifierCode, state: String, nonce: String) {
        self.challenge = challenge
        self.verifierCode = verifierCode
        self.state = state
        self.nonce = nonce
    }

    /// Create the signed IDPChallenge response JWT
    ///
    /// - Parameter signer: JWT Signature provider
    /// - Parameter certificates: X.509 DER encoded certificate chain
    /// - Parameter alg: signature algorithm. Default: "BP256R1"
    /// - Returns: signed JWT
    public func sign(
        with signer: JWTSigner,
        using certificates: [Data],
        alg: JWT.Algorithm = .bp256r1,
        jsonEncoder _: JSONEncoder = JSONEncoder()
    ) -> AnyPublisher<SignedChallenge, Swift.Error> {
        Deferred { () -> AnyPublisher<SignedChallenge, Swift.Error> in
            // [REQ:gemF_Tokenverschlüsselung:A_20526-01] Embed certificate
            let header = JWT.Header(alg: alg, x5c: certificates, typ: "JWT", cty: "NJWT")
            let payload = IDPChallengeResponse(njwt: challenge.challenge.serialize())
            do {
                return try JWT(header: header, payload: payload)
                    .sign(with: signer)
                    .map { jwt in
                        SignedChallenge(originalChallenge: self, signedChallenge: jwt)
                    }
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }

    func validateState(with state: String) -> Bool {
        self.state == state
    }

    public func validateNonce(with idToken: String) throws -> Bool {
        let idTokenJWT = try JWT(from: idToken)
        let idTokenPayload = try idTokenJWT.decodePayload(type: TokenPayload.IDTokenPayload.self)
        return idTokenPayload.nonce == nonce
    }
}

extension IDPChallengeSession: Equatable {}
