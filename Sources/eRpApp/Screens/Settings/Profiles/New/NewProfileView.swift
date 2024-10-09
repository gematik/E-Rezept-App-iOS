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
import IDP
import SwiftUI

struct NewProfileView: View {
    @Perception.Bindable var store: StoreOf<NewProfileDomain>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        ProfilePictureView(
                            image: store.image,
                            userImageData: store.userImageData,
                            color: store.color,
                            connection: nil,
                            style: .xxLarge,
                            isBorderOn: true
                        ) {
                            store.send(.tappedEditProfilePicture)
                        }

                        Button {
                            store.send(.tappedEditProfilePicture)
                        } label: {
                            Text(L10n.stgBtnEditPicture)
                        }

                        SingleElementSectionContainer {
                            FormTextField(
                                L10n.stgTxtNewProfileNamePlaceholder.key,
                                bundle: .module,
                                text: $store.name
                            )
                            .accessibilityIdentifier(A11y.settings.newProfile.stgInpNewProfileName)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .background(Color(.secondarySystemBackground).ignoresSafeArea())
                .gesture(TapGesture().onEnded {
                    UIApplication.shared.dismissKeyboard()
                })
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.editProfilePicture,
                        action: \.destination.editProfilePicture
                    )
                ) { store in
                    EditProfilePictureView(store: store)
                        .navigationTitle(L10n.editPictureTxt)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationBarTitle(L10n.stgTxtNewProfileTitle, displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        NavigationBarCloseItem {
                            store.send(.closeButtonTapped)
                        }
                        .accessibility(identifier: A11y.settings.newProfile.stgBtnNewProfileCancel)
                        .embedToolbarContent()
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            store.send(.save)
                        }, label: {
                            Text(L10n.stgBtnNewProfileCreate)
                        })
                            .accessibility(identifier: A11y.settings.newProfile.stgBtnNewProfileSave)
                            .embedToolbarContent()
                    }
                }
                .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            }
            .accentColor(Colors.primary600)
        }
    }
}

struct NewProfileView_Preview: PreviewProvider {
    static var previews: some View {
        Text("Background")
            .sheet(isPresented: .constant(true)) {
                NewProfileView(
                    store: NewProfileDomain.Dummies.store
                )
            }
    }
}
