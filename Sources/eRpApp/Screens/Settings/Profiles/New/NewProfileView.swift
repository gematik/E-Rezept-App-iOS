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
import IDP
import SwiftUI

struct NewProfileView: View {
    let store: NewProfileDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, NewProfileDomain.Action>

    init(store: NewProfileDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let destinationTag: NewProfileDomain.Destinations.State.Tag?
        let color: ProfileColor
        let picture: ProfilePicture
        let userImageData: Data
        let name: String

        init(with state: NewProfileDomain.State) {
            color = state.color
            picture = state.image ?? .none
            userImageData = state.userImageData ?? .empty
            destinationTag = state.destination?.tag
            name = state.name
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ProfilePictureView(
                        image: viewStore.picture,
                        userImageData: viewStore.userImageData,
                        color: viewStore.color,
                        connection: nil,
                        style: .xxLarge,
                        isBorderOn: true
                    ) {
                        viewStore.send(.setNavigation(tag: .editProfilePicture))
                    }

                    NavigationLink(
                        destination: IfLetStore(
                            store.destinationsScope(
                                state: /NewProfileDomain.Destinations.State.editProfilePicture,
                                action: NewProfileDomain.Destinations.Action.editProfilePictureAction
                            ),
                            then: EditProfilePictureFullView.init(store:)
                        ),
                        tag: NewProfileDomain.Destinations.State.Tag.editProfilePicture,
                        selection: viewStore.binding(
                            get: \.destinationTag,
                            send: NewProfileDomain.Action.setNavigation
                        )
                    ) {
                        Text(L10n.stgBtnEditPicture)
                    }

                    SingleElementSectionContainer {
                        FormTextField(
                            L10n.stgTxtNewProfileNamePlaceholder.key,
                            text: viewStore.binding(get: \.name, send: NewProfileDomain.Action.setName)
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
            .navigationBarTitle(L10n.stgTxtNewProfileTitle, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    NavigationBarCloseItem {
                        viewStore.send(.closeButtonTapped)
                    }
                    .accessibility(identifier: A11y.settings.newProfile.stgBtnNewProfileCancel)
                    .embedToolbarContent()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        viewStore.send(.save)
                    }, label: {
                        Text(L10n.stgBtnNewProfileCreate)
                    })
                        .accessibility(identifier: A11y.settings.newProfile.stgBtnNewProfileSave)
                        .embedToolbarContent()
                }
            }
            .alert(store.scope(state: \.alertState), dismiss: NewProfileDomain.Action.dismissAlert)
        }
        .accentColor(Colors.primary600)
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
