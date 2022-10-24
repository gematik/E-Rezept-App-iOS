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
import eRpKit
import Foundation

enum NewProfileDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var name: String
        var acronym: String
        var emoji: String?
        var color: ProfileColor

        var alertState: AlertState<Action>?
    }

    enum Action: Equatable {
        case setName(String)
        case setEmoji(String?)
        case setColor(ProfileColor)
        case save
        case close
        case saveReceived(Result<UUID, LocalStoreError>)
        case dismissAlert
    }

    struct Environment {
        let schedulers: Schedulers
        let userDataStore: UserDataStore
        let profileDataStore: ProfileDataStore
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .setName(name):
            state.acronym = name.acronym()
            state.name = name
            return .none
        case let .setEmoji(emoji):
            state.emoji = emoji
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
                                  emoji: state.emoji,
                                  lastAuthenticated: nil,
                                  erxTasks: [])
            return environment.profileDataStore.save(profiles: [profile])
                .catchToEffect()
                .map { result in
                    switch result {
                    case let .success(profileId):
                        return Action.saveReceived(.success(profile.id))
                    case let .failure(error):
                        return Action.saveReceived(.failure(error))
                    }
                }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .saveReceived(.success(profileId)):
            environment.userDataStore.set(selectedProfileId: profileId)
            return Effect(value: .close)
        case let .saveReceived(.failure(error)):
            state.alertState = AlertStates.for(error)
            return .none
        case .dismissAlert:
            state.alertState = nil
            return .none
        case .close:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
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
            emoji: "🧠",
            color: .blue
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            userDataStore: DemoUserDefaultsStore(),
            profileDataStore: DemoProfileDataStore()
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
