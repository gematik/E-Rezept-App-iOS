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
import Introspect
import SwiftUI

struct MainView: View {
    let store: MainDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, MainDomain.Action>
    @State var scrollOffset: CGFloat = 0

    init(store: MainDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let isDemoModeEnabled: Bool
        let destinationTag: MainDomain.Destinations.State.Tag?
        let showTooltips: Bool

        init(state: MainDomain.State) {
            isDemoModeEnabled = state.isDemoMode
            destinationTag = state.destination?.tag
            showTooltips = state.destination == nil
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                PrescriptionListView(
                    store: store.scope(
                        state: \.prescriptionListState,
                        action: MainDomain.Action.prescriptionList(action:)
                    )
                ) {
                    HorizontalProfileSelectionView(
                        store: store.scope(
                            state: \.horizontalProfileSelectionState,
                            action: MainDomain.Action.horizontalProfileSelection(action:)
                        )
                    )
                    .accessibility(identifier: A11y.mainScreen.erxBtnProfile)
                }
                // Workaround to get correct accessibility while activating voice over *after*
                // presentation of settings dialog. As soon as we can use multiple `fullScreenCover`
                // (drop iOS <= ~14.4) we may omit this modifier and the `EmptyView()`.
                .accessibility(hidden: viewStore.destinationTag != nil)

                ExtAuthPendingView(
                    store: store.scope(
                        state: \.extAuthPendingState,
                        action: MainDomain.Action.extAuthPending(action:)
                    )
                )

                MainViewNavigation(store: store)
            }
            .demoBanner(isPresented: viewStore.isDemoModeEnabled) {
                viewStore.send(MainDomain.Action.turnOffDemoMode)
            }
            .smallSheet(
                isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .grantChargeItemConsentDrawer },
                    set: { show in
                        if !show,
                           // this distinction is necessary or else .toast state would be nilled out unwantedly
                           viewStore.destinationTag == .grantChargeItemConsentDrawer {
                            viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    GrantChargeItemConsentDrawerView(store: store)
                }
            )
            .toast(
                store.scope(state: \.$destination, action: MainDomain.Action.destination),
                state: /MainDomain.Destinations.State.toast,
                action: MainDomain.Destinations.Action.toast
            )

            .navigationTitle(Text(L10n.erxTitle))
            .navigationBarTitleDisplayMode(.automatic)
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)

                if viewStore.isDemoModeEnabled,
                   let yellow = UIColor(named: Asset.Colors.yellow500.name) {
                    navigationBarAppearance.backgroundColor = yellow
                } else {
                    navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                }
                navigationBar.standardAppearance = navigationBarAppearance
                navigationBar.compactAppearance = navigationBarAppearance
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ScanItem { viewStore.send(.showScannerView) }
                        .embedToolbarContent()
                        .tooltip(tooltip: MainViewTooltip.scan)
                }
            }
            .task {
                await viewStore.send(.subscribeToDemoModeChange).finish()
            }
            .onAppear {
                // [REQ:BSI-eRp-ePA:O.Arch_6#2,O.Resi_2#2,O.Plat_1#2] trigger device security check
                viewStore.send(.loadDeviceSecurityView)
                // Delay sheet animation to not interfere with Onboarding navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewStore.send(.showDrawer)
                }
            }
            .alert(
                store.scope(state: \.$destination, action: MainDomain.Action.destination),
                state: /MainDomain.Destinations.State.alert,
                action: MainDomain.Destinations.Action.alert
            )
        }
        .accentColor(Colors.primary600)
        .navigationViewStyle(StackNavigationViewStyle())
        .tooltipContainer(enabled: viewStore.showTooltips)
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
        let store: MainDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, MainDomain.Action>

        init(store: MainDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let destinationTag: MainDomain.Destinations.State.Tag?

            init(state: MainDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        var body: some View {
            // WelcomeDrawerView small sheet presentation
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .welcomeDrawer },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    WelcomeDrawerView(store: store)
                })
                .accessibilityHidden(true)

            // ScannerView sheet presentation; Work around not being able to use multiple
            // `fullScreenCover` modifier at once. As soon as we drop iOS <= ~14.4, we may omit this.
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .scanner },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.scope(state: \.$destination, action: MainDomain.Action.destination),
                        state: /MainDomain.Destinations.State.scanner,
                        action: MainDomain.Destinations.Action.scanner(action:),
                        then: ErxTaskScannerView.init(store:)
                    )
                })
                .hidden()
                .accessibility(hidden: true)

            // Device security sheet presentation; Work around not being able to use multiple
            // `fullScreenCover` modifier at once. As soon as we drop iOS <= ~14.4, we may omit this.
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .sheet(
                    isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .deviceSecurity },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        IfLetStore(
                            store.scope(state: \.$destination, action: MainDomain.Action.destination),
                            state: /MainDomain.Destinations.State.deviceSecurity,
                            action: MainDomain.Destinations.Action.deviceSecurity(action:),
                            then: DeviceSecurityView.init(store:)
                        )
                    }
                )
                .hidden()
                .accessibility(hidden: true)

            // Navigation into details
            NavigationLinkStore(
                store.scope(state: \.$destination, action: MainDomain.Action.destination),
                state: /MainDomain.Destinations.State.prescriptionDetail,
                action: MainDomain.Destinations.Action.prescriptionDetailAction(action:),
                onTap: { viewStore.send(.setNavigation(tag: .prescriptionDetail)) },
                destination: PrescriptionDetailView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // Navigation into archived prescriptions
            NavigationLinkStore(
                store.scope(state: \.$destination, action: MainDomain.Action.destination),
                state: /MainDomain.Destinations.State.prescriptionArchive,
                action: MainDomain.Destinations.Action.prescriptionArchiveAction(action:),
                onTap: { viewStore.send(.setNavigation(tag: .prescriptionArchive)) },
                destination: PrescriptionArchiveView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // RedeemMethodsView sheet presentation
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .redeem },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.scope(state: \.$destination, action: MainDomain.Action.destination),
                        state: /MainDomain.Destinations.State.redeem,
                        action: MainDomain.Destinations.Action.redeemMethods(action:),
                        then: RedeemMethodsView.init(store:)
                    )
                })
                .accessibility(hidden: true)
                .hidden()

            // CardWallIntroductionView sheet presentation
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .cardWall },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.scope(state: \.$destination, action: MainDomain.Action.destination),
                        state: /MainDomain.Destinations.State.cardWall,
                        action: MainDomain.Destinations.Action.cardWall(action:),
                        then: CardWallIntroductionView.init(store:)
                    )
                })
                .accessibility(hidden: true)
                .hidden()

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(
                    isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .createProfile },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        ZStack {
                            IfLetStore(
                                store.scope(state: \.$destination, action: MainDomain.Action.destination),
                                state: /MainDomain.Destinations.State.createProfile,
                                action: MainDomain.Destinations.Action.createProfileAction(action:),
                                then: CreateProfileView.init(store:)
                            )
                        }
                    }
                )
                .accessibility(hidden: true)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(
                    isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .editName },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        ZStack {
                            IfLetStore(
                                store.scope(state: \.$destination, action: MainDomain.Action.destination),
                                state: /MainDomain.Destinations.State.editName,
                                action: MainDomain.Destinations.Action.editProfileNameAction(action:),
                                then: EditProfileNameView.init(store:)
                            )
                        }
                    }
                )
                .accessibility(hidden: true)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(
                    isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .editProfilePicture },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        IfLetStore(
                            store.scope(state: \.$destination, action: MainDomain.Action.destination),
                            state: /MainDomain.Destinations.State.editProfilePicture,
                            action: MainDomain.Destinations.Action.editProfilePictureAction(action:),
                            then: EditProfilePictureView.init(store:)
                        )
                    }
                )
                .accessibility(hidden: true)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(
                    isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .medicationReminder },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        IfLetStore(
                            store.scope(state: \.$destination, action: MainDomain.Action.destination),
                            state: /MainDomain.Destinations.State.medicationReminder,
                            action: MainDomain.Destinations.Action.medicationReminder(action:),
                            then: MedicationReminderOneDaySummaryView.init(store:)
                        )
                    }
                )
                .accessibility(hidden: true)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(
                store: MainDomain.Store(
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
                store: MainDomain.Store(
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
