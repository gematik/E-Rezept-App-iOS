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
    @Perception.Bindable var store: StoreOf<EditProfilePictureDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Section(
                    header: SectionHeader(isFullScreenPresented: store.isFullScreenPresented)
                ) {
                    ZStack(alignment: .topTrailing) {
                        ProfilePictureView(
                            image: store.picture,
                            userImageData: store.userImageData,
                            color: store.color,
                            connection: nil,
                            style: .xxLarge,
                            isBorderOn: true
                        ) {}
                            .disabled(true)

                        if store.picture != .none || store.userImageData != Data() {
                            ResetPictureButton(
                                isFullScreenPresented: store.isFullScreenPresented
                            ) {
                                store.send(.resetPictureButtonTapped)
                            }
                            .accessibility(identifier: A11y.editProfilePicture.eppBtnResetPicture)
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        ProfilePictureSelector(store: store, isFullScreenPresented: store.isFullScreenPresented)
                            .padding([.top, .bottom])

                        Text(L10n.editColorTxt)
                            .font(.headline.bold())
                            .padding([.horizontal, .top])

                        ProfileColorPicker(
                            color: $store.color.sending(\.editColor)
                        )
                        .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileBgColorPicker)
                        .background(Colors.systemBackgroundTertiary)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        Text(store.color.name, bundle: .module)
                            .foregroundColor(Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                    }
                }

                if store.isFullScreenPresented {
                    Spacer()
                }

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .fullScreenCover(isPresented: Binding<Bool>(
                        get: { store.destination == .cameraPicker },
                        set: { show in
                            if !show {
                                store.send(.resetNavigation)
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        ZStack {
                            CameraPicker(picketImage: $store.userImageData.sending(\.setUserImageData))
                                .ignoresSafeArea()

                            CameraAuthorizationAlertView()
                        }
                    })
                    .hidden()
                    .accessibility(hidden: true)
            }
            .alert(
                $store.scope(state: \.destination?.alert?.alert, action: \.destination.alert)
            )
            .keyboardShortcut(.defaultAction)
            .onChange(of: store.color) { _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(store.isFullScreenPresented ? Colors.systemBackgroundSecondary.ignoresSafeArea() : Colors
                .systemBackgroundTertiary.ignoresSafeArea())
            .sheet(isPresented: Binding<Bool>(
                get: { store.destination == .memojiPicker },
                set: { show in
                    if !show {
                        store.send(.resetNavigation)
                    }
                }
            )) {
                MemojiPickerView { image in
                    guard let data = image?.pngData() else { return }
                    store.send(.setUserImageData(data))
                }
            }
            .sheet(isPresented: Binding<Bool>(
                get: { store.destination == .photoPicker },
                set: { show in
                    if !show {
                        store.send(.resetNavigation)
                    }
                }
            )) {
                PhotoPicker(picketImage: $store.userImageData.sending(\.setUserImageData))
            }
        }
    }
}

extension EditProfilePictureView {
    private struct SectionHeader: View {
        let isFullScreenPresented: Bool

        @Environment(\.dismiss) var dismiss

        var body: some View {
            if isFullScreenPresented {
                EmptyView()
            } else {
                ZStack {
                    CloseButton {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)

                    Text(L10n.editPictureTxt)
                        .padding([.leading, .trailing])
                        .padding(.top, 40)
                        .font(.headline.bold())
                }
            }
        }
    }

    private struct ProfilePictureSelector: View {
        @Perception.Bindable var store: EditProfilePictureDomain.Store
        let isFullScreenPresented: Bool

        var body: some View {
            WithPerceptionTracking {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Image(systemName: SFSymbolName.camera)
                            .frame(width: 80, height: 80)
                            .font(Font.headline.weight(.bold))
                            .foregroundColor(Colors.text)
                            .background(Circle().fill(isFullScreenPresented ? Colors.systemGray5 : Colors.systemGray6))
                            .accessibility(identifier: A11y.editProfilePicture.eppBtnChooseType)
                            .onTapGesture {
                                store.send(.showImportAlert)
                            }

                        ForEach(ProfilePicture.allCases, id: \.rawValue) { image in
                            WithPerceptionTracking {
                                if let displayImage = image.description, !displayImage.name.isEmpty {
                                    Button(action: {
                                        store.send(.editPicture(image))
                                        store.send(.setUserImageData(Data()))
                                    }, label: {
                                        Image(asset: displayImage)
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .background(Circle().foregroundColor(store.color.background))
                                            .border(store.color.border, width: 1, cornerRadius: 99)
                                            .clipShape(Circle())
                                            .accessibilityLabel(image.accessibility)
                                    })
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
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
