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
        ScrollView {
            // This TextField is mandatory to support password autofill from iCloud Keychain, applying  `.hidden()`
            // lets iOS no longer detect it.
            TextField("", text: .constant("E-Rezept App – \(UIDevice.current.name)"))
                .textContentType(.username)
                .frame(width: 1, height: 1, alignment: .leading)
                .opacity(0.01)
                .accessibility(hidden: true)

            if updatePassword {
                SingleElementSectionContainer(
                    header: {
                        SectionHeaderView(
                            text: L10n.cpwTxtSectionUpdateTitle,
                            a11y: A11y.settings.createPassword.cpwTxtSectionUpdateTitle
                        ).padding(.bottom, 8)
                    },
                    footer: { currentPasswordFooter() },
                    content: {
                        SecureField(L10n.cpwInpCurrentPasswordPlaceholder,
                                    text: currentPassword) {
                            viewStore.send(.enterButtonTapped)
                        }
                        .textContentType(.password)
                        .accessibility(identifier: A11y.settings.createPassword.cpwInpCurrentPassword)
                        .padding()
                    }
                )
            }

            SingleElementSectionContainer(
                header: {
                    SectionHeaderView(
                        text: L10n.cpwTxtSectionTitle,
                        a11y: A11y.settings.createPassword.cpwTxtSectionTitle
                    ).padding(.bottom, 8)
                },
                footer: {
                    VStack(spacing: 8) {
                        FootnoteView(
                            text: L10n.cpwTxtPasswordRecommendation,
                            a11y: A11y.settings.createPassword.cpwTxtPasswordRecommendation
                        )

                        PasswordStrengthView(strength: viewStore.passwordStrength)
                    }
                },
                content: {
                    VStack {
                        SecureField(L10n.cpwInpPasswordAPlaceholder,
                                    text: passwordA) {
                            viewStore.send(.enterButtonTapped)
                        }
                        .padding()
                        .textContentType(.newPassword)
                        .accessibility(identifier: A11y.settings.createPassword.cpwInpPasswordA)
                    }
                }
            )

            SingleElementSectionContainer {
                SecureField(L10n.cpwInpPasswordBPlaceholder,
                            text: passwordB) {
                    viewStore.send(.saveButtonTapped)
                }
                .padding()
                .accessibilityLabel(L10n.cpwTxtPasswordBAccessibility)
                .textContentType(.newPassword)
                .accessibility(identifier: A11y.settings.createPassword.cpwInpPasswordB)
            }

            errorFooter()
            saveButtonAndError()
                .padding()
        }
        .background(Colors.systemBackgroundSecondary.ignoresSafeArea())
        .navigationTitle(updatePassword ? L10n.cpwTxtUpdateTitle : L10n.cpwTxtTitle)
    }

    @ViewBuilder private func errorFooter() -> some View {
        if let error = viewStore.passwordErrorMessage {
            Text(error)
                .foregroundColor(Colors.red600)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
                .transformEffect(.init(translationX: 0, y: -16))
        }
    }

    @ViewBuilder private func saveButtonAndError() -> some View {
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

    @ViewBuilder private func currentPasswordFooter() -> some View {
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
