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

import ComposableArchitecture
import IDP
import UIKit

enum CardWallExtAuthConfirmationDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
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
        case openURLReceived(Bool)
        case close
        case openContactSheet
        case closeContactSheet

        case contactByTelephone
        case contactByMail
    }

    struct Environment {
        let idpSession: IDPSession
        let schedulers: Schedulers

        let canOpenURL: (URL) -> Bool
        let openURL: (URL, [UIApplication.OpenExternalURLOptionsKey: Any], ((Bool) -> Void)?) -> Void
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .confirmKK:
            state.loading = true
            // [REQ:gemSpec_IDP_Sek:A_22294] Start login with KK
            return environment.idpSession.startExtAuth(entry: state.selectedKK)
                .map(Action.openURL)
                .catch { error in
                    Effect(value: Action.error(Error.idpError(error)))
                }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .openURL(url):
            return Effect.future { completion in

                // [REQ:gemSpec_IDP_Sek:A_22299] Follow redirect
                guard environment.canOpenURL(url) else {
                    completion(.success(Action.openURLReceived(false)))
                    return
                }

                // [REQ:gemSpec_IDP_Sek:A_22313] Remember State parameter for later verification
                environment.openURL(url, [:]) { result in
                    completion(.success(Action.openURLReceived(result)))
                }
            }
            .receive(on: environment.schedulers.main)
            .eraseToEffect()
        case let .openURLReceived(successful):
            state.loading = false
            if successful {
                return Effect(value: .close)
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
            environment.openURL(url, [:]) { _ in }
            return .none
        case .contactByMail:
            guard let url = URL(string: "mailto:app-feedback@gematik.de") else { return .none }
            environment.openURL(url, [:]) { _ in }
            return .none
        case .close:
            return .none // Handled by parent domain
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
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

        static let environment = Environment(idpSession: DemoIDPSession(storage: MemoryStorage()),
                                             schedulers: Schedulers(),
                                             canOpenURL: UIApplication.shared.canOpenURL,
                                             openURL: UIApplication.shared.open(_:options:completionHandler:))

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)

        static func store(for state: State) -> Store {
            Store(initialState: state,
                  reducer: reducer,
                  environment: environment)
        }
    }
}
