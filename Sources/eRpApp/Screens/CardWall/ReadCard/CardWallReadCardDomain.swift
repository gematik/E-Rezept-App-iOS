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
import CoreNFC
import eRpKit
import Helper
import IDP
import NFCCardReaderProvider
import UIKit

enum CardWallReadCardHelpDomain {
    enum State: Int {
        case first
        case second
        case third
    }
}

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

    enum Route: Equatable {
        case alert(ErpAlertState<Action>)
        case help(CardWallReadCardHelpDomain.State)
    }

    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID
        var pin: String
        var loginOption: LoginOption
        var output: Output

        var route: Route?
    }

    enum Action: Equatable {
        case getChallenge
        case close
        case signChallenge(IDPChallengeSession)
        case wrongCAN
        case wrongPIN

        case stateReceived(State.Output)
        case saveError(LocalStoreError)
        case openMail(String)
        case openHelpViewScreen
        case updatePageIndex(page: CardWallReadCardHelpDomain.State)
        case navigateToIntro
        case setNavigation(tag: Route.Tag?)
        case singleClose
    }

    struct Environment {
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let signatureProvider: SecureEnclaveSignatureProvider
        let sessionProvider: ProfileBasedSessionProvider
        let nfcSessionProvider: NFCSignatureProvider
        let application: ResourceHandler
    }

    static let reducer = Reducer { state, action, environment in

        switch action {
        case .getChallenge:
            state.route = nil
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
            state.route = .alert(AlertStates.saveProfile)
            return .none
        case let .stateReceived(output):
            state.output = output
            defer { CommandLogger.commands = [] }

            switch output {
            case let .retrievingChallenge(.error(error)),
                 let .signingChallenge(.error(error)),
                 let .verifying(.error(error)):
                switch error {
                case .signChallengeError(.verifyCardError(.passwordBlocked)),
                     .signChallengeError(.verifyCardError(.wrongSecretWarning(retryCount: 0))):
                    state.route = .alert(AlertStates.alertFor(error))
                case .signChallengeError(.verifyCardError(.wrongSecretWarning)):
                    state.route = .alert(AlertStates.wrongPIN(error))
                case .signChallengeError(.wrongCAN):
                    state.route = .alert(AlertStates.wrongCAN(error))
                case let .signChallengeError(.cardError(.nfcTag(error: tagError))):
                    if let errorAlert = AlertStates.alert(for: tagError) {
                        state.route = .alert(errorAlert)
                    }
                case let .signChallengeError(.cardConnectionError(nfcError)),
                     let .signChallengeError(.genericError(nfcError)):
                    switch nfcError {
                    case let cardError as NFCCardError:
                        if case let .nfcTag(error: tagError) = cardError,
                           let errorAlert = AlertStates.alert(for: tagError) {
                            state.route = .alert(errorAlert)
                        }
                    case let readerError as NFCTagReaderSession.Error:
                        if case let .nfcTag(error: tagError) = readerError,
                           let errorAlert = AlertStates.alert(for: tagError) {
                            state.route = .alert(errorAlert)
                        }
                    default:
                        state.route = .alert(AlertStates.alertFor(error))
                    }
                case let .signChallengeError(challengeError):
                    state.route = .alert(AlertStates.alertWithReportButton(error: challengeError))
                default:
                    state.route = .alert(AlertStates.alertFor(error))
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
                        guard let can = can else {
                            return Just(Action
                                .stateReceived(State.Output.retrievingChallenge(.error(.inputError(.missingCAN)))))
                                                            .eraseToEffect()
                        }

                        if biometrieFlow {
                            return environment.signChallengeThenAltAuthWithNFCCard(
                                can: can,
                                pin: pin,
                                profileID: profileID
                            )
                        }
                        return environment.signChallengeWithNFCCard(
                            can: can,
                            pin: pin,
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
        case let .openMail(message):
            let mailState = EmailState(subject: L10n.cdwTxtMailSubject.text, body: message)
            guard let url = mailState.createEmailUrl() else { return .none }
            if environment.application.canOpenURL(url) {
                environment.application.open(url)
            }
            return .none
        case .openHelpViewScreen:
            state.route = .help(.first)
            return .none
        case let .updatePageIndex(page):
            guard state.route?.tag == .help else { return .none }
            state.route = .help(page)
            return .none
        case .navigateToIntro:
            state.route = nil
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .setNavigation,
             .singleClose:
            return .none
        }
    }
}

extension CardWallReadCardDomain {
    enum AlertStates {
        typealias Action = CardWallReadCardDomain.Action
        typealias Error = CardWallReadCardDomain.State.Error

        static var saveProfile: ErpAlertState<Action> = .info(AlertState(
            title: TextState(L10n.cdwTxtRcAlertTitleSaveProfile),
            message: TextState(L10n.cdwTxtRcAlertMessageSaveProfile),
            dismissButton: .cancel(TextState(L10n.cdwBtnRcAlertSaveProfile))
        ))

        static func wrongCAN(_ error: State.Error) -> ErpAlertState<Action> {
            ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcCorrectCan), action: .send(.wrongCAN))
            )
        }

        static var tagConnectionLostCount = 0
        static func tagConnectionLost(_ error: CoreNFCError) -> ErpAlertState<Action> {
            Self.tagConnectionLostCount += 1
            if tagConnectionLostCount <= 3 {
                return ErpAlertState(
                    for: error,
                    primaryButton: .default(TextState(L10n.cdwBtnRcHelp), action: .send(.openHelpViewScreen)),
                    secondaryButton: .cancel(.init(L10n.cdwBtnRcRetry), action: .send(.getChallenge))
                )
            } else {
                let report = createNfcReadingReport(with: error, commands: CommandLogger.commands)
                return ErpAlertState(
                    for: error,
                    primaryButton: .default(TextState(L10n.cdwBtnRcAlertReport), action: .send(.openMail(report))),
                    secondaryButton: .cancel(.init(L10n.cdwBtnRcRetry), action: .send(.getChallenge))
                )
            }
        }

        static func wrongPIN(_ error: Error) -> ErpAlertState<Action> {
            ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcCorrectPin), action: .send(.wrongPIN)),
                secondaryButton: .cancel(TextState(L10n.cdwBtnRcAlertCancel), action: .send(.setNavigation(tag: .none)))
            )
        }

        static func alertFor(_ error: CodedError) -> ErpAlertState<Action> {
            ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcAlertClose), action: .send(.setNavigation(tag: .none)))
            )
        }

        static func alertWithReportButton(error: CodedError) -> ErpAlertState<Action> {
            let report = createNfcReadingReport(with: error, commands: CommandLogger.commands)
            return ErpAlertState(
                for: error,
                primaryButton: .default(TextState(L10n.cdwBtnRcAlertReport), action: .send(.openMail(report))),
                secondaryButton: .cancel(.init(L10n.cdwBtnRcRetry), action: .send(.getChallenge))
            )
        }

        static func alert(for tagError: CoreNFCError) -> ErpAlertState<CardWallReadCardDomain.Action>? {
            switch tagError {
            case .tagConnectionLost:
                return CardWallReadCardDomain.AlertStates.tagConnectionLost(tagError)
            case .sessionTimeout, .sessionInvalidated, .other, .unknown:
                return CardWallReadCardDomain.AlertStates.alertWithReportButton(error: tagError)
            case .unsupportedFeature:
                return CardWallReadCardDomain.AlertStates.alertFor(tagError)
            default: return nil
            }
        }
    }

    static func createNfcReadingReport(
        with error: CodedError,
        commands: [Command]
    ) -> String {
        var description = "Teilen Sie uns den Namen Ihrer Krankenversicherung mit:\n"
        description += "\nWelchen Gesundheitskartentyp haben Sie "
        description += "(dies steht i.d.R. seitlich auf der Rückseite Ihrer Karte z.B. IDEMIA oder G&D):\n"

        description = "\nVielen Dank für das Senden dieses Reports. Der generierte Report enthält keine privaten Daten:"
        description += "# NFC Reading error iOS E-Rezept App\n\n"

        description += "Date: \(Date().description)\n"

        description += "\n# RESULT\n\n"
        description += "Tag connections lost count: \(CardWallReadCardDomain.AlertStates.tagConnectionLostCount)"

        description +=
            "Finished with error message: '\(error.localizedDescription) \(error.recoverySuggestionWithErrorList)'\n"
        description += "actual error: \(String(describing: error))\n"

        description += "\n# COMMANDS\n"

        guard !commands.isEmpty else {
            description += "No commands between smart card and device have been sent!\n"
            return description
        }

        for command in commands {
            switch command.type {
            case .send:
                description += "SEND:\n"
                description += "\(command.message.prefix(100))\n"
            case .sendSecureChannel:
                description += "SEND (secure channel, header only):\n"
                description += "\(command.message.prefix(12))\n\n"
            case .response:
                description += "\nRESPONSE:\n"
                description += "\(command.message.prefix(100))...\n\n"
            case .responseSecureChannel:
                description += "RESPONSE (secure channel):\n"
                description += "\(command.message.prefix(8))...\n\n"
            case .description:
                description += "\n*** \(command.message) ***\n\n"
            default: break
            }
        }
        return description
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
                                             sessionProvider: DummyProfileBasedSessionProvider(),
                                             nfcSessionProvider: DemoSignatureProvider(),
                                             application: UIApplication.shared)

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
    func signChallengeWithNFCCard(can: String,
                                  pin: String,
                                  profileID: UUID,
                                  challenge: IDPChallengeSession) -> Effect<CardWallReadCardDomain.Action, Never> {
        Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in

            subscriber.send(.stateReceived(.signingChallenge(.loading)))

            return self.nfcSessionProvider
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
                                     can _: String,
                                     pin _: String,
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
