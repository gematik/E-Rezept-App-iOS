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

import Combine
import ComposableArchitecture
import eRpKit

@Reducer
struct RedeemSuccessDomain: Reducer {
    @ObservableState
    struct State: Equatable {
        var redeemOption: RedeemOption
    }

    enum Action: Equatable {
        case closeButtonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.reviewRequester) var reviewRequester

    func reduce(into _: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .closeButtonTapped:
            reviewRequester.requestReview()

            return Effect.send(.delegate(.close))
        case .delegate:
            return .none
        }
    }
}

extension RedeemSuccessDomain {
    enum Dummies {
        static let state = State(redeemOption: .delivery)
        static let store = StoreOf<RedeemSuccessDomain>(
            initialState: state
        ) {
            RedeemSuccessDomain()
        }

        static func store(with option: RedeemOption) -> StoreOf<RedeemSuccessDomain> {
            Store(initialState: State(redeemOption: option)) {
                EmptyReducer()
            }
        }
    }
}
