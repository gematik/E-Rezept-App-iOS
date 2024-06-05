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

@Reducer
struct EditProfilePictureDomain {
    typealias Store = StoreOf<Self>

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        case cameraPicker
        case memojiPicker
        case photoPicker

        enum Alert: Equatable {
            case photoPicker
            case cameraPicker
            case memojiPicker
            case none
        }
    }

    @ObservableState
    struct State: Equatable {
        let profileId: UUID?
        var color: ProfileColor = .grey
        var picture: ProfilePicture = .none
        var userImageData: Data = .empty
        var isFullScreenPresented = false

        @Presents var destination: Destination.State?

        init(
            profileId: UUID? = nil,
            color: ProfileColor = .grey,
            picture: ProfilePicture = .none,
            userImageData: Data = .empty,
            isFullScreenPresented: Bool = false,
            destination: Destination.State? = nil
        ) {
            self.profileId = profileId
            self.color = color
            self.picture = picture
            self.userImageData = userImageData
            self.isFullScreenPresented = isFullScreenPresented
            self.destination = destination
        }
    }

    enum Action: Equatable {
        case editColor(ProfileColor)
        case editPicture(ProfilePicture)
        case delegate(DelegateAction)
        case setUserImageData(Data)
        case resetPictureButtonTapped
        case updateProfileReceived(Result<Bool, UserProfileServiceError>)
        case resetNavigation
        case showImportAlert
        case destination(PresentationAction<Destination.Action>)
        case nothing
    }

    enum DelegateAction: Equatable {
        case close
        case failure(UserProfileServiceError)
    }

    var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .editColor(color):
            state.color = color
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if let profileId = state.profileId {
                return updateProfile(with: profileId) { profile in
                    profile.color = color.erxColor
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case let .editPicture(picture):
            state.picture = picture
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if let profileId = state.profileId {
                return updateProfile(with: profileId) { profile in
                    profile.image = picture.erxPicture
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
            state.destination = nil
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if let profileId = state.profileId {
                return updateProfile(with: profileId) { profile in
                    profile.userImageData = image
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case .resetPictureButtonTapped:
            state.picture = .none
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
        case .destination(.presented(.alert(.memojiPicker))):
            state.destination = .memojiPicker
            return .none
        case .destination(.presented(.alert(.photoPicker))):
            state.destination = .photoPicker
            return .none
        case .destination(.presented(.alert(.none))):
            state.destination = nil
            return .none
        case .showImportAlert:
            state.destination = .alert(Self.importAlert)
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none
        case .delegate,
             .nothing,
             .destination:
            return .none
        }
    }

    static var importAlert: ErpAlertState<EditProfilePictureDomain.Destination.Alert> = {
        .init(
            title: L10n.eppTxtAlertHeaderProfile,
            actions: {
                ButtonState(action: .photoPicker) {
                    .init(L10n.eppBtnAlertLibrary)
                }
                ButtonState(action: .cameraPicker) {
                    .init(L10n.eppBtnAlertCamera)
                }
                ButtonState(action: .memojiPicker) {
                    .init(L10n.eppBtnAlertEmoji)
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
    ) -> Effect<Result<Bool, UserProfileServiceError>> {
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
