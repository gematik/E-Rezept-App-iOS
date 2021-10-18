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
import Foundation

extension Publisher where Output == IDPSession, Failure == Never {
    /// Request a challenge from the IDP for a specific scope
    ///
    /// - Returns: response with user content statement and signing challenge
    public func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        setFailureType(to: IDPError.self)
            .flatMap { $0.requestChallenge() }
            .eraseToAnyPublisher()
    }

    /// Verify a given challenge with the IDP
    ///
    /// - Parameters:
    ///   - challenge: the received challenge that has been signed
    /// - Returns: exchange token upon success
    public func verify(signedChallenge: SignedChallenge)
        -> AnyPublisher<IDPExchangeToken, IDPError> {
        setFailureType(to: IDPError.self)
            .flatMap { $0.verify(signedChallenge) }
            .eraseToAnyPublisher()
    }

    /// Exchange a token for an actual token
    ///
    /// - Parameters:
    ///   - token: exchange token
    ///   - verifier: initial verifier generated upon requesting the challenge
    /// - Returns: the authenticated token
    public func exchange(token: IDPExchangeToken,
                         challengeSession: ChallengeSession,
                         redirectURI: String? = nil) -> AnyPublisher<IDPToken, IDPError> {
        setFailureType(to: IDPError.self)
            .flatMap { $0.exchange(token: token, challengeSession: challengeSession, redirectURI: redirectURI) }
            .eraseToAnyPublisher()
    }

    /// Extend (or request) a new token for a SSO_TOKEN
    ///
    /// - Parameter token: token should contain a SSO_TOKEN
    /// - Returns: a re-authenticated token
    public func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        setFailureType(to: IDPError.self)
            .flatMap { $0.refresh(token: token) }
            .eraseToAnyPublisher()
    }
}
