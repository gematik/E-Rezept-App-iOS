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
// swiftlint:disable file_length
// swiftlint:disable type_body_length

import Combine
import CombineSchedulers
import DataKit
import Foundation
import GemCommonsKit
import HTTPClient
import TrustStore

/// Random generator function type
public typealias Random<T> = (Int) throws -> T
/// Function that returns the current date/now
public typealias TimeProvider = () -> Date

/// IDPSession acts as an interactor/mediator for the IDPClient and IDPStorage
public class DefaultIDPSession: IDPSession {
    private let client: IDPClient
    private let storage: IDPStorage
    private let schedulers: IDPSchedulers
    private let time: TimeProvider
    private let cryptoBox: IDPCrypto
    private let trustStoreSession: TrustStoreSession
    private let extAuthRequestStorage: ExtAuthRequestStorage

    private var disposeBag = Set<AnyCancellable>()

    /// Initialize a DefaultIDPSession
    ///
    /// - Parameters:
    ///   - config: the IDP configuration
    ///   - storage: the IDP Storage
    ///   - schedulers: the Schedulers to use for internal operations
    ///   - httpClient: a `HTTPClient` for performing the network operations
    ///   - trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the discoveryDocument
    public convenience init(
        config: Configuration,
        storage: IDPStorage,
        schedulers: IDPSchedulers,
        httpClient: HTTPClient,
        trustStoreSession: TrustStoreSession,
        extAuthRequestStorage: ExtAuthRequestStorage
    ) {
        self.init(
            client: RealIDPClient(client: config, httpClient: httpClient),
            storage: storage,
            schedulers: schedulers,
            trustStoreSession: trustStoreSession,
            extAuthRequestStorage: extAuthRequestStorage
        )
    }

    /// Initialize an IDP Session
    ///
    /// - Parameters:
    ///   - client: IDP Client
    ///   - storage: the backing session storage
    ///   - schedulers: the schedulers for the session's internal operations
    ///   - trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the discoveryDocument
    ///   - time: the time provider
    ///   - idpCrypto: Crypto material relevant for encryption, decryption and validation
    required init(
        client: IDPClient,
        storage: IDPStorage,
        schedulers: IDPSchedulers,
        trustStoreSession: TrustStoreSession,
        extAuthRequestStorage: ExtAuthRequestStorage,
        time: @escaping TimeProvider = Date.init,
        idpCrypto: IDPCrypto = IDPCrypto()
    ) {
        self.client = client
        self.storage = storage
        self.schedulers = schedulers
        self.time = time
        self.trustStoreSession = trustStoreSession
        self.extAuthRequestStorage = extAuthRequestStorage
        cryptoBox = idpCrypto

        loadDiscoveryDocument()
            .subscribe(on: schedulers.networkIO)
            .receive(on: schedulers.serialIO)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    DLog("Discovery document error: \(error)")
                }
            }, receiveValue: { _ in
                // document should have been saved by `loadDiscoveryDocument`, prevent double trigger(s)
            })
            .store(in: &disposeBag)
    }

    /// Whether the session has access to a (valid) authenticated session (e.g. token)
    public var isLoggedIn: AnyPublisher<Bool, IDPError> {
        // [REQ:gemSpec_eRp_FdV:A_21326#3,A_21327#3] Triggered at every app start, profile change, pull to refresh
        autoRefreshedToken.map { token in
            token != nil
        }
        .eraseToAnyPublisher()
    }

    public func invalidateAccessToken() {
        // [REQ:BSI-eRp-ePA:O.Source_5#3] Invalidation means deleting the token
        storage.set(token: nil)
    }

    /// Subscribe to the session's IDPToken and receive the latest (session) token through this Publisher
    public var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
        storage.token
            .refreshIfExpired(session: self, time: time)
            .eraseToAnyPublisher()
    }

    public func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        getAndValidateChallenge(redirect: nil)
            .flatMap { [weak self] challengeSession -> AnyPublisher<IDPChallengeSession, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .requestChallengeUnexpectedNil)).eraseToAnyPublisher()
                }
                guard let expirationDate = challengeSession.challenge.exp,
                      expirationDate.timeIntervalSince(self.time()) > 0 else {
                    return Fail(error:
                        IDPError.internal(error: .challengeExpired))
                        .eraseToAnyPublisher()
                }
                return Just(challengeSession)
                    .setFailureType(to: IDPError.self)
                    .merge(with: Just(())
                        // To prevent endless-recursion we call Just(Void()) instead of self.requestChallenge(scope: scope) | swiftlint:disable:this line_length
                        .setFailureType(to: IDPError.self)
                        .delay(
                            for: .init(expirationDate.timeIntervalSince(self.time()).toDispatchTimeInterval()),
                            scheduler: self.schedulers.compute
                        )
                        .flatMap { _ -> AnyPublisher<IDPChallengeSession, IDPError> in
                            self.requestChallenge()
                        })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func verify(_ signedChallenge: SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<IDPExchangeToken, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .verifyUnexpectedNil)).eraseToAnyPublisher()
                }
                // [REQ:gemF_Tokenverschlüsselung:A_20526-01] Encryption with JWE
                guard let jwe = try? signedChallenge.encrypt(with: document.encryptionPublicKey,
                                                             using: self.cryptoBox) else {
                    return Fail(error: IDPError.encryption).eraseToAnyPublisher()
                }

                return self.client.verify(jwe, using: document)
            }
            .flatMap { exchangeToken -> AnyPublisher<IDPExchangeToken, IDPError> in
                guard signedChallenge.originalChallenge.validateState(with: exchangeToken.state) else {
                    return Fail(error: IDPError.invalidStateParameter).eraseToAnyPublisher()
                }

                // [REQ:gemSpec_IDP_Frontend:A_20527] Returning the AUTHORIZATION_CODE
                return Just(exchangeToken).setFailureType(to: IDPError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // swiftlint:disable:next function_body_length
    public func exchange(
        token exchange: IDPExchangeToken,
        challengeSession: ChallengeSession,
        idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>
    ) -> AnyPublisher<IDPToken, IDPError> {
        loadDiscoveryDocument() // swiftlint:disable:this trailing_closure
            .flatMap { [weak self] document -> AnyPublisher<IDPToken, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .exchangeUnexpectedNil)).eraseToAnyPublisher()
                }
                // [REQ:gemSpec_IDP_Frontend:A_20529-01] Encryption
                // [REQ:gemSpec_IDP_Frontend:A_21323,A_21324#1] Crypto box contains `Token-Key`
                guard let encryptedKeyVerifier = try? KeyVerifier(
                    with: self.cryptoBox.aesKey,
                    codeVerifier: challengeSession.verifierCode
                ).encrypted(with: document.encryptionPublicKey, using: self.cryptoBox) else {
                    return Fail(error: IDPError.encryption).eraseToAnyPublisher()
                }

                return self.client.exchange(
                    token: exchange,
                    verifier: challengeSession.verifierCode,
                    redirectURI: exchange.redirect,
                    encryptedKeyVerifier: encryptedKeyVerifier,
                    using: document
                )
                .flatMap { [weak self] token -> AnyPublisher<IDPToken, IDPError> in
                    guard let self = self else {
                        return Fail(error: IDPError.internal(error: .exchangeTokenUnexpectedNil)).eraseToAnyPublisher()
                    }
                    // [REQ:gemSpec_IDP_Frontend:A_19938-01,A_20283-01] Decrypt, fails if wrong aes key
                    guard let decrypted = try? token.decrypted(with: self.cryptoBox.aesKey) else {
                        return Fail(error: IDPError.decryption).eraseToAnyPublisher()
                    }
                    guard (try? challengeSession.validateNonce(with: decrypted.idToken)) ?? false else {
                        return Fail(error: IDPError.invalidNonce).eraseToAnyPublisher()
                    }
                    // [REQ:gemSpec_IDP_Frontend:A_20625] Validate ID_TOKEN signature
                    guard let jwt = try? JWT(from: decrypted.idToken),
                          (try? jwt.verify(with: document.signingCert)) ?? false else {
                        return Fail(error: IDPError.invalidSignature("ID_TOKEN")).eraseToAnyPublisher()
                    }
                    do {
                        let idToken = try jwt.decodePayload(type: TokenPayload.IDTokenPayload.self)
                        if case let .failure(validationError) = idTokenValidator(idToken) {
                            return Fail(error: IDPError.unspecified(error: validationError)).eraseToAnyPublisher()
                        }
                    } catch {
                        return Fail(error: IDPError.unspecified(error: error)).eraseToAnyPublisher()
                    }
                    return Just(IDPToken(
                        accessToken: decrypted.accessToken, // [REQ:gemSpec_IDP_Frontend:A_20283-01] Usage
                        expires: self.time().addingTimeInterval(TimeInterval(token.expiresIn)),
                        idToken: decrypted.idToken, // [REQ:gemSpec_IDP_Frontend:A_19938-01] Usage
                        ssoToken: exchange.sso,
                        tokenType: decrypted.tokenType,
                        redirect: exchange.redirect
                    )).setFailureType(to: IDPError.self).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] token in
                // [REQ:BSI-eRp-ePA:O.Tokn_1#5] Storing the token from a successfull login
                self?.storage.set(token: token)
            })
            .eraseToAnyPublisher()
    }

    public func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        guard let ssoToken = token.ssoToken else {
            return Fail(error: IDPError.tokenUnavailable).eraseToAnyPublisher()
        }
        return getAndValidateChallenge(redirect: token.redirect)
            .flatMap { [weak self] challengeSession -> AnyPublisher<IDPToken, IDPError> in // IDPChallengeSession
                guard let self = self else {
                    return Fail<IDPToken, IDPError>(error: IDPError.internal(error: .refreshTokenUnexpectedNil))
                        .eraseToAnyPublisher()
                }
                return self.ssoLoginAndExchange(
                    challengeSession: challengeSession,
                    ssoToken: ssoToken,
                    redirect: token.redirect
                )
            }
            .eraseToAnyPublisher()
    }

    // [REQ:BSI-eRp-ePA:O.Resi_6#2] Implementation of loading the discovery document for fetching signature and
    // encryption keys.
    private func loadDiscoveryDocument() -> AnyPublisher<DiscoveryDocument, IDPError> {
        storage.discoveryDocument
            .first()
            // [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623,A_20614]
            .validateOrNil(with: trustStoreSession, timeProvider: time)
            .setFailureType(to: IDPError.self)
            .flatMap { [weak self] document -> AnyPublisher<DiscoveryDocument, IDPError> in
                guard let self = self else {
                    return Fail(
                        error: IDPError.internal(error: .loadDiscoveryDocumentUnexpectedNil)
                    ).eraseToAnyPublisher()
                }
                if let document = document {
                    return Just(document).setFailureType(to: IDPError.self).eraseToAnyPublisher()
                } else {
                    // [REQ:gemSpec_IDP_Frontend:A_20512]
                    self.storage.set(discovery: nil)
                    return self.client // swiftlint:disable:this trailing_closure
                        .loadDiscoveryDocument()
                        .flatMap { fetchedDocument -> AnyPublisher<DiscoveryDocument, IDPError> in
                            // Validate JWT/DiscoveryDocument signature
                            // [REQ:gemSpec_Krypt:A_17207] Only implemented for brainpoolP256r1
                            // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02] Assure that brainpoolP256r1 is used
                            // [REQ:gemSpec_Krypt:GS-A_4361-02] Assure that brainpoolP256r1 is used
                            // [REQ:BSI-eRp-ePA:O.Resi_6#4] Discovery Document signature verification
                            guard (try? fetchedDocument.backing.verify(with: fetchedDocument.discKey)) ?? false else {
                                return Fail(error: IDPError.validation(error: IDPError.invalidDiscoveryDocument))
                                    .eraseToAnyPublisher()
                            }
                            if fetchedDocument.isValid(on: self.time()) {
                                return Just(fetchedDocument).setFailureType(to: IDPError.self).eraseToAnyPublisher()
                            } else {
                                return Fail(error: IDPError.validation(error: IDPError.invalidDiscoveryDocument))
                                    .eraseToAnyPublisher()
                            }
                        }
                        // [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623]
                        .validate(with: self.trustStoreSession, timeProvider: self.time)
                        .handleEvents(receiveOutput: { [weak self] renewed in
                            self?.storage.set(discovery: renewed)
                        })
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    public func pairDevice(with registrationData: RegistrationData,
                           token: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<PairingEntry, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .pairDeviceUnexpectedNil)).eraseToAnyPublisher()
                }
                /// [REQ:gemSpec_IDP_Frontend:A_21416] Encryption
                guard let jwe = try? registrationData.encrypted(with: document.encryptionPublicKey,
                                                                using: self.cryptoBox) else {
                    return Fail(error: IDPError.encryption).eraseToAnyPublisher()
                }

                // [REQ:gemSpec_IDP_Frontend:A_21414] Encrypt ACCESS_TOKEN when requesting the pairing endpoint
                guard let tokenJWT = try? JWT(from: token.accessToken),
                      let tokenPayload = try? tokenJWT.decodePayload(type: TokenPayload.AccesTokenPayload.self),
                      let tokenJWE = try? JWE.nest(jwt: tokenJWT,
                                                   with: document.encryptionPublicKey,
                                                   using: self.cryptoBox,
                                                   expiry: tokenPayload.exp),
                      let encryptedAccessToken = tokenJWE.encoded().utf8string
                else {
                    return Fail(error: IDPError.encryption).eraseToAnyPublisher()
                }
                let encryptedToken = token.mutating(accessToken: encryptedAccessToken)

                return self.client.registerDevice(jwe, token: encryptedToken, using: document).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // [REQ:gemSpec_IDP_Frontend:A_21576] deletion call
    public func unregisterDevice(_ keyIdentifier: String, token: IDPToken) -> AnyPublisher<Bool, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<Bool, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .unregisterDeviceUnexpectedNil)).eraseToAnyPublisher()
                }
                // [REQ:gemSpec_IDP_Frontend:A_21443] Encrypt ACCESS_TOKEN when requesting the unregister endpoint
                guard let tokenJWT = try? JWT(from: token.accessToken),
                      let tokenPayload = try? tokenJWT.decodePayload(type: TokenPayload.AccesTokenPayload.self),
                      let tokenJWE = try? JWE.nest(jwt: tokenJWT,
                                                   with: document.encryptionPublicKey,
                                                   using: self.cryptoBox,
                                                   expiry: tokenPayload.exp),
                      let encryptedAccessToken = tokenJWE.encoded().utf8string
                else {
                    return Fail(error: IDPError.encryption).eraseToAnyPublisher()
                }
                let encryptedToken = token.mutating(accessToken: encryptedAccessToken)

                return self.client.unregisterDevice(keyIdentifier, token: encryptedToken, using: document)
            }
            .eraseToAnyPublisher()
    }

    public func listDevices(token: IDPToken) -> AnyPublisher<PairingEntries, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<PairingEntries, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .listDevicesUnexpectedNil)).eraseToAnyPublisher()
                }
                // [REQ:gemSpec_IDP_Frontend:A_21443] Encrypt ACCESS_TOKEN when requesting the list endpoint
                guard let tokenJWT = try? JWT(from: token.accessToken),
                      let tokenPayload = try? tokenJWT.decodePayload(type: TokenPayload.AccesTokenPayload.self),
                      let tokenJWE = try? JWE.nest(jwt: tokenJWT,
                                                   with: document.encryptionPublicKey,
                                                   using: self.cryptoBox,
                                                   expiry: tokenPayload.exp),
                      let encryptedAccessToken = tokenJWE.encoded().utf8string
                else {
                    return Fail(error: IDPError.encryption).eraseToAnyPublisher()
                }

                let encryptedToken = token.mutating(accessToken: encryptedAccessToken)

                return self.client.listDevices(token: encryptedToken, using: document)
            }
            .eraseToAnyPublisher()
    }

    public func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<IDPExchangeToken, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .altVerifyUnexpectedNil)).eraseToAnyPublisher()
                }
                /// [REQ:gemSpec_IDP_Frontend:A_21431] Encryption
                guard let jwe = try? signedChallenge.encrypted(with: document.encryptionPublicKey,
                                                               using: self.cryptoBox) else {
                    return Fail(error: IDPError.encryption).eraseToAnyPublisher()
                }

                return self.client.altVerify(jwe, using: document)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<KKAppDirectory, IDPError> in
                guard let self = self else {
                    return Fail(
                        error: IDPError.internal(error: .loadDirectoryKKAppsUnexpectedNil)
                    ).eraseToAnyPublisher()
                }
                return self.client.loadDirectoryKKApps(using: document)
                    .tryMap { jwtContainer in
                        // [REQ:gemSpec_IDP_Sek:A_22296] Signature verification
                        // [REQ:BSI-eRp-ePA:O.Resi_6#3] Discovery Document signature verification
                        guard try jwtContainer.verify(with: document.discKey) == true else {
                            throw IDPError.invalidSignature("kk_apps document signature wrong")
                        }
                        return try jwtContainer
                            .claims()
                            .filterGID()
                            .sorted()
                    }
                    .mapError { $0.asIDPError() }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func startExtAuth(entry: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<URL, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .startExtAuthUnexpectedNil)).eraseToAnyPublisher()
                }
                guard let verifierCode = try? self.cryptoBox.generateRandomVerifier(),
                      let codeChallenge = verifierCode.sha256()?.encodeBase64urlsafe().asciiString else {
                    return Fail(error: IDPError.internal(error: .extAuthVerifierCodeCreation))
                        .eraseToAnyPublisher()
                }
                guard let state = try? self.cryptoBox.generateRandomState(),
                      let nonce = try? self.cryptoBox.generateRandomNonce() else {
                    return Fail(error: IDPError.internal(error: .extAuthStateNonceCreation)).eraseToAnyPublisher()
                }

                // [REQ:gemSpec_IDP_Sek:A_22295] Usage of kk_app_id
                let extAuth = IDPExtAuth(kkAppId: entry.identifier,
                                         state: state,
                                         codeChallenge: codeChallenge,
                                         codeChallengeMethod: .sha256,
                                         nonce: nonce,
                                         authType: entry.gId ? .gid : .fasttrack)

                let challengeSession = ExtAuthChallengeSession(verifierCode: verifierCode, nonce: nonce, for: entry)

                // swiftlint:disable:next trailing_closure
                return self.client.startExtAuth(extAuth, using: document)
                    .first()
                    .handleEvents(receiveOutput: { redirectUrl in
                        let storageIdentifier: String
                        if entry.gId {
                            storageIdentifier = state
                        } else {
                            // [REQ:gemSpec_IDP_Sek:A_22299] Remember State parameter for later verification
                            guard let components = URLComponents(url: redirectUrl, resolvingAgainstBaseURL: true),
                                  let returnState = components.queryItemWithName("state")?.value
                            else {
                                return
                            }
                            storageIdentifier = returnState
                        }
                        self.extAuthRequestStorage.setExtAuthRequest(challengeSession, for: storageIdentifier)
                    })
                    .mapError { $0.asIDPError() }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func extAuthVerifyAndExchange(
        _ url: URL,
        idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>
    ) -> AnyPublisher<IDPToken, IDPError> {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItemWithName("code")?.value,
              let state = components.queryItemWithName("state")?.value else {
            return Fail(
                error: IDPError.internal(error: .extAuthVerifyAndExchangeMissingQueryItem)
            ).eraseToAnyPublisher()
        }

        let verify = IDPExtAuthVerify(code: code, state: state)

        // [REQ:gemSpec_IDP_Sek:A_22301] Send authorization request
        return extAuthVerify(verify)
            .flatMap { [weak self] token -> AnyPublisher<IDPToken, IDPError> in
                guard let self = self else {
                    return Fail(
                        error: IDPError.internal(error: .extAuthVerifyAndExchangeUnexpectedNil)
                    ).eraseToAnyPublisher()
                }

                guard let challengeSession = extAuthRequestStorage.getExtAuthRequest(for: token.state) else {
                    return Fail(error: IDPError.extAuthOriginalRequestMissing).eraseToAnyPublisher()
                }
                let isPkvFastTrackFlowInitiated = challengeSession.entry.identifier.hasSuffix("pkv")
                // swiftlint:disable:next trailing_closure
                return self.exchange(
                    token: token,
                    challengeSession: challengeSession,
                    idTokenValidator: idTokenValidator
                )
                // Temporary workaround (see above isPkvFastTrackFlowInitiated)
                .map { idpToken in
                    if isPkvFastTrackFlowInitiated {
                        return IDPToken(
                            accessToken: idpToken.accessToken,
                            expires: idpToken.expires,
                            idToken: idpToken.idToken,
                            ssoToken: idpToken.ssoToken,
                            tokenType: idpToken.tokenType,
                            redirect: idpToken.redirect,
                            isPkvFastTrackFlowInitiated: true
                        )
                    } else {
                        return idpToken
                    }
                }
                .handleEvents(receiveOutput: { _ in
                    self.extAuthRequestStorage.setExtAuthRequest(nil, for: token.state)
                })
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func extAuthVerify(_ verify: IDPExtAuthVerify) -> AnyPublisher<IDPExchangeToken, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<IDPExchangeToken, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .extAuthVerifyUnexpectedNil)).eraseToAnyPublisher()
                }
                return self.client.extAuthVerify(verify, using: document)
            }
            .eraseToAnyPublisher()
    }
}

extension IDPToken {
    func mutating(accessToken: String) -> IDPToken {
        IDPToken(
            accessToken: accessToken,
            expires: expires,
            idToken: idToken,
            ssoToken: ssoToken,
            tokenType: tokenType,
            redirect: redirect
        )
    }
}

extension DefaultIDPSession {
    /// IDP Configuration
    public struct Configuration {
        /// Client-ID
        let clientId: String
        /// Token exchange redirect URL
        let redirectURI: URL
        /// External Authentication redirect URI
        let extAuthRedirectURI: URL
        /// IDP server discovery url
        let discoveryURL: URL
        /// List of scopes to be authorized by the user.
        let scopes: [IDPScope]

        /// Initialize IDP Configuration
        ///
        /// - Parameters:
        ///   - clientId: client id
        ///   - redirectURL: token exchange redirect URL
        ///   - discoveryURL: IDP server discovery document URL
        ///   - scopes: List of scopes to be authorized by the user.
        public init(clientId: String,
                    redirectURI: URL,
                    extAuthRedirectURI: URL,
                    discoveryURL: URL,
                    scopes: [IDPScope]) {
            self.clientId = clientId
            self.redirectURI = redirectURI
            self.extAuthRedirectURI = extAuthRedirectURI
            self.discoveryURL = discoveryURL
            self.scopes = scopes
        }
    }

    private func getAndValidateChallenge(redirect: String?) -> AnyPublisher<IDPChallengeSession, IDPError> {
        loadDiscoveryDocument()
            .flatMap { [weak self] document -> AnyPublisher<IDPChallengeSession, IDPError> in
                guard let self = self else {
                    return Fail(error: IDPError.internal(error: .getAndValidateUnexpectedNil)).eraseToAnyPublisher()
                }
                // Generate a verifierCode
                // [REQ:gemSpec_IDP_Frontend:A_20309] generation and hashing for codeChallenge
                guard let verifierCode = try? self.cryptoBox.generateRandomVerifier(),
                      let codeChallenge = verifierCode.sha256()?.encodeBase64urlsafe().asciiString else {
                    return Fail(error: IDPError.internal(error: .verifierCodeCreation)).eraseToAnyPublisher()
                }
                guard let state = try? self.cryptoBox.generateRandomState(),
                      let nonce = try? self.cryptoBox.generateRandomNonce() else {
                    return Fail(error: IDPError.internal(error: .stateNonceCreation)).eraseToAnyPublisher()
                }
                // [REQ:gemSpec_IDP_Frontend:A_20483]
                return self.client.requestChallenge(
                    codeChallenge: codeChallenge,
                    method: .sha256,
                    state: state,
                    nonce: nonce,
                    using: document,
                    redirect: redirect
                )
                .flatMap { challenge -> AnyPublisher<IDPChallengeSession, IDPError> in

                    // [REQ:gemSpec_Krypt:A_17207] Only implemented for brainpoolP256r1
                    // [REQ:gemSpec_IDP_Frontend:A_19908-01] Signature check
                    // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02] Assure that brainpoolP256r1 is used
                    guard let verified = try? challenge.challenge.verify(with: document.authentication.cert),
                          verified else {
                        return Fail(error: IDPError.validation(error: JWT.Error.invalidSignature))
                            .eraseToAnyPublisher()
                    }
                    // Verify expiration date
                    guard let expirationDate = challenge.exp, self.time() < expirationDate else {
                        return Fail(error: IDPError.validation(error: JWT.Error.invalidExpirationDate))
                            .eraseToAnyPublisher()
                    }
                    return Just(IDPChallengeSession(challenge: challenge,
                                                    verifierCode: verifierCode,
                                                    state: state,
                                                    nonce: nonce))
                        .setFailureType(to: IDPError.self)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func ssoLoginAndExchange(challengeSession: IDPChallengeSession,
                                     ssoToken: String,
                                     redirect: String) -> AnyPublisher<IDPToken, IDPError> {
        let challenge = challengeSession.challenge
        return loadDiscoveryDocument()
            // swiftlint:disable:previous trailing_closure
            .flatMap { [weak self] document -> AnyPublisher<IDPToken, IDPError> in
                guard let self = self else {
                    return Fail(
                        error: IDPError.internal(error: .ssoLoginAndExchangeUnexpectedNil)
                    ).eraseToAnyPublisher()
                }
                return self.client.refresh(with: challenge, ssoToken: ssoToken, using: document, for: redirect)
                    .flatMap { exchangeToken in
                        self.exchange(token: exchangeToken, challengeSession: challengeSession)
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { [weak self] result in
                if case let .failure(error) = result,
                   case IDPError.serverError = error {
                    self?.storage.set(token: nil)
                }
            })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == DiscoveryDocument, Failure == IDPError {
    /// Returns a Publisher that validates the input streams discoveryDocument against the given trustStoreSession. If
    /// the validity cannot be verified, the publisher fails with an `IDPError.trustStore` error.
    ///
    /// [REQ:gemSpec_IDP_Frontend:A_20617-01]
    /// [REQ:gemSpec_IDP_Frontend:A_20623]
    ///
    /// - Parameter trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the
    /// discoveryDocument.
    /// - Returns: An AnyPublisher of `DiscoveryDocument`and `IDPError`
    func validate(with trustStoreSession: TrustStoreSession,
                  timeProvider: @escaping (() -> Date)) -> AnyPublisher<DiscoveryDocument, IDPError> {
        flatMap { document -> AnyPublisher<DiscoveryDocument, IDPError> in
            guard document.isValid(on: timeProvider()) else {
                return Fail(error: IDPError.invalidDiscoveryDocument).eraseToAnyPublisher()
            }
            // [REQ:gemSpec_IDP_Frontend:A_20623] Validation call
            return trustStoreSession.validate(discoveryDocument: document)
                .mapError { IDPError.trustStore(error: $0) }
                .flatMap { isValid -> AnyPublisher<DiscoveryDocument, IDPError> in
                    if isValid {
                        return Just(document).setFailureType(to: IDPError.self).eraseToAnyPublisher()
                    } else {
                        return Fail(error: IDPError.invalidDiscoveryDocument).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == DiscoveryDocument? {
    /// Returns a Publisher that validates the input streams discoveryDocument and returns nil if validity cannot be
    /// checked. All Errors are caught and result in an empty discoveryDocument.
    ///
    /// [REQ:gemSpec_IDP_Frontend:A_20617-01,A_20623]
    ///
    /// - Parameters:
    ///   - trustStoreSession: `TrustStoreSession` that is used to check the validity and trust of the disoveryDocument.
    ///   - time: Time provider to check the discovery document against.
    /// - Returns: An AnyPublisher of `DiscoveryDocument`and `Never`.
    func validateOrNil(with trustStoreSession: TrustStoreSession,
                       timeProvider: @escaping (() -> Date)) -> AnyPublisher<DiscoveryDocument?, Failure> {
        flatMap { document -> AnyPublisher<DiscoveryDocument?, Failure> in
            if let document = document,
               document.isValid(on: timeProvider()) {
                return Just(document)
                    .setFailureType(to: IDPError.self)
                    .validate(with: trustStoreSession, timeProvider: timeProvider)
                    .map { $0 as DiscoveryDocument? }
                    .catch { _ -> AnyPublisher<DiscoveryDocument?, Never> in
                        Just(nil).eraseToAnyPublisher()
                    }
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }
            return Just(nil).setFailureType(to: Failure.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

extension TrustStoreSession {
    /// Returns a publisher that checks a discoveryDocument against the trust store. The Stream contains an output
    /// boolean for the plain check or an TrustStoreError in case the TrustStoreSession sub streams failed.
    ///
    /// [REQ:gemSpec_IDP_Frontend:A_20623] Validation
    ///
    /// - Parameter discoveryDocument: The DiscoveryDocument that needs to be checked.
    /// - Returns: A publisher that contains an output with the check value or an failure if the check failed
    /// due to an underlying error.
    func validate(discoveryDocument: DiscoveryDocument) -> AnyPublisher<Bool, TrustStoreError> {
        // [REQ:BSI-eRp-ePA:O.Resi_6#5] Discovery Document signature verification
        validate(certificate: discoveryDocument.discKey)
            .zip(validate(certificate: discoveryDocument.signingCert))
            .map { isDiscKeyValid, isSigningCertValid -> Bool in
                isDiscKeyValid && isSigningCertValid
            }
            .eraseToAnyPublisher()
    }
}

extension TimeInterval {
    func toDispatchTimeInterval() -> DispatchTimeInterval {
        DispatchTimeInterval.milliseconds(Int(self * 1000))
    }
}

extension Publisher where Output == IDPToken?, Failure == Never {
    // [REQ:gemSpec_eRp_FdV:A_21326#4,A_21327#4] Triggered at every app start, profile change, pull to refresh
    func refreshIfExpired(session: DefaultIDPSession,
                          time: @escaping TimeProvider) -> AnyPublisher<IDPToken?, IDPError> {
        setFailureType(to: IDPError.self)
            .flatMap { [weak session] token -> AnyPublisher<IDPToken?, IDPError> in
                // We cannot refresh a token if none is existent
                guard let token = token else {
                    return Just(nil).setFailureType(to: IDPError.self).eraseToAnyPublisher()
                }
                // [REQ:BSI-eRp-ePA:O.Auth_9#2] application is also checking for expiration
                guard token.expires > time() else {
                    // [REQ:gemSpec_eRp_FdV:A_21326#5,A_21327#5] Either return a refreshed IDPToken
                    //  (or nil in case of error) to overwrite the current one
                    guard let session = session else {
                        return Just(nil)
                            .setFailureType(to: IDPError.self)
                            .eraseToAnyPublisher()
                    }
                    return session
                        .refresh(token: token)
                        .map { $0 as IDPToken? }
                        // Rethrow "no internet" errors, in all other cases, return no token, so user can restart
                        // authentication
                        .tryCatch { error throws -> AnyPublisher<IDPToken?, IDPError> in
                            if case let IDPError.network(error: httpError) = error,
                               case HTTPClientError.httpError = httpError {
                                throw error
                            }
                            return Just(nil)
                                .setFailureType(to: IDPError.self)
                                .eraseToAnyPublisher()
                        }
                        .mapError { $0.asIDPError() }
                        .eraseToAnyPublisher()
                }
                return Just(token).setFailureType(to: IDPError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
