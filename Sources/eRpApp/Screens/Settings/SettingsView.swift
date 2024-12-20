//
//  Copyright (c) 2024 gematik GmbH
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
import Perception
import SwiftUI
import SwiftUIIntrospect

struct SettingsView: View {
    @Perception.Bindable var store: StoreOf<SettingsDomain>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // [REQ:BSI-eRp-ePA:O.Source_8#3] Debug menu is only visible on debug builds
                        #if ENABLE_DEBUG_VIEW
                        DebugSectionView(store: store)
                        #endif

                        ProfilesView(store: store.scope(state: \.profiles, action: \.profiles))

                        PersonalSettingsView(store: store)

                        HealthCardSectionView(store: store)

                        TrackerSectionView(store: store)

                        SettingsExploreView(store: store)

                        SettingsContactInfoView()

                        SettingsLegalInfoView(store: store)

                        BottomSectionView(store: store)
                    }

                    // Tracking comply sheet presentation
                    // [REQ:BSI-eRp-ePA:O.Purp_5#3] Show comply view for settings triggered analytics enabling
                    // [REQ:gemSpec_eRp_FdV:A_19982#3,A_19089-01#3] Show information dialog for analytics usage
                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .sheet(item: $store.scope(
                            state: \.destination?.complyTracking,
                            action: \.destination.complyTracking
                        )) { _ in
                            TrackingComplyView(store: store)
                        }

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .sheet(item: $store.scope(
                            state: \.destination?.newProfile,
                            action: \.destination.newProfile
                        )) { store in
                            NewProfileView(store: store)
                                .accentColor(Colors.primary600)
                        }
                        .accessibility(hidden: true)
                }
                .navigationDestination(
                    item: $store.scope(state: \.destination?.editProfile,
                                       action: \.destination.editProfile)
                ) { store in
                    EditProfileView(store: store)
                }
                .navigationDestination(
                    item: $store.scope(state: \.destination?.appSecurity,
                                       action: \.destination.appSecurity)
                ) { store in
                    AppSecuritySelectionView(store: store)
                }
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.medicationReminderList,
                        action: \.destination.medicationReminderList
                    )
                ) { store in
                    MedicationReminderListView(store: store)
                }
                .accentColor(Colors.primary600)
                .background(Color(.secondarySystemBackground).ignoresSafeArea())
                .navigationTitle(L10n.stgTxtTitle)
                .demoBanner(isPresented: store.isDemoMode)
                .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
                .task {
                    await store.send(.task).finish()
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

extension SettingsView {
    private struct TrackerSectionView: View {
        @Perception.Bindable var store: StoreOf<SettingsDomain>

        var body: some View {
            SingleElementSectionContainer(header: {
                HeaderView()
            }, footer: {
                WithPerceptionTracking {
                    Label(title: {
                        Text(store.isDemoMode ?
                            L10n.stgTrkTxtFootnoteDisabled : L10n.stgTrkTxtFootnote)
                    }, icon: {})
                        .accessibilityIdentifier(A18n.settings.tracking.stgTrkTxtFootnote)
                }
            }, content: {
                WithPerceptionTracking {
                    // [REQ:gemSpec_eRp_FdV:A_19097-01#2] Toggle within Settings to enable and disable usage analytics
                    // [REQ:BSI-eRp-ePA:O.Purp_5#1] Toggle within Settings to enable and disable usage analytics
                    // [REQ:BSI-eRp-ePA:O.Purp_6#1] Current Analytics state is inspectable by the user
                    // [REQ:gemSpec_eRp_FdV:A_19982#4] Opt out of analytics
                    Toggle(isOn: $store.trackerOptIn.sending(\.toggleTrackingTapped).animation()) {
                        Label(title: {
                            Text(L10n.stgTrkBtnTitle)
                        }, icon: { Image(systemName: SFSymbolName.waveformEcg) })
                            .accessibilityIdentifier(A18n.settings.tracking.stgTrkBtnTitle)
                    }
                    .disabled(store.state.isDemoMode)
                    .buttonStyle(.navigation)
                }
            })
        }

        private struct HeaderView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 16) {
                    Label(title: { Text(L10n.stgTrkTxtTitle) }, icon: {})
                        .accessibility(identifier: A11y.settings.tracking.stgTrkTxtTitle)

                    // [REQ:gemSpec_eRp_FdV:A_19089-01#4] User info for usage analytics
                    Label(title: { Text(L10n.stgTrkTxtExplanation) }, icon: {})
                        .font(.body)
                        .accessibilityIdentifier(A11y.settings.tracking.stgTrkTxtExplanation)
                }
            }
        }
    }

    #if ENABLE_DEBUG_VIEW
    // [REQ:BSI-eRp-ePA:O.Source_8#4] DebugSectionView is only available on debug builds
    private struct DebugSectionView: View {
        @Perception.Bindable var store: StoreOf<SettingsDomain>

        var body: some View {
            SingleElementSectionContainer(header: {
                Label(title: {
                    Text("Debug")
                }, icon: {})
                    .accessibilityIdentifier("stg_txt_debug_title")
            }, content: {
                WithPerceptionTracking {
                    Button {
                        store.send(.showDebug)
                    } label: {
                        Label("Debug", systemImage: SFSymbolName.ant)
                    }
                    .accessibility(identifier: "stg_btn_debug")
                    .buttonStyle(.navigation)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.debug, action: \.destination.debug)
                    ) { store in
                        DebugView(store: store)
                    }
                }
            })
        }
    }
    #endif

    private struct BottomSectionView: View {
        @Perception.Bindable var store: StoreOf<SettingsDomain>

        var body: some View {
            SingleElementSectionContainer(header: {
                Spacer(minLength: 64)
            }, footer: {
                WithPerceptionTracking {
                    VersionInfoView(appVersion: store.appVersion)
                }
            }, content: {})
        }
    }

    struct TrackingComplyView: View {
        @Perception.Bindable var store: StoreOf<SettingsDomain>

        var body: some View {
            WithPerceptionTracking {
                NavigationStack {
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
                                store.send(.confirmedOptInTracking)
                            }
                            .font(Font.body.weight(.semibold))
                            .padding()
                            Button(L10n.stgTrkBtnAlertNo) {
                                store.send(.resetNavigation)
                            }
                            .accessibility(identifier: A11y.settings.tracking.stgTrkBtnNo)
                            .font(Font.body.weight(.semibold))
                            .padding([.leading, .trailing, .bottom])
                        }
                    }
                    .navigationBarItems(
                        trailing: CloseButton { store.send(.resetNavigation) }
                            .accessibility(identifier: A18n.redeem.overview.rdmBtnCloseButton)
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .introspect(.navigationView(style: .stack),
                                on: .iOS(.v15, .v16, .v17, .v18)) { navigationController in
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

    private struct PersonalSettingsView: View {
        @Perception.Bindable var store: StoreOf<SettingsDomain>

        var body: some View {
            WithPerceptionTracking {
                SectionContainer(
                    header: { Text(L10n.stgTxtHeaderPersonalSettings) },
                    content: {
                        Button {
                            store.send(.languageSettingsTapped)
                        } label: {
                            Label(L10n.stgBtnLanguageSettings, systemImage: SFSymbolName.globe)
                        }
                        .accessibility(identifier: A11y.settings.security.stgBtnLanguageSettings)
                        .buttonStyle(.navigation)

                        Button {
                            store.send(.showMedicationReminderList)
                        } label: {
                            Label(L10n.stgBtnMedicationReminder, systemImage: SFSymbolName.alarm)
                        }
                        .accessibility(identifier: A11y.settings.security.stgBtnMedicationReminder)
                        .buttonStyle(.navigation)

                        Button(action: {
                            store.send(.showAppSecurity)
                        }, label: {
                            Label(L10n.stgBtnDeviceSecurity, systemImage: SFSymbolName.iPhonelocked)
                        })
                            .accessibility(identifier: A11y.settings.security.stgBtnDeviceSecurity)
                            .buttonStyle(.navigation)
                    }
                )
            }
        }
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
