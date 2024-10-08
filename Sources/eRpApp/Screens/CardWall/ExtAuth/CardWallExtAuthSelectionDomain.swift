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

import ComposableArchitecture
import IDP
import UIKit

@Reducer
struct CardWallExtAuthSelectionDomain {
    @ObservableState
    struct State: Equatable {
        var kkList: KKAppDirectory?
        var filteredKKList: KKAppDirectory = .init(apps: [KKAppDirectory.Entry]())
        var error: IDPError?
        var selectedKK: KKAppDirectory.Entry?
        var searchText: String = ""

        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall_extAuthConfirm
        case confirmation(CardWallExtAuthConfirmationDomain)
        // sourcery: AnalyticsScreen = cardWall_extAuthSelectionHelp
        case help(CardWallExtAuthHelpDomain)
    }

    enum Action: Equatable {
        case loadKKList
        case selectKK(KKAppDirectory.Entry)
        case confirmKK
        case error(IDPError)
        case updateSearchText(newString: String)

        case filteredKKList(search: String)
        case reset

        case resetNavigation
        case helpButtonTapped
        case destination(PresentationAction<Destination.Action>)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case loadKKList(Result<KKAppDirectory, IDPError>)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.idpSession) var idpSession: IDPSession
    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadKKList:
            state.error = nil
            state.selectedKK = nil
            // [REQ:gemSpec_IDP_Frontend:A_22296-01] Load available apps
            // [REQ:gemSpec_IDP_Frontend:A_23082#2] Load available apps
            return .publisher(
                idpSession.loadDirectoryKKApps()
                    .first()
                    .catchToPublisher()
                    .map { Action.response(.loadKKList($0)) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.loadKKList(.success(result))):
            state.error = nil
            state.kkList = result
            return .none
        case let .response(.loadKKList(.failure(error))):
            state.error = error
            return .none
        case let .selectKK(entry):
            // [REQ:BSI-eRp-ePA:O.Auth_4#6] Business logic of user selecting the insurance company
            // [REQ:gemSpec_IDP_Frontend:A_22294-01] Select KK
            state.selectedKK = entry
            return .none
        // [REQ:BSI-eRp-ePA:O.Auth_4#7] Proceed to confirmation screen
        case .confirmKK:
            guard let selectedKK = state.selectedKK else { return .none }

            state.destination = .confirmation(.init(selectedKK: selectedKK))
            return .none
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
            state.searchText = newString.trimmed()
            return state.searchText
                .isEmpty ? Effect.send(.reset) : Effect.send(.filteredKKList(search: state.searchText))
        case .resetNavigation:
            state.destination = nil
            return .none
        case let .error(error):
            state.error = error
            return .none
        case .destination(.presented(.confirmation(action: .delegate(.close)))):
            return Effect.send(.delegate(.close))
        case .helpButtonTapped:
            state.destination = .help(.init())
            return .none
        case .destination,
             .delegate:
            return .none // Handled by parent domain
        }
    }
}

extension KKAppDirectory.Entry: Identifiable {
    public var id: String {
        identifier
    }
}

extension CardWallExtAuthSelectionDomain {
    enum Dummies {
        static let state = State()

        static let store = Store(initialState: state) {
            CardWallExtAuthSelectionDomain()
        }
    }
}
