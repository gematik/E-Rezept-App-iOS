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
import CombineSchedulers
import DataKit
import Foundation

/// VerifierCode
public typealias VerifierCode = String
/// IDP Scope
public typealias IDPScope = String

/// IDPSession acts as an interactor/mediator for the IDPClient and IDPStorage
/// sourcery: StreamWrapped
public protocol IDPSession {
    /// Whether the session has access to a (valid) authenticated session (e.g. token)
    var isLoggedIn: AnyPublisher<Bool, IDPError> { get }

    /// Subscribe to the session's IDPToken and receive the latest (session) token through this Publisher
    var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> { get }

    /// Invalidates the active token. Use to logout the user or mark the existing Session as invalid, e.g. due to an
    /// 403/forbidden server response.
    func invalidateAccessToken()

    /// Request a challenge from the IDPClient for certain scopes
    ///
    /// - Returns: Published `IDPChallengeSession`
    func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError>

    /// Verify the signed challenge
    ///
    /// - Parameters:
    ///   - signedChallenge: the received challenge
    /// - Returns:
    func verify(_ signedChallenge: SignedChallenge)
        -> AnyPublisher<IDPExchangeToken, IDPError>

    /// Exchange the token with verifier for the actual token
    ///
    /// - Parameters:
    ///   - token: the exchange token
    ///   - verifier: plain verifier code
    ///   - redirectUIR: optional redirect URI to use for the token exchange.
    /// - Returns:
    func exchange(token: IDPExchangeToken,
                  challengeSession: ChallengeSession,
                  redirectURI: String?) -> AnyPublisher<IDPToken, IDPError>

    /// Refresh token
    ///
    /// - Parameter token: the token to refresh
    /// - Returns: renewed token or error
    func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError>

    /// Pairs the device with a biometric key.
    ///
    /// - Parameters:
    ///   - registrationData: `RegistrationData` containing information about the biometric key to register.
    ///   - token: Accesstoken for authentication and authorization for the new key.
    /// - Returns: AnyPublisher with a`PairingEntry` containing registration information upon success.
    func pairDevice(with registrationData: RegistrationData, token: IDPToken) -> AnyPublisher<PairingEntry, IDPError>

    /// Unregisters the devices key with the given identifier.
    /// - Parameter keyIdentifier: Key identifier to unregister.
    func unregisterDevice(_ keyIdentifier: String) -> AnyPublisher<Bool, IDPError>

    /// Verify a given challenge with the IDP using alternative authentication, a.k.a. biometric secured key.
    ///
    /// - Parameter signedChallenge: `SignedAuthenticationData` that is signed with a biometric key instead of an eGK.
    /// - Returns: AnyPublisher with `IDPExchangeToken` if successfull, fails with an `IDPError` otherwise.
    func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError>

    /// Load available Insurance companies that are capable of External Authentication (*FastTrack*).
    func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError>

    /// Initial step for external authentication with insurance company app.
    /// - Parameters:
    ///   - entry: The reference to an insurance company app to user for the authentication.
    func startExtAuth(entry: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError>

    /// Follow up step whenever an insurance company app authorizes a user login.
    /// - Parameters:
    ///   - url: Universal link containing login information
    func extAuthVerifyAndExchange(_ url: URL) -> AnyPublisher<IDPToken, IDPError>
}

extension IDPSession {
    /// Verify signed challenge and immediately exchange the token
    ///
    /// - Parameter challenge: singed challenge
    /// - Returns: Publisher that emits `IDPToken` or `IDPError`
    public func verifyAndExchange(signedChallenge: SignedChallenge) -> AnyPublisher<IDPToken, IDPError> {
        verify(signedChallenge)
            .flatMap { exchangeToken in
                self.exchange(token: exchangeToken,
                              challengeSession: signedChallenge.originalChallenge,
                              redirectURI: nil)
            }
            .eraseToAnyPublisher()
    }
}

extension IDPSession {
    /// Create a new IDPInterceptor for this session
    ///
    /// - Parameter delegate: the IDP Session delegate
    /// - Returns: new IDPInterceptor
    public func httpInterceptor(delegate: IDPSessionDelegate?) -> IDPInterceptor {
        IDPInterceptor(session: self, delegate: delegate)
    }
}
