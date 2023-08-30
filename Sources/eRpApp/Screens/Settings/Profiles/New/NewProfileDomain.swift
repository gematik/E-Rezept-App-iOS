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

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case editProfilePicture(EditProfilePictureDomain.State)
        }

        enum Action: Equatable {
            case editProfilePictureAction(action: EditProfilePictureDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.editProfilePicture,
                action: /Action.editProfilePictureAction
            ) {
                EditProfilePictureDomain()
            }
        }
    }

    struct State: Equatable {
        var name: String
        var acronym: String
        var color: ProfileColor
        var image: ProfilePicture?
        var userImageData: Data?
        var destination: Destinations.State?
        var alertState: AlertState<Action>?
    }

    enum Action: Equatable {
        case setName(String)
        case setColor(ProfileColor)
        case save
        case closeButtonTapped
        case dismissAlert
        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)
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

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
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
                                  image: state.image?.erxPicture ?? .none,
                                  userImageData: state.userImageData,
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
            return EffectTask(value: .delegate(.close))
        case let .response(.saveReceived(.failure(error))):
            state.alertState = AlertStates.for(error)
            return .none
        case .dismissAlert:
            state.alertState = nil
            return .none
        case .closeButtonTapped:
            return EffectTask(value: .delegate(.close))
        case .setNavigation(tag: .editProfilePicture):
            state.destination = .editProfilePicture(.init(profile: UserProfile(
                from: Profile(name: state.name,
                              color: state.color.erxColor,
                              image: (state.image ?? .none).erxPicture,
                              userImageData: state.userImageData),
                isAuthenticated: false
            ), isNewProfile: true))
            return .none
        case let .destination(.editProfilePictureAction(action: .setNewUserValues(userValues))):
            state.destination = nil
            state.color = userValues.color.viewModelColor
            state.userImageData = userValues.userImageData
            state.image = userValues.image.viewModelPicture
            return .none
        case .setNavigation:
            return .none
        case .destination(.editProfilePictureAction):
            return .none
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
