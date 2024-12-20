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
import ComposableArchitecture
import CoreNFC
import eRpKit
import Helper
import IDP
import NFCCardReaderProvider
import UIKit

@Reducer
struct CardWallReadCardDomain {
    @ObservableState
    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID
        var pin: String
        var loginOption: LoginOption
        var output: Output

        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)
        // Screen tracking handled inside
        case help(ReadCardHelpDomain)

        enum Alert: Equatable {
            case dismiss
            case close
            case unlockCard
            case signChallenge
            case wrongCAN
            case wrongPIN
            case openMail(String)
            case openHelpView
        }
    }

    enum Action: Equatable {
        case signChallenge
        case saveError(LocalStoreError)
        case openHelpView

        case resetNavigation
        case destination(PresentationAction<Destination.Action>)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case state(State.Output)
        }

        enum Delegate: Equatable {
            case close
            case singleClose
            case unlockCardClose

            case wrongCAN
            case wrongPIN
            case navigateToIntro
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore
    @Dependency(\.profileBasedSessionProvider) var profileBasedSessionProvider: ProfileBasedSessionProvider
    @Dependency(\.nfcSessionProvider) var nfcSessionProvider: NFCSignatureProvider
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler
    @Dependency(\.router) var router: Routing

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    private var environment: Environment {
        .init(
            schedulers: schedulers,
            profileDataStore: profileDataStore,
            sessionProvider: profileBasedSessionProvider,
            nfcSessionProvider: nfcSessionProvider,
            application: resourceHandler
        )
    }

    struct Environment {
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let sessionProvider: ProfileBasedSessionProvider
        let nfcSessionProvider: NFCSignatureProvider
        let application: ResourceHandler
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
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
            case let .signingChallenge(.error(error)),
                 let .verifying(.error(error)):
                switch error {
                case .signChallengeError(.verifyCardError(.passwordBlocked)),
                     .signChallengeError(.verifyCardError(.wrongSecretWarning(retryCount: 0))):
                    state.destination = .alert(AlertStates.alertBlockedCard(error))
                case .signChallengeError(.verifyCardError(.wrongSecretWarning)):
                    state.destination = .alert(AlertStates.wrongPIN(error))
                case .signChallengeError(.wrongCAN):
                    state.destination = .alert(AlertStates.wrongCAN(error))
                case let .signChallengeError(.cardError(.nfcTag(error: tagError))):
                    if let errorAlert = AlertStates.alert(for: tagError) {
                        state.destination = .alert(errorAlert)
                    }
                case let .signChallengeError(.nfcHealthCardSession(.coreNFC(coreNFCError))):
                    if let errorAlert = AlertStates.alert(for: coreNFCError) {
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
        // [REQ:BSI-eRp-ePA:O.Auth_3#2] Implementation of eGK connection
        case .signChallenge,
             .destination(.presented(.alert(.signChallenge))):
            let pin = state.pin
            let biometrieFlow = state.loginOption == .withBiometry
            let profileID = state.profileId

            let environment = environment
            return .run { [profileId = state.profileId] send in
                let can = try await environment.sessionProvider.userDataStore(for: profileId).can.async()
                guard let can = can else {
                    await send(.response(.state(State.Output.signingChallenge(.error(.inputError(.missingCAN))))))
                    return
                }

                if biometrieFlow {
                    await environment.signChallengeThenAltAuthWithNFCCard(
                        can: can,
                        pin: pin,
                        profileID: profileID,
                        send: send
                    )
                } else {
                    await environment.signChallengeWithNFCCard(
                        can: can,
                        pin: pin,
                        profileID: profileID,
                        send: send
                    )
                }
            }
        case let .destination(.presented(.alert(.openMail(message)))):
            let mailState = EmailState(subject: L10n.cdwTxtMailSubject.text, body: message)
            guard let url = mailState.createEmailUrl() else { return .none }
            if resourceHandler.canOpenURL(url) {
                resourceHandler.open(url)
            }
            return .none
        case .openHelpView,
             .destination(.presented(.alert(.openHelpView))):
            state.destination = .help(.init())
            return .none
        case .delegate(.navigateToIntro):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.wrongPIN))):
            return .send(.delegate(.wrongPIN))
        case .destination(.presented(.alert(.wrongCAN))):
            return .send(.delegate(.wrongCAN))
        case .destination(.presented(.alert(.close))):
            return .send(.delegate(.close))
        case .destination(.presented(.alert(.unlockCard))):
            state.destination = nil
            return .send(.delegate(.unlockCardClose))
        case .destination(.presented(.alert(.dismiss))):
            state.destination = nil
            return .none
        case let .destination(.presented(.help(action: .delegate(delegate)))):
            switch delegate {
            case .close:
                state.destination = nil
                return .none
            case .navigateToIntro:
                state.destination = nil
                return .send(.delegate(.navigateToIntro))
            }
        case .resetNavigation:
            state.destination = nil
            return .none
        case .delegate,
             .destination:
            return .none
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

        static let store = Store(initialState: state) {
            CardWallReadCardDomain()
        }
    }
}
