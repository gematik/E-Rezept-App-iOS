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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Perception
import SwiftUI
import SwiftUIIntrospect

struct MainView: View {
    @Perception.Bindable var store: StoreOf<MainDomain>

    @State var scrollOffset: CGFloat = 0

    struct ViewState: Equatable {
        let isDemoModeEnabled: Bool
        let showTooltips: Bool

        init(state: MainDomain.State) {
            isDemoModeEnabled = state.isDemoMode
            showTooltips = state.destination == nil
        }
    }

    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                ZStack(alignment: .topLeading) {
                    PrescriptionListView(
                        store: store.scope(state: \.prescriptionListState, action: \.prescriptionList)
                    ) {
                        HorizontalProfileSelectionView(
                            store: store.scope(
                                state: \.horizontalProfileSelectionState,
                                action: \.horizontalProfileSelection
                            )
                        )
                        .accessibility(identifier: A11y.mainScreen.erxBtnProfile)
                    }

                    ExtAuthPendingView(
                        store: store.scope(
                            state: \.extAuthPendingState,
                            action: \.extAuthPending
                        )
                    )

                    MainViewNavigation(store: store)
                }
                .demoBanner(isPresented: store.isDemoMode) {
                    store.send(MainDomain.Action.turnOffDemoMode)
                }
                .smallSheet($store.scope(
                    state: \.destination?.grantChargeItemConsentDrawer,
                    action: \.destination.grantChargeItemConsentDrawer
                )) { _ in
                    GrantChargeItemConsentDrawerView(store: store)
                }
                .toast($store.scope(state: \.destination?.toast, action: \.destination.toast))
                .navigationTitle(Text(L10n.erxTitle))
                .navigationBarTitleDisplayMode(.automatic)
                .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17)) { navigationController in
                    let navigationBar = navigationController.navigationBar
                    navigationBar.barTintColor = UIColor(Colors.systemBackground)
                    let navigationBarAppearance = UINavigationBarAppearance()
                    navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)

                    if store.isDemoMode {
                        navigationBarAppearance.backgroundColor = UIColor(Colors.yellow500)
                    } else {
                        navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                    }
                    navigationBar.standardAppearance = navigationBarAppearance
                    navigationBar.compactAppearance = navigationBarAppearance
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ScanItem { store.send(.showScannerView) }
                            .embedToolbarContent()
                            .tooltip(tooltip: MainViewTooltip.scan)
                    }
                }
                .task {
                    await store.send(.subscribeToDemoModeChange).finish()
                }
                .task {
                    // [REQ:BSI-eRp-ePA:O.Arch_10#2] Trigger for the update check
                    await store.send(.checkForForcedUpdates).finish()
                }
                .onAppear {
                    // [REQ:BSI-eRp-ePA:O.Arch_6#2,O.Resi_2#2,O.Plat_1#2] trigger device security check
                    store.send(.loadDeviceSecurityView)
                    // Delay sheet animation to not interfere with Onboarding navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        store.send(.showDrawer)
                    }
                }
                .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            }
            .accentColor(Colors.primary600)
            .navigationViewStyle(StackNavigationViewStyle())
            .tooltipContainer(enabled: store.showTooltips)
        }
    }
}

extension MainDomain.State {
    var showTooltips: Bool {
        destination == nil
    }
}

// swiftlint:disable:next no_extension_access_modifier
private extension MainView {
    // MARK: - screen related views

    struct ScanItem: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: SFSymbolName.plusCircleFill)
                    .font(Font.title3.weight(.bold))
                    .foregroundColor(Colors.primary700)
            }
            .buttonStyle(.borderless)
            .accessibility(identifier: A18n.mainScreen.erxBtnScnPrescription)
            .accessibility(label: Text(L10n.erxBtnScnPrescription))
        }
    }

    struct MainViewNavigation: View {
        @Perception.Bindable var store: StoreOf<MainDomain>

        var body: some View {
            WithPerceptionTracking {
                // WelcomeDrawerView small sheet presentation
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(
                            state: \.destination?.welcomeDrawer,
                            action: \.destination.toast
                        )
                    ) { _ in
                        WelcomeDrawerView(store: store)
                    }
                    .accessibilityHidden(true)

                // ScannerView sheet presentation; Work around not being able to use multiple
                // `fullScreenCover` modifier at once. As soon as we drop iOS <= ~14.4, we may omit this.
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .fullScreenCover(
                        item: $store.scope(
                            state: \.destination?.scanner,
                            action: \.destination.scanner
                        )
                    ) { store in
                        ErxTaskScannerView(store: store)
                    }
                    .hidden()
                    .accessibility(hidden: true)

                // Device security sheet presentation; Work around not being able to use multiple
                // `fullScreenCover` modifier at once. As soon as we drop iOS <= ~14.4, we may omit this.
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(
                        item: $store.scope(
                            state: \.destination?.deviceSecurity,
                            action: \.destination.deviceSecurity
                        )
                    ) { store in
                        DeviceSecurityView(store: store)
                    }
                    .hidden()
                    .accessibility(hidden: true)

                // Navigation into details
                NavigationLink(
                    item: $store.scope(
                        state: \.destination?.prescriptionDetail,
                        action: \.destination.prescriptionDetail
                    )
                ) { store in
                    PrescriptionDetailView(store: store)
                } label: {
                    EmptyView()
                }
                .accessibility(hidden: true)

                // Navigation into archived prescriptions
                NavigationLink(
                    item: $store.scope(
                        state: \.destination?.prescriptionArchive,
                        action: \.destination.prescriptionArchive
                    )
                ) { store in
                    PrescriptionArchiveView(store: store)
                } label: {
                    EmptyView()
                }
                .accessibility(hidden: true)

                // RedeemMethodsView sheet presentation
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .fullScreenCover(
                        item: $store.scope(
                            state: \.destination?.redeemMethods,
                            action: \.destination.redeemMethods
                        )
                    ) { store in
                        RedeemMethodsView(store: store)
                    }
                    .accessibility(hidden: true)
                    .hidden()

                // CardWallIntroductionView sheet presentation
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .fullScreenCover(
                        item: $store.scope(
                            state: \.destination?.cardWall,
                            action: \.destination.cardWall
                        )
                    ) { store in
                        CardWallIntroductionView(store: store)
                    }
                    .accessibility(hidden: true)
                    .hidden()

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(
                            state: \.destination?.createProfile,
                            action: \.destination.createProfile
                        )
                    ) { store in
                        CreateProfileView(store: store)
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(
                            state: \.destination?.editProfileName,
                            action: \.destination.editProfileName
                        )
                    ) { store in
                        EditProfileNameView(store: store)
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(
                            state: \.destination?.editProfilePicture,
                            action: \.destination.editProfilePicture
                        )
                    ) { store in
                        EditProfilePictureView(store: store)
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(
                            state: \.destination?.medicationReminder,
                            action: \.destination.medicationReminder
                        )
                    ) { store in
                        MedicationReminderOneDaySummaryView(store: store)
                    }
                    .accessibility(hidden: true)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(
                store: StoreOf<MainDomain>(
                    initialState: .init(
                        destination: .createProfile(CreateProfileDomain.State()),
                        prescriptionListState: PrescriptionListDomain.State(),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                    )
                ) {
                    MainDomain()
                }
            )
            .preferredColorScheme(.light)

            MainView(
                store: StoreOf<MainDomain>(
                    initialState: .init(
                        prescriptionListState: PrescriptionListDomain.State(
                            prescriptions: Prescription.Dummies.prescriptions
                        ),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
                    )
                ) {
                    MainDomain()
                }
            )
            .preferredColorScheme(.light)

            MainView(store: MainDomain.Dummies.store)
                .preferredColorScheme(.light)

            MainView(store: MainDomain.Dummies.store)
                .previewDevice("iPod touch (7th generation)")
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
        }
    }
}
