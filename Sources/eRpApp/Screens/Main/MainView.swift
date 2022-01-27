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
import Introspect
import SwiftUI

struct MainView: View {
    let store: MainDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, MainDomain.Action>
    @State
    var formattedString: String?

    init(store: MainDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let isScannerViewPresented: Bool
        let isDeviceSecurityViewPresented: Bool
        let isDemoModeEnabled: Bool

        let route: MainDomain.Route?
        let profile: UserProfile?

        init(state: MainDomain.State) {
            isScannerViewPresented = state.scannerState != nil
            isDeviceSecurityViewPresented = state.deviceSecurityState != nil
            isDemoModeEnabled = state.isDemoMode
            route = state.route
            profile = state.profile
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
                        .accessibility(hidden: viewStore.isScannerViewPresented)

                    ExtAuthPendingView(
                        store: store.scope(
                            state: \.extAuthPendingState,
                            action: MainDomain.Action.extAuthPending(action:)
                        )
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        UserProfileSelectionItem(store: store, formattedString: $formattedString)
                            .accessibility(value: Text(formattedString ?? ""))
                            .accessibilityElement(children: .combine)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        ScanItem { viewStore.send(.showScannerView) }
                    }
                }

                // ScannerView sheet presentation; Work around not being able to use multiple `fullScreenCover` modifier
                // at once. As soon as we drop iOS <= ~14.4, we may omit this.
                EmptyView()
                    .fullScreenCover(isPresented: viewStore.binding(
                        get: \.isScannerViewPresented,
                        send: MainDomain.Action.dismissScannerView
                    )) {
                        IfLetStore(
                            store.scope(
                                state: { $0.scannerState },
                                action: MainDomain.Action.scanner(action:)
                            ),
                            then: ErxTaskScannerView.init(store:)
                        )
                    }

                // Device security sheet presentation; Work around not being able to use multiple `fullScreenCover`
                // modifier at once. As soon as we drop iOS <= ~14.4, we may omit this.
                EmptyView()
                    .sheet(
                        isPresented: viewStore.binding(
                            get: \.isDeviceSecurityViewPresented,
                            send: MainDomain.Action.dismissDeviceSecurityView
                        )
                    ) {
                        IfLetStore(
                            store.scope(
                                state: { $0.deviceSecurityState },
                                action: MainDomain.Action.deviceSecurity(action:)
                            ),
                            then: DeviceSecurityView.init(store:)
                        )
                    }

                EmptyView()
                    .sheet(isPresented: Binding<Bool>(get: {
                        viewStore.route?.tag == .selectProfile
                    }, set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }),
                    onDismiss: {},
                    content: {
                        IfLetStore(store.scope(
                            state: (\MainDomain.State.route)
                                .appending(path: /MainDomain.Route.selectProfile)
                                .extract(from:),
                            action: MainDomain.Action.selectProfile(action:)
                        ), then: ProfileSelectionView.init)
                    })
            }
            .navigationBarTitleDisplayMode(.inline)
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
                viewStore.send(.registerProfileListener)
                viewStore.send(.subscribeToDemoModeChange)
                viewStore.send(.loadDeviceSecurityView)
            }
            .onDisappear {
                viewStore.send(.unregisterProfileListener)
                viewStore.send(.unsubscribeFromDemoModeChange)
            }
        }
        .accentColor(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// swiftlint:disable no_extension_access_modifier
private extension MainView {
    // MARK: - screen related views

    struct UserProfileSelectionItem: View {
        let store: MainDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, MainDomain.Action>

        init(store: MainDomain.Store, formattedString: Binding<String?>) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
            _formattedString = formattedString
        }

        struct ViewState: Equatable {
            let profile: UserProfile?

            init(state: MainDomain.State) {
                profile = state.profile
            }
        }

        @Binding
        var formattedString: String?
        let maxCharacterLength = 16

        var body: some View {
            Button(action: {
                viewStore.send(.showProfileSelection)
            }, label: {
                if let profile = viewStore.profile {
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .strokeBorder(profile.color.border, lineWidth: 2)
                            .frame(width: 32, height: 32, alignment: .center)
                            .background(Circle().fill(profile.color.background))
                            .overlay(
                                Text(profile.emoji ?? profile.acronym)
                                    .font(.system(size: 13))
                            )
                            .overlay(ProfileCell.ConnectionStatusCircle(status: profile.connectionStatus),
                                     alignment: .bottomTrailing)

                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .center, spacing: 4) {
                                Text(profile.name.prefix(maxCharacterLength).trimmingCharacters(in: .whitespaces))
                                    .font(.subheadline.weight(.semibold))
                                Image(systemName: SFSymbolName.chevronForward)
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundColor(Color(.label))

                            if let date = profile.lastSuccessfulSync {
                                RelativeTimerViewForToolbars(date: date, formattedString: $formattedString)
                                    .foregroundColor(Color(.secondaryLabel))
                                    .font(.caption)
                            } else {
                                Text(L10n.proTxtSelectionProfileNotConnected)
                                    .foregroundColor(Color(.secondaryLabel))
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } else {
                    ProgressView()
                }
            })
                .contentShape(Rectangle())
                .accessibility(identifier: A18n.mainScreen.erxBtnProfile)
        }
    }

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
                )
            )
            .preferredColorScheme(.light)

            MainView(
                store: MainDomain.Dummies.storeFor(
                    MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(
                            groupedPrescriptions: Array(
                                repeating: GroupedPrescription.Dummies.twoPrescriptions,
                                count: 2
                            )
                        )
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
