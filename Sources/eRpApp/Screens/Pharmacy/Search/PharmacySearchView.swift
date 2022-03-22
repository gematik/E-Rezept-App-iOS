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
import Pharmacy
import SwiftUI

struct PharmacySearchView: View {
    let store: PharmacySearchDomain.Store
    let profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store?
    let isModalView: Bool

    @ObservedObject
    var viewStore: ViewStore<ViewState, PharmacySearchDomain.Action>

    init(store: PharmacySearchDomain.Store,
         profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store? = nil,
         isModalView: Bool = true) {
        self.store = store
        self.isModalView = isModalView
        self.profileSelectionToolbarItemStore = profileSelectionToolbarItemStore
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let showLocationHint: Bool
        let routeTag: PharmacySearchDomain.Route.Tag?
        let pharmacyFilterState: PharmacySearchFilterDomain.State?
        let searchText: String
        let searchState: PharmacySearchDomain.SearchState
        let pharmacies: [PharmacyLocationViewModel]

        init(state: PharmacySearchDomain.State) {
            showLocationHint = state.showLocationHint
            routeTag = state.route?.tag
            pharmacyFilterState = state.pharmacyFilterState
            searchText = state.searchText
            searchState = state.searchState
            pharmacies = state.pharmacies
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 15.0, *) { /* see .backport.searchable() below */ } else {
                SearchBar(
                    searchText: viewStore.binding(
                        get: \.searchText,
                        send: PharmacySearchDomain.Action.searchTextChanged
                    ),
                    prompt: L10n.phaSearchTxtSearchHint.key
                ) {
                    viewStore.send(.performSearch)
                }
                .padding()

                GreyDivider(topPadding: 0)
            }

            PharmacyDetailViewNavigation(store: store, isModalView: isModalView)

            if case .searchResultOk = viewStore.searchState {
                // List of (optional) location hint and populated search results >> location hint is scrollable
                List {
                    locationHintViewOrEmpty()
                        .buttonStyle(PlainButtonStyle())
                        .backport.listRowSeparatorHiddenAllEdges()

                    ForEach(viewStore.pharmacies, id: \.self) { pharmacyViewModel in
                        // todo rather than using a button, use directly a nav link
                        Button(
                            action: { viewStore.send(.showDetails(pharmacyViewModel)) },
                            label: { PharmacySearchCell(pharmacy: pharmacyViewModel) }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .accessibility(identifier: A11y.pharmacySearch.phaSearchTxtResultList)
            } else {
                // Stack of (optional) location hint and further search result states (empty, error, etc.)
                VStack {
                    locationHintViewOrEmpty()
                        .padding(.horizontal)
                        .padding(.top, 6)

                    Group {
                        switch viewStore.searchState {
                        case .searchRunning:
                            SearchRunningView()
                                .accessibility(identifier: A11y.pharmacySearch.phaSearchSearchRunning)
                        case .localizingDevice:
                            LocalizingDeviceView()
                                .accessibility(identifier: A11y.pharmacySearch.phaSearchLocalizingDevice)
                        case .startView:
                            StartView()
                                .accessibility(identifier: A11y.pharmacySearch.phaSearchLocalizingDevice)
                        case .searchResultEmpty:
                            NoResultsView()
                                .accessibility(identifier: A11y.pharmacySearch.phaSearchNoResults)
                                .padding(.horizontal, 30)
                        case .searchAfterLocalizationWasAuthorized:
                            EmptyView()
                        case .error:
                            ErrorView { viewStore.send(.performSearch) }
                                .accessibility(identifier: A11y.pharmacySearch.phaSearchError)
                        case .searchResultOk: // This case was already considered within `List` further above
                            EmptyView()
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }

            Spacer(minLength: 0)

            // Search-Filter sheet presentation
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .sheet(isPresented: viewStore.binding(
                    get: { $0.pharmacyFilterState != nil },
                    send: PharmacySearchDomain.Action.dismissFilterSheetView
                )) {
                    IfLetStore(
                        store.scope(
                            state: \.pharmacyFilterState,
                            action: PharmacySearchDomain.Action.pharmacyFilterView(action:)
                        ),
                        then: PharmacySearchFilterView.init(store:)
                    )
                }
                .hidden()
                .accessibility(hidden: true)

            if let profileSelectionToolbarItemStore = profileSelectionToolbarItemStore {
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
            }
        }
        .ifLet(profileSelectionToolbarItemStore) { view, profileSelectionToolbarItemStore in
            view.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    UserProfileSelectionToolbarItem(store: profileSelectionToolbarItemStore) {
                        viewStore.send(.setNavigation(tag: .selectProfile))
                    }
                    .accessibility(identifier: A18n.mainScreen.erxBtnProfile)
                }
            }
        }
        .navigationTitle(L10n.tabTxtPharmacySearch)
        .navigationBarTitleDisplayMode(.inline)
        .backport.searchable(
            text: viewStore.binding(
                get: \.searchText,
                send: PharmacySearchDomain.Action.searchTextChanged
            ),
            prompt: L10n.phaSearchTxtSearchHint.key
        ) {
            viewStore.send(.performSearch)
        }
        .alert(
            store.scope(state: \.alertState),
            dismiss: .alertDismissButtonTapped
        )
        .navigationBarItems(
            trailing: trailingNavigationBarItem()
        )
        .introspectNavigationController { navigationController in
            let navigationBar = navigationController.navigationBar
            navigationBar.barTintColor = UIColor(Colors.systemBackground)
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
            navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
            navigationBar.standardAppearance = navigationBarAppearance
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

extension PharmacySearchView {
    // TODO: rebuild view structure,  // swiftlint:disable:this todo
    // also `trailingNavigationBarItem` and alike are deprecating (Use `toolbar(content:)`)
    @ViewBuilder
    private func trailingNavigationBarItem() -> some View {
        WithViewStore(store) { viewStore in
            if isModalView {
                NavigationBarCloseItem {
                    viewStore.send(.close)
                }
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func locationHintViewOrEmpty() -> some View {
        WithViewStore(store) { viewStore in
            if viewStore.state.showLocationHint {
                LocalizationHintView(
                    textAction: { viewStore.send(.hintButtonTapped) },
                    closeAction: { viewStore.send(.hintDismissButtonTapped) }
                )
            } else {
                EmptyView()
            }
        }
    }

    private struct LocalizationHintView: View {
        let textAction: () -> Void
        let closeAction: () -> Void

        var body: some View {
            HintView(
                hint: Hint<PharmacySearchDomain.Action>(
                    id: A11y.prescriptionDetails.prscDtlHntNoctuFeeWaiver,
                    title: L10n.phaSearchTxtLocationHintTitle.text,
                    message: L10n.phaSearchTxtLocationHintMessage.text,
                    actionText: L10n.phaSearchBtnLocationHintAction,
                    imageName: Asset.Prescriptions.Details.apothekerin.name,
                    closeAction: .hintDismissButtonTapped,
                    style: .neutral,
                    buttonStyle: .tertiary,
                    imageStyle: .topAligned
                ),
                textAction: textAction,
                closeAction: closeAction
            )
        }
    }

    private struct PharmacyDetailViewNavigation: View {
        let store: PharmacySearchDomain.Store
        let isModalView: Bool

        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: { $0.pharmacyDetailState },
                            action: PharmacySearchDomain.Action.pharmacyDetailView(action:)
                        )
                    ) { scopedStore in
                        PharmacyDetailView(store: scopedStore, isModalView: isModalView)
                            .navigationBarTitle(L10n.phaDetailTxtTitle, displayMode: .inline)
                    },
                    isActive: viewStore.binding(
                        get: { $0.pharmacyDetailState != nil },
                        send: PharmacySearchDomain.Action.dismissPharmacyDetailView
                    )
                ) {
                    EmptyView()
                }
                .accessibility(hidden: true)
            }
        }
    }

    private struct SearchRunningView: View {
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    ProgressView()
                        .padding(.horizontal)
                    Text(L10n.phaSearchTxtProgressSearch)
                        .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }

    private struct LocalizingDeviceView: View {
        var body: some View {
            HStack {
                ProgressView()
                    .padding([.horizontal])
                Text(L10n.phaSearchTxtProgressLocating)
                    .padding()
                Spacer()
            }
        }
    }

    private struct StartView: View {
        var body: some View {
            Text(L10n.phaSearchTxtMinSearchChars)
                .padding()
                .multilineTextAlignment(.center)
        }
    }

    private struct NoResultsView: View {
        var body: some View {
            VStack {
                Text(L10n.phaSearchTxtNoResultsTitle)
                    .font(.headline)
                    .padding(.bottom, 1)
                Text(L10n.phaSearchTxtNoResults)
                    .font(.subheadline)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private struct ErrorView: View {
        let buttonAction: () -> Void

        var body: some View {
            VStack {
                Text(L10n.phaSearchTxtErrorNoServerResponseHeadline)
                    .font(.headline)
                    .padding(.bottom, 1)

                Text(L10n.phaSearchTxtErrorNoServerResponseSubheadline)
                    .font(.subheadline)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 1)

                Button(action: buttonAction) {
                    Text(L10n.phaSearchBtnErrorNoServerResponse)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct PharmacySearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Search with result
            NavigationView {
                PharmacySearchView(store: PharmacySearchDomain.Dummies.store)
            }
            // Search with empty Result
            NavigationView {
                PharmacySearchView(
                    store: PharmacySearchDomain.Dummies.storeFor(
                        PharmacySearchDomain.Dummies.stateEmpty
                    )
                )
            }
            // Search running
            NavigationView {
                PharmacySearchView(
                    store: PharmacySearchDomain.Dummies.storeFor(
                        PharmacySearchDomain.Dummies.stateSearchRunning
                    )
                )
            }
            // Search with result dark mode
            NavigationView {
                PharmacySearchView(store: PharmacySearchDomain.Dummies.store)
            }
            .preferredColorScheme(.dark)

            // Search with filtered elements
            NavigationView {
                PharmacySearchView(
                    store: PharmacySearchDomain.Dummies.storeFor(
                        PharmacySearchDomain.Dummies.stateFilterItems
                    )
                )
            }
        }
    }
}

// TODO: for now dead code. Keep for reactivation in future. // swiftlint:disable:this todo
// extension PharmacySearchView {
//    private struct SortAndFilterActionView: View {
//        let store: PharmacySearchDomain.Store
//
//        var body: some View {
//            WithViewStore(store) { _ in
//                HStack {
//                    /*
//                      swiftlint:disable:next todo
//                      TODO: This filter button is deactivated until the ApoVZD-Server
//                      provides the necessary data.
//
//                     Button(action: {
//                         viewStore.send(.showPharmacyFilterView)
//                     }, label: {
//                         Image(systemName: SFSymbolName.filter)
//                         Text(L10n.phaSearchBtnShowFilterView)
//
//                     })
//                     .foregroundColor(Colors.primary600)
//                     .font(Font.subheadline.weight(.semibold))
//                     .padding(.trailing, 2)
//                      */
//                }
//            }
//        }
//    }
//
//    private struct FilterItemsView: View {
//        let store: PharmacySearchDomain.Store
//
//        var body: some View {
//            WithViewStore(store) { viewStore in
//                HStack {
//                    ForEach(viewStore.state.pharmacyFilterOptions, id: \.self) { filterOption in
//                        Button(action: {
//                            viewStore.send(.removeFilterOption(filterOption))
//                        }, label: {
//                            HStack {
//                                Text(filterOption.localizedString())
//                                    .font(.footnote)
//                                Image(systemName: SFSymbolName.crossIconFill)
//                            }
//                            .padding([.top, .bottom], 4)
//                            .padding([.leading, .trailing], 8)
//                            .background(RoundedRectangle(cornerRadius: 16).fill(Colors.backgroundSecondary))
//                        })
//                    }
//                }
//                .foregroundColor(Colors.systemLabelSecondary)
//            }
//        }
//    }
// }
