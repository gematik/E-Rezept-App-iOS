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
import eRpKit
import Foundation
import IDP

@Reducer
struct CardWallIntroductionDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall_CAN
        case can(CardWallCANDomain)
        // sourcery: AnalyticsScreen = cardWall_extAuth
        case extAuth(CardWallExtAuthSelectionDomain)
        // sourcery: AnalyticsScreen = contactInsuranceCompany
        case egk(OrderHealthCardDomain)
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        @ReducerCaseEphemeral
        case contactSheet(ConfirmationDialogState<ContactSheet>)

        enum Alert: Equatable {
            case dismiss
            case searchKK
            case openContactSheet
        }

        enum ContactSheet: Equatable {
            case contactByTelephone
            case contactByMail
        }
    }

    @ObservableState
    struct State: Equatable {
        /// App is only usable with NFC for now
        let isNFCReady: Bool
        let profileId: UUID
        var entry: KKAppDirectory.Entry?
        var loading = false
        @Presents var destination: Destination.State?
    }

    // sourcery: CodedError = "029"
    enum Error: Swift.Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case idpError(IDPError)
        // sourcery: errorCode = "02"
        case universalLinkFailed
        // sourcery: errorCode = "03"
        case kkNotFound

        var errorDescription: String? {
            switch self {
            case let .idpError(error):
                return error.localizedDescription
            case .universalLinkFailed:
                return L10n.cdwTxtExtauthConfirmUniversalLinkFailedError.text
            case .kkNotFound:
                return L10n.cdwTxtIntroAlertKkNotFoundTitle.text
            }
        }
    }

    indirect enum Action: Equatable {
        case task
        case advance
        case advanceCAN(String?)

        case response(Response)
        case delegate(Delegate)

        case resetNavigation

        case extAuthTapped
        case directExtAuthTapped
        case openURL(URL)
        case error(Error)
        case openContactSheet

        case egkButtonTapped
        case destination(PresentationAction<Destination.Action>)

        enum Response: Equatable {
            case profileReceived(Result<Profile?, LocalStoreError>)
            case checkKK(Result<KKAppDirectory, IDPError>, KKAppDirectory.Entry)
            case openURL(Bool)
        }

        enum Delegate: Equatable {
            case close
            case unlockCardClose
        }
    }

    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore
    @Dependency(\.idpSession) var idpSession: IDPSession
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .publisher(
                profileDataStore.fetchProfile(by: state.profileId)
                    .catchToPublisher()
                    .map { Action.response(.profileReceived($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.profileReceived(.success(profile))):
            state.entry = profile?.gIdEntry
            return .none
        case .response(.profileReceived(.failure)):
            return .none
        case .advance:
            return .publisher(
                userSessionProvider.userSession(for: state.profileId).secureUserStore.can
                    .first()
                    .map(Action.advanceCAN)
                    .eraseToAnyPublisher
            )
        case let .advanceCAN(can):
            state.destination = .can(CardWallCANDomain.State(
                isDemoModus: userSession.isDemoMode,
                profileId: state.profileId,
                can: can ?? ""
            ))
            return .none
        case .delegate(.close):
            return .none
        case .egkButtonTapped:
            state.destination = .egk(.init())
            return .none
        case .resetNavigation,
             .destination(.presented(.egk(.delegate(.close)))):
            state.destination = nil
            return .none
        case .destination(.presented(.can(.delegate(.navigateToIntro)))),
             // [REQ:BSI-eRp-ePA:O.Auth_4#3] Present the gID flow for selecting the correct insurance company
             .extAuthTapped:
            state.destination = .extAuth(CardWallExtAuthSelectionDomain.State())
            return .none
        case .directExtAuthTapped:
            guard let selectedKK = state.entry else { return .none }
            state.loading = true
            return .publisher(
                idpSession.loadDirectoryKKApps()
                    .first()
                    .catchToPublisher()
                    .map { Action.response(.checkKK($0, selectedKK)) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.checkKK(.success(result), selectedKK)):
            if result.apps.contains(selectedKK) {
                return .publisher(
                    idpSession.startExtAuth(entry: selectedKK)
                        .first()
                        .map(Action.openURL)
                        .catch { error in
                            Just(Action.error(Error.idpError(error)))
                        }
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )
            } else {
                state.loading = false
                state.destination = .alert(AlertStates.kkNotFound)
                return .none
            }
        case let .openURL(url):
            return Effect.run { send in
                let action = await withCheckedContinuation { continuation in
                    // [REQ:gemSpec_IDP_Sek:A_22299] Follow redirect
                    // [REQ:BSI-eRp-ePA:O.Plat_10#3] Follow redirect
                    guard resourceHandler.canOpenURL(url) else {
                        continuation.resume(returning: Action.response(.openURL(false)))
                        return
                    }

                    // [REQ:gemSpec_IDP_Sek:A_22313-01] Remember State parameter for later verification
                    resourceHandler.open(url, options: [:]) { result in
                        continuation.resume(returning: Action.response(.openURL(result)))
                    }
                }
                await send(action)
            }
        case let .response(.openURL(successful)):
            state.loading = false
            if successful {
                return Effect.send(.delegate(.close))
            } else {
                state.destination = .alert(AlertStates.alert(for: Error.universalLinkFailed))
            }
            return .none
        case let .response(.checkKK(.failure(error), _)):
            state.loading = false
            state.destination = .alert(AlertStates.alert(for: Error.idpError(error)))
            return .none
        case let .error(error):
            state.loading = false
            state.destination = .alert(AlertStates.alert(for: error))
            return .none
        case .destination(.presented(.alert(.openContactSheet))):
            return .send(.openContactSheet)
        case .openContactSheet:
            state.destination = .contactSheet(ConfirmationDialogState<Destination.ContactSheet>(
                title: { TextState(L10n.cdwTxtExtauthConfirmContactsheetTitle) },
                actions: {
                    ButtonState(action: .send(.contactByTelephone)) {
                        TextState(L10n.cdwTxtExtauthConfirmContactsheetTelephone)
                    }
                    ButtonState(action: .send(.contactByMail)) {
                        TextState(L10n.cdwTxtExtauthConfirmContactsheetMail)
                    }
                    ButtonState(role: .cancel, action: .send(.none)) {
                        TextState(L10n.cdwBtnIntroAlertClose)
                    }
                }
            ))
            return .none
        case .destination(.presented(.contactSheet(.contactByTelephone))):
            guard let url = URL(string: "tel:+498002773777") else { return .none }
            resourceHandler.open(url, options: [:]) { _ in }
            return .none
        case .destination(.presented(.contactSheet(.contactByMail))):
            guard let url = URL(string: "mailto:app-feedback@gematik.de") else { return .none }
            resourceHandler.open(url, options: [:]) { _ in }
            return .none
        case .destination(.presented(.alert(.searchKK))):
            state.destination = .extAuth(CardWallExtAuthSelectionDomain.State())
            return .none
        case .destination(.presented(.can(.delegate(.close)))),
             .destination(.presented(.extAuth(.delegate(.close)))):
            state.destination = nil
            return .run { send in
                try await schedulers.main.sleep(for: 0.05)
                await send(.delegate(.close))
            }
        case .destination(.presented(.can(.delegate(.unlockCardClose)))):
            state.destination = nil
            return .run { send in
                try await schedulers.main.sleep(for: 0.05)
                await send(.delegate(.unlockCardClose))
            }
        case .destination:
            return .none
        case .delegate(.unlockCardClose):
            return .none
        }
    }
}

extension CardWallIntroductionDomain {
    enum AlertStates {
        typealias Action = CardWallIntroductionDomain.Destination.Alert

        static var kkNotFound: ErpAlertState<Action> = .info(
            AlertState(
                title: { TextState(L10n.cdwTxtIntroAlertKkNotFoundTitle) },
                actions: {
                    ButtonState(role: .cancel, action: .searchKK) {
                        TextState(L10n.alertBtnOk)
                    }
                },
                message: { TextState(L10n.cdwTxtIntroKkNotFoundAlertMessage) }
            )
        )

        static func alertFor(_ error: IDPError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: nil
            ) {
                ButtonState(action: .dismiss) {
                    .init(L10n.cdwBtnIntroAlertClose)
                }
            }
        }

        static var universalLinkError: ErpAlertState<Action> = .info(
            AlertState(
                title: { TextState(L10n.cdwTxtExtauthConfirmUniversalLinkFailedError) },
                actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.cdwBtnIntroAlertClose)
                    }
                    ButtonState(action: .openContactSheet) {
                        .init(L10n.cdwBtnExtauthConfirmContact)
                    }
                },
                message: {
                    TextState(
                        "\(Error.universalLinkFailed.erpErrorCode) \n \(L10n.cdwTxtExtauthConfirmErrorDescription.text)"
                    )
                }
            )
        )

        static func alert(for error: Error) -> ErpAlertState<Action> {
            switch error {
            case let .idpError(error):
                return CardWallIntroductionDomain.AlertStates.alertFor(error)
            case .universalLinkFailed:
                return CardWallIntroductionDomain.AlertStates.universalLinkError
            case .kkNotFound:
                return CardWallIntroductionDomain.AlertStates.kkNotFound
            }
        }
    }
}

extension CardWallIntroductionDomain {
    enum Dummies {
        static let state = State(isNFCReady: true, profileId: UUID())

        static let store = Store(initialState: state) {
            CardWallIntroductionDomain()
        }
    }
}
