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
import SwiftUI

struct AddProfileView: View {
    let store: AddProfileDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, AddProfileDomain.Action>

    init(store: AddProfileDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let isValidName: Bool
        var profileName: String

        init(state: AddProfileDomain.State) {
            isValidName = state.isValidName
            profileName = state.profileName
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            VStack(spacing: 8) {
                Section(header:
                    Text(L10n.addTxtTitle)
                        .font(.system(size: 16, weight: .bold))) {
                        TextField(L10n.addTxtProfile1, text: viewStore.binding(
                            get: \.profileName,
                            send: AddProfileDomain.Action.updateProfileName(profileName:)
                        ))
                            .foregroundColor(Colors.textSecondary)
                            .padding()
                            .border(Colors.primary700, width: 2, cornerRadius: 8)
                            .padding(.vertical)
                            .padding(.horizontal)

                        Button(action: {
                            viewStore.send(.saveProfile(viewStore.profileName), animation: .easeInOut)
                        }, label: {
                            HStack {
                                Text(L10n.addBtnSave)
                                    .foregroundColor(viewStore.isValidName ? Color(.white) : Color(.systemGray))
                                    .font(.system(size: 16, weight: .bold))
                                    .padding()
                                    .padding(.horizontal)
                            }
                        })
                            .disabled(!viewStore.isValidName)
                            .background(viewStore.isValidName ? Colors.primary : Color(.systemGray4))
                            .cornerRadius(16)
                }
            }
        }.padding()
            .background(Colors.systemBackground.ignoresSafeArea())
    }
}

struct AddProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddProfileView(store: AddProfileDomain.Dummies.store)
                .previewDevice("iPhone 11")

            AddProfileView(store: AddProfileDomain.Dummies.store)
                .previewDevice("iPhone 13 Pro")

            AddProfileView(store: AddProfileDomain.Dummies.store)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
