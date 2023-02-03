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
import IDP
import SwiftUI

struct SettingsView: View {
    let store: SettingsDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, SettingsDomain.Action>

    init(store: SettingsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let isDemoMode: Bool
        let profilesRouteTag: ProfilesDomain.Route.Tag?

        let routeTag: SettingsDomain.Route.Tag?

        init(state: SettingsDomain.State) {
            isDemoMode = state.isDemoMode
            profilesRouteTag = state.profiles.route?.tag
            routeTag = state.route?.tag
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    #if ENABLE_DEBUG_VIEW
                    DebugSectionView(store: store)
                    #endif

                    ProfilesView(store: profilesStore)

                    DemoModeSectionView(store: store)

                    HealthCardSectionView(store: store)

                    TrackerSectionView(store: store)

                    SecuritySectionView(store: store)

                    SettingsContactInfoView()

                    SettingsLegalInfoView(store: store)

                    BottomSectionView(store: store)
                }
                .alert(profilesAlertStore, dismiss: .setNavigation(tag: nil))

                // Tracking comply sheet presentation
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: Binding<Bool>(
                        get: { viewStore.routeTag == .complyTracking },
                        set: { show in
                            if !show { viewStore.send(.setNavigation(tag: nil)) }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        TrackingComplyView(store: store)
                    })
                    .hidden()
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: Binding<Bool>(get: {
                        viewStore.profilesRouteTag == .newProfile
                    }, set: { show in
                        if !show {
                            viewStore.send(.profiles(action: .setNavigation(tag: nil)))
                        }
                    }),
                    onDismiss: {},
                    content: {
                        IfLetStore(newProfileStore, then: NewProfileView.init)
                    })
                    .hidden()
                    .accessibility(hidden: true)

                NavigationLink(
                    destination: IfLetStore(profileStore) { profileStore in
                        EditProfileView(store: profileStore)
                    },
                    tag: ProfilesDomain.Route.Tag.editProfile, // swiftlint:disable:next trailing_closure
                    selection: viewStore.binding(get: \.profilesRouteTag, send: { tag in
                        SettingsDomain.Action.profiles(action: .setNavigation(tag: tag))
                    })
                ) {}
                    .hidden()
                    .accessibility(hidden: true)

                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\SettingsDomain.State.route)
                                .appending(path: /SettingsDomain.Route.setAppPassword)
                                .extract(from:),
                            action: SettingsDomain.Action.createPassword(action:)
                        )
                    ) { createStore in
                        CreatePasswordView(store: createStore)
                    },
                    tag: SettingsDomain.Route.Tag.setAppPassword,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {}
                    .hidden()
                    .accessibility(hidden: true)
            }
            .accentColor(Colors.primary600)
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .navigationTitle(L10n.stgTxtTitle)
            .demoBanner(isPresented: viewStore.isDemoMode)
            .alert(
                self.store
                    .scope(state: (\SettingsDomain.State.route).appending(path: /SettingsDomain.Route.alert)
                        .extract(from:)),
                dismiss: .setNavigation(tag: .none)
            )
            .onAppear {
                viewStore.send(.initSettings)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
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
            SingleElementSectionContainer(
                header: {
                    Label(title: { Text(L10n.stgTxtHeaderDemoMode) }, icon: {})
                        .accessibilityIdentifier(A18n.settings.demo.stgTxtHeaderDemoMode)
                }, footer: {
                    Label(title: { Text(L10n.stgTxtFootnoteDemoMode) }, icon: {})
                        .accessibilityIdentifier(A18n.settings.demo.stgTxtFootnoteDemoMode)
                }, content: {
                    Toggle(isOn: viewStore.binding(
                        get: \.isDemoMode,
                        send: SettingsDomain.Action.toggleDemoModeSwitch
                    )
                    .animation()) {
                            Label(L10n.stgTxtDemoMode, systemImage: SFSymbolName.wandAndStars)
                    }
                    .accessibilityIdentifier(A18n.settings.demo.stgTxtDemoMode)
                }
            )
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
            SingleElementSectionContainer(header: {
                HeaderView()
            }, footer: {
                Label(title: {
                    Text(viewStore.state.isDemoMode ?
                        L10n.stgTrkTxtFootnoteDisabled : L10n.stgTrkTxtFootnote)
                }, icon: {})
                    .accessibilityIdentifier(A18n.settings.tracking.stgTrkTxtFootnote)
            }, content: {
                Toggle(isOn: viewStore.binding(
                    get: \.trackerOptIn,
                    send: SettingsDomain.Action.toggleTrackingTapped
                )
                .animation()) {
                        Label(title: {
                            Text(L10n.stgTrkBtnTitle)
                        }, icon: { Image(systemName: SFSymbolName.waveformEcg) })
                            .accessibilityIdentifier(A18n.settings.tracking.stgTrkBtnTitle)
                }
                .disabled(viewStore.state.isDemoMode)
                .buttonStyle(.navigation)
            })
        }

        private struct HeaderView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 16) {
                    Label(title: { Text(L10n.stgTrkTxtTitle) }, icon: {})
                        .accessibility(identifier: A11y.settings.tracking.stgTrkTxtTitle)

                    // [REQ:gemSpec_eRp_FdV:A_19089] User info for usage tracking
                    Label(title: { Text(L10n.stgTrkTxtExplanation) }, icon: {})
                        .font(.body)
                        .accessibilityIdentifier(A11y.settings.tracking.stgTrkTxtExplanation)
                }
            }
        }
    }

    #if ENABLE_DEBUG_VIEW
    private struct DebugSectionView: View {
        let store: SettingsDomain.Store
        @ObservedObject
        var viewStore: ViewStore<ViewState, SettingsDomain.Action>

        init(store: SettingsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let routeTag: SettingsDomain.Route.Tag?

            init(state: SettingsDomain.State) {
                routeTag = state.route?.tag
            }
        }

        var body: some View {
            SingleElementSectionContainer(header: {
                Label(title: {
                    Text("Debug")
                }, icon: {})
                    .accessibilityIdentifier("stg_txt_debug_title")
            }, content: {
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\SettingsDomain.State.route)
                                .appending(path: /SettingsDomain.Route.debug)
                                .extract(from:),
                            action: SettingsDomain.Action.debug(action:)
                        )
                    ) { debugStore in
                        DebugView(store: debugStore)
                    },
                    tag: SettingsDomain.Route.Tag.debug,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label("Debug", systemImage: SFSymbolName.ant)
                }
                .accessibility(identifier: "stg_btn_debug")
                .buttonStyle(.navigation)
            })
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
            SingleElementSectionContainer(header: {
                Spacer(minLength: 64)
            }, footer: {
                VersionInfoView(appVersion: viewStore.appVersion)
            }, content: {})
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
                            viewStore.send(.setNavigation(tag: nil))
                        }
                        .accessibility(identifier: A11y.settings.tracking.stgTrkBtnNo)
                        .font(Font.body.weight(.semibold))
                        .padding([.leading, .trailing, .bottom])
                    }
                }
                .navigationBarItems(
                    trailing: CloseButton { viewStore.send(.setNavigation(tag: nil)) }
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
            .accentColor(Colors.primary600)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

extension SettingsView {
    var profilesStore: ProfilesDomain.Store {
        store.scope(state: \.profiles, action: SettingsDomain.Action.profiles)
    }

    var profileStore: Store<EditProfileDomain.State?, EditProfileDomain.Action> {
        profilesStore.scope(
            state: (\ProfilesDomain.State.route)
                .appending(path: /ProfilesDomain.Route.editProfile)
                .extract(from:),
            action: ProfilesDomain.Action.profile(action:)
        )
    }

    var profilesAlertStore: Store<ErpAlertState<ProfilesDomain.Action>?, ProfilesDomain.Action> {
        profilesStore.scope(
            state: (\ProfilesDomain.State.route)
                .appending(path: /ProfilesDomain.Route.alert)
                .extract(from:)
        )
    }

    var newProfileStore: Store<NewProfileDomain.State?, NewProfileDomain.Action> {
        profilesStore.scope(
            state: (\ProfilesDomain.State.route)
                .appending(path: /ProfilesDomain.Route.newProfile)
                .extract(from:),
            action: ProfilesDomain.Action.newProfile(action:)
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            #if ENABLE_DEBUG_VIEW
            SettingsView(store: SettingsDomain.Dummies.store)
            #else
            SettingsView(store: SettingsDomain.Dummies.store)
            #endif
        }
    }
}
