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
import eRpStyleKit
import PhotosUI
import SwiftUI

struct EditProfilePictureView: View {
    let store: EditProfilePictureDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, EditProfilePictureDomain.Action>

    init(store: EditProfilePictureDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let color: ProfileColor
        let picture: ProfilePicture
        let userImageData: Data
        let destinationTag: EditProfilePictureDomain.Destinations.State.Tag?
        let isFullScreenPresented: Bool

        init(state: EditProfilePictureDomain.State) {
            color = state.color ?? .grey
            picture = state.picture ?? .none
            destinationTag = state.destination?.tag
            userImageData = state.userImageData ?? .empty
            isFullScreenPresented = state.isFullScreenPresented
        }
    }

    var body: some View {
        VStack {
            Section(
                header: SectionHeader(isFullScreenPresented: viewStore.isFullScreenPresented)
            ) {
                ZStack(alignment: .topTrailing) {
                    ProfilePictureView(
                        image: viewStore.picture,
                        userImageData: viewStore.userImageData,
                        color: viewStore.color,
                        connection: nil,
                        style: .xxLarge,
                        isBorderOn: true
                    ) {}
                        .disabled(true)

                    if viewStore.picture != .none || viewStore.userImageData != .empty {
                        ResetPictureButton(
                            isFullScreenPresented: viewStore.isFullScreenPresented
                        ) {
                            viewStore.send(.resetPictureButtonTapped)
                        }
                        .accessibility(identifier: A11y.editProfilePicture.eppBtnResetPicture)
                    }
                }

                VStack(alignment: .leading) {
                    ProfilePictureSelector(store: store)
                        .padding([.top, .bottom])

                    Text(L10n.editColorTxt)
                        .font(.headline.bold())
                        .padding([.trailing, .top])

                    ProfileColorPicker(
                        color: viewStore.binding(
                            get: \.color,
                            send: EditProfilePictureDomain.Action.editColor
                        )
                    )
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileBgColorPicker)
                    .background(Colors.systemBackgroundTertiary)
                    .cornerRadius(16)

                    if !viewStore.isFullScreenPresented {
                        Text(viewStore.color.name)
                            .foregroundColor(Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }

            if viewStore.isFullScreenPresented {
                Spacer()
            }

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .cameraPicker },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    ZStack {
                        CameraPicker(picketImage: viewStore.binding(
                            get: \.userImageData,
                            send: EditProfilePictureDomain.Action.setUserImageData
                        )).ignoresSafeArea()

                        CameraAuthorizationAlertView()
                    }
                })
                .hidden()
                .accessibility(hidden: true)
        }
        .alert(
            store.scope(state: \.$destination, action: EditProfilePictureDomain.Action.destination),
            state: /EditProfilePictureDomain.Destinations.State.alert,
            action: EditProfilePictureDomain.Destinations.Action.alert
        )
        .keyboardShortcut(.defaultAction)
        .onChange(of: viewStore.color) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(viewStore.isFullScreenPresented ? Colors.systemBackgroundSecondary.ignoresSafeArea() : Colors
            .systemBackgroundTertiary.ignoresSafeArea())
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

extension EditProfilePictureView {
    private struct SectionHeader: View {
        let isFullScreenPresented: Bool

        var body: some View {
            if isFullScreenPresented {
                EmptyView()
            } else {
                Text(L10n.editPictureTxt)
                    .padding([.leading, .trailing, .top])
                    .font(.headline.bold())
            }
        }
    }

    private struct ProfilePictureSelector: View {
        let store: EditProfilePictureDomain.Store

        @ObservedObject var viewStore: ViewStore<ViewState, EditProfilePictureDomain.Action>

        init(store: EditProfilePictureDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let color: ProfileColor
            let destinationTag: EditProfilePictureDomain.Destinations.State.Tag?

            init(state: EditProfilePictureDomain.State) {
                color = state.color ?? .grey
                destinationTag = state.destination?.tag
            }
        }

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Image(systemName: SFSymbolName.camera)
                        .frame(width: 80, height: 80)
                        .font(Font.headline.weight(.bold))
                        .foregroundColor(Colors.systemColorBlack)
                        .background(Circle().fill(Colors.systemGray5))
                        .accessibility(identifier: A11y.editProfilePicture.eppBtnChooseType)
                        .onTapGesture {
                            viewStore.send(.setNavigation(tag: .alert))
                        }

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
        let isFullScreenPresented: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: SFSymbolName.trash)
                    .font(Font.caption.weight(.bold))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(8)
                    .background(
                        Circle().foregroundColor(isFullScreenPresented ? Colors.systemColorWhite : Colors.systemGray6)
                    )
            }
            .padding()
            .background(
                Circle()
                    .foregroundColor(isFullScreenPresented ? Colors.systemBackgroundSecondary : Colors
                        .systemBackground)
                    .padding(12)
            )
        }
    }
}

struct EditProfilePictureView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditProfilePictureView(store: EditProfilePictureDomain.Dummies.store)
                .previewDevice("iPhone 11")

            EditProfilePictureView(store: EditProfilePictureDomain.Dummies.store)
                .previewDevice("iPhone 13 Pro")

            EditProfilePictureView(store: EditProfilePictureDomain.Dummies.store)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
