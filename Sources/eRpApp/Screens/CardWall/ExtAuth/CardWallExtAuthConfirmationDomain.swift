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
import IDP
import UIKit

@Reducer
struct CardWallExtAuthConfirmationDomain {
    @ObservableState
    struct State: Equatable {
        let selectedKK: KKAppDirectory.Entry

        var loading = false

        var error: Error?

        @Presents var contactActionSheet: ConfirmationDialogState<Action.ContactSheet>?
    }

    // sourcery: CodedError = "012"
    enum Error: Swift.Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case idpError(IDPError)
        // sourcery: errorCode = "02"
        case universalLinkFailed

        var errorDescription: String? {
            switch self {
            case let .idpError(error):
                return error.localizedDescription
            case .universalLinkFailed:
                return L10n.cdwTxtExtauthConfirmUniversalLinkFailedError.text
            }
        }
    }

    enum Action: Equatable {
        case confirmKK
        case error(Error)
        case openURL(URL)
        case openContactSheet

        case contactSheet(PresentationAction<ContactSheet>)
        case response(Response)
        case delegate(Delegate)

        enum ContactSheet: Equatable {
            case contactByTelephone
            case contactByMail
        }

        enum Response: Equatable {
            case openURL(Bool)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.idpSession) var idpSession: IDPSession
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler

    struct Environment {
        let idpSession: IDPSession
        let schedulers: Schedulers

        let resourceHandler: ResourceHandler
    }

    private var environment: Environment {
        .init(idpSession: idpSession, schedulers: schedulers, resourceHandler: resourceHandler)
    }

    var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .confirmKK:
            state.loading = true
            // [REQ:gemSpec_IDP_Frontend:A_22294-01] Start login via gID
            // [REQ:BSI-eRp-ePA:O.Auth_4#9,O.Plat_10#2] Start login via gID
            return .publisher(
                environment.idpSession.startExtAuth(entry: state.selectedKK)
                    .first()
                    .map(Action.openURL)
                    .catch { error in
                        Just(Action.error(Error.idpError(error)))
                    }
                    .receive(on: environment.schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .openURL(url):
            return Effect.run { send in
                let action = await withCheckedContinuation { continuation in
                    // [REQ:gemSpec_IDP_Frontend:A_22299-01] Follow redirect
                    // [REQ:BSI-eRp-ePA:O.Plat_10#3] Follow redirect
                    guard environment.resourceHandler.canOpenURL(url) else {
                        continuation.resume(returning: Action.response(.openURL(false)))
                        return
                    }

                    // [REQ:gemSpec_IDP_Frontend:A_22313-01] Universal link options
                    environment.resourceHandler.open(url, options: [.universalLinksOnly: false]) { result in
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
            environment.resourceHandler.open(url, options: [:]) { _ in }
            return .none
        case .contactSheet(.presented(.contactByMail)):
            guard let url = URL(string: "mailto:app-feedback@gematik.de") else { return .none }
            environment.resourceHandler.open(url, options: [:]) { _ in }
            return .none
        case .delegate,
             .contactSheet:
            return .none // Handled by parent domain
        }
    }
}

extension CardWallExtAuthConfirmationDomain {
    enum Dummies {
        static let state = State(selectedKK: .init(name: "Dummy KK", identifier: "identifier"),
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
