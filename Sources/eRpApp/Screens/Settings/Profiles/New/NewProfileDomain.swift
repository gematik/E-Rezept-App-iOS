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
import eRpKit
import Foundation

struct NewProfileDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var name: String
        var acronym: String
        var color: ProfileColor

        var alertState: AlertState<Action>?
    }

    enum Action: Equatable {
        case setName(String)
        case setColor(ProfileColor)
        case save
        case closeButtonTapped
        case dismissAlert

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case saveReceived(Result<UUID, LocalStoreError>)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .setName(name):
            state.acronym = name.acronym()
            state.name = name
            return .none
        case let .setColor(color):
            state.color = color
            return .none
        case .save:
            let name = state.name.trimmed()
            guard name.lengthOfBytes(using: .utf8) > 0 else {
                state.alertState = AlertStates.emptyName
                return .none
            }
            let profile = Profile(name: name,
                                  identifier: UUID(),
                                  insuranceId: nil,
                                  color: state.color.erxColor,
                                  lastAuthenticated: nil,
                                  erxTasks: [])
            return profileDataStore.save(profiles: [profile])
                .catchToEffect()
                .map { result in
                    switch result {
                    case .success:
                        return Action.response(.saveReceived(.success(profile.id)))
                    case let .failure(error):
                        return Action.response(.saveReceived(.failure(error)))
                    }
                }
                .receive(on: schedulers.main)
                .eraseToEffect()
        case let .response(.saveReceived(.success(profileId))):
            userDataStore.set(selectedProfileId: profileId)
            return Effect(value: .delegate(.close))
        case let .response(.saveReceived(.failure(error))):
            state.alertState = AlertStates.for(error)
            return .none
        case .dismissAlert:
            state.alertState = nil
            return .none
        case .closeButtonTapped:
            return Effect(value: .delegate(.close))

        case .delegate:
            return .none
        }
    }
}

extension NewProfileDomain {
    enum AlertStates {
        typealias Action = NewProfileDomain.Action

        static var emptyName = AlertState<Action>(
            title: TextState(L10n.stgTxtNewProfileErrorMessageTitle),
            message: TextState(L10n.stgTxtNewProfileMissingNameError),
            dismissButton: .default(TextState(L10n.alertBtnOk))
        )

        static func `for`(_ error: LocalStoreError) -> AlertState<Action> {
            AlertState(
                title: TextState(L10n.stgTxtNewProfileErrorMessageTitle),
                message: TextState(error.localizedDescriptionWithErrorList),
                dismissButton: .default(TextState(L10n.alertBtnOk))
            )
        }
    }
}

extension NewProfileDomain {
    enum Dummies {
        static let state = State(
            name: "Anna Vetter",
            acronym: "AV",
            color: .blue
        )

        static let store = Store(
            initialState: state,
            reducer: NewProfileDomain()
        )
    }
}
