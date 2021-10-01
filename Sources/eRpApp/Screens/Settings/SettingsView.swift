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

struct SettingsView: View {
    let store: SettingsDomain.Store

    #if ENABLE_DEBUG_VIEW
    let debugStore: DebugDomain.Store
    #endif

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Group {
                    List {
                        #if ENABLE_DEBUG_VIEW
                        DebugSectionView(store: debugStore,
                                         showDebugView: viewStore.binding(
                                             get: { $0.showDebugView },
                                             send: SettingsDomain.Action.toggleDebugView
                                         ))
                        #endif

                        DemoModeSectionView(store: store)

                        SecuritySectionView(store: store)

                        // [REQ:gemSpec_BSI_FdV:O.Tokn_9] integration in SettingsView
                        TokenSectionView(store: store)

                        TrackerSectionView(store: store)

                        LegalInfoSectionView(store: store)

                        BottomSectionView(store: store)
                    }
                    .listStyle(InsetGroupedListStyle())

                    // Tracking comply sheet presentation
                    EmptyView()
                        .sheet(isPresented: viewStore.binding(
                            get: { $0.showTrackerComplyView },
                            send: SettingsDomain.Action.dismissTrackerComplyView
                        )) {
                            TrackingComplyView(store: store)
                        }
                }
                .navigationBarTitle(Text(L10n.stgTxtTitle), displayMode: .inline)
                .navigationBarItems(
                    leading: NavigationTextButton(
                        text: L10n.navDone,
                        a11y: A18n.settings.demo.navDone
                    ) {
                        viewStore.send(.close)
                    }
                )
                .edgesIgnoringSafeArea(.bottom)
                .demoBanner(isPresented: viewStore.state.isDemoMode)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .alert(
                self.store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
            .onAppear {
                viewStore.send(.initSettings)
            }
        }
    }

    private struct DemoModeSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(
                    header: SectionHeaderView(
                        text: L10n.stgTxtHeaderDemoMode,
                        a11y: A18n.settings.demo.stgTxtHeaderDemoMode
                    ).padding(.bottom, 8),
                    footer: FootnoteView(
                        text: L10n.stgTxtFootnoteDemoMode,
                        a11y: A18n.settings.demo.stgTxtFootnoteDemoMode
                    )
                ) {
                    ToggleCell(
                        text: L10n.stgTxtDemoMode,
                        a11y: A18n.settings.demo.stgTxtDemoMode,
                        systemImage: SFSymbolName.wandAndStars,
                        backgroundColor: Colors.systemColorClear,
                        isToggleOn: viewStore.binding(
                            get: \.isDemoMode,
                            send: SettingsDomain.Action.toggleDemoModeSwitch
                        )
                        .animation()
                    )
                }
                .textCase(.none)
            }
        }
    }

    private struct TokenSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section {
                    NavigationLink(destination: IDPTokenView(token: viewStore.state.token)) {
                        ListCellView(
                            sfSymbolName: SFSymbolName.key,
                            text: L10n.stgTxtSecurityTokens
                        )
                    }
                    .accessibility(identifier: A11y.settings.security.stgTxtSecurityTokens)
                }
                .disabled(viewStore.state.token == nil)
            }
        }
    }

    private struct TrackerSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(
                    header: HeaderView(),
                    footer: FootnoteView(
                        text: viewStore.state.isDemoMode ?
                            L10n.stgTrkTxtFootnoteDisabled : L10n.stgTrkTxtFootnote,
                        a11y: A18n.settings.tracking.stgTrkTxtFootnote
                    )
                ) {
                    ToggleCell(
                        text: L10n.stgTrkBtnTitle,
                        a11y: A18n.settings.tracking.stgTrkBtnTitle,
                        systemImage: SFSymbolName.wandAndStars,
                        backgroundColor: Colors.systemColorClear,
                        isToggleOn: viewStore.binding(
                            get: \.trackerOptIn,
                            send: SettingsDomain.Action.toggleTrackingTapped
                        )
                        .animation(),
                        isDisabled: Binding(
                            get: { viewStore.state.isDemoMode },
                            set: { _, _ in }
                        )
                    )
                }
                .textCase(.none)
            }
        }

        private struct HeaderView: View {
            var body: some View {
                VStack {
                    SectionHeaderView(
                        text: L10n.stgTrkTxtTitle,
                        a11y: A11y.settings.tracking.stgTrkTxtTitle
                    )
                    .padding(.bottom, 8)

                    // [REQ:gemSpec_eRp_FdV:A_19089] User info for usage tracking
                    HeadernoteView(
                        text: L10n.stgTrkTxtExplanation,
                        a11y: A11y.settings.tracking.stgTrkTxtExplanation
                    )
                }
            }
        }
    }

    private struct LegalInfoSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { _ in
                Section(
                    header: SectionHeaderView(
                        text: L10n.stgTxtHeaderLegalInfo,
                        a11y: A18n.settings.legalNotice.stgLnoTxtHeaderLegalInfo
                    ).padding(.bottom, 8)
                ) {
                    SettingsLegalInfoView(store: store)
                }
                .textCase(.none)
            }
        }
    }

    #if ENABLE_DEBUG_VIEW
    private struct DebugSectionView: View {
        let store: DebugDomain.Store

        @Binding var showDebugView: Bool

        var body: some View {
            Section(header: SectionHeaderView(text: "Debug", a11y: "Debug").padding(.bottom, 8)) {
                NavigationLink(
                    destination: DebugView(store: store),
                    isActive: $showDebugView
                ) {
                    ListCellView(
                        sfSymbolName: SFSymbolName.ant,
                        text: "Debug"
                    )
                }
                .border(Colors.systemColorClear, cornerRadius: 16)
            }
            .textCase(.none)
        }
    }
    #endif

    private struct BottomSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(header: Spacer(minLength: 64),
                        footer: VersionInfoView(appVersion: viewStore.appVersion)
                            .padding(.bottom)) {
                    LogoutButton {
                        viewStore.send(.logout)
                    }
                }
                .listRowBackground(Colors.red600)
            }
        }

        struct LogoutButton: View {
            @Environment(\.colorScheme) var colorScheme
            let action: () -> Void

            var body: some View {
                Button(action: action) {
                    HStack {
                        Text(L10n.stgBtnLogout)
                    }
                    .frame(maxWidth: .infinity)
                }
                .accessibility(identifier: A18n.settings.logout.stgBtnLogout)
                .font(Font.body.weight(.semibold))
                .foregroundColor(colorScheme == .dark ? Colors.systemLabel : Colors.systemColorWhite)
            }
        }
    }

    struct TrackingComplyView: View {
        let store: SettingsDomain.Store

        var body: some View {
            NavigationView {
                WithViewStore(store) { viewStore in
                    VStack(alignment: .center, spacing: 16) {
                        ScrollView(.vertical) {
                            Text(L10n.stgTrkTxtAlertTitle)
                                .foregroundColor(Colors.systemLabel)
                                .multilineTextAlignment(.center)
                                .font(Font.title.bold())
                                .padding()
                                .accessibility(identifier: A18n.redeem.overview.rdmTxtPharmacyTitle)
                            Text(L10n.stgTrkTxtAlertMessage)
                                .font(.body)
                                .foregroundColor(Colors.systemLabel)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .accessibility(identifier: A18n.redeem.overview.rdmTxtPharmacySubtitle)
                        }
                        VStack(alignment: .center, spacing: 4) {
                            PrimaryTextButton(
                                text: L10n.stgTrkBtnAlertYes,
                                a11y: A11y.settings.tracking.stgTrkBtnYes
                            ) {
                                viewStore.send(.confirmedOptInTracking)
                            }
                            .font(Font.body.weight(.semibold))
                            .padding()
                            Button(L10n.stgTrkBtnAlertNo) {
                                viewStore.send(.dismissTrackerComplyView)
                            }
                            .accessibility(identifier: A11y.settings.tracking.stgTrkBtnNo)
                            .font(Font.body.weight(.semibold))
                            .padding([.leading, .trailing, .bottom])
                        }
                    }
                    .navigationBarItems(
                        trailing: CloseButton { viewStore.send(.dismissTrackerComplyView) }
                            .accessibility(identifier: A18n.redeem.overview.rdmBtnCloseButton)
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .introspectNavigationController { navigationController in
                        let navigationBar = navigationController.navigationBar
                        navigationBar.barTintColor = UIColor(Colors.systemBackground)
                        let navigationBarAppearance = UINavigationBarAppearance()
                        navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                        navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                        navigationBar.standardAppearance = navigationBarAppearance
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            #if ENABLE_DEBUG_VIEW
            SettingsView(store: SettingsDomain.Dummies.store,
                         debugStore: DebugDomain.Dummies.store)
            #else
            SettingsView(store: SettingsDomain.Dummies.store)
            #endif
        }.generateVariations()
    }
}
