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
import HTTPClient
import IDP
@testable import IDPLive

// swiftlint:disable all
public class IDPSessionMock: IDPSession {
    private var clientId: String
    public required init(clientId: String = "mock_client_id") {
        self.clientId = clientId
    }

    public static var fixtureIDPToken = IDPToken(
        accessToken: "SECRET ACCESSTOKEN",
        expires: Date(),
        idToken: "IDP TOKEN",
        ssoToken: "SSO TOKEN",
        tokenType: "type",
        redirect: "redirect"
    )

    public var idpToken: CurrentValueSubject<IDPToken?, IDPError> = CurrentValueSubject(nil)

    public var isLoggedIn_CallsCount = 0
    public var isLoggedIn_Called: Bool {
        isLoggedIn_CallsCount > 0
    }

    public var isLoggedIn: AnyPublisher<Bool, IDPError> {
        isLoggedIn_CallsCount += 1
        return autoRefreshedToken.map { token in
            token != nil
        }
        .eraseToAnyPublisher()
    }

    public var invalidateAccessToken_CallsCount = 0
    public var invalidateAccessToken_Called: Bool {
        invalidateAccessToken_CallsCount > 0
    }

    public func invalidateAccessToken() {
        invalidateAccessToken_CallsCount += 1
    }

    public var autoRefreshedToken_CallsCount = 0
    public var autoRefreshedToken_Called: Bool {
        autoRefreshedToken_CallsCount > 0
    }

    public var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
        autoRefreshedToken_CallsCount += 1
        return idpToken.eraseToAnyPublisher()
    }

    public var requestChallenge_Publisher: AnyPublisher<IDPChallengeSession, IDPError>! =
        try! Just(IDPChallengeSession(
            challenge: IDPChallenge(
                challenge: JWT(header: JWT.Header(), payload: IDPChallenge.Claim())
            ),
            verifierCode: "bla",
            state: "super random state",
            nonce: "super randome nonce"
        ))
        .setFailureType(to: IDPError.self)
        .eraseToAnyPublisher()
    public var requestChallenge_CallsCount = 0
    public var requestChallenge_Called: Bool {
        requestChallenge_CallsCount > 0
    }

    public func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        requestChallenge_CallsCount += 1
        return requestChallenge_Publisher
    }

    public var verify_Publisher: AnyPublisher<IDPExchangeToken, IDPError>! =
        Just(IDPExchangeToken(code: "SUPER_SECRET_AUTH_CODE", sso: nil, state: "state", redirect: "redirect"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    public var verify_ReceivedArguments: SignedChallenge?
    public var verify_CallsCount = 0
    public var verify_Called: Bool {
        verify_CallsCount > 0
    }

    public func verify(_ signedChallenge: SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError> {
        verify_CallsCount += 1
        verify_ReceivedArguments = signedChallenge
        return verify_Publisher
    }

    public var ssoLogin_Publisher: AnyPublisher<IDPExchangeToken, IDPError>! =
        Just(IDPExchangeToken(code: "SUPER_SECRET_AUTH_CODE", sso: nil, state: "state", redirect: "redirect"))
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    public var ssoLogin_ReceivedArguments: (IDPChallengeSession, String)?
    public var ssoLogin_CallsCount = 0
    public var ssoLogin_Called: Bool {
        ssoLogin_CallsCount > 0
    }

    public func ssoLogin(challenge: IDPChallengeSession, sso: String) -> AnyPublisher<IDPExchangeToken, IDPError> {
        ssoLogin_CallsCount += 1
        ssoLogin_ReceivedArguments = (challenge, sso)
        return ssoLogin_Publisher
    }

    public var exchange_Publisher: AnyPublisher<IDPToken, IDPError>! =
        Just(fixtureIDPToken)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    public var exchange_ReceivedArguments: (token: IDPExchangeToken,
                                            challengeSession: ChallengeSession,
                                            idTokenValidator: (TokenPayload.IDTokenPayload) -> Result<Bool, Error>)?
    public var exchange_CallsCount = 0
    public var exchange_Called: Bool {
        exchange_CallsCount > 0
    }

    public func exchange(
        token: IDPExchangeToken,
        challengeSession: ChallengeSession,
        idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>
    ) -> AnyPublisher<IDPToken, IDPError> {
        exchange_CallsCount += 1
        exchange_ReceivedArguments = (token: token,
                                      challengeSession: challengeSession,
                                      idTokenValidator: idTokenValidator)
        return exchange_Publisher
    }

    public var refresh_Publisher: AnyPublisher<IDPToken, IDPError>! =
        Just(fixtureIDPToken)
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    public var refresh_ReceivedArguments: IDPToken?
    public var refresh_CallsCount = 0
    public var refresh_Called: Bool {
        refresh_CallsCount > 0
    }

    public func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        refresh_CallsCount += 1
        refresh_ReceivedArguments = token
        return refresh_Publisher
    }

    public var pairDevice_Publisher: AnyPublisher<PairingEntry, IDPError>!
    public var pairDevice_ReceivedArguments: (registrationData: RegistrationData, token: IDPToken)?
    public var pairDevice_CallsCount = 0
    public var pairDevice_Called: Bool {
        pairDevice_CallsCount > 0
    }

    public func pairDevice(with registrationData: RegistrationData,
                           token: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        pairDevice_CallsCount += 1
        pairDevice_ReceivedArguments = (registrationData: registrationData, token: token)
        return pairDevice_Publisher
    }

    public var unregisterDevice_Publisher: AnyPublisher<Bool, IDPError>!
    public var unregisterDevice_ReceivedArguments: (String, IDPToken)?
    public var unregisterDevice_CallsCount = 0
    public var unregisterDevice_Called: Bool {
        unregisterDevice_CallsCount > 0
    }

    public func unregisterDevice(_ keyIdentifier: String, token: IDPToken) -> AnyPublisher<Bool, IDPError> {
        unregisterDevice_CallsCount += 1
        unregisterDevice_ReceivedArguments = (keyIdentifier, token)
        return unregisterDevice_Publisher
    }

    public var listDevices_Publisher: AnyPublisher<PairingEntries, IDPError>!
    public var listDevices_ReceivedArguments: IDPToken?
    public var listDevices_CallsCount = 0
    public var listDevices_Called: Bool {
        listDevices_CallsCount > 0
    }

    public func listDevices(token: IDPToken) -> AnyPublisher<PairingEntries, IDPError> {
        listDevices_CallsCount += 1
        listDevices_ReceivedArguments = token
        return listDevices_Publisher
    }

    public var altVerify_Publisher: AnyPublisher<IDPExchangeToken, IDPError>!
    public var altVerify_ReceivedArguments: SignedAuthenticationData?
    public var altVerify_CallsCount = 0
    public var altVerify_Called: Bool {
        altVerify_CallsCount > 0
    }

    public func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        altVerify_CallsCount += 1
        altVerify_ReceivedArguments = signedChallenge
        return altVerify_Publisher
    }

    public var loadDirectoryKKApps_Publisher: AnyPublisher<KKAppDirectory, IDPError>!
    public var loadDirectoryKKApps_CallsCount = 0
    public var loadDirectoryKKApps_Called: Bool {
        loadDirectoryKKApps_CallsCount > 0
    }

    public func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError> {
        loadDirectoryKKApps_CallsCount += 1
        return loadDirectoryKKApps_Publisher
    }

    public var startExtAuth_Publisher: AnyPublisher<URL, IDPError>!
    public var startExtAuth_ReceivedArguments: KKAppDirectory.Entry?
    public var startExtAuth_CallsCount = 0
    public var startExtAuth_Called: Bool {
        startExtAuth_CallsCount > 0
    }

    public func startExtAuth(entry: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError> {
        startExtAuth_CallsCount += 1
        startExtAuth_ReceivedArguments = entry
        return startExtAuth_Publisher
    }

    public var extAuthVerifyAndExchange_Publisher: AnyPublisher<IDPToken, IDPError>!
    public var extAuthVerifyAndExchange_ReceivedArguments: (
        URL,
        (TokenPayload.IDTokenPayload) -> Result<Bool, Error>
    )?
    public var extAuthVerifyAndExchange_CallsCount = 0
    public var extAuthVerifyAndExchange_Called: Bool {
        extAuthVerifyAndExchange_CallsCount > 0
    }

    public func extAuthVerifyAndExchange(
        _ url: URL,
        idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>
    ) -> AnyPublisher<IDPToken, IDPError> {
        extAuthVerifyAndExchange_CallsCount += 1
        extAuthVerifyAndExchange_ReceivedArguments = (url, idTokenValidator)
        return extAuthVerifyAndExchange_Publisher
    }
}

// swiftlint:enable all
