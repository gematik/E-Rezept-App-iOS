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

        let destinationTag: SettingsDomain.Destinations.State.Tag?

        init(state: SettingsDomain.State) {
            isDemoMode = state.isDemoMode
            destinationTag = state.destination?.tag
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
                .alert(
                    store.destinationsScope(state: /SettingsDomain.Destinations.State.alert),
                    dismiss: .setNavigation(tag: nil)
                )

                // Tracking comply sheet presentation
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .complyTracking },
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
                        viewStore.destinationTag == .newProfile
                    }, set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }),
                    onDismiss: {},
                    content: {
                        IfLetStore(
                            store.destinationsScope(
                                state: /SettingsDomain.Destinations.State.newProfile,
                                action: SettingsDomain.Destinations.Action.newProfileAction
                            ),
                            then: NewProfileView.init(store:)
                        )
                    })
                    .hidden()
                    .accessibility(hidden: true)

                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /SettingsDomain.Destinations.State.editProfile,
                            action: SettingsDomain.Destinations.Action.editProfileAction
                        ),
                        then: EditProfileView.init(store:)
                    ),
                    tag: SettingsDomain.Destinations.State.Tag.editProfile, // swiftlint:disable:next trailing_closure
                    selection: viewStore.binding(get: \.destinationTag, send: { tag in
                        SettingsDomain.Action.setNavigation(tag: tag)
                    })
                ) {}
                    .hidden()
                    .accessibility(hidden: true)

                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /SettingsDomain.Destinations.State.setAppPassword,
                            action: SettingsDomain.Destinations.Action.setAppPasswordAction
                        ),
                        then: CreatePasswordView.init(store:)
                    ),
                    tag: SettingsDomain.Destinations.State.Tag.setAppPassword,
                    selection: viewStore.binding(
                        get: \.destinationTag,
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
                store.destinationsScope(state: /SettingsDomain.Destinations.State.alert),
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
                // [REQ:gemSpec_eRp_FdV:A_19097] Toggle within Settings to enable and disable usage tracking
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
            let destinationTag: SettingsDomain.Destinations.State.Tag?

            init(state: SettingsDomain.State) {
                destinationTag = state.destination?.tag
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
                        destinationsScopedStore
                            .scope(
                                state: /SettingsDomain.Destinations.State.debug,
                                action: SettingsDomain.Destinations.Action.debugAction
                            ),
                        then: DebugView.init(store:)
                    ),
                    tag: SettingsDomain.Destinations.State.Tag.debug,
                    selection: viewStore.binding(
                        get: \.destinationTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label("Debug", systemImage: SFSymbolName.ant)
                }
                .accessibility(identifier: "stg_btn_debug")
                .buttonStyle(.navigation)
            })
        }

        var destinationsScopedStore: Store<SettingsDomain.Destinations.State?, SettingsDomain.Destinations.Action> {
            store.scope(state: \SettingsDomain.State.destination, action: SettingsDomain.Action.destination)
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            #if ENABLE_DEBUG_VIEW
            SettingsView(store: SettingsDomain.Dummies.store)
            #else
            SettingsView(store: SettingsDomain.Dummies.store)
            #endif
        }.preferredColorScheme(.dark)
    }
}
