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

import Combine
import Foundation

/// Protocol for challenge sessions that need to be verified at some point in the process.
public protocol ChallengeSession {
    /// The verifier code used to request the `challenge`
    var verifierCode: VerifierCode { get }

    /// Validate the session with the given id token
    func validateNonce(with idToken: String) throws -> Bool
}

public struct ExtAuthChallengeSession: ChallengeSession, Equatable {
    public var verifierCode: VerifierCode
    public let nonce: String
    public let entry: KKAppDirectory.Entry

    public init(verifierCode: VerifierCode, nonce: String, for entry: KKAppDirectory.Entry) {
        self.verifierCode = verifierCode
        self.nonce = nonce
        self.entry = entry
    }

    public func validateNonce(with idToken: String) throws -> Bool {
        let idTokenJWT = try JWT(from: idToken)
        let idTokenPayload = try idTokenJWT.decodePayload(type: TokenPayload.IDTokenPayload.self)
        return idTokenPayload.nonce == nonce
    }
}

/// sourcery: StreamWrapped
public protocol ExtAuthRequestStorage: AnyObject {
    func setExtAuthRequest(_ request: ExtAuthChallengeSession?, for state: String)
    func getExtAuthRequest(for state: String) -> ExtAuthChallengeSession?

    /// Removes all pending requests
    func reset()

    var pendingExtAuthRequests: AnyPublisher<[ExtAuthChallengeSession], Never> { get }
}

/// All relevant constraints needed for a successful challenge exchange
public struct IDPChallengeSession: ChallengeSession, Codable {
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
            // [REQ:gemSpec_IDP_Frontend:A_20526-01] Embed certificate
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
