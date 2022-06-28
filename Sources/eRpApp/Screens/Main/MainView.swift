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
    let profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, MainDomain.Action>

    init(store: MainDomain.Store, profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
        self.profileSelectionToolbarItemStore = profileSelectionToolbarItemStore
    }

    struct ViewState: Equatable {
        let isDemoModeEnabled: Bool

        let routeTag: MainDomain.Route.Tag?

        init(state: MainDomain.State) {
            isDemoModeEnabled = state.isDemoMode
            routeTag = state.route?.tag
        }
    }

    var body: some View {
        NavigationView {
            Group {
                ZStack {
                    GroupedPrescriptionListView(store: store.scope(
                        state: \.prescriptionListState,
                        action: MainDomain.Action.prescriptionList(action:)
                    ))
                        // Workaround to get correct accessibility while activating voice over *after* presentation of
                        // settings dialog. As soon as we can use multiple `fullScreenCover` (drop iOS <= ~14.4) we may
                        // omit this modifier and the `EmptyView()`.
                        .accessibility(hidden: viewStore.routeTag != nil)

                    ExtAuthPendingView(
                        store: store.scope(
                            state: \.extAuthPendingState,
                            action: MainDomain.Action.extAuthPending(action:)
                        )
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        UserProfileSelectionToolbarItem(store: profileSelectionToolbarItemStore) {
                            viewStore.send(.setNavigation(tag: .selectProfile))
                        }
                        .embedToolbarContent()
                        .accessibility(identifier: A18n.mainScreen.erxBtnProfile)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        ScanItem { viewStore.send(.showScannerView) }
                            .embedToolbarContent()
                    }
                }

                // ScannerView sheet presentation; Work around not being able to use multiple `fullScreenCover` modifier
                // at once. As soon as we drop iOS <= ~14.4, we may omit this.
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

                // Device security sheet presentation; Work around not being able to use multiple `fullScreenCover`
                // modifier at once. As soon as we drop iOS <= ~14.4, we may omit this.
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

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: Binding<Bool>(get: {
                        viewStore.routeTag == .selectProfile
                    }, set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }),
                    onDismiss: {},
                    content: {
                        ProfileSelectionView(
                            store: profileSelectionToolbarItemStore
                                .scope(state: \.profileSelectionState,
                                       action: ProfileSelectionToolbarItemDomain.Action.profileSelection(action:))
                        )
                    })
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

                // RedeemView sheet presentation
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
                                action: MainDomain.Action.redeemView(action:)
                            ),
                            then: RedeemView.init(store:)
                        )
                    })
                    .accessibility(hidden: true)
                    .hidden()
                // CardWallView sheet presentation
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
                            then: CardWallView.init(store:)
                        )
                    })
                    .accessibility(hidden: true)
                    .hidden()
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
}

// swiftlint:disable no_extension_access_modifier
private extension MainView {
    // MARK: - screen related views

    struct ScanItem: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: SFSymbolName.camera)
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
                        prescriptionListState: GroupedPrescriptionListDomain.State()
                    )
                ),
                profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Dummies.store
            )
            .preferredColorScheme(.light)

            MainView(
                store: MainDomain.Dummies.storeFor(
                    MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(
                            groupedPrescriptions: Array(
                                repeating: GroupedPrescription.Dummies.prescriptions,
                                count: 2
                            )
                        )
                    )
                ),
                profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Dummies.store
            )
            .preferredColorScheme(.light)

            MainView(store: MainDomain.Dummies.store,
                     profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Dummies.store)
                .preferredColorScheme(.light)

            MainView(store: MainDomain.Dummies.store,
                     profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Dummies.store)
                .previewDevice("iPod touch (7th generation)")
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
        }
    }
}
