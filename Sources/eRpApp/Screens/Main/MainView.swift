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
        let routeTag: MainDomain.Route.Tag?
        var isNotLoading: Bool

        init(state: MainDomain.State) {
            isDemoModeEnabled = state.isDemoMode
            routeTag = state.route?.tag
            isNotLoading = !state.prescriptionListState.loadingState.isLoading
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                PrescriptionListView(store: store.scope(
                    state: \.prescriptionListState,
                    action: MainDomain.Action.prescriptionList(action:)
                ))
                    .introspectScrollView { scrollView in
                        let refreshControl: RefreshControl
                        if let control = scrollView.refreshControl as? RefreshControl {
                            refreshControl = control
                        } else {
                            refreshControl = RefreshControl()
                            scrollView.refreshControl = refreshControl
                        }
                        refreshControl.onRefreshAction = {
                            viewStore.send(.refreshPrescription)
                        }
                        if viewStore.isNotLoading, refreshControl.isRefreshing {
                            refreshControl.endRefreshing()
                        }
                    }
                    // Workaround to get correct accessibility while activating voice over *after*
                    // presentation of settings dialog. As soon as we can use multiple `fullScreenCover`
                    // (drop iOS <= ~14.4) we may omit this modifier and the `EmptyView()`.
                    .accessibility(hidden: viewStore.routeTag != nil)

                HorizontalProfileSelectionView(
                    store: store.scope(
                        state: \.horizontalProfileSelectionState,
                        action: MainDomain.Action.horizontalProfileSelection(action:)
                    )
                )
                .padding(.horizontal)
                .offset(x: 0, y: max(scrollOffset, 0))
                .accessibility(identifier: A11y.mainScreen.erxBtnProfile)

                ExtAuthPendingView(
                    store: store.scope(
                        state: \.extAuthPendingState,
                        action: MainDomain.Action.extAuthPending(action:)
                    )
                )

                MainViewNavigation(store: store)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ScanItem { viewStore.send(.showScannerView) }
                        .embedToolbarContent()
                }
            }
            .onPreferenceChange(ViewOffsetKey.self) {
                scrollOffset = $0
            }
            .navigationTitle(Text(L10n.erxTitle))
            .navigationBarTitleDisplayMode(viewStore.isDemoModeEnabled ? .inline : .automatic)
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
            }
            .demoBanner(isPresented: viewStore.isDemoModeEnabled) {
                viewStore.send(MainDomain.Action.turnOffDemoMode)
            }
            .onAppear {
                viewStore.send(.subscribeToDemoModeChange)
                viewStore.send(.loadDeviceSecurityView)
            }
            .onDisappear {
                viewStore.send(.unsubscribeFromDemoModeChange)
            }
            .alert(
                self.store
                    .scope(state: (\MainDomain.State.route).appending(path: /MainDomain.Route.alert)
                        .extract(from:)),
                dismiss: .setNavigation(tag: .none)
            )
        }
        .accentColor(Colors.primary600)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    struct MainViewNavigation: View {
        let store: MainDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, MainDomain.Action>

        init(store: MainDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let routeTag: MainDomain.Route.Tag?

            init(state: MainDomain.State) {
                routeTag = state.route?.tag
            }
        }

        var body: some View {
            // ScannerView sheet presentation; Work around not being able to use multiple
            // `fullScreenCover` modifier at once. As soon as we drop iOS <= ~14.4, we may omit this.
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { viewStore.routeTag == .scanner },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.scope(
                            state: (\MainDomain.State.route)
                                .appending(path: /MainDomain.Route.scanner)
                                .extract(from:),
                            action: MainDomain.Action.scanner(action:)
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
                        get: { viewStore.routeTag == .deviceSecurity },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        IfLetStore(
                            store.scope(
                                state: (\MainDomain.State.route)
                                    .appending(path: /MainDomain.Route.deviceSecurity)
                                    .extract(from:),
                                action: MainDomain.Action.deviceSecurity(action:)
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
                    store.scope(
                        state: (\MainDomain.State.route)
                            .appending(path: /MainDomain.Route.prescriptionDetail)
                            .extract(from:),
                        action: MainDomain.Action.prescriptionDetailAction(action:)
                    )
                ) { scopedStore in
                    WithViewStore(scopedStore.scope(state: \.prescription.source)) { viewStore in
                        switch viewStore.state {
                        case .scanner: PrescriptionLowDetailView(store: scopedStore)
                        case .server: PrescriptionFullDetailView(store: scopedStore)
                        }
                    }
                },
                tag: MainDomain.Route.Tag.prescriptionDetail,
                selection: viewStore.binding(
                    get: \.routeTag,
                    send: MainDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

            // RedeemMethodsView sheet presentation
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { viewStore.routeTag == .redeem },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.scope(
                            state: (\MainDomain.State.route)
                                .appending(path: /MainDomain.Route.redeem)
                                .extract(from:),
                            action: MainDomain.Action.redeemMethods(action:)
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
                    get: { viewStore.routeTag == .cardWall },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.scope(
                            state: (\MainDomain.State.route)
                                .appending(path: /MainDomain.Route.cardWall)
                                .extract(from:),
                            action: MainDomain.Action.cardWall(action:)
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
                        get: { viewStore.routeTag == .addProfile },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        ZStack {
                            IfLetStore(
                                store.scope(
                                    state: (\MainDomain.State.route)
                                        .appending(path: /MainDomain.Route.addProfile)
                                        .extract(from:),
                                    action: MainDomain.Action.addProfileAction(action:)
                                ),
                                then: AddProfileView.init(store:)
                            )
                        }
                    }
                )
                .accessibility(hidden: true)
        }
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
                    .padding(.leading)
                    .padding(.vertical)
            }
            .accessibility(identifier: A18n.mainScreen.erxBtnScnPrescription)
            .accessibility(label: Text(L10n.erxBtnScnPrescription))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(
                store: MainDomain.Dummies.storeFor(
                    MainDomain.State(
                        prescriptionListState: PrescriptionListDomain.State(),
                        horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
                    )
                )
            )
            .preferredColorScheme(.light)

            MainView(
                store: MainDomain.Dummies.storeFor(
                    MainDomain.State(
                        prescriptionListState: PrescriptionListDomain.State(
                            groupedPrescriptions: Array(
                                repeating: GroupedPrescription.Dummies.prescriptions,
                                count: 2
                            )
                        ), horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
                    )
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
