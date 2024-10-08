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
import eRpKit
import Foundation

@Reducer
struct NewProfileDomain {
    @ObservableState
    struct State: Equatable {
        var name: String
        var color: ProfileColor
        var image: ProfilePicture?
        var userImageData: Data?
        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case editProfilePicture(EditProfilePictureDomain)
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Destination.Alert>)

        enum Alert: Equatable {}
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case save
        case closeButtonTapped

        case destination(PresentationAction<Destination.Action>)
        case tappedEditProfilePicture
        case resetNavigation
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

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .save:
            let name = state.name.trimmed()
            guard name.lengthOfBytes(using: .utf8) > 0 else {
                state.destination = .alert(.info(AlertStates.emptyName))
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
            return Effect.send(.delegate(.close))
        case let .response(.saveReceived(.failure(error))):
            state.destination = .alert(.init(for: error))
            return .none
        case .closeButtonTapped:
            return Effect.send(.delegate(.close))

        case .tappedEditProfilePicture:
            state.destination = .editProfilePicture(.init(
                profileId: nil,
                color: state.color,
                picture: state.image ?? .none,
                userImageData: state.userImageData ?? Data(),
                isFullScreenPresented: true
            ))
            return .none
        case let .destination(.presented(.editProfilePicture(.editColor(color)))):
            state.color = color
            return .none
        case let .destination(.presented(.editProfilePicture(.editPicture(picture)))):
            state.image = picture
            return .none
        case let .destination(.presented(.editProfilePicture(.setUserImageData(image)))):
            state.userImageData = image
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none

        case .delegate,
             .destination,
             .binding:
            return .none
        }
    }
}

extension NewProfileDomain {
    enum AlertStates {
        typealias Action = NewProfileDomain.Destination.Alert

        static var emptyName = AlertState<Action>(
            title: { TextState(L10n.stgTxtNewProfileErrorMessageTitle) },
            actions: {
                ButtonState(role: .cancel, action: .send(.none)) {
                    TextState(L10n.alertBtnOk)
                }
            },
            message: { TextState(L10n.stgTxtNewProfileMissingNameError) }
        )
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
