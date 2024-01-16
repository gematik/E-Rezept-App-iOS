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
import eRpKit
import SwiftUI

struct PrescriptionListView<StickyHeader: View>: View {
    let store: PrescriptionListDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionListDomain.Action>

    let header: StickyHeader

    init(store: PrescriptionListDomain.Store, @ViewBuilder header: @escaping () -> StickyHeader) {
        self.store = store
        self.header = header()
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let isLoading: Bool
        let showError: Bool
        let openPrescription: [Prescription]
        let error: PrescriptionRepositoryError?

        init(state: PrescriptionListDomain.State) {
            isLoading = state.loadingState.isLoading
            showError = state.loadingState.error != nil
            error = state.loadingState.error
            openPrescription = state.prescriptions.filter { !$0.isArchived }
        }
    }

    var body: some View {
        RefreshScrollView(
            store: store,
            content: {
                if viewStore.openPrescription.isEmpty {
                    PrescriptionListEmptyView(store: store)
                } else {
                    ListView(store: store)
                }
            },
            header: {
                header
            }, action: {
                viewStore.send(.redeemButtonTapped(
                    openPrescriptions: viewStore.openPrescription
                ))
            }
        )
        .onAppear {
            viewStore.send(.registerActiveUserProfileListener)
            viewStore.send(.registerSelectedProfileIDListener)
        }
        .onDisappear {
            viewStore.send(.unregisterActiveUserProfileListener)
            viewStore.send(.unregisterSelectedProfileIDListener)
        }
        .alert(
            L10n.alertErrorTitle.key,
            isPresented: viewStore.binding(
                get: \.showError,
                send: PrescriptionListDomain.Action.alertDismissButtonTapped
            ),
            actions: {
                Button(L10n.alertBtnOk) {
                    viewStore.send(.alertDismissButtonTapped)
                }
            },
            message: {
                Text(viewStore.error?
                    .localizedDescriptionWithErrorList ?? "alert_error_message_unknown")
            }
        )
    }

    private struct ListView: View {
        let store: PrescriptionListDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionListDomain.Action>

        init(store: PrescriptionListDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let profile: UserProfile?
            let openPrescription: [Prescription]
            let hasArchivedPrescriptions: Bool

            init(state: PrescriptionListDomain.State) {
                profile = state.profile
                openPrescription = state.prescriptions.filter { !$0.isArchived }
                hasArchivedPrescriptions = state.prescriptions.first(where: \.isArchived) != nil
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                ListHeaderView(store: store)
                    .padding(.bottom, 4)

                VStack(spacing: 16) {
                    ForEach(viewStore.openPrescription) { prescription in
                        PrescriptionView(
                            prescription: prescription
                        ) {
                            viewStore
                                .send(.prescriptionDetailViewTapped(selectedPrescription: prescription))
                        }
                    }
                }
                .padding()

                if let date = viewStore.profile?.lastSuccessfulSync {
                    RelativeTimerView(date: date)
                        .font(.footnote)
                        .foregroundColor(Colors.textSecondary)
                }

                if viewStore.hasArchivedPrescriptions {
                    Button {
                        viewStore
                            .send(.showArchivedButtonTapped)
                    } label: {
                        Text(L10n.mainBtnArchivedPresc)
                            .font(.subheadline.weight(.semibold))
                    }
                    .accessibilityIdentifier(A11y.mainScreen.erxBtnArcPrescription)
                    .padding(.top, 28)
                    .padding(.bottom)
                }
            }
        }
    }

    private struct ListHeaderView: View {
        let store: PrescriptionListDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionListDomain.Action>

        init(store: PrescriptionListDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let profile: UserProfile?
            let isConnected: Bool

            init(state: PrescriptionListDomain.State) {
                profile = state.profile
                isConnected = profile?.connectionStatus == .connected
            }
        }

        var body: some View {
            HStack {
                ProfilePictureView(
                    image: viewStore.profile?.image,
                    userImageData: viewStore.profile?.userImageData,
                    color: viewStore.profile?.color,
                    connection: viewStore.profile?.connectionStatus,
                    style: .small
                ) {
                    if let profile = viewStore.profile {
                        viewStore.send(.profilePictureViewTapped(profile))
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                Spacer()

                Button {
                    viewStore.send(.refresh)
                } label: {
                    if viewStore.isConnected {
                        Image(systemName: SFSymbolName.refresh)
                    } else {
                        Text(L10n.mainBtnLogin)
                    }
                }
                .buttonStyle(.quartary)
                .accessibilityIdentifier(viewStore.isConnected ? A11y.mainScreen.erxBtnRefresh : A11y.mainScreen
                    .erxBtnLogin)
            }
            .padding(.top, 38)
            .padding(.horizontal)
        }
    }
}

struct PrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                PrescriptionListView(
                    store: PrescriptionListDomain.Store(
                        initialState: PrescriptionListDomain.Dummies.stateWithPrescriptions
                    ) {
                        PrescriptionListDomain()
                    }
                ) {
                    Text("Header")
                }
            }.preferredColorScheme(.light)

            VStack {
                PrescriptionListView(
                    store: PrescriptionListDomain.Store(
                        initialState: PrescriptionListDomain.Dummies.state
                    ) { PrescriptionListDomain()
                    }
                ) {
                    Text("Header")
                }
            }
            .preferredColorScheme(.light)

            VStack {
                PrescriptionListView(store: PrescriptionListDomain.Dummies.store) {
                    Text("Header")
                }
            }
            .previewDevice("iPod touch (7th generation)")
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)

            VStack {
                PrescriptionListView(
                    store: PrescriptionListDomain.Dummies.storeFor(
                        PrescriptionListDomain.State(
                            prescriptions: Prescription.Dummies.prescriptions
                        )
                    )
                ) {
                    Text("Header")
                }
            }
            .preferredColorScheme(.light)

            VStack {
                PrescriptionListView(
                    store: PrescriptionListDomain.Dummies.storeFor(
                        PrescriptionListDomain.State(
                            prescriptions: Prescription.Dummies.prescriptions
                        )
                    )
                ) {
                    Text("Header")
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
