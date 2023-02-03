//
//  Copyright (c) 2023 gematik GmbH
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

// swiftlint:disable all
public class MockIDPClient: IDPClient {
    private var clientId: String
    public required init(clientId: String = "mock_client_id") {
        self.clientId = clientId
    }

    var requestChallenge_Publisher: AnyPublisher<IDPChallenge, IDPError>! =
        try! Just(IDPChallenge(challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim()), consent: nil))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    var requestChallenge_ReceivedArguments = [(
        codeChallenge: String,
        method: IDPCodeChallengeMode,
        state: String,
        nonce: String,
        discovery: DiscoveryDocument,
        redirect: String?
    )]()
    var requestChallenge_CallsCount = 0
    var requestChallenge_Called: Bool {
        requestChallenge_CallsCount > 0
    }

    public func requestChallenge(codeChallenge: String,
                                 method: IDPCodeChallengeMode,
                                 state: String,
                                 nonce: String,
                                 using document: DiscoveryDocument,
                                 redirect: String?) -> AnyPublisher<IDP.IDPChallenge, IDP.IDPError> {
        requestChallenge_CallsCount += 1
        requestChallenge_ReceivedArguments.append((codeChallenge, method, state, nonce, document, redirect))
        return requestChallenge_Publisher
    }

    var verify_Publisher: AnyPublisher<IDPExchangeToken, IDPError>! =
        Just(IDPExchangeToken(code: "SUPER_SECRET_AUTH_CODE", sso: nil, state: "state", redirect: "redirect"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    var verify_ReceivedArguments: (
        challenge: JWE,
        document: DiscoveryDocument
    )?
    var verify_CallsCount = 0
    var verify_Called: Bool {
        verify_CallsCount > 0
    }

    public func verify(
        _ signedChallenge: JWE,
        using document: DiscoveryDocument
    ) -> AnyPublisher<IDPExchangeToken, IDPError> {
        verify_CallsCount += 1
        verify_ReceivedArguments = (challenge: signedChallenge,
                                    document: document)
        return verify_Publisher
    }

    var ssoLogin_Publisher: AnyPublisher<IDPExchangeToken, IDPError>! =
        Just(IDPExchangeToken(code: "SUPER_SECRET_AUTH_CODE", sso: nil, state: "state", redirect: "redirect"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    var ssoLogin_ReceivedArguments: (
        unsignedChallenge: IDPChallenge,
        sso: String,
        document: DiscoveryDocument,
        redirect: String
    )?
    var ssoLogin_CallsCount = 0
    var ssoLogin_Called: Bool {
        ssoLogin_CallsCount > 0
    }

    public func refresh(with unsignedChallenge: IDPChallenge,
                        ssoToken: String,
                        using document: DiscoveryDocument,
                        for redirect: String)
        -> AnyPublisher<IDPExchangeToken, IDPError> {
        ssoLogin_CallsCount += 1
        ssoLogin_ReceivedArguments = (unsignedChallenge: unsignedChallenge,
                                      sso: ssoToken,
                                      document: document,
                                      redirect: redirect)
        return ssoLogin_Publisher
    }

    var exchange_Publisher: AnyPublisher<TokenPayload, IDPError>! =
        Just(TokenPayload(
            accessToken: "SECRET ACCESSTOKEN",
            expiresIn: 0,
            idToken: "IDP TOKEN",
            ssoToken: "SSO TOKEN",
            tokenType: "type"
        ))
        .setFailureType(to: IDPError.self)
        .eraseToAnyPublisher()
    var exchange_ReceivedArguments: (token: IDPExchangeToken,
                                     verifier: String,
                                     redirectURI: String?,
                                     encryptedKeyVerifier: JWE,
                                     document: DiscoveryDocument)?
    var exchange_CallsCount = 0
    var exchange_Called: Bool {
        exchange_CallsCount > 0
    }

    public func exchange(
        token: IDPExchangeToken,
        verifier: String,
        redirectURI: String?,
        encryptedKeyVerifier: JWE,
        using document: DiscoveryDocument
    ) -> AnyPublisher<TokenPayload, IDPError> {
        exchange_CallsCount += 1
        exchange_ReceivedArguments = (token: token,
                                      verifier: verifier,
                                      redirectURI: redirectURI,
                                      encryptedKeyVerifier: encryptedKeyVerifier,
                                      document: document)
        return exchange_Publisher
    }

    var loadDiscoveryDocument_CallsCount = 0
    var loadDiscoveryDocument_Called: Bool {
        loadDiscoveryDocument_CallsCount > 0
    }

    var discoveryDocument: DiscoveryDocument?
    public func loadDiscoveryDocument() -> AnyPublisher<DiscoveryDocument, IDPError> {
        Deferred { () -> AnyPublisher<DiscoveryDocument, IDPError> in
            self.loadDiscoveryDocument_CallsCount += 1
            guard let document = self.discoveryDocument else {
                return Fail(error: IDPError.decoding(error: "No Discovery document available from MockClient"))
                    .eraseToAnyPublisher()
            }
            return Just(document)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    public var registerDevice_Publisher: AnyPublisher<PairingEntry, IDPError>!
    public var registerDevice_ReceivedArguments: (JWE, IDPToken, DiscoveryDocument)?
    public var registerDevice_CallsCount = 0
    public var registerDevice_Called: Bool {
        registerDevice_CallsCount > 0
    }

    public func registerDevice(_ jwe: JWE, token: IDPToken,
                               using document: DiscoveryDocument) -> AnyPublisher<PairingEntry, IDPError> {
        registerDevice_CallsCount += 1
        registerDevice_ReceivedArguments = (jwe, token, document)
        return registerDevice_Publisher
    }

    public var unregisterDevice_Publisher: AnyPublisher<Bool, IDPError>!
    public var unregisterDevice_ReceivedArguments: (String, IDPToken, DiscoveryDocument)?
    public var unregisterDevice_CallsCount = 0
    public var unregisterDevice_Called: Bool {
        unregisterDevice_CallsCount > 0
    }

    public func unregisterDevice(_ keyIdentifier: String, token: IDPToken,
                                 using document: DiscoveryDocument) -> AnyPublisher<Bool, IDPError> {
        unregisterDevice_CallsCount += 1
        unregisterDevice_ReceivedArguments = (keyIdentifier, token, document)
        return unregisterDevice_Publisher
    }

    public var listDevices_Publisher: AnyPublisher<PairingEntries, IDPError>!
    public var listDevices_ReceivedArguments: (IDPToken, DiscoveryDocument)?
    public var listDevices_CallsCount = 0
    public var listDevices_Called: Bool {
        listDevices_CallsCount > 0
    }

    public func listDevices(token: IDPToken,
                            using document: DiscoveryDocument) -> AnyPublisher<PairingEntries, IDPError> {
        listDevices_CallsCount += 1
        listDevices_ReceivedArguments = (token, document)
        return listDevices_Publisher
    }

    public var altVerify_Publisher: AnyPublisher<IDPExchangeToken, IDPError>!
    public var altVerify_ReceivedArguments: (JWE, DiscoveryDocument)?
    public var altVerify_CallsCount = 0
    public var altVerify_Called: Bool {
        altVerify_CallsCount > 0
    }

    public func altVerify(_ encryptedSignedChallenge: JWE,
                          using document: DiscoveryDocument) -> AnyPublisher<IDPExchangeToken, IDPError> {
        altVerify_CallsCount += 1
        altVerify_ReceivedArguments = (encryptedSignedChallenge, document)
        return altVerify_Publisher
    }

    // MARK: - loadDirectoryKKApps

    public var loadDirectoryKKAppsUsingCallsCount = 0
    public var loadDirectoryKKAppsUsingCalled: Bool {
        loadDirectoryKKAppsUsingCallsCount > 0
    }

    public var loadDirectoryKKAppsUsingReceivedDocument: DiscoveryDocument?
    public var loadDirectoryKKAppsUsingReceivedInvocations: [DiscoveryDocument] = []
    public var loadDirectoryKKAppsUsingReturnValue: AnyPublisher<IDPDirectoryKKApps, IDPError>!
    public var loadDirectoryKKAppsUsingClosure: ((DiscoveryDocument) -> AnyPublisher<IDPDirectoryKKApps, IDPError>)?

    public func loadDirectoryKKApps(using document: DiscoveryDocument) -> AnyPublisher<IDPDirectoryKKApps, IDPError> {
        loadDirectoryKKAppsUsingCallsCount += 1
        loadDirectoryKKAppsUsingReceivedDocument = document
        loadDirectoryKKAppsUsingReceivedInvocations.append(document)
        return loadDirectoryKKAppsUsingClosure.map { $0(document) } ?? loadDirectoryKKAppsUsingReturnValue
    }

    public var startExtAuthUsingCallsCount = 0
    public var startExtAuthUsingCalled: Bool {
        startExtAuthUsingCallsCount > 0
    }

    public var startExtAuthUsingReceivedArguments: (IDPExtAuth, DiscoveryDocument)?
    public var startExtAuthUsingReceivedInvocations: [(IDPExtAuth, DiscoveryDocument)] = []
    public var startExtAuthUsingReturnValue: AnyPublisher<URL, IDPError>!
    public var startExtAuthUsingClosure: ((IDPExtAuth, DiscoveryDocument) -> AnyPublisher<URL, IDPError>)?

    public func startExtAuth(_ app: IDPExtAuth, using document: DiscoveryDocument) -> AnyPublisher<URL, IDPError> {
        startExtAuthUsingCallsCount += 1
        startExtAuthUsingReceivedArguments = (app, document)
        startExtAuthUsingReceivedInvocations.append((app, document))
        return startExtAuthUsingClosure.map { $0(app, document) } ?? startExtAuthUsingReturnValue
    }

    public var extAuthVerifyUsingCallsCount = 0
    public var extAuthVerifyUsingCalled: Bool {
        extAuthVerifyUsingCallsCount > 0
    }

    public var extAuthVerifyUsingReceivedDocument: DiscoveryDocument?
    public var extAuthVerifyUsingReceivedInvocations: [DiscoveryDocument] = []
    public var extAuthVerifyUsingReturnValue: AnyPublisher<IDPExchangeToken, IDPError>!
    public var extAuthVerifyUsingClosure: ((DiscoveryDocument) -> AnyPublisher<IDPExchangeToken, IDPError>)?

    public func extAuthVerify(_: IDPExtAuthVerify,
                              using document: DiscoveryDocument) -> AnyPublisher<IDPExchangeToken, IDPError> {
        extAuthVerifyUsingCallsCount += 1
        extAuthVerifyUsingReceivedDocument = document
        extAuthVerifyUsingReceivedInvocations.append(document)
        return extAuthVerifyUsingClosure.map { $0(document) } ?? extAuthVerifyUsingReturnValue
    }
}

extension String: Swift.Error {}

// swiftlint:enable all
