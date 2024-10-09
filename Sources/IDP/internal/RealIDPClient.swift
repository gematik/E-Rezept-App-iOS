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
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import Combine
import CryptoKit
import Foundation
import HTTPClient

protocol IDPClientConfig {
    var clientId: String { get }
    var redirectURI: URL { get }
    var extAuthRedirectURI: URL { get }
    var discoveryURL: URL { get }
    var scopes: [IDPScope] { get }
}

class RealIDPClient: IDPClient {
    private let clientConfig: IDPClientConfig
    private let httpClient: HTTPClient
    private let jsonParser: JSONDecoder
    private let jsonEncoder: JSONEncoder

    /// Initialize the IDPClient
    ///
    /// - Parameters:
    ///   - config: IDP Config
    ///   - httpClient: the HTTPClient to use. Default: DefaultHTTPClient(urlSession: .init(configuration: .ephemeral)
    ///   - parser: JSON parser to parse JWT Payloads. Default: JSONDecoder()
    ///   - jsonEncoder: JSON encoder to encode JWE header and payload description
    init(
        client config: IDPClientConfig,
        httpClient: HTTPClient = DefaultHTTPClient(urlSessionConfiguration: .ephemeral),
        parser: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = RealIDPClient.defaultEncoder
    ) {
        clientConfig = config
        self.httpClient = httpClient
        jsonParser = parser
        self.jsonEncoder = jsonEncoder
    }

    func loadDiscoveryDocument() -> AnyPublisher<DiscoveryDocument, IDPError> {
        // load discovery dokument jwt
        httpClient.send(request: URLRequest(url: clientConfig.discoveryURL))
            .mapError {
                $0 as Error
            }
            .tryMap { data, _, _ -> AnyPublisher<DiscoveryDocument, Error> in
                let jwt = try JWT(from: data)
                let payload = try jwt.decodePayload(type: DiscoveryDocumentPayload.self)
                return self.httpClient
                    // load public encryption key
                    .send(request: URLRequest(url: payload.pukIdpEnc.correct(), cachePolicy: .reloadIgnoringCacheData))
                    .zip(
                        // load public signature key
                        self.httpClient
                            .send(request: URLRequest(url: payload.pukIdpSig.correct(),
                                                      cachePolicy: .reloadIgnoringCacheData))
                    ) { pukIdpEncResponse, pukIdpSigResponse in
                        (pukIdpEncResponse, pukIdpSigResponse)
                    }
                    .mapError {
                        $0 as Error
                    }
                    .tryMap { pukIdpEncResponse, pukIdpSigResponse -> DiscoveryDocument in
                        try DiscoveryDocument(
                            jwt: jwt,
                            pukIdpEncResponse: pukIdpEncResponse,
                            pukIdpSigResponse: pukIdpSigResponse
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap {
                $0
            }
            .mapError {
                $0.asIDPError()
            }
            .eraseToAnyPublisher()
    }

    // swiftlint:disable:next function_parameter_count
    func requestChallenge(
        codeChallenge: String,
        method: IDPCodeChallengeMode,
        state: String,
        nonce: String,
        using document: DiscoveryDocument,
        redirect: String?
    ) -> AnyPublisher<IDPChallenge, IDPError> {
        var authenticationComponents = URLComponents(
            url: document.authentication.url,
            resolvingAgainstBaseURL: false
        )
        // [REQ:gemSpec_IDP_Frontend:A_20483#3|15] Fill all the values into the GET Request
        let queryItems = [
            // [REQ:gemSpec_IDP_Frontend:A_20603,A_20601,A_20601-01] Transfer
            URLQueryItem(name: "client_id", value: clientConfig.clientId.urlPercentEscapedString()),
            URLQueryItem(name: "code_challenge", value: codeChallenge.urlPercentEscapedString()),
            URLQueryItem(name: "code_challenge_method", value: method.rawValue.urlPercentEscapedString()),
            URLQueryItem(name: "state", value: state.urlPercentEscapedString()),
            URLQueryItem(name: "scope", value: clientConfig.scopes.joined(separator: " ").urlPercentEscapedString()),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "nonce", value: nonce.urlPercentEscapedString()),
            URLQueryItem(
                // [REQ:gemSpec_IDP_Frontend:A_20740] transfer
                name: "redirect_uri",
                value: (redirect ?? clientConfig.redirectURI.absoluteString).urlPercentEscapedString()
            ),
        ]
        authenticationComponents?.percentEncodedQueryItems = queryItems
        guard let url = authenticationComponents?.url else {
            return Fail(error: IDPError.internal(error: .constructingChallengeRequestUrl))
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return httpClient.send(request: request, interceptors: []) { _, _ in
            nil // Don't follow the redirect, but handle it
        }
        .tryMap { body, _, status -> IDPChallenge in
            if status.isSuccessful {
                do {
                    return try self.jsonParser.decode(IDPChallenge.self, from: body)
                } catch {
                    throw IDPError.decoding(error: error)
                }
            } else {
                throw Self.responseError(for: body)
            }
        }
        .mapError {
            $0.asIDPError()
        }
        .eraseToAnyPublisher()
    }

    func verify(
        _ signedChallenge: JWE,
        using document: DiscoveryDocument
    ) -> AnyPublisher<IDPExchangeToken, IDPError> {
        // [REQ:gemSpec_IDP_Frontend:A_20526-01] Building and sending the request
        var request = URLRequest(url: document.authentication.url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        guard let signedChallengeJWEString = signedChallenge.encoded().utf8string else {
            return Fail(error: IDPError.internal(error: .signedChallengeEncoded))
                .eraseToAnyPublisher()
        }

        request.setFormUrlEncodedHeader()
        request.setFormUrlEncodedBody(parameters: ["signed_challenge": signedChallengeJWEString])

        let redirect = clientConfig.redirectURI.absoluteString

        return httpClient.send(request: request, interceptors: []) { _, _ in
            nil // Don't follow the redirect, but handle it
        }
        .tryMap { body, httpResponse, status -> IDPExchangeToken in
            if status.isRedirect {
                guard let locationComponents = httpResponse.locationComponents(),
                      let code = locationComponents.queryItemWithName("code")?.value,
                      let state = locationComponents.queryItemWithName("state")?.value
                else {
                    throw IDPError.internal(error: .verifyResponseMissingHeaderValue)
                }
                let sso = locationComponents.queryItemWithName("ssotoken")?.value
                // [REQ:gemSpec_IDP_Frontend:A_20600]
                return IDPExchangeToken(
                    code: code,
                    sso: sso,
                    state: state,
                    redirect: redirect
                )
            } else {
                throw Self.responseError(for: body)
            }
        }
        .mapError { $0.asIDPError() }
        .eraseToAnyPublisher()
    }

    func refresh(with unsignedChallenge: IDPChallenge,
                 ssoToken: String,
                 using document: DiscoveryDocument,
                 for redirect: String)
        -> AnyPublisher<IDPExchangeToken, IDPError> {
        var request = URLRequest(url: document.sso.url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        guard let unsignedChallenge = unsignedChallenge.challenge.serialize().urlPercentEscapedString(),
              let ssotoken = ssoToken.urlPercentEscapedString() else {
            return Fail(error: IDPError.internal(error: .constructingRefreshWithSSOTokenRequest)).eraseToAnyPublisher()
        }
        request.setFormUrlEncodedHeader()
        request.setFormUrlEncodedBody(parameters: [
            "unsigned_challenge": unsignedChallenge,
            "ssotoken": ssotoken,
        ])

        return httpClient.send(request: request, interceptors: []) { _, _ in
            nil // Don't follow the redirect, but handle it
        }
        .tryMap { data, httpResponse, status -> IDPExchangeToken in
            if status.isRedirect {
                guard let locationComponents = httpResponse.locationComponents(),
                      let code = locationComponents.queryItemWithName("code")?.value,
                      let state = locationComponents.queryItemWithName("state")?.value
                else {
                    throw IDPError.internal(error: .refreshResponseMissingHeaderValue)
                }
                let sso = locationComponents.queryItemWithName("ssotoken")?.value ?? ssoToken
                return IDPExchangeToken(code: code, sso: sso, state: state, redirect: redirect)
            } else {
                throw Self.responseError(for: data)
            }
        }
        .mapError { $0.asIDPError() }
        .eraseToAnyPublisher()
    }

    func exchange(token: IDPExchangeToken,
                  verifier: String,
                  redirectURI: String?,
                  encryptedKeyVerifier: JWE,
                  using document: DiscoveryDocument) -> AnyPublisher<TokenPayload, IDPError> {
        var request = URLRequest(url: document.token.url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setFormUrlEncodedHeader()

        guard let keyVerifierJWEString: String = encryptedKeyVerifier.encoded().utf8string else {
            return Fail(error: IDPError.internal(error: .encryptedKeyVerifierEncoding)).eraseToAnyPublisher()
        }

        // [REQ:gemSpec_IDP_Frontend:A_20529-01#4|10] Putting all parameters into the HTTP body
        let parameters = [
            "key_verifier": keyVerifierJWEString,
            "code": token.code,
            "grant_type": "authorization_code",
            // [REQ:gemSpec_IDP_Frontend:A_20740] transfer
            "redirect_uri": redirectURI ?? clientConfig.redirectURI.absoluteString,
            "code_verifier": verifier,
            // [REQ:gemSpec_IDP_Frontend:A_20603] transfer
            "client_id": clientConfig.clientId,
        ]
        request.setFormUrlEncodedBody(parameters: parameters)

        // [REQ:gemSpec_IDP_Frontend:A_20529-01#5] Sending the Request with the default HTTPClient via TLS.
        return httpClient.send(request: request)
            .tryMap { body, _, status -> TokenPayload in
                // [REQ:gemSpec_IDP_Frontend:A_19938-01#2|3] 2xx HTTPCodes are treated as tokens
                if status.isSuccessful {
                    return try JSONDecoder().decode(TokenPayload.self, from: body)
                } else {
                    throw Self.responseError(for: body)
                }
            }
            .mapError {
                // [REQ:gemSpec_IDP_Frontend:A_20079] Network timeouts will traverse the queue as `HTTPError`s.
                $0.asIDPError()
            }
            .eraseToAnyPublisher()
    }

    func registerDevice(_ encryptedRegistration: JWE, token: IDPToken,
                        using document: DiscoveryDocument) -> AnyPublisher<PairingEntry, IDPError> {
        var request = URLRequest(url: document.pairing.url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")

        guard let encryptedRegistrationData = encryptedRegistration.encoded().utf8string else {
            return Fail(error: IDPError.internal(error: .registeredDeviceEncoding)).eraseToAnyPublisher()
        }

        request.setFormUrlEncodedHeader()
        request.setFormUrlEncodedBody(parameters: ["encrypted_registration_data": encryptedRegistrationData])

        return httpClient.send(request: request)
            .tryMap { body, _, status -> PairingEntry in
                if status.isSuccessful {
                    return try JSONDecoder().decode(PairingEntry.self, from: body)
                } else {
                    throw Self.responseError(for: body)
                }
            }
            .mapError { $0.asIDPError() }
            .eraseToAnyPublisher()
    }

    func unregisterDevice(_ keyIdentifier: String, token: IDPToken,
                          using document: DiscoveryDocument) -> AnyPublisher<Bool, IDPError> {
        var request = URLRequest(
            url: document.pairing.url.appendingPathComponent(keyIdentifier),
            cachePolicy: .reloadIgnoringCacheData
        )
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")

        return httpClient.send(request: request)
            .tryMap { body, _, status -> Bool in
                if status.isSuccessful {
                    return true
                } else {
                    throw Self.responseError(for: body)
                }
            }
            .mapError { $0.asIDPError() }
            .eraseToAnyPublisher()
    }

    func listDevices(token: IDPToken, using document: DiscoveryDocument) -> AnyPublisher<PairingEntries, IDPError> {
        var request = URLRequest(
            url: document.pairing.url,
            cachePolicy: .reloadIgnoringCacheData
        )
        request.httpMethod = "GET"
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Accept")
        request.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")

        return httpClient.send(request: request)
            .tryMap { body, _, status -> PairingEntries in
                if status.isSuccessful {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    return try decoder.decode(PairingEntries.self, from: body)
                } else {
                    guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
                        throw Self.fallbackServerResponse
                    }
                    throw IDPError.serverError(responseError)
                }
            }
            .mapError { $0.asIDPError() }
            .eraseToAnyPublisher()
    }

    func altVerify(_ encryptedSignedChallenge: JWE,
                   using document: DiscoveryDocument) -> AnyPublisher<IDPExchangeToken, IDPError> {
        var request = URLRequest(url: document.authenticationPaired.url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        guard let encryptedSignedChallengeData = encryptedSignedChallenge.encoded().utf8string else {
            return Fail(error: IDPError.internal(error: .encryptedSignedChallengeEncoding))
                .eraseToAnyPublisher()
        }

        request.setFormUrlEncodedHeader()
        request
            .setFormUrlEncodedBody(parameters: ["encrypted_signed_authentication_data": encryptedSignedChallengeData])

        return httpClient.send(request: request, interceptors: []) { _, _ in
            nil // Don't follow the redirect, but handle it
        }
        .tryMap { [redirect = clientConfig.redirectURI.absoluteString] data, httpResponse, status -> IDPExchangeToken in
            if status.isRedirect {
                guard let locationComponents = httpResponse.locationComponents(),
                      let code = locationComponents.queryItemWithName("code")?.value,
                      let state = locationComponents.queryItemWithName("state")?.value
                else {
                    throw IDPError.internal(error: .altVerifyResponseMissingHeaderValue)
                }
                let sso = locationComponents.queryItemWithName("ssotoken")?.value
                return IDPExchangeToken(code: code,
                                        sso: sso,
                                        state: state,
                                        redirect: redirect)
            } else {
                throw Self.responseError(for: data)
            }
        }
        .mapError { $0.asIDPError() }
        .eraseToAnyPublisher()
    }

    func loadDirectoryKKApps(using document: DiscoveryDocument) -> AnyPublisher<IDPDirectoryKKApps, IDPError> {
        guard let url = document.directoryKKAppsgId?.url else {
            return Fail(error: Self.missingFeature).eraseToAnyPublisher()
        }
        // load complete kk_apps directory
        let request = URLRequest(url: url)

        return httpClient.send(request: request)
            .mapError {
                $0 as Error
            }
            .tryMap { data, _, status -> IDPDirectoryKKApps in
                if status.isSuccessful {
                    let jwt = try JWT(from: data)
                    return IDPDirectoryKKApps(jwt: jwt)
                } else {
                    guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: data) else {
                        throw Self.fallbackServerResponse
                    }
                    throw IDPError.serverError(responseError)
                }
            }
            .mapError {
                $0.asIDPError()
            }
            .eraseToAnyPublisher()
    }

    func startExtAuth(_ app: IDPExtAuth, using document: DiscoveryDocument) -> AnyPublisher<URL, IDPError> {
        guard let url = document.federationAuth?.url else {
            return Fail(error: Self.missingFeature).eraseToAnyPublisher()
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let queryItems = [
            URLQueryItem(name: "idp_iss", value: app.kkAppId.urlPercentEscapedString()),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientConfig.clientId.urlPercentEscapedString()),
            URLQueryItem(name: "state", value: app.state),
            URLQueryItem(
                name: "redirect_uri",
                value: clientConfig.extAuthRedirectURI.absoluteString.urlPercentEscapedString()
            ),
            URLQueryItem(name: "scope", value: clientConfig.scopes.joined(separator: " ").urlPercentEscapedString()),
            URLQueryItem(name: "code_challenge", value: app.codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: app.codeChallengeMethod.rawValue),
            URLQueryItem(name: "nonce", value: app.nonce),
        ]
        components?.percentEncodedQueryItems = queryItems
        guard let url = components?.url else {
            return Fail(error: IDPError.internal(error: .constructingExtAuthRequestUrl)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)

        return httpClient.send(request: request, interceptors: []) { _, _ in
            nil // Don't follow the redirect, but handle it
        }
        .tryMap { data, httpResponse, status -> URL in
            if status.isRedirect {
                guard let components = httpResponse.locationComponents(),
                      let redirect = components.url else {
                    throw Self.fallbackServerResponse
                }
                if components.queryItemWithName("error") != nil {
                    throw Self.responseError(for: components)
                }
                return redirect
            } else {
                throw Self.responseError(for: data)
            }
        }
        .mapError { $0.asIDPError() }
        .eraseToAnyPublisher()
    }

    // [REQ:gemSpec_IDP_Frontend:A_22302-01#2] Sending the required data as POST to the backend.
    func extAuthVerify(_ verify: IDPExtAuthVerify,
                       using document: DiscoveryDocument) -> AnyPublisher<IDPExchangeToken, IDPError> {
        guard let url = document.federationAuth?.url else {
            return Fail(error: Self.missingFeature).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = "POST"

        let formUrlParameters = [
            "state": verify.state,
            "code": verify.code,
        ]

        request.setFormUrlEncodedHeader()
        request.setFormUrlEncodedBody(parameters: formUrlParameters)

        return httpClient.send(request: request, interceptors: []) { _, _ in
            nil // Don't follow the redirect, but handle it
        }
        .tryMap { [redirect = clientConfig.extAuthRedirectURI.absoluteString] body, httpResponse, status
            -> IDPExchangeToken in
            if status.isRedirect {
                guard let locationComponents = httpResponse.locationComponents(),
                      let code = locationComponents.queryItemWithName("code")?.value,
                      let state = locationComponents.queryItemWithName("state")?.value
                else {
                    throw IDPError.internal(error: .extAuthVerifyResponseMissingHeaderValue)
                }
                let sso = locationComponents.queryItemWithName("ssotoken")?.value
                // [REQ:gemSpec_IDP_Frontend:A_20600]
                return IDPExchangeToken(code: code,
                                        sso: sso,
                                        state: state,
                                        redirect: redirect)
            } else {
                throw Self.responseError(for: body)
            }
        }
        .mapError { $0.asIDPError() }
        .eraseToAnyPublisher()
    }
}

extension RealIDPClient {
    // [REQ:gemSpec_IDP_Frontend:A_19937#2,A_20605] Decoding server errors
    private static func responseError(for body: Data) -> IDPError {
        guard let responseError = try? JSONDecoder().decode(IDPError.ServerResponse.self, from: body) else {
            return Self.fallbackServerResponse
        }
        return IDPError.serverError(responseError)
    }

    private static func responseError(for urlComponents: URLComponents) -> IDPError {
        .serverError(
            .init(
                error: urlComponents.queryItemWithName("error")?.value ?? "Unable to decode error.",
                errorText: urlComponents
                    .queryItemWithName("gematik_error_text")?
                    .value?
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? "Unable to decode error text.",
                timestamp: Int(urlComponents.queryItemWithName("gematik_timestamp")?.value ?? "0") ?? 0,
                uuid: urlComponents.queryItemWithName("gematik_uuid")?.value ?? "Unable to decode uuid.",
                code: urlComponents.queryItemWithName("gematik_code")?.value ?? "Unable to decode code."
            )
        )
    }

    private static var fallbackServerResponse: IDPError {
        IDPError.serverError(
            .init(
                error: "Unable to decode.",
                errorText: "Unable to decode server error",
                timestamp: Int(round(Date().timeIntervalSince1970)),
                uuid: "unknown",
                code: "-1"
            )
        )
    }

    private static var missingFeature: IDPError {
        IDPError.serverError(
            .init(
                error: "Missing Server Feature",
                errorText: "Endpoint not available within Discovery Document. Change environment or reset DD",
                timestamp: Int(round(Date().timeIntervalSince1970)),
                uuid: "unknown",
                code: "-1"
            )
        )
    }
}

extension HTTPURLResponse {
    func locationComponents() -> URLComponents? {
        guard let locationHeader = value(forHTTPHeaderField: "Location"),
              let location = URL(string: locationHeader) else {
            return nil
        }
        return URLComponents(
            url: location,
            resolvingAgainstBaseURL: false
        )
    }
}

extension URLComponents {
    func queryItemWithName(_ name: String) -> URLQueryItem? {
        queryItems?.first { $0.name == name }
    }
}

extension RealIDPClient {
    private static var defaultEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dataEncodingStrategy = .base64
        return jsonEncoder
    }()
}

extension Swift.Error {
    /// Map any Error to an IDPError
    public func asIDPError() -> IDPError {
        if let error = self as? HTTPClientError {
            return IDPError.network(error: error)
        } else if let error = self as? IDPError {
            return error
        } else if let error = self as? JWT.Error {
            return .decoding(error: error)
        } else {
            return IDPError.unspecified(error: self)
        }
    }
}

extension DefaultIDPSession.Configuration: IDPClientConfig {}

extension DiscoveryDocument {
    init(
        jwt: JWT,
        pukIdpEncResponse: HTTPResponse,
        pukIdpSigResponse: HTTPResponse
    ) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.dataDecodingStrategy = .base64

        let pukIdpEnc = try decoder.decode(JWK.self, from: pukIdpEncResponse.data)
        let pukIdpSig = try decoder.decode(JWK.self, from: pukIdpSigResponse.data)
        try self.init(jwt: jwt, encryptPuks: pukIdpEnc, signingPuks: pukIdpSig)
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
