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

extension SettingsView {
    struct SecuritySectionView: View {
        let store: AppSecurityDomain.Store
        @ObservedObject
        var viewStore: ViewStore<Void, AppSecurityDomain.Action>

        init(store: SettingsDomain.Store) {
            self.store = store.scope(state: { $0.appSecurityState },
                                     action: { .appSecurity(action: $0) })
            viewStore = ViewStore(self.store.stateless)
        }

        var body: some View {
            Section(header: HeaderView(store: store)) {
                AppSecuritySelectionView(store: store)
            }
            .textCase(.none)
        }

        private struct HeaderView: View {
            let store: AppSecurityDomain.Store

            var body: some View {
                WithViewStore(store) { viewStore in
                    VStack {
                        SectionHeaderView(
                            text: L10n.stgTxtHeaderSecurity,
                            a11y: A18n.settings.security.stgTxtHeaderSecurity
                        )
                        .padding(.bottom, 8)

                        if viewStore.state.selectedSecurityOption == nil {
                            WarningView(text: NSLocalizedString("stg_txt_security_warning",
                                                                comment: "stg_hnt_security_warning"))
                                .accessibility(identifier: "")
                        }

                        if let error = viewStore.state.errorToDisplay {
                            WarningView(text: error.errorDescription ?? "")
                                .accessibility(identifier: "stg_hnt_biometrics_warning")
                        }
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

    struct AppSecuritySelectionView: View {
        let store: AppSecurityDomain.Store
        @ObservedObject
        var viewStore: ViewStore<ViewState, AppSecurityDomain.Action>

        init(store: AppSecurityDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let availableSecurityOptions: [AppSecurityOption]
            let selectedSecurityOption: AppSecurityOption?
            let showCreatePasswordScreen: Bool
            init(state: AppSecurityDomain.State) {
                availableSecurityOptions = state.availableSecurityOptions
                selectedSecurityOption = state.selectedSecurityOption
                showCreatePasswordScreen = state.showCreatePasswordScreen
            }
        }

        var body: some View {
            ForEach(viewStore.state.availableSecurityOptions) { option in
                let binding = viewStore.binding(
                    get: { $0.selectedSecurityOption == option },
                    send: .select(option)
                )
                .animation()

                switch option {
                case let .biometry(biometryType):
                    switch biometryType {
                    case .faceID:
                        SelectionCell(
                            text: L10n.stgTxtSecurityOptionFaceidTitle,
                            description: nil,
                            a11y: A18n.settings.security.stgTxtSecurityFaceid,
                            systemImage: SFSymbolName.faceId,
                            isOn: binding
                        )
                    case .touchID:
                        SelectionCell(
                            text: L10n.stgTxtSecurityOptionTouchidTitle,
                            description: nil,
                            a11y: A18n.settings.security.stgTxtSecurityTouchid,
                            systemImage: SFSymbolName.touchId,
                            isOn: binding
                        )
                    }
                case .password:
                    NavigationLink(
                        destination: IfLetStore(
                            store.scope(
                                state: { $0.createPasswordState },
                                action: { AppSecurityDomain.Action.createPassword(action: $0) }
                            )
                        ) { store in
                            CreatePasswordView(store: store)
                        },
                        isActive: viewStore.binding(
                            get: \.showCreatePasswordScreen,
                            send: { active -> AppSecurityDomain.Action in
                                if active {
                                    return AppSecurityDomain.Action.select(.password)
                                } else {
                                    return AppSecurityDomain.Action.hideCreatePasswordScreen
                                }
                            }
                        )
                    ) {
                        SelectionCell(
                            text: L10n.stgTxtSecurityOptionPasswordTitle,
                            description: nil,
                            a11y: A18n.settings.security.stgTxtSecurityPassword,
                            systemImage: SFSymbolName.rectangleAndPencilAndEllipsis,
                            isOn: binding
                        )
                    }
                case .unsecured:
                    EmptyView()
                }
            }
        }
    }
}

struct AppSecuritySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SettingsView.AppSecuritySelectionView(store: AppSecurityDomain.Dummies.store)
            }.generateVariations(selection: .devices, oneDark: true)
        }
    }
}
