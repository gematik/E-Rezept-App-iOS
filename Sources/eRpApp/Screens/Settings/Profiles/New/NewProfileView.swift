//
//  Copyright (c) 2022 gematik GmbH
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

struct NewProfileView: View {
    let store: NewProfileDomain.Store

    @ObservedObject
    var viewStore: ViewStore<NewProfileDomain.State, NewProfileDomain.Action>

    init(store: NewProfileDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    @State
    var emoji: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ProfilePicturePicker(
                        emoji: viewStore.binding(
                            get: \.emoji,
                            send: NewProfileDomain.Action.setEmoji
                        ),
                        acronym: viewStore.acronym,
                        color: viewStore.color.background,
                        borderColor: viewStore.color.border
                    )
                    .padding(.top)
                    .padding(.bottom, 8)

                    SingleElementSectionContainer {
                        FormTextField(
                            L10n.stgTxtNewProfileNamePlaceholder.key,
                            text: viewStore.binding(get: \.name, send: NewProfileDomain.Action.setName)
                        )
                        .accessibilityIdentifier(A11y.settings.newProfile.stgInpNewProfileName)
                    }

                    ProfileColorPicker(color: viewStore
                        .binding(get: \.color, send: NewProfileDomain.Action.setColor))
                                            .accessibility(identifier: A11y.settings.newProfile
                                                .stgTxtNewProfileBgColorPicker)
                                            .background(Color(.tertiarySystemBackground))
                                            .cornerRadius(16)
                                            .padding([.horizontal, .bottom])
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
                        viewStore.send(.close)
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