//
//  Copyright (c) 2022 gematik GmbH
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
import ComposableArchitecture
import eRpKit
import HealthCardAccess
import IDP

enum CardWallReadCardDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        let isDemoModus: Bool
        var pin: String
        var loginOption: LoginOption
        var output: Output
        var alertState: AlertState<Action>?
    }

    enum Token: CaseIterable, Hashable {
        case idpChallenge
        case signAndVerify
    }

    enum Action: Equatable {
        case getChallenge
        case close
        case signChallenge(IDPChallengeSession)
        case wrongCAN
        case wrongPIN

        case stateReceived(State.Output)
        case saveError(LocalStoreError)
        case alertDismissButtonTapped
    }

    struct Environment {
        let userSession: UserSession
        let schedulers: Schedulers
        let currentProfile: AnyPublisher<Profile, LocalStoreError>
        let idTokenValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>
        let profileDataStore: ProfileDataStore
        let signatureProvider: SecureEnclaveSignatureProvider
    }

    static let reducer = Reducer { state, action, environment in

        switch action {
        case .getChallenge:
            return environment.idpChallengePublisher
                .eraseToEffect()
                .cancellable(id: Token.idpChallenge, cancelInFlight: true)
        case let .stateReceived(.loggedIn(idpToken)):
            let payload = try? idpToken.idTokenPayload()
            state.output = .loggedIn(idpToken)
            return environment.saveProfileWith(
                insuranceId: payload?.idNummer,
                insurance: payload?.organizationName,
                givenName: payload?.givenName,
                familyName: payload?.familyName
            )
        case .saveError:
            state.alertState = saveProfileAlertState
            return .none
        case let .stateReceived(output):
            state.output = output

            switch output {
            case let .retrievingChallenge(.error(error)),
                 let .signingChallenge(.error(error)),
                 let .verifying(.error(error)):
                switch error {
                case .signChallengeError(.wrongPin):
                    state.alertState = AlertStates.wrongPIN(error)
                case .signChallengeError(.wrongCAN):
                    state.alertState = AlertStates.wrongCAN(error)
                default:
                    state.alertState = AlertStates.alertFor(error)
                }
            default:
                break
            }
            return .none
        case .close:
            // This should be handled by the parent reducer
            return .none
        case let .signChallenge(challenge):
            let pin = state.pin
            let biometrieFlow = state.loginOption == .withBiometry

            return Effect.concatenate(
                Effect.cancel(id: Token.idpChallenge),
                environment.userSession.secureUserStore.can
                    .first()
                    .flatMap { can -> Effect<Action, Never> in
                        guard let can = can,
                              let canData = try? CAN.from(Data(can.utf8)) else {
                            return Just(Action
                                .stateReceived(State.Output.retrievingChallenge(.error(.inputError(.missingCAN)))))
                                                            .eraseToEffect()
                        }
                        guard let format2Pin = try? Format2Pin(pincode: pin) else {
                            return Just(Action.stateReceived(.retrievingChallenge(.error(.inputError(.missingPIN)))))
                                .eraseToEffect()
                        }

                        if biometrieFlow {
                            return environment.signChallengeThenAltAuthWithNFCCard(can: canData, pin: format2Pin)
                        }
                        return environment.signChallengeWithNFCCard(can: canData, pin: format2Pin, challenge: challenge)
                    }
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.signAndVerify, cancelInFlight: true)
            )
        case .wrongCAN:
            return .none
        case .wrongPIN:
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        }
    }

    static var saveProfileAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.cdwTxtRcAlertTitleSaveProfile),
            message: TextState(L10n.cdwTxtRcAlertMessageSaveProfile),
            dismissButton: .cancel(TextState(L10n.cdwBtnRcAlertSaveProfile))
        )
    }()
}

extension CardWallReadCardDomain {
    enum AlertStates {
        typealias Action = CardWallReadCardDomain.Action
        typealias Error = CardWallReadCardDomain.State.Error

        static func wrongCAN(_ error: Error) -> AlertState<Action> {
            AlertState(
                title: TextState(error.localizedDescription),
                message: error.recoverySuggestion.map(TextState.init),
                primaryButton: .default(TextState(L10n.cdwBtnRcCorrectCan), action: .send(.wrongCAN)),
                secondaryButton: .cancel(TextState(L10n.cdwBtnRcAlertCancel), action: .send(.alertDismissButtonTapped))
            )
        }

        static func wrongPIN(_ error: Error) -> AlertState<Action> {
            AlertState(
                title: TextState(error.localizedDescription),
                message: error.recoverySuggestion.map(TextState.init),
                primaryButton: .default(TextState(L10n.cdwBtnRcCorrectPin), action: .send(.wrongPIN)),
                secondaryButton: .cancel(TextState(L10n.cdwBtnRcAlertCancel), action: .send(.alertDismissButtonTapped))
            )
        }

        static func alertFor(_ error: Error) -> AlertState<Action> {
            AlertState(
                title: TextState(error.localizedDescription),
                message: error.recoverySuggestion.map(TextState.init),
                dismissButton: .default(TextState(L10n.cdwBtnRcAlertClose), action: .send(.alertDismissButtonTapped))
            )
        }
    }
}

extension CardWallReadCardDomain {
    enum Dummies {
        static let state = State(isDemoModus: false, pin: "", loginOption: .withoutBiometry, output: .idle)
        static let environment = Environment(userSession: DemoSessionContainer(),
                                             schedulers: Schedulers(),
                                             currentProfile: DemoSessionContainer().profile(),
                                             idTokenValidator: DemoSessionContainer().idTokenValidator(),
                                             profileDataStore: DemoProfileDataStore(),
                                             signatureProvider: DummySecureEnclaveSignatureProvider())

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}

extension CardWallReadCardDomain.Environment {
    func saveProfileWith(
        insuranceId: String?,
        insurance: String?,
        givenName: String?,
        familyName: String?
    ) -> Effect<CardWallReadCardDomain.Action, Never> {
        currentProfile
            .first()
            .flatMap { profile -> AnyPublisher<Bool, LocalStoreError> in
                profileDataStore.update(profileId: profile.id) { profile in
                    profile.insuranceId = insuranceId
                    profile.insurance = insurance
                    profile.givenName = givenName
                    profile.familyName = familyName
                }
                .eraseToAnyPublisher()
            }
            .map { _ in
                CardWallReadCardDomain.Action.close
            }
            .catch { error in
                Just(CardWallReadCardDomain.Action.saveError(error))
            }
            .receive(on: schedulers.main)
            .eraseToEffect()
    }

    // [REQ:gemSpec_eRp_FdV:A_20172]
    var idpChallengePublisher: Effect<CardWallReadCardDomain.Action, Never> {
        Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in
            userSession.idpSession.requestChallenge()
                .map { CardWallReadCardDomain.State.Output.challengeLoaded($0) }
                .catch { Just(CardWallReadCardDomain.State.Output.retrievingChallenge(.error(.idpError($0)))) }
                .onSubscribe { _ in
                    subscriber.send(.stateReceived(.retrievingChallenge(.loading)))
                }
                .receive(on: self.schedulers.main)
                .sink(receiveCompletion: { _ in
                    subscriber.send(completion: .finished)
                }, receiveValue: { value in
                    subscriber.send(.stateReceived(value))
                })
        }
    }

    // [REQ:gemSpec_eRp_FdV:A_20172]
    // [REQ:gemSpec_IDP_Frontend:A_20526-01] sign and verify with idp
    func signChallengeWithNFCCard(can: CAN,
                                  pin: Format2Pin,
                                  challenge: IDPChallengeSession) -> Effect<CardWallReadCardDomain.Action, Never> {
        Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in

            subscriber.send(.stateReceived(.signingChallenge(.loading)))

            return self.userSession.nfcSessionProvider
                .sign(can: can, pin: pin, challenge: challenge)
                .mapError(CardWallReadCardDomain.State.Error.signChallengeError)
                .receive(on: self.schedulers.main)
                .flatMap { signedChallenge in
                    self.verifyResultWithIDP(signedChallenge, can: can, pin: pin)
                }
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        subscriber.send(CardWallReadCardDomain.Action.stateReceived(.signingChallenge(.error(error))))
                    }
                    subscriber.send(completion: .finished)
                }, receiveValue: { value in
                    subscriber.send(value)
                })
        }
    }

    // [REQ:gemSpec_eRp_FdV:A_20172]
    // [REQ:gemSpec_IDP_Frontend:A_20526-01] verify with idp
    private func verifyResultWithIDP(_ signedChallenge: SignedChallenge,
                                     can _: CAN,
                                     pin _: Format2Pin,
                                     registerBiometrics _: Bool = false)
        -> Effect<CardWallReadCardDomain.Action, Never> {
        Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in
            subscriber.send(.stateReceived(.verifying(.loading)))
            return idTokenValidator
                .mapError(CardWallReadCardDomain.State.Error.profileValidation)
                .flatMap { idTokenValidator in
                    self.userSession.idpSession
                        .verify(signedChallenge)
                        .exchangeIDPToken(
                            idp: self.userSession.idpSession,
                            challengeSession: signedChallenge.originalChallenge,
                            idTokenValidator: idTokenValidator.validate(idToken:)
                        )
                }
                .eraseToCardWallLoginState()
                .receive(on: self.schedulers.main)
                .sink(receiveCompletion: { _ in
                    subscriber.send(completion: .finished)
                }, receiveValue: { value in
                    subscriber.send(.stateReceived(value))
                })
        }
    }
}