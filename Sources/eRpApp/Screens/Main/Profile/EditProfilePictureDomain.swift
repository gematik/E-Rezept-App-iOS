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

import Combine
import ComposableArchitecture
import eRpKit
import PhotosUI
import SwiftUI

struct EditProfilePictureDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        .cancel(id: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case updateProfile
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case alert(ErpAlertState<EditProfilePictureDomain.Action>)
            case cameraPicker
            case photoPicker
        }

        enum Action: Equatable {}

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    struct State: Equatable {
        var profile: UserProfile
        var color: ProfileColor?
        var picture: ProfilePicture?
        var userImageData: Data?
        var destination: Destinations.State?
        var isNewProfile = false
    }

    enum Action: Equatable {
        case setProfileValues
        case editColor(ProfileColor?)
        case editPicture(ProfilePicture?)
        case delegate(DelegateAction)
        case setUserImageData(Data)
        case setNewUserValues(Profile)
        case updateProfileReceived(Result<Bool, UserProfileServiceError>)
        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)
        case nothing
    }

    enum DelegateAction: Equatable {
        case close
        case failure(UserProfileServiceError)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setProfileValues:
            state.color = state.profile.color
            state.picture = state.profile.image
            state.userImageData = state.profile.userImageData
            return .none
        case let .editColor(color):
            state.color = color
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if !state.isNewProfile {
                return updateProfile(with: state.profile.id) { profile in
                    profile.color = (color ?? .grey).erxColor
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case let .editPicture(picture):
            state.picture = picture
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if !state.isNewProfile {
                return updateProfile(with: state.profile.id) { profile in
                    profile.image = (picture ?? .none).erxPicture
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case .updateProfileReceived(.success):
            return .none
        case let .updateProfileReceived(.failure(error)):
            state.color = state.profile.color
            state.picture = state.profile.image
            state.userImageData = state.profile.userImageData
            return .init(value: .delegate(.failure(error)))
        case let .setUserImageData(image):
            state.userImageData = image
            // Check if isNewProfile, because "updateProfile" fails without profileID and then is reversing the change
            if !state.isNewProfile {
                return updateProfile(with: state.profile.id) { profile in
                    profile.userImageData = image
                }
                .map(Action.updateProfileReceived)
            }
            return .none
        case .setNavigation(tag: .cameraPicker):
            state.destination = .cameraPicker
            return .none
        case .setNavigation(tag: .photoPicker):
            state.destination = .photoPicker
            return .none
        case .setNavigation(tag: .alert):
            state.destination = .alert(Self.importAlert)
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .delegate,
             .nothing,
             .setNewUserValues,
             .setNavigation,
             .destination:
            return .none
        }
    }

    static var importAlert: ErpAlertState<Action> = {
        .init(
            title: L10n.eppTxtAlertHeaderProfile,
            actions: {
                ButtonState(action: .setNavigation(tag: .photoPicker)) {
                    .init(L10n.eppBtnAlertLibrary)
                }
                ButtonState(action: .setNavigation(tag: .cameraPicker)) {
                    .init(L10n.eppBtnAlertCamera)
                }
                ButtonState(action: .setNavigation(tag: .none)) {
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
        userProfileService
            .update(profileId: profileId, mutating: mutating)
            .receive(on: schedulers.main)
            .first()
            .catchToEffect()
    }
}

extension EditProfilePictureDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state,
            reducer: EditProfilePictureDomain()
        )

        static let state = State(profile: UserProfile.Dummies.profileA, color: .red)

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: EditProfilePictureDomain()
            )
        }
    }
}
