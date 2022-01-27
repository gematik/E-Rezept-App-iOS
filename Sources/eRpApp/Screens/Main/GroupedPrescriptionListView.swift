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

import ComposableArchitecture
import eRpKit
import Introspect
import SwiftUI

struct GroupedPrescriptionListView: View {
    let store: GroupedPrescriptionListDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, GroupedPrescriptionListDomain.Action>

    init(store: GroupedPrescriptionListDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let isLoading: Bool
        let showError: Bool
        let error: ErxRepositoryError?
        let showPrescriptionDetails: Bool

        let isRedeemViewPresented: Bool
        let isCardWallPresented: Bool

        init(state: GroupedPrescriptionListDomain.State) {
            isLoading = state.loadingState.isLoading
            showError = state.loadingState.error != nil
            error = state.loadingState.error

            showPrescriptionDetails = state.selectedPrescriptionDetailState != nil

            isRedeemViewPresented = state.redeemState != nil
            isCardWallPresented = state.cardWallState != nil
        }
    }

    var body: some View {
        Group {
            ListView(store: store)
                .introspectScrollView { scrollView in
                    let refreshControl: RefreshControl
                    if let control = scrollView.refreshControl as? RefreshControl {
                        refreshControl = control
                    } else {
                        refreshControl = RefreshControl()
                        scrollView.refreshControl = refreshControl
                    }
                    refreshControl.onRefreshAction = {
                        viewStore.send(.refresh)
                    }
                    if !viewStore.isLoading, refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
                .accessibility(hidden: viewStore.isRedeemViewPresented)
                .onAppear {
                    viewStore.send(.loadLocalGroupedPrescriptions)
                    viewStore.send(.loadRemoteGroupedPrescriptionsAndSave)
                }
                .onDisappear { viewStore.send(.removeSubscriptions) }
                .alert(isPresented: viewStore.binding(
                    get: \.showError,
                    send: GroupedPrescriptionListDomain.Action.alertDismissButtonTapped
                )) {
                    Alert(
                        title: Text(L10n.alertErrorTitle),
                        message: Text(viewStore.error?
                            .localizedDescription ?? "alert_error_message_unknown"),
                        dismissButton: .default(Text(L10n.alertBtnOk)) {
                            viewStore.send(.alertDismissButtonTapped)
                        }
                    )
                }

            // Navigation into details
            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: { $0.selectedPrescriptionDetailState },
                        action: GroupedPrescriptionListDomain.Action.prescriptionDetailAction(action:)
                    )
                ) { scopedStore in
                    WithViewStore(scopedStore.scope(state: \.prescription.source)) { viewStore in
                        switch viewStore.state {
                        case .scanner: PrescriptionLowDetailView(store: scopedStore)
                        case .server: PrescriptionFullDetailView(store: scopedStore)
                        }
                    }
                },
                isActive: viewStore.binding(
                    get: \.showPrescriptionDetails,
                    send: GroupedPrescriptionListDomain.Action.dismissPrescriptionDetailView
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

            // RedeemView sheet presentation
            EmptyView()
                .fullScreenCover(isPresented: viewStore.binding(
                    get: { $0.isRedeemViewPresented },
                    send: GroupedPrescriptionListDomain.Action.dismissRedeemView
                )) {
                    IfLetStore(
                        store.scope(
                            state: { $0.redeemState },
                            action: GroupedPrescriptionListDomain.Action.redeemView(action:)
                        ),
                        then: RedeemView.init(store:)
                    )
                }

            // CardWallView sheet presentation
            EmptyView()
                .fullScreenCover(isPresented: viewStore.binding(
                    get: { $0.isCardWallPresented },
                    send: GroupedPrescriptionListDomain.Action.dismissCardWall
                )) {
                    IfLetStore(
                        store.scope(
                            state: { $0.cardWallState },
                            action: GroupedPrescriptionListDomain.Action.cardWall(action:)
                        ),
                        then: CardWallView.init(store:)
                    )
                }
        }
    }
}

extension GroupedPrescriptionListView {
    struct ListView: View {
        let store: GroupedPrescriptionListDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, GroupedPrescriptionListDomain.Action>

        init(store: GroupedPrescriptionListDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let isHintViewHidden: Bool

            let groupedPrescriptionsOpen: [GroupedPrescription]
            let groupedPrescriptionsArchived: [GroupedPrescription]

            let isLoading: Bool

            init(state: GroupedPrescriptionListDomain.State) {
                isHintViewHidden = state.hintState.hint == nil
                groupedPrescriptionsOpen = state.groupedPrescriptions.filter { !$0.isArchived }
                groupedPrescriptionsArchived = state.groupedPrescriptions.filter(\.isArchived)

                isLoading = state.loadingState.isLoading
            }
        }

        var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {
                    MainHintView(store: store.scope(
                        state: { $0.hintState },
                        action: GroupedPrescriptionListDomain.Action.hint(action:)
                    ))
                        .hidden(viewStore.isHintViewHidden)

                    if viewStore.groupedPrescriptionsOpen
                        .isEmpty { HintView<GroupedPrescriptionListDomain.Action>(
                        hint: Hint(id: A18n.mainScreen.erxHntShowCardWall,
                                   title: NSLocalizedString("hint_txt_card_wall_title", comment: ""),
                                   message: NSLocalizedString("hint_txt_card_wall", comment: ""),
                                   actionText: L10n.hintBtnCardWall,
                                   action: GroupedPrescriptionListDomain.Action.refresh,
                                   imageName: Asset.Illustrations.egkBlau.name,
                                   closeAction: nil,
                                   style: .neutral,
                                   buttonStyle: .tertiary,
                                   imageStyle: .topAligned),
                        textAction: { viewStore.send(.refresh) },
                        closeAction: nil
                    )
                    }

                    CurrentSectionView(isLoading: viewStore.isLoading) {
                        viewStore.send(.refresh)
                    }

                    if !viewStore.groupedPrescriptionsOpen.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(viewStore.groupedPrescriptionsOpen) { groupedPrescription in
                                GroupedPrescriptionView(
                                    groupedPrescription: groupedPrescription,
                                    store: store
                                )
                            }
                        }
                    } else {
                        SectionPlaceholderView(text: L10n.erxTxtNoCurrentPrescriptions)
                    }

                    RedeemSectionView()

                    if !viewStore.groupedPrescriptionsArchived.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(viewStore.groupedPrescriptionsArchived) { groupedRedeemedPrescription in
                                GroupedPrescriptionView(
                                    groupedPrescription: groupedRedeemedPrescription,
                                    store: store
                                )
                            }
                        }
                    } else {
                        SectionPlaceholderView(text: L10n.erxTxtNotYetRedeemed)
                    }

                }.padding()
            }
        }

        struct CurrentSectionView: View {
            let isLoading: Bool
            let buttonPressed: () -> Void

            var body: some View {
                HStack {
                    Text(L10n.erxTxtCurrent).font(Font.title3.bold())
                    Spacer()
                    if isLoading {
                        RefreshLoadingStateView(text: L10n.erxTxtRefreshLoading)
                    } else {
                        TertiaryListButton(text: L10n.erxBtnRefresh,
                                           accessibilityIdentifier: A18n.mainScreen.erxBtnRefresh,
                                           action: buttonPressed)
                    }
                }
                .padding(.top, 24)
            }
        }

        struct RedeemSectionView: View {
            var body: some View {
                HStack {
                    Text(L10n.erxTxtRedeemed).font(Font.title3.bold())
                    Spacer()
                }
                .padding(.top, 24)
            }
        }

        struct SectionPlaceholderView: View {
            let text: LocalizedStringKey
            var body: some View {
                Text(text)
                    .foregroundColor(Color(.systemGray))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedCorner(radius: 16).foregroundColor(Colors.secondary))
            }
        }

        struct RefreshLoadingStateView: View {
            @ScaledMetric var scale: CGFloat = 1
            var text: LocalizedStringKey

            var body: some View {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.trailing, 2)
                        .scaleEffect(x: scale, y: scale, anchor: .center)
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemGray)
                }
            }
        }
    }
}

struct GroupedPrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                GroupedPrescriptionListView(
                    store: GroupedPrescriptionListDomain.Store(
                        initialState: GroupedPrescriptionListDomain.Dummies.stateWithTwoPrescriptions,
                        reducer: GroupedPrescriptionListDomain.Reducer.empty,
                        environment: GroupedPrescriptionListDomain.Dummies.environment
                    )
                )
            }.preferredColorScheme(.light)

            VStack {
                GroupedPrescriptionListView(
                    store: GroupedPrescriptionListDomain.Store(
                        initialState: GroupedPrescriptionListDomain.Dummies.state,
                        reducer: GroupedPrescriptionListDomain.Reducer.empty,
                        environment: GroupedPrescriptionListDomain.Dummies.environment
                    )
                )
            }
            .preferredColorScheme(.light)

            VStack {
                GroupedPrescriptionListView(store: GroupedPrescriptionListDomain.Dummies.store)
            }
            .previewDevice("iPod touch (7th generation)")
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)

            let state = GroupedPrescriptionListDomain.State(
                groupedPrescriptions: [GroupedPrescription.Dummies.twoPrescriptions]
            )

            VStack {
                GroupedPrescriptionListView(store: GroupedPrescriptionListDomain.Dummies.storeFor(state))
            }
            .preferredColorScheme(.light)
        }
    }
}
