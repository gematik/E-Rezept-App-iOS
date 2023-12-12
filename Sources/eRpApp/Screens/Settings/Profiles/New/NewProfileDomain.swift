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

    struct State: Equatable {
        var name: String
        var color: ProfileColor
        var image: ProfilePicture?
        var userImageData: Data?
        @PresentationState var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case editProfilePicture(EditProfilePictureDomain.State)
            case alert(AlertState<Action.Alert>)
        }

        enum Action: Equatable {
            case editProfilePictureAction(action: EditProfilePictureDomain.Action)
            case alert(Alert)

            enum Alert: Equatable {}
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

    enum Action: Equatable {
        case setName(String)
        case save
        case closeButtonTapped
        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

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
        Reduce(core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .setName(name):
            state.name = name
            return .none
        case .save:
            let name = state.name.trimmed()
            guard name.lengthOfBytes(using: .utf8) > 0 else {
                state.destination = .alert(AlertStates.emptyName)
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
            return .publisher(
                profileDataStore.save(profiles: [profile])
                    .catchToPublisher()
                    .map { result in
                        switch result {
                        case .success:
                            return Action.response(.saveReceived(.success(profile.id)))
                        case let .failure(error):
                            return Action.response(.saveReceived(.failure(error)))
                        }
                    }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.saveReceived(.success(profileId))):
            userDataStore.set(selectedProfileId: profileId)
            return EffectTask.send(.delegate(.close))
        case let .response(.saveReceived(.failure(error))):
            state.destination = .alert(AlertStates.for(error))
            return .none
        case .closeButtonTapped:
            return EffectTask.send(.delegate(.close))

        case .setNavigation(tag: .editProfilePicture):
            state.destination = .editProfilePicture(.init(
                profileId: nil,
                color: state.color,
                picture: state.image,
                userImageData: state.userImageData,
                isFullScreenPresented: true
            ))
            return .none
        case let .destination(.presented(.editProfilePictureAction(action: .editColor(color)))):
            state.color = color ?? .grey
            return .none
        case let .destination(.presented(.editProfilePictureAction(action: .editPicture(picture)))):
            state.image = picture ?? ProfilePicture.none
            return .none
        case let .destination(.presented(.editProfilePictureAction(action: .setUserImageData(image)))):
            state.userImageData = image
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none

        case .setNavigation,
             .delegate,
             .destination:
            return .none
        }
    }
}

extension NewProfileDomain {
    enum AlertStates {
        typealias Action = NewProfileDomain.Destinations.Action.Alert

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
            color: .blue
        )

        static let store = Store(initialState: state) {
            NewProfileDomain()
        }
    }
}
