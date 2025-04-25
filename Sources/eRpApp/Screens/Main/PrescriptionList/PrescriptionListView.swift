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
import eRpStyleKit
import SwiftUI

struct PrescriptionListView<StickyHeader: View>: View {
    @Perception.Bindable var store: StoreOf<PrescriptionListDomain>

    let header: StickyHeader

    init(store: StoreOf<PrescriptionListDomain>, @ViewBuilder header: @escaping () -> StickyHeader) {
        self.store = store
        self.header = header()
    }

    var body: some View {
        WithPerceptionTracking {
            RefreshScrollView(
                store: store,
                content: {
                    if store.openPrescriptions.isEmpty {
                        PrescriptionListEmptyView(store: store)
                            .transition(.opacity.animation(.easeOut(duration: 0.2)))
                    } else {
                        ListView(store: store)
                            .transition(.opacity.animation(.easeOut(duration: 0.2)))
                    }
                },
                header: {
                    header
                }, action: {
                    store.send(.redeemButtonTapped(
                        openPrescriptions: store.openPrescriptions
                    ))
                }
            )
            .onAppear {
                store.send(.registerActiveUserProfileListener)
            }
            .onDisappear {
                store.send(.unregisterActiveUserProfileListener)
            }
            .alert(
                L10n.alertErrorTitle.key,
                isPresented: .init(get: {
                    store.showError
                }, set: { show in
                    if !show {
                        store.send(.alertDismissButtonTapped)
                    }
                }),
                actions: {
                    Button(L10n.alertBtnOk) {
                        store.send(.alertDismissButtonTapped)
                    }
                },
                message: {
                    Text(store.loadingState.error?
                        .localizedDescriptionWithErrorList ?? "alert_error_message_unknown")
                }
            )
        }
    }

    private struct ListView: View {
        @Perception.Bindable var store: StoreOf<PrescriptionListDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack(spacing: 0) {
                    ListHeaderView(store: store)
                        .padding(.bottom, 4)

                    VStack(spacing: 16) {
                        ForEach(store.openPrescriptions) { prescription in
                            PrescriptionView(
                                prescription: prescription
                            ) {
                                store.send(.prescriptionDetailViewTapped(selectedPrescription: prescription))
                            }
                        }
                    }
                    .padding()

                    if let date = store.profile?.lastSuccessfulSync {
                        RelativeTimerView(date: date)
                            .font(.footnote)
                            .foregroundColor(Colors.textSecondary)
                    }

                    if store.hasArchivedPrescriptions {
                        Button {
                            store.send(.showArchivedButtonTapped)
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
    }

    private struct ListHeaderView: View {
        @Perception.Bindable var store: StoreOf<PrescriptionListDomain>

        var body: some View {
            WithPerceptionTracking {
                HStack {
                    ProfilePictureView(
                        image: store.profile?.image,
                        userImageData: store.profile?.userImageData,
                        color: store.profile?.color,
                        connection: store.profile?.connectionStatus,
                        style: .small
                    ) {
                        if let profile = store.profile {
                            store.send(.profilePictureViewTapped(profile))
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    Spacer()

                    Button {
                        store.send(.refresh)
                    } label: {
                        if store.isConnected {
                            Image(systemName: SFSymbolName.refresh)
                        } else {
                            Text(L10n.mainBtnLogin)
                        }
                    }
                    .buttonStyle(.quartary)
                    .accessibilityIdentifier(store.isConnected ? A11y.mainScreen.erxBtnRefresh : A11y.mainScreen
                        .erxBtnLogin)
                }
                .padding(.top, 38)
                .padding(.horizontal)
            }
        }
    }
}

struct PrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                PrescriptionListView(
                    store: StoreOf<PrescriptionListDomain>(
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
                    store: StoreOf<PrescriptionListDomain>(
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
