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
                    header: SectionHeaderView(
                        text: L10n.cpwTxtSectionUpdateTitle,
                        a11y: A11y.settings.createPassword.cpwTxtSectionUpdateTitle
                    ).padding(.bottom, 8),
                    footer: currentPasswordFooter()
                ) {
                    SecureFieldWithReveal(titleKey: L10n.cpwInpCurrentPasswordPlaceholder,
                                          text: currentPassword) {}
                        .accessibility(identifier: A11y.settings.createPassword.cpwInpCurrentPassword)
                }
                .textCase(.none)
            }

            Section(
                header: SectionHeaderView(
                    text: L10n.cpwTxtSectionTitle,
                    a11y: A11y.settings.createPassword.cpwTxtSectionTitle
                ).padding(.bottom, 8),
                footer: VStack(spacing: 8) {
                    FootnoteView(
                        text: L10n.cpwTxtPasswordRecommendation,
                        a11y: A11y.settings.createPassword.cpwTxtPasswordRecommendation
                    )

                    PasswordStrengthView(strength: viewStore.passwordStrength)
                }
            ) {
                VStack {
                    SecureFieldWithReveal(titleKey: L10n.cpwInpPasswordAPlaceholder,
                                          text: passwordA,
                                          textContentType: .newPassword) {}
                        .accessibility(identifier: A11y.settings.createPassword.cpwInpPasswordA)
                }
            }
            .textCase(.none)

            Section {
                SecureFieldWithReveal(titleKey: L10n.cpwInpPasswordBPlaceholder,
                                      accessibilityLabelKey: L10n.cpwTxtPasswordBAccessibility,
                                      text: passwordB,
                                      textContentType: .newPassword) {
                    viewStore.send(.saveButtonTapped)
                }
                .accessibility(identifier: A11y.settings.createPassword.cpwInpPasswordB)
            }

            Section(header: errorFooter(),
                    footer: saveButtonAndError()) {
                EmptyView()
            }
            .textCase(.none)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(updatePassword ? L10n.cpwTxtUpdateTitle : L10n.cpwTxtTitle)
    }

    @ViewBuilder
    private func errorFooter() -> some View {
        if let error = viewStore.passwordErrorMessage {
            Text(error)
                .foregroundColor(Colors.red600)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
                .transformEffect(.init(translationX: 0, y: -16))
        }
    }

    @ViewBuilder
    private func saveButtonAndError() -> some View {
        PrimaryTextButton(
            text: updatePassword ? L10n.cpwBtnChange : L10n.cpwBtnSave,
            a11y: updatePassword ?
                A11y.settings.createPassword.cpwBtnUpdate : A11y.settings.createPassword.cpwBtnSave,
            image: nil,
            isEnabled: viewStore.hasValidPasswordEntries
        ) {
            UIApplication.shared.dismissKeyboard()
            viewStore.send(.saveButtonTapped)
        }
    }

    @ViewBuilder
    private func currentPasswordFooter() -> some View {
        if viewStore.showOriginalPasswordWrong {
            VStack(alignment: .leading) {
                Text(L10n.cpwTxtCurrentPasswordWrong)
                    .foregroundColor(Colors.red600)
                    .font(.footnote)
            }
        } else {
            EmptyView()
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
