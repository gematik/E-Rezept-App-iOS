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
import eRpStyleKit
import PhotosUI
import SwiftUI

struct EditProfilePictureFullView: View {
    let store: EditProfilePictureDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, EditProfilePictureDomain.Action>

    init(store: EditProfilePictureDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let profile: UserProfile
        let color: ProfileColor
        let picture: ProfilePicture
        let userImageData: Data
        let destinationTag: EditProfilePictureDomain.Destinations.State.Tag?

        init(state: EditProfilePictureDomain.State) {
            profile = state.profile
            color = state.color ?? .grey
            picture = state.picture ?? .none
            destinationTag = state.destination?.tag
            userImageData = state.userImageData ?? .empty
        }
    }

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                ProfilePictureView(
                    image: viewStore.picture,
                    userImageData: viewStore.userImageData,
                    color: viewStore.color,
                    connection: nil,
                    style: .xxLarge
                ) {}
                    .disabled(true)

                if viewStore.picture != .none || viewStore.userImageData != .empty {
                    ResetPictureButton {
                        viewStore.send(.editPicture(nil))
                        viewStore.send(.setUserImageData(.empty))
                    }.background(Circle().foregroundColor(Color(.secondarySystemBackground)).padding(12))
                }
            }

            VStack(alignment: .leading) {
                ProfilePictureSelector(store: store)
                    .padding([.top, .bottom])

                Text(L10n.editColorTxt)
                    .font(.headline.bold())
                    .padding([.trailing, .top])

                ProfileColorPicker(color: viewStore.binding(
                    get: \.color,
                    send: EditProfilePictureDomain.Action.editColor
                )).accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileBgColorPicker)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(16)
                    .padding([.horizontal, .bottom])
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .navigationTitle(L10n.editPictureTxt)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewStore.send(.setProfileValues)
        }
        .onChange(of: viewStore.color) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .sheet(isPresented: Binding<Bool>(
            get: { viewStore.state.destinationTag == .photoPicker },
            set: { show in
                if !show {
                    viewStore.send(.setNavigation(tag: nil))
                }
            }
        )) {
            PhotoPicker(picketImage: viewStore.binding(
                get: \.userImageData,
                send: EditProfilePictureDomain.Action.setUserImageData
            ))
        }
    }
}

extension EditProfilePictureFullView {
    private struct ProfilePictureSelector: View {
        let store: EditProfilePictureDomain.Store

        @ObservedObject var viewStore: ViewStore<ViewState, EditProfilePictureDomain.Action>

        init(store: EditProfilePictureDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let profile: UserProfile
            let color: ProfileColor

            init(state: EditProfilePictureDomain.State) {
                profile = state.profile
                color = state.color ?? .grey
            }
        }

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button(action: {
                        viewStore.send(.setNavigation(tag: .photoPicker))
                    }, label: {
                        Image(systemName: SFSymbolName.camera)
                            .frame(width: 80, height: 80)
                            .font(Font.headline.weight(.bold))
                            .foregroundColor(Color(.secondaryLabel))
                            .background(Circle().fill(Colors.secondary))
                            .border(Colors.systemGray4, width: 1, cornerRadius: 99)
                    })

                    ForEach(ProfilePicture.allCases, id: \.rawValue) { image in
                        if let displayImage = image.description, !displayImage.name.isEmpty {
                            Button(action: {
                                viewStore.send(.editPicture(image))
                                viewStore.send(.setUserImageData(.empty))
                            }, label: {
                                Image(displayImage)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .background(Circle().foregroundColor(viewStore.color.background))
                                    .border(viewStore.color.border, width: 1, cornerRadius: 99)
                                    .clipShape(Circle())
                                    .accessibilityLabel(image.accessibility)
                            })
                        }
                    }
                }
            }
        }
    }

    private struct ResetPictureButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: SFSymbolName.crossIconPlain)
                    .font(Font.caption.weight(.bold))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(8)
                    .background(Circle().foregroundColor(Colors.systemColorWhite))
            }
            .padding()
        }
    }
}
