//
//  Copyright (c) 2021 gematik GmbH
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

struct CreatePasswordView: View {
    let store: CreatePasswordDomain.Store
    @ObservedObject private var viewStore: ViewStore<CreatePasswordDomain.State, CreatePasswordDomain.Action>

    init(store: CreatePasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var currentPassword: Binding<String> {
        viewStore.binding(get: \.password, send: CreatePasswordDomain.Action.setCurrentPassword).animation()
    }

    var passwordA: Binding<String> {
        viewStore.binding(get: \.passwordA, send: CreatePasswordDomain.Action.setPasswordA).animation()
    }

    var passwordB: Binding<String> {
        viewStore.binding(get: \.passwordB, send: CreatePasswordDomain.Action.setPasswordB).animation()
    }

    var updatePassword: Bool {
        viewStore.mode == .update
    }

    var body: some View {
        List {
            if updatePassword {
                Section(
                    header: SectionView(
                        text: L10n.cpwTxtSectionUpdateTitle,
                        a11y: A11y.settings.createPassword.cpwTxtSectionUpdateTitle
                    ),
                    footer: currentPasswordFooter()
                ) {
                    SecureFieldWithReveal(L10n.cpwInpCurrentPasswordPlaceholder,
                                          text: currentPassword) {}
                        .accessibility(identifier: A11y.settings.createPassword.cpwInpCurrentPassword)
                }
            }

            Section(
                header: SectionView(
                    text: L10n.cpwTxtSectionTitle,
                    a11y: A11y.settings.createPassword.cpwTxtSectionTitle
                ),
                footer: FootnoteView(
                    text: L10n.cpwTxtPasswordRecommendation,
                    a11y: A11y.settings.createPassword.cpwTxtPasswordRecommendation
                )
            ) {
                SecureFieldWithReveal(L10n.cpwInpPasswordAPlaceholder,
                                      text: passwordA,
                                      textContentType: .newPassword) {}
                    .accessibility(identifier: A11y.settings.createPassword.cpwInpPasswordA)
            }

            Section(footer: saveButtonAndError()) {
                SecureFieldWithReveal(L10n.cpwInpPasswordBPlaceholder,
                                      accessibilityLabelKey: L10n.cpwTxtPasswordBAccessibility,
                                      text: passwordB,
                                      textContentType: .newPassword) {
                    viewStore.send(.saveButtonTapped)
                }
                .accessibility(identifier: A11y.settings.createPassword.cpwInpPasswordB)
            }
        }

        .listStyle(GroupedListStyle())

        .navigationTitle(updatePassword ? L10n.cpwTxtUpdateTitle : L10n.cpwTxtTitle)
    }

    private func saveButtonAndError() -> some View {
        VStack(alignment: .leading) {
            if viewStore.showPasswordsNotEqualMessage {
                Text(L10n.cpwTxtPasswordsDontMatch)
                    .foregroundColor(Colors.red600)
                    .font(.footnote)
            }

            PrimaryTextButton(
                text: updatePassword ? L10n.cpwBtnChange : L10n.cpwBtnSave,
                a11y: updatePassword ?
                    A11y.settings.createPassword.cpwBtnUpdate : A11y.settings.createPassword.cpwBtnSave,
                image: nil,
                isEnabled: viewStore.hasValidPasswordEntries
            ) { viewStore.send(.saveButtonTapped) }
                .padding(.top)
        }
    }

    private func currentPasswordFooter() -> some View {
        VStack(alignment: .leading) {
            if viewStore.showOriginalPasswordWrong {
                Text(L10n.cpwTxtCurrentPasswordWrong)
                    .foregroundColor(Colors.red600)
                    .font(.footnote)
            }
        }
    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreatePasswordView(store: CreatePasswordDomain.Dummies.store)
        }
    }
}
