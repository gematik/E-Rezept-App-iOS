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

import CodedError
import Combine
import ComposableArchitecture
import eRpKit
import eRpResources
import FeatureHelpers
import Foundation
import IDP

/// Domain for handling card wall introduction flow
@Reducer
public struct CardWallIntroductionDomain { // swiftlint:disable:this type_body_length
    /// Initializes a new CardWallIntroductionDomain
    public init() {}

    /// Destination states for navigation from introduction screen
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        // sourcery: AnalyticsScreen = cardWall_CAN
        /// Navigate to CAN input
        case can(CardWallCANDomain)
        // sourcery: AnalyticsScreen = cardWall_extAuth
        /// Navigate to external authentication
        case extAuth(CardWallExtAuthSelectionDomain)
        // sourcery: AnalyticsScreen = contactInsuranceCompany
        /// Navigate to health card ordering
        case egk(OrderHealthCardDomain)
        // sourcery: AnalyticsScreen = alert
        /// Show alert dialog
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        /// Show contact sheet
        @ReducerCaseEphemeral
        case contactSheet(ConfirmationDialogState<ContactSheet>)

        /// Alert types
        public enum Alert: Equatable {
            /// Dismiss the alert
            case dismiss
            /// Search for insurance companies
            case searchKK
            /// Open contact sheet
            case openContactSheet
        }

        /// Contact sheet options
        public enum ContactSheet: Equatable {
            /// Contact by telephone
            case contactByTelephone
            /// Contact by mail
            case contactByMail
        }
    }

    /// State for the introduction screen
    @ObservableState
    public struct State: Equatable {
        /// App is only usable with NFC for now
        let isNFCReady: Bool
        let profileId: UUID
        var entry: KKAppDirectory.Entry?
        var insuranceType: Profile.InsuranceType = .unknown
        var loading = false
        @Presents public var destination: Destination.State?

        init(
            isNFCReady: Bool,
            profileId: UUID,
            entry: KKAppDirectory.Entry? = nil,
            insuranceType: Profile.InsuranceType = .unknown,
            loading: Bool = false,
            destination: CardWallIntroductionDomain.Destination.State? = nil
        ) {
            self.isNFCReady = isNFCReady
            self.profileId = profileId
            self.entry = entry
            self.insuranceType = insuranceType
            self.loading = loading
            self.destination = destination
        }

        public init(isNFCReady: Bool, profileId: UUID) {
            self.isNFCReady = isNFCReady
            self.profileId = profileId
        }
    }

    @CodedError("029")
    public enum Error: Swift.Error, Equatable, LocalizedError {
        @ErrorCode("01")
        case idpError(IDPError)
        @ErrorCode("02")
        case universalLinkFailed
        @ErrorCode("03")
        case kkNotFound

        public var errorDescription: String? {
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

    /// Actions that can be performed in the introduction domain
    public indirect enum Action: Equatable {
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

        public enum Response: Equatable {
            case profileReceived(Result<Profile?, LocalStoreError>)
            case checkKK(Result<KKAppDirectory, IDPError>, KKAppDirectory.Entry)
            case openURL(Bool)
        }

        public enum Delegate: Equatable {
            case close
            case unlockCardClose
        }
    }

    @Dependency(\.secureUserDataStoreClient) var secureUserDataStoreClient
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.openURLHandler) var openURLHandler
    @Dependency(\.profileBasedSessionProvider) var profileBasedSessionProvider
    @Dependency(\.profilesStore) var profilesStore

    /// The reducer body that handles state transitions and effects
    public var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .publisher(
                profilesStore.fetchProfile(identifier: state.profileId)
                    .map(Result.success)
                    .catch { Just(Result.failure($0)) }
                    .map { Action.response(.profileReceived($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.profileReceived(.success(profile))):
            state.entry = profile?.gIdEntry
            state.insuranceType = profile?.insuranceType ?? .unknown

            // skip to selection for initial pkv
            if state.insuranceType == .pKV, state.entry == nil {
                state.destination = .extAuth(CardWallExtAuthSelectionDomain.State(
                    profileId: state.profileId,
                    insuranceType: state.insuranceType
                ))
            }
            return .none
        case .response(.profileReceived(.failure)):
            return .none
        case .advance:
            return .publisher(
                secureUserDataStoreClient.can(profileId: state.profileId)
                    .first()
                    .map(Action.advanceCAN)
                    .eraseToAnyPublisher
            )
        case let .advanceCAN(can):
            state.destination = .can(CardWallCANDomain.State(
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
            state.destination = .extAuth(CardWallExtAuthSelectionDomain.State(
                profileId: state.profileId,
                insuranceType: state.insuranceType
            ))
            return .none
        case .directExtAuthTapped:
            guard let selectedKK = state.entry else { return .none }
            state.loading = true
            guard let idpSession = try? profileBasedSessionProvider.idpSession(state.profileId) else { return .none }
            return .publisher(
                idpSession
                    .loadDirectoryKKApps()
                    .first()
                    .map(Result.success)
                    .catch { Just(Result.failure($0)) }
                    .map { Action.response(.checkKK($0, selectedKK)) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.checkKK(.success(result), selectedKK)):
            guard let idpSession = try? profileBasedSessionProvider.idpSession(state.profileId) else { return .none }
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
                // [REQ:gemSpec_IDP_Sek:A_22299] Follow redirect
                // [REQ:BSI-eRp-ePA:O.Plat_10#3] Follow redirect
                guard await openURLHandler.canOpenURL(url) else {
                    await send(.response(.openURL(false)))
                    return
                }

                // [REQ:gemSpec_IDP_Sek:A_22313-01] Remember State parameter for later verification
                await openURLHandler.open(url)
                await send(.response(.openURL(true)))
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
            return .run { _ in
                await openURLHandler.open(url)
            }
        case .destination(.presented(.contactSheet(.contactByMail))):
            guard let url = URL(string: "mailto:app-feedback@gematik.de") else { return .none }
            return .run { _ in
                await openURLHandler.open(url)
            }
        case .destination(.presented(.alert(.searchKK))):
            state.destination = .extAuth(CardWallExtAuthSelectionDomain.State(
                profileId: state.profileId,
                insuranceType: state.insuranceType
            ))
            return .none
        case .destination(.presented(.can(.delegate(.close)))),
             .destination(.presented(.extAuth(.delegate(.close)))):
            @Dependency(\.dismiss) var dismiss
            return .run { _ in await dismiss(animation: .default) }
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
