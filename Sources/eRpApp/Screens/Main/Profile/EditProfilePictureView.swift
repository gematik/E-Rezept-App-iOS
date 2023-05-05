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
import SwiftUI

struct EditProfilePictureView: View {
    let store: EditProfilePictureDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, EditProfilePictureDomain.Action>

    init(store: EditProfilePictureDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let profile: UserProfile
        let color: ProfileColor
        let picture: ProfilePicture

        init(state: EditProfilePictureDomain.State) {
            profile = state.profile
            color = state.color ?? .grey
            picture = state.picture ?? .none
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Section(header:
                Text(L10n.editPictureTxt)
                    .padding([.leading, .trailing, .top])
                    .font(.system(size: 16, weight: .bold))) {
                    ZStack(alignment: .topTrailing) {
                        ProfilePictureView(
                            text: viewStore.profile.acronym,
                            image: viewStore.picture,
                            color: viewStore.color.background,
                            connection: nil,
                            style: .xxLarge
                        ) {}
                            .disabled(true)

                        if viewStore.picture != .none {
                            ResetPictureButton {
                                viewStore.send(.editPicture(nil))
                            }.background(Circle().foregroundColor(Colors.systemBackground).padding(8))
                        }
                    }

                    VStack(alignment: .leading) {
                        ProfilePictureSelector(store: store)
                            .padding([.trailing, .top, .bottom])

                        Text(L10n.editColorTxt)
                            .font(.system(size: 16, weight: .bold))
                            .padding([.leading, .trailing, .top])

                        ProfileColorPicker(color: viewStore.binding(
                            get: \.color,
                            send: EditProfilePictureDomain.Action.editColor
                        ))
                            .cornerRadius(16)

                        Text(viewStore.color.name)
                            .foregroundColor(Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
            }
        }
        .onAppear {
            viewStore.send(.setProfileValues)
        }
        .padding()
        .background(Colors.systemBackground.ignoresSafeArea())
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

extension EditProfilePictureView {
    private struct ProfilePictureSelector: View {
        let store: EditProfilePictureDomain.Store

        @ObservedObject
        var viewStore: ViewStore<ViewState, EditProfilePictureDomain.Action>

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
            ScrollView(.horizontal) {
                HStack {
                    ForEach(ProfilePicture.allCases, id: \.rawValue) { image in
                        if let displayImage = image.description, !displayImage.name.isEmpty {
                            Image(displayImage)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .background(Circle().foregroundColor(viewStore.color.background))
                                .border(viewStore.color.border, width: 1, cornerRadius: 99)
                                .clipShape(Circle())
                                .onTapGesture {
                                    viewStore.send(.editPicture(image))
                                }
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
                    .background(Circle().foregroundColor(Color(.systemGray6)))
            }
            .padding()
        }
    }
}
