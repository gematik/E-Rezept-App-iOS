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

import Combine
import ComposableArchitecture
import eRpKit
import PhotosUI
import SwiftUI

struct EditProfilePictureDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case alert(ErpAlertState<Action.Alert>)
            case cameraPicker
            case photoPicker
        }

        enum Action: Equatable {
            case alert(Alert)

            enum Alert: Equatable {
                case photoPicker
                case cameraPicker
                case none
            }
        }

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    struct State: Equatable {
        let profileId: UUID?
        var color: ProfileColor?
        var picture: ProfilePicture?
        var userImageData: Data?
        var isFullScreenPresented = false

        @PresentationState var destination: Destinations.State?
    }

    enum Action: Equatable {
        case editColor(ProfileColor?)
        case editPicture(ProfilePicture?)
        case delegate(DelegateAction)
        case setUserImageData(Data)
        case resetPictureButtonTapped
        case updateProfileReceived(Result<Bool, UserProfileServiceError>)
        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)
        case nothing
    }

    enum DelegateAction: Equatable {
        case close
        case failure(UserProfileServiceError)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .editColor(color):
            state.color = color
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if let profileId = state.profileId {
                return updateProfile(with: profileId) { profile in
                    profile.color = (color ?? .grey).erxColor
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case let .editPicture(picture):
            state.picture = picture
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if let profileId = state.profileId {
                return updateProfile(with: profileId) { profile in
                    profile.image = (picture ?? .none).erxPicture
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case .updateProfileReceived(.success):
            return .none
        case let .updateProfileReceived(.failure(error)):
            return .send(.delegate(.failure(error)))
        case let .setUserImageData(image):
            state.userImageData = image
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if let profileId = state.profileId {
                return updateProfile(with: profileId) { profile in
                    profile.userImageData = image
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case .resetPictureButtonTapped:
            state.picture = nil
            state.userImageData = .empty
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if let profileId = state.profileId {
                return updateProfile(with: profileId) { profile in
                    profile.image = ProfilePicture.none.erxPicture
                    profile.userImageData = .empty
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case .destination(.presented(.alert(.cameraPicker))):
            state.destination = .cameraPicker
            return .none
        case .destination(.presented(.alert(.photoPicker))):
            state.destination = .photoPicker
            return .none
        case .destination(.presented(.alert(.none))):
            state.destination = nil
            return .none
        case .setNavigation(tag: .alert):
            state.destination = .alert(Self.importAlert)
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .delegate,
             .nothing,
             .setNavigation,
             .destination:
            return .none
        }
    }

    static var importAlert: ErpAlertState<EditProfilePictureDomain.Destinations.Action.Alert> = {
        .init(
            title: L10n.eppTxtAlertHeaderProfile,
            actions: {
                ButtonState(action: .photoPicker) {
                    .init(L10n.eppBtnAlertLibrary)
                }
                ButtonState(action: .cameraPicker) {
                    .init(L10n.eppBtnAlertCamera)
                }
                ButtonState(role: .cancel, action: .none) {
                    .init(L10n.eppBtnAlertAbort)
                }
            },
            message: L10n.eppTxtAlertSubheaderChoose
        )
    }()
}

extension EditProfilePictureDomain {
    func updateProfile(
        with profileId: UUID,
        mutating: @escaping (inout eRpKit.Profile) -> Void
    ) -> EffectTask<Result<Bool, UserProfileServiceError>> {
        .publisher(
            userProfileService
                .update(profileId: profileId, mutating: mutating)
                .receive(on: schedulers.main)
                .first()
                .catchToPublisher()
                .eraseToAnyPublisher
        )
    }
}

extension EditProfilePictureDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state
        ) {
            EditProfilePictureDomain()
        }

        static let state = State(profileId: UserProfile.Dummies.profileA.id, color: .red)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state) {
                EditProfilePictureDomain()
            }
        }
    }
}
