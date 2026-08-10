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
import IDP
import UIKit

/// Domain for handling external authentication provider selection
@Reducer
public struct CardWallExtAuthSelectionDomain {
    /// Initializes a new CardWallExtAuthSelectionDomain
    public init() {}

    /// State for the external authentication selection screen
    @ObservableState
    public struct State: Equatable {
        init(
            profileId: UUID,
            insuranceType: Profile.InsuranceType = .unknown,
            kkList: KKAppDirectory? = nil,
            filteredKKList: KKAppDirectory = .init(apps: [KKAppDirectory.Entry]()),
            error: IDPError? = nil,
            searchText: String = "",
            selectLoading: Bool = false,
            destination: CardWallExtAuthSelectionDomain.Destination.State? = nil
        ) {
            self.profileId = profileId
            self.insuranceType = insuranceType
            self.kkList = kkList
            self.filteredKKList = filteredKKList
            self.error = error
            self.searchText = searchText
            self.selectLoading = selectLoading
            self.destination = destination
        }

        public init(profileId: UUID) {
            self.profileId = profileId
        }

        let profileId: UUID
        var insuranceType: Profile.InsuranceType = .unknown
        var kkList: KKAppDirectory?
        var filteredKKList: KKAppDirectory = .init(apps: [KKAppDirectory.Entry]())
        var error: IDPError?
        var searchText: String = ""

        var selectLoading = false

        @Presents public var destination: Destination.State?
    }

    @CodedError("012")
    public enum Error: Swift.Error, Equatable, LocalizedError {
        @ErrorCode("01")
        case idpError(IDPError)
        @ErrorCode("02")
        case universalLinkFailed

        public var errorDescription: String? {
            switch self {
            case let .idpError(error):
                return error.localizedDescription
            case .universalLinkFailed:
                return L10n.cdwTxtExtauthConfirmUniversalLinkFailedError.text
            }
        }
    }

    /// Destination states for navigation from selection screen
    @Reducer
    public enum Destination {
        // sourcery: AnalyticsScreen = cardWall_extAuthSelectionHelp
        /// Navigate to help screen
        case help(CardWallExtAuthHelpDomain)
        // sourcery: AnalyticsScreen = alert
        /// Show alert dialog
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        /// Show contact sheet
        @ReducerCaseEphemeral
        case contactSheet(ConfirmationDialogState<ContactSheet>)

        public enum Alert: Equatable {
            case dismiss
            case openContactSheet
        }

        public enum ContactSheet: Equatable {
            case contactByTelephone
            case contactByMail
        }
    }

    /// Actions that can be performed in the selection domain
    public enum Action: Equatable {
        case loadKKList
        case selectKK(KKAppDirectory.Entry)
        case error(IDPError)
        case updateSearchText(newString: String)

        case filteredKKList(search: String)
        case reset

        case selectError(Error)
        case openURL(URL)

        case resetNavigation
        case helpButtonTapped
        case destination(PresentationAction<Destination.Action>)

        case response(Response)
        case delegate(Delegate)

        public enum Response: Equatable {
            case loadKKList(Result<KKAppDirectory, IDPError>)
            case openURL(Bool)
        }

        public enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.profileBasedSessionProvider) var profileBasedSessionProvider
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.openURLHandler) var openURLHandler

    /// The reducer body that handles state transitions and effects
    public var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadKKList:
            state.error = nil
            guard let idpSession = try? profileBasedSessionProvider.idpSession(state.profileId) else { return .none }
            // [REQ:gemSpec_IDP_Frontend:A_22296-01] Load available apps
            // [REQ:gemSpec_IDP_Frontend:A_23082#2] Load available apps
            return .publisher(
                idpSession
                    .loadDirectoryKKApps()
                    .first()
                    .map(Result.success)
                    .catch { Just(Result.failure($0)) }
                    .map { Action.response(.loadKKList($0)) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.loadKKList(.success(result))):
            state.error = nil
            var kkListFilteredForInsuranceType = result.apps.filter { $0.pkv == (state.insuranceType == .pKV) }
            if state.insuranceType == .federalKV {
                kkListFilteredForInsuranceType = kkListFilteredForInsuranceType.filter {
                    $0.name.localizedCaseInsensitiveContains(Profile.InsuranceType.federalKVAlias)
                }
            }
            state.kkList = KKAppDirectory(apps: kkListFilteredForInsuranceType)
            return .none
        case let .response(.loadKKList(.failure(error))):
            state.error = error
            return .none
        case let .selectKK(entry):
            // [REQ:BSI-eRp-ePA:O.Auth_4#6] Business logic of user selecting the insurance company
            // [REQ:gemSpec_IDP_Frontend:A_22294-01] Select KK
            // [REQ:BSI-eRp-ePA:O.Auth_4#7,O.Auth_4#8] Directly start login via gID
            state.selectLoading = true

            guard let idpSession = try? profileBasedSessionProvider.idpSession(state.profileId) else { return .none }
            // [REQ:gemSpec_IDP_Frontend:A_22294-01] Start login via gID
            // [REQ:BSI-eRp-ePA:O.Auth_4#9,O.Plat_10#2] Start login via gID
            return .publisher(
                idpSession
                    .startExtAuth(entry: entry)
                    .first()
                    .map(Action.openURL)
                    .catch { error in
                        Just(Action.selectError(Error.idpError(error)))
                    }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .openURL(url):
            return Effect.run { send in
                // [REQ:gemSpec_IDP_Frontend:A_22299-01] Follow redirect
                // [REQ:BSI-eRp-ePA:O.Plat_10#3] Follow redirect
                guard await openURLHandler.canOpenURL(url) else {
                    return await send(.response(.openURL(false)))
                }

                // [REQ:gemSpec_IDP_Frontend:A_22313-01] Universal link options
                await openURLHandler.openWithOptions(url, [.universalLinksOnly: false])
                await send(.response(.openURL(true)))
            }
        case let .response(.openURL(successful)):
            state.selectLoading = false
            if successful {
                return Effect.send(.delegate(.close))
            } else {
                state.destination = .alert(AlertStates.alert(for: .universalLinkFailed))
            }
            return .none
        case let .selectError(error):
            state.selectLoading = false
            state.destination = .alert(AlertStates.alert(for: error))
            return .none
        case .destination(.presented(.alert(.openContactSheet))):
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
                        TextState(L10n.alertBtnClose)
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
        case let .filteredKKList(search):
            if let kkList = state.kkList {
                state
                    .filteredKKList = KKAppDirectory(apps: kkList.apps
                        .filter { $0.name.lowercased().contains(search.lowercased()) })
            }
            return .none
        case .reset:
            state.filteredKKList = state.kkList ?? .init(apps: [KKAppDirectory.Entry]())
            return .none
        case let .updateSearchText(newString):
            state.searchText = newString.trimmingCharacters(in: .whitespacesAndNewlines)
            return state.searchText
                .isEmpty ? Effect.send(.reset) : Effect.send(.filteredKKList(search: state.searchText))
        case .resetNavigation:
            state.destination = nil
            return .none
        case let .error(error):
            state.error = error
            return .none
        case .helpButtonTapped:
            state.destination = .help(.init(insuranceType: state.insuranceType))
            return .none
        case .destination,
             .delegate:
            return .none // Handled by parent domain
        }
    }
}

extension CardWallExtAuthSelectionDomain {
    enum Dummies {
        static let state = State(profileId: UUID())

        static let store = Store(initialState: state) {
            CardWallExtAuthSelectionDomain()
        }
    }
}

extension CardWallExtAuthSelectionDomain {
    enum AlertStates {
        typealias Action = CardWallExtAuthSelectionDomain.Destination.Alert

        static func alertFor(_ error: IDPError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: nil
            ) {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.alertBtnOk)
                }
            }
        }

        static var universalLinkError: ErpAlertState<Action> = .info(
            AlertState(
                title: { TextState(L10n.cdwTxtExtauthConfirmUniversalLinkFailedError) },
                actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnClose)
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
                return alertFor(error)
            case .universalLinkFailed:
                return universalLinkError
            }
        }
    }
}

extension CardWallExtAuthSelectionDomain.Destination.State: Equatable {}
extension CardWallExtAuthSelectionDomain.Destination.Action: Equatable {}
