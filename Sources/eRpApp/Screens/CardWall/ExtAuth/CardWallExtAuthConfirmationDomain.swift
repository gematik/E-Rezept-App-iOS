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

import ComposableArchitecture
import IDP
import UIKit

struct CardWallExtAuthConfirmationDomain: ReducerProtocol {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        let selectedKK: KKAppDirectory.Entry

        var loading = false

        var error: Error?

        var contactActionSheet: ConfirmationDialogState<Action>?
    }

    // sourcery: CodedError = "012"
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case idpError(IDPError)
        // sourcery: errorCode = "02"
        case universalLinkFailed
    }

    enum Action: Equatable {
        case confirmKK
        case error(Error)
        case openURL(URL)
        case openContactSheet
        case closeContactSheet

        case contactByTelephone
        case contactByMail

        case response(Response)
        case delegate(Delegate)

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

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .confirmKK:
            state.loading = true
            // [REQ:gemSpec_IDP_Sek:A_22294] Start login with KK
            return environment.idpSession.startExtAuth(entry: state.selectedKK)
                .first()
                .map(Action.openURL)
                .catch { error in
                    EffectTask(value: Action.error(Error.idpError(error)))
                }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .openURL(url):
            return .future { completion in

                // [REQ:gemSpec_IDP_Sek:A_22299] Follow redirect
                guard environment.resourceHandler.canOpenURL(url) else {
                    completion(.success(Action.response(.openURL(false))))
                    return
                }

                // [REQ:gemSpec_IDP_Sek:A_22313] Remember State parameter for later verification
                environment.resourceHandler.open(url, options: [:]) { result in
                    completion(.success(Action.response(.openURL(result))))
                }
            }
            .receive(on: environment.schedulers.main)
            .eraseToEffect()
        case let .response(.openURL(successful)):
            state.loading = false
            if successful {
                return EffectTask(value: .delegate(.close))
            } else {
                state.error = Error.universalLinkFailed
            }
            return .none
        case let .error(error):
            state.loading = false
            state.error = error
            return .none
        case .openContactSheet:
            state.contactActionSheet = ConfirmationDialogState(
                title: TextState(L10n.cdwTxtExtauthConfirmContactsheetTitle),
                buttons: [
                    .default(
                        TextState(L10n.cdwTxtExtauthConfirmContactsheetTelephone),
                        action: .send(.contactByTelephone)
                    ),
                    .default(TextState(L10n.cdwTxtExtauthConfirmContactsheetMail), action: .send(.contactByMail)),
                    .cancel(TextState(L10n.alertBtnClose), action: .send(.closeContactSheet)),
                ]
            )
            return .none
        case .closeContactSheet:
            state.contactActionSheet = nil
            return .none
        case .contactByTelephone:
            guard let url = URL(string: "tel:+498002773777") else { return .none }
            environment.resourceHandler.open(url, options: [:]) { _ in }
            return .none
        case .contactByMail:
            guard let url = URL(string: "mailto:app-feedback@gematik.de") else { return .none }
            environment.resourceHandler.open(url, options: [:]) { _ in }
            return .none
        case .delegate:
            return .none // Handled by parent domain
        }
    }
}

extension CardWallExtAuthConfirmationDomain.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .idpError(error):
            return error.localizedDescription
        case .universalLinkFailed:
            return L10n.cdwTxtExtauthConfirmUniversalLinkFailedError.text
        }
    }
}

extension CardWallExtAuthConfirmationDomain {
    enum Dummies {
        static let state = State(selectedKK: .init(name: "Dummy KK", identifier: "identifier"),
                                 error: nil)

        static let store = Store(initialState: state,
                                 reducer: CardWallExtAuthConfirmationDomain())

        static func store(for state: State) -> Store {
            Store(initialState: state, reducer: CardWallExtAuthConfirmationDomain())
        }
    }
}
