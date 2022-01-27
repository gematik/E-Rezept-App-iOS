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
import IDP
import SwiftUI

struct SettingsView: View {
    let store: SettingsDomain.Store

    #if ENABLE_DEBUG_VIEW
    let debugStore: DebugDomain.Store
    #endif

    @ObservedObject
    var viewStore: ViewStore<ViewState, SettingsDomain.Action>

    #if !ENABLE_DEBUG_VIEW
    init(store: SettingsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }
    #else
    init(store: SettingsDomain.Store, debugStore: DebugDomain.Store) {
        self.store = store
        self.debugStore = debugStore
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }
    #endif

    struct ViewState: Equatable {
        #if ENABLE_DEBUG_VIEW
        let showDebugView: Bool
        #endif
        let showTrackerComplyView: Bool
        let isDemoMode: Bool
        let route: ProfilesDomain.Route?
        let routeTag: ProfilesDomain.Route.Tag?

        init(state: SettingsDomain.State) {
            #if ENABLE_DEBUG_VIEW
            showDebugView = state.showDebugView
            #endif
            showTrackerComplyView = state.showTrackerComplyView
            isDemoMode = state.isDemoMode
            route = state.profiles.route
            routeTag = state.profiles.route?.tag
        }
    }

    var body: some View {
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

                    ProfileSectionView(store: profilesStore)

                    DemoModeSectionView(store: store)

                    SecuritySectionView(store: store)

                    TrackerSectionView(store: store)

                    LegalInfoSectionView(store: store)

                    BottomSectionView(store: store)
                }
                .listStyle(InsetGroupedListStyle())
                .alert(profilesAlertStore, dismiss: .setNavigation(tag: nil))

                // Tracking comply sheet presentation
                EmptyView()
                    .sheet(isPresented: viewStore.binding(
                        get: { $0.showTrackerComplyView },
                        send: SettingsDomain.Action.dismissTrackerComplyView
                    )) {
                        TrackingComplyView(store: store)
                    }

                EmptyView()
                    .sheet(isPresented: Binding<Bool>(get: {
                        viewStore.route?.tag == .newProfile
                    }, set: { show in
                        if !show {
                            viewStore.send(.profiles(action: .setNavigation(tag: nil)))
                        }
                    }),
                    onDismiss: {},
                    content: {
                        IfLetStore(newProfileStore, then: NewProfileView.init)
                    })

                NavigationLink(
                    destination: IfLetStore(profileStore) { profileStore in
                        EditProfileView(store: profileStore)
                    },
                    tag: ProfilesDomain.Route.Tag.details, // swiftlint:disable:next trailing_closure
                    selection: viewStore.binding(get: \.routeTag, send: { tag in
                        SettingsDomain.Action.profiles(action: .setNavigation(tag: tag))
                    })
                ) {}
                    .hidden()
                    .accessibility(hidden: true)
            }
            .navigationBarTitle(Text(L10n.stgTxtTitle))
            .edgesIgnoringSafeArea(.bottom)
            .demoBanner(isPresented: viewStore.isDemoMode)
        }
        .accentColor(Colors.primary700)
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

extension SettingsView {
    private struct DemoModeSectionView: View {
        let store: SettingsDomain.Store

        @ObservedObject
        var viewStore: ViewStore<ViewState, SettingsDomain.Action>

        init(store: SettingsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let isDemoMode: Bool

            init(state: SettingsDomain.State) {
                isDemoMode = state.isDemoMode
            }
        }

        var body: some View {
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

    private struct TrackerSectionView: View {
        let store: SettingsDomain.Store

        @ObservedObject
        var viewStore: ViewStore<ViewState, SettingsDomain.Action>

        init(store: SettingsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let isDemoMode: Bool
            let trackerOptIn: Bool

            init(state: SettingsDomain.State) {
                isDemoMode = state.isDemoMode
                trackerOptIn = state.trackerOptIn
            }
        }

        var body: some View {
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
                    ListCellView(sfSymbolName: SFSymbolName.ant, text: "Debug")
                }
                .border(Colors.systemColorClear, cornerRadius: 16)
            }
            .textCase(.none)
        }
    }
    #endif

    private struct BottomSectionView: View {
        let store: SettingsDomain.Store

        @ObservedObject
        var viewStore: ViewStore<ViewState, SettingsDomain.Action>

        init(store: SettingsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let appVersion: AppVersion

            init(state: SettingsDomain.State) {
                appVersion = state.appVersion
            }
        }

        var body: some View {
            Section(header: Spacer(minLength: 64),
                    footer: VersionInfoView(appVersion: viewStore.appVersion)
                        .padding(.bottom)) {}
        }
    }

    struct TrackingComplyView: View {
        let store: SettingsDomain.Store

        @ObservedObject
        var viewStore: ViewStore<Void, SettingsDomain.Action>

        init(store: SettingsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.stateless)
        }

        var body: some View {
            NavigationView {
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
            .accentColor(Colors.primary700)
            .navigationViewStyle(StackNavigationViewStyle())
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
        }
    }
}
