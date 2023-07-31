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
import ComposableArchitecture
import CoreNFC
import eRpKit
import Helper
import IDP
import NFCCardReaderProvider
import UIKit

enum CardWallReadCardHelpDomain {
    enum State: Int {
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp1
        case first
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp2
        case second
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp3
        case third
    }
}

struct CardWallReadCardDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        .cancel(id: CardWallReadCardDomain.Token.self)
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

        var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<CardWallReadCardDomain.Action>)
            // Screen tracking handled inside
            case help(CardWallReadCardHelpDomain.State)
        }

        enum Action: Equatable {
            case egkAction(action: OrderHealthCardDomain.Action)
            case confirmation(action: CardWallExtAuthConfirmationDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    enum Action: Equatable {
        case getChallenge
        case signChallenge(IDPChallengeSession)

        case saveError(LocalStoreError)
        case openMail(String)
        case openHelpViewScreen
        case updatePageIndex(page: CardWallReadCardHelpDomain.State)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case state(State.Output)
        }

        enum Delegate: Equatable {
            case close
            case singleClose

            case wrongCAN
            case wrongPIN
            case navigateToIntro
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore
    @Dependency(\.secureEnclaveSignatureProvider) var signatureProvider: SecureEnclaveSignatureProvider
    @Dependency(\.profileBasedSessionProvider) var profileBasedSessionProvider: ProfileBasedSessionProvider
    @Dependency(\.nfcSessionProvider) var nfcSessionProvider: NFCSignatureProvider
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    private var environment: Environment {
        .init(
            schedulers: schedulers,
            profileDataStore: profileDataStore,
            signatureProvider: signatureProvider,
            sessionProvider: profileBasedSessionProvider,
            nfcSessionProvider: nfcSessionProvider,
            application: resourceHandler
        )
    }

    struct Environment {
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let signatureProvider: SecureEnclaveSignatureProvider
        let sessionProvider: ProfileBasedSessionProvider
        let nfcSessionProvider: NFCSignatureProvider
        let application: ResourceHandler
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .getChallenge:
            state.destination = nil
            return environment.idpChallengePublisher(for: state.profileId)
                .eraseToEffect()
                .cancellable(id: Token.idpChallenge, cancelInFlight: true)
        case let .response(.state(.loggedIn(idpToken))):
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
            state.destination = .alert(AlertStates.saveProfile)
            return .none
        case let .response(.state(output)):
            state.output = output
            defer { CommandLogger.commands = [] }

            switch output {
            case let .retrievingChallenge(.error(error)),
                 let .signingChallenge(.error(error)),
                 let .verifying(.error(error)):
                switch error {
                case .signChallengeError(.verifyCardError(.passwordBlocked)),
                     .signChallengeError(.verifyCardError(.wrongSecretWarning(retryCount: 0))):
                    state.destination = .alert(AlertStates.alertFor(error))
                case .signChallengeError(.verifyCardError(.wrongSecretWarning)):
                    state.destination = .alert(AlertStates.wrongPIN(error))
                case .signChallengeError(.wrongCAN):
                    state.destination = .alert(AlertStates.wrongCAN(error))
                case let .signChallengeError(.cardError(.nfcTag(error: tagError))):
                    if let errorAlert = AlertStates.alert(for: tagError) {
                        state.destination = .alert(errorAlert)
                    }
                case let .signChallengeError(.cardConnectionError(nfcError)),
                     let .signChallengeError(.genericError(nfcError)):
                    switch nfcError {
                    case let cardError as NFCCardError:
                        if case let .nfcTag(error: tagError) = cardError,
                           let errorAlert = AlertStates.alert(for: tagError) {
                            state.destination = .alert(errorAlert)
                        }
                    case let readerError as NFCTagReaderSession.Error:
                        if case let .nfcTag(error: tagError) = readerError,
                           let errorAlert = AlertStates.alert(for: tagError) {
                            state.destination = .alert(errorAlert)
                        }
                    default:
                        state.destination = .alert(AlertStates.alertFor(error))
                    }
                case let .signChallengeError(challengeError):
                    state.destination = .alert(AlertStates.alertWithReportButton(error: challengeError))
                default:
                    state.destination = .alert(AlertStates.alertFor(error))
                }
            default:
                break
            }
            return .none
        case .delegate(.close):
            // This should be handled by the parent reducer
            return Self.cleanup()
        case let .signChallenge(challenge):
            let pin = state.pin
            let biometrieFlow = state.loginOption == .withBiometry
            let profileID = state.profileId

            let environment = environment

            return .concatenate(
                .cancel(id: Token.idpChallenge),
                environment.sessionProvider.userDataStore(for: state.profileId).can
                    .first()
                    .flatMap { can -> EffectTask<Action> in
                        guard let can = can else {
                            return Just(Action
                                .response(.state(State.Output.retrievingChallenge(.error(.inputError(.missingCAN))))))
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
        case let .openMail(message):
            let mailState = EmailState(subject: L10n.cdwTxtMailSubject.text, body: message)
            guard let url = mailState.createEmailUrl() else { return .none }
            if resourceHandler.canOpenURL(url) {
                resourceHandler.open(url)
            }
            return .none
        case .openHelpViewScreen:
            state.destination = .help(.first)
            return .none
        case let .updatePageIndex(page):
            guard state.destination?.tag == .help else { return .none }
            state.destination = .help(page)
            return .none
        case .delegate(.navigateToIntro):
            state.destination = nil
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .setNavigation,
             .delegate,
             .destination:
            return .none
        }
    }
}

extension CardWallReadCardDomain {
    static func createNfcReadingReport(
        with error: CodedError,
        commands: [Command]
    ) -> String {
        @Dependency(\.dateProvider) var dateProvider

        var description = "Teilen Sie uns den Namen Ihrer Krankenversicherung mit:\n"
        description += "\nWelchen Gesundheitskartentyp haben Sie "
        description += "(dies steht i.d.R. seitlich auf der Rückseite Ihrer Karte z.B. IDEMIA oder G&D):\n"

        description = "\nVielen Dank für das Senden dieses Reports. Der generierte Report enthält keine privaten Daten:"
        description += "# NFC Reading error iOS E-Rezept App\n\n"

        description += "Date: \(dateProvider().description)\n"

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

        static let store = Store(initialState: state, reducer: CardWallReadCardDomain())
    }
}

extension CardWallReadCardDomain.Environment {
    func saveProfileWith(
        profileId: UUID,
        insuranceId: String?,
        insurance: String?,
        givenName: String?,
        familyName: String?
    ) -> EffectTask<CardWallReadCardDomain.Action> {
        profileDataStore.update(profileId: profileId) { profile in
            profile.insuranceId = insuranceId
            // This is needed to ensure proper pKV faking (can be removed when the debug option to fake pKV is removed.)
            if profile.insuranceType == .unknown {
                profile.insuranceType = .gKV
            }
            profile.insurance = insurance
            profile.givenName = givenName
            profile.familyName = familyName
        }
        .map { _ in
            CardWallReadCardDomain.Action.delegate(.close)
        }
        .catch { error in
            Just(CardWallReadCardDomain.Action.saveError(error))
        }
        .receive(on: schedulers.main)
        .eraseToEffect()
    }

    // [REQ:gemSpec_eRp_FdV:A_20172]
    func idpChallengePublisher(for profileID: UUID) -> EffectTask<CardWallReadCardDomain.Action> {
        EffectTask<CardWallReadCardDomain.Action>.run { subscriber -> Cancellable in
            sessionProvider
                .idpSession(for: profileID)
                .requestChallenge()
                .map { CardWallReadCardDomain.State.Output.challengeLoaded($0) }
                .catch { Just(CardWallReadCardDomain.State.Output.retrievingChallenge(.error(.idpError($0)))) }
                .onSubscribe { _ in
                    subscriber.send(.response(.state(.retrievingChallenge(.loading))))
                }
                .receive(on: self.schedulers.main)
                .sink(receiveCompletion: { _ in
                    subscriber.send(completion: .finished)
                }, receiveValue: { value in
                    subscriber.send(.response(.state(value)))
                })
        }
    }

    // [REQ:gemSpec_eRp_FdV:A_20172]
    // [REQ:gemSpec_IDP_Frontend:A_20526-01] sign and verify with idp
    func signChallengeWithNFCCard(can: String,
                                  pin: String,
                                  profileID: UUID,
                                  challenge: IDPChallengeSession) -> EffectTask<CardWallReadCardDomain.Action> {
        .run { subscriber -> Cancellable in

            subscriber.send(.response(.state(.signingChallenge(.loading))))

            return self.nfcSessionProvider
                .sign(can: can, pin: pin, challenge: challenge)
                .first()
                .mapError(CardWallReadCardDomain.State.Error.signChallengeError)
                .receive(on: self.schedulers.main)
                .flatMap { signedChallenge in
                    self.verifyResultWithIDP(signedChallenge, can: can, pin: pin, profileID: profileID)
                }
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        subscriber.send(.response(.state(.signingChallenge(.error(error)))))
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
        -> EffectTask<CardWallReadCardDomain.Action> {
        .run { subscriber -> Cancellable in
            subscriber.send(.response(.state(.verifying(.loading))))
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
                    subscriber.send(.response(.state(value)))
                })
        }
    }
}
