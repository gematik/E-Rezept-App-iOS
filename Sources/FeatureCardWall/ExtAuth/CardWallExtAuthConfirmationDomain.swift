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
import eRpResources
import FeatureHelpers
import IDP
import UIKit

/// Domain for handling external authentication confirmation
@Reducer
public struct CardWallExtAuthConfirmationDomain {
    /// Initializes a new CardWallExtAuthConfirmationDomain
    public init() {}

    /// State for the external authentication confirmation screen
    @ObservableState
    public struct State: Equatable {
        let profileId: UUID
        let selectedKK: KKAppDirectory.Entry

        var loading = false

        var error: Error?

        @Presents var contactActionSheet: ConfirmationDialogState<Action.ContactSheet>?
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

    /// Actions that can be performed in the confirmation domain
    public enum Action: Equatable {
        case confirmKK
        case error(Error)
        case openURL(URL)
        case openContactSheet

        case contactSheet(PresentationAction<ContactSheet>)
        case response(Response)
        case delegate(Delegate)

        public enum ContactSheet: Equatable {
            case contactByTelephone
            case contactByMail
        }

        public enum Response: Equatable {
            case openURL(Bool)
        }

        public enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.openURLHandler) var openURLHandler
    @Dependency(\.profileBasedSessionProvider) var profileBasedSessionProvider

    /// The reducer body that handles state transitions and effects
    public var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .confirmKK:
            state.loading = true

            guard let idpSession = try? profileBasedSessionProvider.idpSession(state.profileId) else { return .none }
            // [REQ:gemSpec_IDP_Frontend:A_22294-01] Start login via gID
            // [REQ:BSI-eRp-ePA:O.Auth_4#9,O.Plat_10#2] Start login via gID
            return .publisher(
                idpSession
                    .startExtAuth(entry: state.selectedKK)
                    .first()
                    .map(Action.openURL)
                    .catch { error in
                        Just(Action.error(Error.idpError(error)))
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
            state.loading = false
            if successful {
                return Effect.send(.delegate(.close))
            } else {
                state.error = Error.universalLinkFailed
            }
            return .none
        case let .error(error):
            state.loading = false
            state.error = error
            return .none
        case .openContactSheet:
            state.contactActionSheet = ConfirmationDialogState<Action.ContactSheet>(
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
            )
            return .none
        case .contactSheet(.presented(.contactByTelephone)):
            guard let url = URL(string: "tel:+498002773777") else { return .none }
            return .run { _ in
                await openURLHandler.open(url)
            }
        case .contactSheet(.presented(.contactByMail)):
            guard let url = URL(string: "mailto:app-feedback@gematik.de") else { return .none }
            return .run { _ in
                await openURLHandler.open(url)
            }
        case .delegate,
             .contactSheet:
            return .none // Handled by parent domain
        }
    }
}

extension CardWallExtAuthConfirmationDomain {
    enum Dummies {
        static let state = State(profileId: UUID(),
                                 selectedKK: .init(name: "Dummy KK", identifier: "identifier"),
                                 error: nil)

        static let store = Store(initialState: state) {
            CardWallExtAuthConfirmationDomain()
        }

        static func store(for state: State) -> StoreOf<CardWallExtAuthConfirmationDomain> {
            Store(initialState: state) {
                CardWallExtAuthConfirmationDomain()
            }
        }
    }
}
