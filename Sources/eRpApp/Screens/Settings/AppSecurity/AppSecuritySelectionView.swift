//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct AppSecuritySelectionView: View {
    @Perception.Bindable var store: StoreOf<AppSecurityDomain>

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                SectionContainer(
                    header: { HeaderView(store: store) },
                    content: {
                        let isBiometricSelected = store.isBiometricSelected
                        if store.availableSecurityOptions.contains(.biometry(.faceID)) {
                            Toggle(isOn: .init(
                                get: { isBiometricSelected },
                                set: { _ in store.send(.toggleBiometricSelected(.faceID)) }
                            )) {
                                Label(L10n.stgTxtSecurityOptionFaceidTitle)
                            }
                            .accessibility(identifier: A18n.settings.security.stgTglSecurityFaceid)
                        }

                        if store.availableSecurityOptions.contains(.biometry(.touchID)) {
                            Toggle(isOn: .init(
                                get: { isBiometricSelected },
                                set: { _ in store.send(.toggleBiometricSelected(.touchID)) }
                            )) {
                                Label(L10n.stgTxtSecurityOptionTouchidTitle)
                            }
                            .accessibility(identifier: A18n.settings.security.stgTglSecurityTouchid)
                        }

                        let isPasswordSelected = store.isPasswordSelected
                        if store.availableSecurityOptions.contains(.password) {
                            WithPerceptionTracking {
                                Toggle(isOn: .init(
                                    get: { isPasswordSelected },
                                    set: { _ in store.send(.togglePasswordSelected) }
                                )) {
                                    Label(L10n.stgTxtSecurityOptionPasswordTitle)
                                }
                                .accessibility(identifier: A18n.settings.security.stgTglSecurityPassword)
                            }
                        }

                        if store.availableSecurityOptions.contains(.password),
                           isPasswordSelected {
                            Button {
                                store.send(.appPasswordTapped)
                            } label: {
                                Label(L10n.stgTxtSecurityOptionChangePasswordTitle)
                                    .padding(.bottom, 4)
                            }
                            .accessibility(identifier: A18n.settings.security.stgBtnSecurityChangePassword)
                            .buttonStyle(.navigation)
                        }
                    }
                )
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.appPassword, action: \.destination.appPassword)
            ) { store in
                CreatePasswordView(store: store)
            }
            .onAppear {
                store.send(.loadSecurityOption)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(L10n.stgBtnDeviceSecurity)
            .background(Color(.secondarySystemBackground))
        }
    }

    private struct HeaderView: View {
        @Perception.Bindable var store: StoreOf<AppSecurityDomain>

        var body: some View {
            WithPerceptionTracking {
                if let error = store.errorToDisplay {
                    WarningView(text: error.errorDescription ?? "")
                        .accessibility(identifier: A11y.settings.security.stgHntBiometricsWarning)
                }
            }
        }

        private struct WarningView: View {
            var text: String

            var body: some View {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: SFSymbolName.exclamationMark)
                        .foregroundColor(Colors.red900)
                        .font(.title3)
                        .padding(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(text)
                            .font(Font.subheadline)
                            .foregroundColor(Colors.red900)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(8)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Colors.red100))
                .border(Colors.red300, width: 0.5, cornerRadius: 12)
            }
        }
    }
}

struct AppSecuritySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppSecuritySelectionView(store: AppSecurityDomain.Dummies.store)
        }
    }
}
