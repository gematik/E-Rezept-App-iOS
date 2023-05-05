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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Introspect
import SwiftUI

struct MainView: View {
    let store: MainDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, MainDomain.Action>
    @State var scrollOffset: CGFloat = 0

    init(store: MainDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
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
            .onAppear {
                viewStore.send(.subscribeToDemoModeChange)
                viewStore.send(.loadDeviceSecurityView)
                // Delay sheet animation to not interfere with Onboarding navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewStore.send(.showWelcomeDrawer)
                }
            }
            .onDisappear {
                viewStore.send(.unsubscribeFromDemoModeChange)
            }
            .alert(
                store.destinationsScope(state: /MainDomain.Destinations.State.alert),
                dismiss: .nothing
            )
        }
        .accentColor(Colors.primary600)
        .navigationViewStyle(StackNavigationViewStyle())
        .tooltipContainer(enabled: viewStore.showTooltips)
    }
}

// swiftlint:disable no_extension_access_modifier
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
            viewStore = ViewStore(store.scope(state: ViewState.init))
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
                        store.destinationsScope(
                            state: /MainDomain.Destinations.State.scanner,
                            action: MainDomain.Destinations.Action.scanner(action:)
                        ),
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
                            store.destinationsScope(
                                state: /MainDomain.Destinations.State.deviceSecurity,
                                action: MainDomain.Destinations.Action.deviceSecurity(action:)
                            ),
                            then: DeviceSecurityView.init(store:)
                        )
                    }
                )
                .hidden()
                .accessibility(hidden: true)

            // Navigation into details
            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(
                        state: /MainDomain.Destinations.State.prescriptionDetail,
                        action: MainDomain.Destinations.Action.prescriptionDetailAction(action:)
                    )
                ) { scopedStore in
                    WithViewStore(scopedStore) { $0.prescription.source } content: { viewStore in
                        switch viewStore.state {
                        case .scanner: PrescriptionLowDetailView(store: scopedStore)
                        case .server: PrescriptionFullDetailView(store: scopedStore)
                        }
                    }
                },
                tag: MainDomain.Destinations.State.Tag.prescriptionDetail,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: MainDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

            // Navigation into archived prescriptions
            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(
                        state: /MainDomain.Destinations.State.prescriptionArchive,
                        action: MainDomain.Destinations.Action.prescriptionArchiveAction(action:)
                    ),
                    then: PrescriptionArchiveView.init(store:)
                ),
                tag: MainDomain.Destinations.State.Tag.prescriptionArchive,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: MainDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

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
                        store.destinationsScope(
                            state: /MainDomain.Destinations.State.redeem,
                            action: MainDomain.Destinations.Action.redeemMethods(action:)
                        ),
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
                        store.destinationsScope(
                            state: /MainDomain.Destinations.State.cardWall,
                            action: MainDomain.Destinations.Action.cardWall(action:)
                        ),
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
                                store.destinationsScope(
                                    state: /MainDomain.Destinations.State.createProfile,
                                    action: MainDomain.Destinations.Action.createProfileAction(action:)
                                ),
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
                                store.destinationsScope(
                                    state: /MainDomain.Destinations.State.editName,
                                    action: MainDomain.Destinations.Action.editProfileNameAction(action:)
                                ),
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
                        ZStack {
                            IfLetStore(
                                store.scope(
                                    state: (\MainDomain.State.destination)
                                        .appending(path: /MainDomain.Destinations.State.editProfilePicture)
                                        .extract(from:)
                                ) { .destination(.editProfilePictureAction(action: $0)) },
                                then: EditProfilePictureView.init(store:)
                            )
                        }
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
                    ),
                    reducer: MainDomain()
                )
            )
            .preferredColorScheme(.light)

            MainView(
                store: MainDomain.Store(
                    initialState: .init(
                        prescriptionListState: PrescriptionListDomain.State(
                            prescriptions: Prescription.Dummies.prescriptions
                        ),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
                    ),
                    reducer: MainDomain()
                )
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
