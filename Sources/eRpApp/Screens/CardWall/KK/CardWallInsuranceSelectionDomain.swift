//
//  Copyright (c) 2021 gematik GmbH
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

enum CardWallInsuranceSelectionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var kkList: KKAppDirectory?
        var errorMessage: String?
        var selectedKK: KKAppDirectory.Entry?
    }

    enum Action: Equatable {
        case loadKKList
        case loadKKListReceived(Result<KKAppDirectory, IDPError>)
        case selectKK(KKAppDirectory.Entry)
        case confirmKK
        case error(String)
        case openURL(URL)
        case openURLReceived(Bool)
        case close
    }

    struct Environment {
        let idpSession: IDPSession
        let schedulers: Schedulers
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadKKList:
            state.selectedKK = nil
            // [REQ:gemSpec_IDP_Sek:A_22296] Load available apps
            return environment.idpSession.loadDirectoryKKApps()
                .catchToEffect()
                .map(Action.loadKKListReceived)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .loadKKListReceived(.success(result)):
            state.errorMessage = nil
            state.kkList = result
            return .none
        case let .loadKKListReceived(.failure(error)):
            state.errorMessage = error.localizedDescription
            return .none
        case let .selectKK(entry):
            // [REQ:gemSpec_IDP_Sek:A_22294] Select KK
            state.selectedKK = entry
            return .none
        case .confirmKK:
            guard let selectedKK = state.selectedKK else { return .none }
            // [REQ:gemSpec_IDP_Sek:A_22294] Start login with KK
            return environment.idpSession.startExtAuth(entry: selectedKK)
                .map(Action.openURL)
                .catch { error in
                    Effect(value: Action.error(error.localizedDescription))
                }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .openURL(url):
            return Effect.future { completion in
                // [REQ:gemSpec_IDP_Sek:A_22299] Follow redirect
                guard UIApplication.shared.canOpenURL(url) else {
                    completion(.success(Action.openURLReceived(false)))
                    return
                }

                // [REQ:gemSpec_IDP_Sek:A_22313] Remember State parameter for later verification
                // May Be To Do: .universalLinksOnly: true aus der AFO abwarten
                UIApplication.shared.open(url, options: [:]) { result in
                    completion(.success(Action.openURLReceived(result)))
                }
            }
        case let .openURLReceived(successfull):
            if successfull {
                return Effect(value: .close)
            }
            return .none
        case let .error(error):
            state.errorMessage = error
            return .none
        case .close:
            return .none // Handled by parent domain
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension KKAppDirectory.Entry: Identifiable {
    public var id: String { // swiftlint:disable:this identifier_name
        identifier
    }
}

extension CardWallInsuranceSelectionDomain {
    enum Dummies {
        static let state = State()
        static let environment = Environment(idpSession: DemoIDPSession(storage: MemoryStorage()),
                                             schedulers: Schedulers())

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
