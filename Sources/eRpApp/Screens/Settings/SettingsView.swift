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

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    DemoModeSectionView(store: store)

                    SecuritySectionView(store: store)

                    TrackerSectionView(store: store)

                    LegalInfoSectionView(store: store)

                    #if ENABLE_DEBUG_VIEW
                    DebugSectionView(store: store)
                    #endif

                    BottomSectionView(store: store)

                    // Tracking comply sheet presentation
                    EmptyView()
                        .sheet(isPresented: viewStore.binding(
                            get: { $0.showTrackerComplyView },
                            send: SettingsDomain.Action.dismissTrackerComplyView
                        )) {
                            TrackingComplyView(store: store)
                        }
                }
                .background(Color(.secondarySystemBackground))
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
                SectionView(text: L10n.stgTxtHeaderDemoMode, a11y: A18n.settings.demo.stgTxtHeaderDemoMode)

                ToggleCell(
                    text: L10n.stgTxtDemoMode,
                    a11y: A18n.settings.demo.stgTxtDemoMode,
                    systemImage: SFSymbolName.wandAndStars,
                    isToggleOn: viewStore.binding(
                        get: \.isDemoMode,
                        send: SettingsDomain.Action.toggleDemoModeSwitch
                    )
                    .animation()
                )
                FootnoteView(text: L10n.stgTxtFootnoteDemoMode, a11y: A18n.settings.demo.stgTxtFootnoteDemoMode)
            }
            .padding([.leading, .trailing])
        }
    }

    private struct SecuritySectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { _ in
                SectionView(
                    text: L10n.stgTxtHeaderSecurity,
                    a11y: A18n.settings.security.stgTxtHeaderSecurity
                )
                .padding(.bottom, 2)

                AppSecuritySelectionView(store: store.scope(
                    state: { $0.appSecurityState },
                    action: { .appSecurity(action: $0) }
                ))

                Spacer()
                    .padding(.bottom, 20)
            }
            .padding([.leading, .trailing])
        }
    }

    private struct TrackerSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                SectionView(
                    text: L10n.stgTrkTxtTitle,
                    a11y: A11y.settings.tracking.stgTrkTxtTitle
                )
                .padding(.bottom, 2)

                // [REQ:gemSpec_eRp_FdV:A_19089] User info for usage tracking
                HeadernoteView(
                    text: L10n.stgTrkTxtExplanation,
                    a11y: A11y.settings.tracking.stgTrkTxtExplanation
                )

                ToggleCell(
                    text: L10n.stgTrkBtnTitle,
                    a11y: A18n.settings.tracking.stgTrkBtnTitle,
                    systemImage: SFSymbolName.wandAndStars,
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

                // [REQ:gemSpec_eRp_FdV:A_19089] User info for usage tracking
                FootnoteView(
                    text: viewStore.state.isDemoMode ?
                        L10n.stgTrkTxtFootnoteDisabled : L10n.stgTrkTxtFootnote,
                    a11y: A18n.settings.tracking.stgTrkTxtFootnote
                )

                Spacer()
                    .padding(.bottom, 20)
            }
            .padding([.leading, .trailing])
        }
    }

    private struct LegalInfoSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { _ in
                SectionView(
                    text: L10n.stgTxtHeaderLegalInfo,
                    a11y: A18n.settings.legalNotice.stgLnoTxtHeaderLegalInfo
                )
                .padding(.bottom, 2)

                SettingsLegalInfoView(store: store)

                Spacer().padding(.bottom, 20)
            }
            .padding([.leading, .trailing])
        }
    }

    #if ENABLE_DEBUG_VIEW
    private struct DebugSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                SectionView(
                    text: "Debug",
                    a11y: "Debug"
                )
                .padding(.bottom, 2)

                NavigationLink(
                    destination: DebugView(store:
                                            store.scope(
                                                state: \.debug,
                                                action: SettingsDomain.Action.debug(action:)
                                            )),
                    isActive: viewStore.binding(
                        get: { $0.showDebugView },
                        send: SettingsDomain.Action.toggleDebugView
                    )
                ) {
                    ListCellView(
                        sfSymbolName: SFSymbolName.ant,
                        text: "Debug",
                        accessibility: "Debug"
                    )
                }
                .border(Colors.systemColorClear, cornerRadius: 16)
            }
            .padding([.leading, .trailing])
        }
    }
    #endif

    private struct BottomSectionView: View {
        let store: SettingsDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Spacer()

                LogoutButton {
                    viewStore.send(.logout)
                }

                // Version info
                VersionInfoView(appVersion: viewStore.appVersion)
                    .padding(.bottom)
            }
            .padding([.leading, .trailing, .bottom])
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
            SettingsView(store: SettingsDomain.Dummies.store)
        }.generateVariations()
    }
}
