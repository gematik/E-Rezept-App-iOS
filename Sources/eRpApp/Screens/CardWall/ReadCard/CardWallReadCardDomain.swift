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

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: CardWallReadCardDomain.Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case idpChallenge
        case signAndVerify
    }

    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID
        var pin: String
        var loginOption: LoginOption
        var output: Output
        var alertState: AlertState<Action>?
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
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let signatureProvider: SecureEnclaveSignatureProvider
        var sessionProvider: ProfileBasedSessionProvider
    }

    static let reducer = Reducer { state, action, environment in

        switch action {
        case .getChallenge:
            return environment.idpChallengePublisher(for: state.profileId)
                .eraseToEffect()
                .cancellable(id: Token.idpChallenge, cancelInFlight: true)
        case let .stateReceived(.loggedIn(idpToken)):
            let payload = try? idpToken.idTokenPayload()
            state.output = .loggedIn(idpToken)
            return environment.saveProfileWith(
                profileId: state.profileId,
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
            return cleanup()
        case let .signChallenge(challenge):
            let pin = state.pin
            let biometrieFlow = state.loginOption == .withBiometry
            let profileID = state.profileId

            return Effect.concatenate(
                Effect.cancel(id: Token.idpChallenge),
                environment.sessionProvider.userDataStore(for: state.profileId).can
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
                            return environment.signChallengeThenAltAuthWithNFCCard(
                                can: canData,
                                pin: format2Pin,
                                profileID: profileID
                            )
                        }
                        return environment.signChallengeWithNFCCard(
                            can: canData,
                            pin: format2Pin,
                            profileID: profileID,
                            challenge: challenge
                        )
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
        static let state = State(
            isDemoModus: false,
            profileId: DemoProfileDataStore.anna.id,
            pin: "",
            loginOption: .withoutBiometry,
            output: .idle
        )
        static let environment = Environment(schedulers: Schedulers(),
                                             profileDataStore: DemoProfileDataStore(),
                                             signatureProvider: DummySecureEnclaveSignatureProvider(),
                                             sessionProvider: DummyProfileBasedSessionProvider())

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}

extension CardWallReadCardDomain.Environment {
    func saveProfileWith(
        profileId: UUID,
        insuranceId: String?,
        insurance: String?,
        givenName: String?,
        familyName: String?
    ) -> Effect<CardWallReadCardDomain.Action, Never> {
        profileDataStore.update(profileId: profileId) { profile in
            profile.insuranceId = insuranceId
            profile.insurance = insurance
            profile.givenName = givenName
            profile.familyName = familyName
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
    func idpChallengePublisher(for profileID: UUID) -> Effect<CardWallReadCardDomain.Action, Never> {
        Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in
            sessionProvider
                .idpSession(for: profileID)
                .requestChallenge()
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
                                  profileID: UUID,
                                  challenge: IDPChallengeSession) -> Effect<CardWallReadCardDomain.Action, Never> {
        Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in

            subscriber.send(.stateReceived(.signingChallenge(.loading)))

            return self.sessionProvider
                .signatureProvider(for: profileID)
                .sign(can: can, pin: pin, challenge: challenge)
                .mapError(CardWallReadCardDomain.State.Error.signChallengeError)
                .receive(on: self.schedulers.main)
                .flatMap { signedChallenge in
                    self.verifyResultWithIDP(signedChallenge, can: can, pin: pin, profileID: profileID)
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
                                     profileID: UUID,
                                     registerBiometrics _: Bool = false)
        -> Effect<CardWallReadCardDomain.Action, Never> {
        Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in
            subscriber.send(.stateReceived(.verifying(.loading)))
            return sessionProvider.idTokenValidator(for: profileID)
                .mapError(CardWallReadCardDomain.State.Error.profileValidation)
                .flatMap { idTokenValidator in
                    self.sessionProvider.idpSession(for: profileID)
                        .verify(signedChallenge)
                        .exchangeIDPToken(
                            idp: sessionProvider.idpSession(for: profileID),
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
