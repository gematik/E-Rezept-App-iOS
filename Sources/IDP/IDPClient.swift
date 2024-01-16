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

public enum IDPCodeChallengeMode: String {
    case plain
    case sha256 = "S256"
}

/// Identity Provider protocol that should be implemented according to 'gemSpec_IDP_Dienst'.
public protocol IDPClient {
    /// Load the DiscoveryDocument for the IDPClient
    ///
    /// - Returns: a stream that emits once either a DiscoveryDocument or IDPError.
    func loadDiscoveryDocument() -> AnyPublisher<DiscoveryDocument, IDPError>

    /// Request a challenge from the IDP for a specific scope
    ///
    /// - Note: for more info check out 'gemSpec_IDP_Dienst#3.7'
    ///
    /// - Parameter codeChallenge: SHA256 hashed verifier code, see `exchange(token:)`.
    /// - Parameter method: codeChallenge hashing method. Must be S256 to indicate SHA256 hashed value.
    /// - Parameter state: OAuth parameter state of high entropy.
    /// - Parameter nonce: OpenID parameter nonce of high entropy.
    /// - Parameter document:
    ///     use this DiscoveryDocument to resolve the actual endpoint and verify the response(s) [when applicable]
    /// - Parameter redirect: Overwrite the common redirect. Used for FastTrack where the redirect differs from normal
    ///     IDP usage.
    /// - Returns: response with user content statement and signing challenge
    func requestChallenge( // swiftlint:disable:this function_parameter_count
        codeChallenge: String,
        method: IDPCodeChallengeMode,
        state: String,
        nonce: String,
        using document: DiscoveryDocument,
        redirect: String?
    ) -> AnyPublisher<IDPChallenge, IDPError>

    /// Verify a given challenge with the IDP
    ///
    /// - Parameters:
    ///   - signedChallenge: Encrypted challenge that has been signed with the egk
    ///   - document: Use this DiscoveryDocument to resolve the actual endpoints
    /// - Returns: exchange token upon success
    func verify(
        _ signedChallenge: JWE,
        using document: DiscoveryDocument
    ) -> AnyPublisher<IDPExchangeToken, IDPError>

    /// Refreshes the authentication with a given SSO token. The SSO token must be retrieved by a prior`verify` and
    /// `exchange`.
    ///
    /// - Parameters:
    ///   - unsigned: The unsigned IDP-Challenge. Generate a new challenge for each sso refresh by using
    ///               `requestChallenge`.
    ///   - sso: The SSO token from a prior successful login via `verify` and `exchange`.
    ///   - document: The discovery document to use.
    ///   - redirect: The redirect that the refresh is requested for. Must match the initial SSO token redirect.
    func refresh(with unsignedChallenge: IDPChallenge,
                 ssoToken: String,
                 using document: DiscoveryDocument,
                 for redirect: String) -> AnyPublisher<IDPExchangeToken, IDPError>

    /// Exchange a token for an actual token
    ///
    /// - Parameters:
    ///   - token: exchange token
    ///   - verifier: initial verifier generated upon requesting the challenge.
    ///               Must be at least 43 * 128-bit unreserved characters long.
    ///               See https://tools.ietf.org/html/rfc7636#section-4.2
    ///   - redirectURI: redirect_uri to use for the backend call.
    ///   - encryptedKeyVerifier: encrypted  symmetric key together with the `verifier`
    ///   - document: use this DiscoveryDocument to resolve the actual endpoint
    /// - Returns: the authenticated token
    func exchange(token: IDPExchangeToken,
                  verifier: String,
                  redirectURI: String?,
                  encryptedKeyVerifier: JWE,
                  using document: DiscoveryDocument) -> AnyPublisher<TokenPayload, IDPError>

    /// Register a new biometric key for alternative authentication.
    ///
    /// - Parameters:
    ///   - jwe: JWE encrypting the `PairingRegistration` of the key to register.
    ///   - token: Access token for authentication and authorization for the new key.
    ///   - document: use this DiscoveryDocument to resolve the actual endpoint
    /// - Returns: AnyPublisher with a`PairingEntry` containing registration information upon success.
    func registerDevice(_ jwe: JWE,
                        token: IDPToken,
                        using document: DiscoveryDocument)
        -> AnyPublisher<PairingEntry, IDPError>

    /// Unregisters a key of the device with the given identifier.
    /// - Parameters:
    ///   - keyIdentifier: Identifier of the key to remove.
    ///   - token: Authentication token to authenticate the removal.
    ///   - document: use this DiscoveryDocument to resolve the actual endpoint
    /// - Returns: AnyPublisher with a`Bool` containing `true` upon success, `false` otherwise.
    func unregisterDevice(_ keyIdentifier: String,
                          token: IDPToken,
                          using document: DiscoveryDocument) -> AnyPublisher<Bool, IDPError>

    /// List all registered devices.
    /// - Parameters:
    ///   - token: Authentication token to authenticate the removal.
    ///   - document: use this DiscoveryDocument to resolve the actual endpoint
    /// - Returns: AnyPublisher with a`PairingEntries` containing all registered devices.
    func listDevices(token: IDPToken, using document: DiscoveryDocument) -> AnyPublisher<PairingEntries, IDPError>

    /// Verify a given challenge with the IDP using alternative authentication, a.k.a. biometric secured key.
    /// - Parameters:
    ///   - encryptedSignedChallenge: JWE encrypting a `SignedAuthenticationChallenge`.
    ///   - document: Use this DiscoveryDocument to resolve the actual endpoints and
    /// - Returns: exchange token upon success
    func altVerify(_ encryptedSignedChallenge: JWE,
                   using document: DiscoveryDocument)
        -> AnyPublisher<IDPExchangeToken, IDPError>

    /// Load available Insurance companies that are capable of External Authentication (*FastTrack*).
    /// - Parameter document: The DiscoveryDocument to resolve the actual endpoint.
    func loadDirectoryKKApps(using document: DiscoveryDocument) -> AnyPublisher<IDPDirectoryKKApps, IDPError>

    /// Initial step for external authentication with insurance company app.
    /// - Parameters:
    ///   - app: The reference to an insurance company app to user for the authentication.
    ///   - document: The DiscoveryDocument to resolve the actual endpoint.
    func startExtAuth(_ app: IDPExtAuth, using document: DiscoveryDocument) -> AnyPublisher<URL, IDPError>

    /// Follow up step whenever an insurance company app authorizes a user login.
    /// - Parameters:
    ///   - verify: Data used to authenticate and authorize the user.
    ///   - document: The DiscoveryDocument to resolve the actual endpoint.
    func extAuthVerify(_ verify: IDPExtAuthVerify, using document: DiscoveryDocument)
        -> AnyPublisher<IDPExchangeToken, IDPError>
}

extension IDPClient {
    /// Request a challenge from the IDP for a specific scope
    ///
    /// - Note: for more info check out 'gemSpec_IDP_Dienst#3.7'
    ///
    /// - Parameter codeChallenge: SHA256 hashed verifier code, see `exchange(token:)`.
    /// - Parameter method: codeChallenge hashing method. Must be S256 to indicate SHA256 hashed value.
    /// - Parameter state: OAuth parameter state of high entropy.
    /// - Parameter nonce: OpenID parameter nonce of high entropy.
    /// - Parameter document:
    ///     use this DiscoveryDocument to resolve the actual endpoint and verify the response(s) [when applicable]
    /// - Returns: response with user content statement and signing challenge
    func requestChallenge(
        codeChallenge: String,
        method: IDPCodeChallengeMode,
        state: String,
        nonce: String,
        using document: DiscoveryDocument
    ) -> AnyPublisher<IDPChallenge, IDPError> {
        requestChallenge(
            codeChallenge: codeChallenge,
            method: method,
            state: state,
            nonce: nonce,
            using: document,
            redirect: nil
        )
    }
}
