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
import CombineSchedulers
import Dependencies
import Foundation
import IDP

class DemoIDPSession: IDPSession {
    @Dependency(\.schedulers) var schedulers
    private let storage: IDPStorage
    private var uiScheduler: AnySchedulerOf<DispatchQueue> {
        schedulers.main
    }

    var currentValue = CurrentValueSubject<IDPToken?, IDPError>(nil)

    var isLoggedIn: AnyPublisher<Bool, IDPError> {
        autoRefreshedToken.map { token in
            token != nil
        }
        .eraseToAnyPublisher()
    }

    var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
        storage.token
            .setFailureType(to: IDPError.self)
            .eraseToAnyPublisher()
    }

    init(storage: IDPStorage) {
        self.storage = storage

        let token = IDPToken(
            accessToken: "SECRET ACCESSTOKEN",
            expires: Date.distantFuture,
            idToken: "IDP TOKEN",
            ssoToken: "SSO TOKEN",
            redirect: ""
        )
        self.storage.set(token: token)
    }

    func invalidateAccessToken() {
        storage.set(token: nil)
        currentValue.value = nil
    }

    func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        Future { promise in
            promise(Result {
                IDPChallengeSession(
                    challenge: try IDPChallenge(
                        challenge: JWT(header: JWT.Header(), payload: DemoPayload())
                    ),
                    verifierCode: "code_verifier",
                    state: "randomState",
                    nonce: "randomNonce"
                )
            })
        }
        .mapError { $0.asIDPError() }
        .delay(for: 0.5, scheduler: uiScheduler)
        .eraseToAnyPublisher()
    }

    func verify(_: SignedChallenge)
        -> AnyPublisher<IDPExchangeToken, IDPError> {
        Just(IDPExchangeToken(code: "SUPER_SECRET_AUTH_CODE", sso: nil, state: "state", redirect: ""))
            .setFailureType(to: IDPError.self)
            .delay(for: 1.5, scheduler: uiScheduler)
            .eraseToAnyPublisher()
    }

    func exchange(token: IDPExchangeToken,
                  challengeSession _: ChallengeSession,
                  idTokenValidator _: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<
        IDPToken,
        IDPError
    > {
        currentValue.send(
            IDPToken(
                accessToken: "SECRET ACCESSTOKEN",
                expires: Date.distantFuture,
                idToken: "IDP TOKEN",
                ssoToken: "SSO TOKEN",
                redirect: ""
            )
        )
        return currentValue // swiftlint:disable:this trailing_closure
            .compactMap { $0 }
            .handleEvents(receiveOutput: { token in
                self.storage.set(token: token)
            })
            .eraseToAnyPublisher()
    }

    func refresh(token _: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        Just(IDPToken(
            accessToken: "SECRET ACCESSTOKEN",
            expires: Date.distantFuture,
            idToken: "IDP TOKEN",
            ssoToken: "SSO TOKEN",
            redirect: ""
        ))
            .setFailureType(to: IDPError.self)
            .delay(for: 1.5, scheduler: uiScheduler)
            .eraseToAnyPublisher()
    }

    func pairDevice(with _: RegistrationData, token _: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        Fail(error: IDPError.notAvailableInDemoMode)
            .eraseToAnyPublisher()
    }

    func unregisterDevice(_: String, token _: IDPToken) -> AnyPublisher<Bool, IDPError> {
        Fail(error: IDPError.notAvailableInDemoMode)
            .eraseToAnyPublisher()
    }

    func listDevices(token _: IDPToken) -> AnyPublisher<PairingEntries, IDPError> {
        Fail(error: IDPError.notAvailableInDemoMode)
            .eraseToAnyPublisher()
    }

    func altVerify(_: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        Fail(error: IDPError.notAvailableInDemoMode)
            .eraseToAnyPublisher()
    }

    func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError> {
        Fail(error: IDPError.notAvailableInDemoMode)
            .eraseToAnyPublisher()
    }

    func startExtAuth(entry _: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError> {
        Fail(error: IDPError.notAvailableInDemoMode)
            .eraseToAnyPublisher()
    }

    func extAuthVerifyAndExchange(
        _: URL,
        idTokenValidator _: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>
    ) -> AnyPublisher<IDPToken, IDPError> {
        Fail(error: IDPError.notAvailableInDemoMode)
            .eraseToAnyPublisher()
    }
}

extension DemoIDPSession {
    struct DemoPayload: Claims {}
}
