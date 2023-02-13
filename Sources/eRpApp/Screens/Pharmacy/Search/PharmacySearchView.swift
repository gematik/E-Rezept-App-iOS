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

import ComposableArchitecture
import eRpStyleKit
import Pharmacy
import SwiftUI
import UIKit

struct PharmacySearchView: View {
    let store: PharmacySearchDomain.Store
    let profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store?
    let isRedeemRecipe: Bool

    @ObservedObject
    var viewStore: ViewStore<ViewState, PharmacySearchDomain.Action>

    init(store: PharmacySearchDomain.Store,
         profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store? = nil,
         isRedeemRecipe: Bool = true) {
        self.store = store
        self.isRedeemRecipe = isRedeemRecipe
        self.profileSelectionToolbarItemStore = profileSelectionToolbarItemStore
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    @State var scrollOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            if #unavailable(iOS 15.0) { /* see .backport.searchable() below */
                SearchBar(
                    searchText: viewStore.binding(
                        get: \.searchText,
                        send: PharmacySearchDomain.Action.searchTextChanged
                    ),
                    prompt: L10n.phaSearchTxtSearchHint.key
                ) { viewStore.send(.performSearch) }
                    .padding()

                GreyDivider(topPadding: 0)
            }

            PharmacyDetailViewNavigation(store: store, isRedeemRecipe: isRedeemRecipe)

            DebugPharmacies(viewStore: viewStore)

            ZStack {
                switch viewStore.searchState {
                case .searchAfterLocalizationWasAuthorized,
                     .localizingDevice:
                    LocalizingDeviceView()
                        .accessibility(identifier: A11y.pharmacySearch.phaSearchLocalizingDevice)
                case .startView:
                    ScrollView {
                        PharmacySearchStartView(store: store)
                            .accessibility(identifier: A11y.pharmacySearch.phaSearchLocalizingDevice)
                    }
                case .searchResultEmpty:
                    VStack {
                        PharmacyFilterBar(openFiltersAction: {
                            viewStore.send(.setNavigation(tag: .filter), animation: .default)
                        }, removeFilter: { option in
                            viewStore.send(.removeFilterOption(option.element), animation: .default)
                        }, elements: viewStore.filter)
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))

                        NoResultsView()
                            .accessibility(identifier: A11y.pharmacySearch.phaSearchNoResults)
                            .padding(.horizontal, 30)
                    }
                case .error:
                    ErrorView { viewStore.send(.performSearch) }
                        .accessibility(identifier: A11y.pharmacySearch.phaSearchError)
                case .searchRunning,
                     .searchResultOk:
                    ScrollViewWithStickyHeader(header: {
                        PharmacyFilterBar(openFiltersAction: {
                            viewStore.send(.setNavigation(tag: .filter), animation: .default)
                        }, removeFilter: { option in
                            viewStore.send(.removeFilterOption(option.element), animation: .default)
                        }, elements: viewStore.filter)
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }, content: {
                        ResultsView(viewStore: viewStore)
                    })
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay(VStack {
                if viewStore.searchState == .searchRunning {
                    SearchRunningView()
                        .accessibility(identifier: A11y.pharmacySearch.phaSearchSearchRunning)
                        .transition(.slide)
                        .padding(.top, 80)
                }
            }, alignment: .top)

            Spacer(minLength: 0)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(isPresented: Binding<Bool>(get: {
                    viewStore.routeTag == .filter
                }, set: { show in
                    if !show {
                        viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                    }
                }),
                onDismiss: {},
                content: {
                    IfLetStore(pharmacySearchFilterStore, then: PharmacySearchFilterView.init(store:))
                        .accentColor(Colors.primary600)
                })
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
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isRedeemRecipe {
                    NavigationBarCloseItem {
                        viewStore.send(.close)
                    }
                }
            }
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if let profileSelectionToolbarItemStore = profileSelectionToolbarItemStore {
                    UserProfileSelectionToolbarItem(store: profileSelectionToolbarItemStore) {
                        viewStore.send(.setNavigation(tag: .selectProfile))
                    }
                    .embedToolbarContent()
                    .accessibility(identifier: A18n.mainScreen.erxBtnProfile)
                }
            }
        }
        .navigationTitle(L10n.tabTxtPharmacySearch)
        .backport.searchable(
            text: searchText,
            prompt: L10n.phaSearchTxtSearchHint.key,
            displayModeAlways: true,
            suggestions: {
                Suggestions(viewStore: viewStore)
            },
            onSubmitOfSearch: {
                viewStore.send(.performSearch, animation: .default)
            }
        )
        .alert(
            store.scope(state: (\PharmacySearchDomain.State.route)
                .appending(path: /PharmacySearchDomain.Route.alert)
                .extract(from:)),
            dismiss: .setNavigation(tag: .none)
        )
        .searchableForceCancelButtonVisible(forceCancelButtonVisible)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onReceive(NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewStore.send(.onAppear)
        }
    }

    struct Suggestions: View {
        @ObservedObject
        var viewStore: ViewStore<ViewState, PharmacySearchDomain.Action>

        struct Suggestion: View {
            internal init(_ text: String) {
                self.text = text
            }

            let text: String

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    Text(text)
                        .backport.searchCompletion(text)
                        .padding(.vertical, 8)
                        .foregroundColor(Colors.systemLabel)
                }
            }
        }

        var body: some View {
            if !viewStore.searchHistory.isEmpty {
                Text(L10n.phaSearchTxtHistoryTitle)
                    .font(.headline)
                    .padding(.bottom)
                    .padding(.top, 24)

                ForEach(viewStore.searchHistory, id: \.hash) { item in
                    Suggestion(item)
                }
            } else {
                EmptyView()
            }
        }
    }

    var searchText: Binding<String> {
        viewStore.binding(
            get: \.searchText,
            send: PharmacySearchDomain.Action.searchTextChanged
        )
    }

    var forceCancelButtonVisible: Binding<Bool> {
        Binding {
            viewStore.searchState.isNotStartView
        } set: { value in
            if !value {
                viewStore.send(.searchTextChanged(""), animation: .default)
            }
        }
    }

    var pharmacySearchFilterStore: Store<PharmacySearchFilterDomain.State?, PharmacySearchFilterDomain.Action> {
        store.scope(
            state: (\PharmacySearchDomain.State.route)
                .appending(path: /PharmacySearchDomain.Route.filter)
                .extract(from:),
            action: PharmacySearchDomain.Action.pharmacyFilterView(action:)
        )
    }
}

extension PharmacySearchView {
    struct DebugPharmacies: View {
        @AppStorage("debug_pharmacies") var debugPharmacies: [DebugPharmacy] = []
        @AppStorage("show_debug_pharmacies") var showDebugPharmacies = false

        @ObservedObject
        var viewStore: ViewStore<ViewState, PharmacySearchDomain.Action>

        var body: some View {
            if showDebugPharmacies, !debugPharmacies.isEmpty {
                List {
                    ForEach(debugPharmacies) { debugPharmacy in
                        let viewModel = debugPharmacy.asPharmacyViewModel()
                        Button(
                            action: { viewStore.send(.showDetails(viewModel)) },
                            label: { PharmacySearchCell(pharmacy: viewModel, showDistance: false) }
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

extension PharmacySearchView {
    struct ViewState: Equatable {
        let routeTag: PharmacySearchDomain.Route.Tag?
        let searchText: String
        let searchState: PharmacySearchDomain.SearchState
        let pharmacies: [PharmacyLocationViewModel]
        let filter: [PharmacyFilterBar<PharmacySearchFilterDomain.PharmacyFilterOption>
            .Filter<PharmacySearchFilterDomain.PharmacyFilterOption>]
        let showDistance: Bool

        let searchHistory: [String]
        let showFilterBar: Bool

        init(state: PharmacySearchDomain.State) {
            routeTag = state.route?.tag
            searchText = state.searchText
            searchState = state.searchState
            pharmacies = state.pharmacies
            filter = state.pharmacyFilterOptions.map { option in
                PharmacyFilterBar<PharmacySearchFilterDomain.PharmacyFilterOption>.Filter(
                    element: option,
                    key: option.localizedStringKey,
                    accessibilityIdentifier: option.rawValue
                )
            }
            showDistance = state.pharmacyFilterOptions.contains { $0 == .currentLocation }
            searchHistory = searchText.lengthOfBytes(using: .utf8) == 0 ? state.searchHistory : []
            showFilterBar = state.searchState.isNotStartView
        }
    }
}

extension PharmacySearchView {
    private struct PharmacyDetailViewNavigation: View {
        let store: PharmacySearchDomain.Store
        let isRedeemRecipe: Bool

        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\PharmacySearchDomain.State.route)
                                .appending(path: /PharmacySearchDomain.Route.pharmacy)
                                .extract(from:),
                            action: PharmacySearchDomain.Action.pharmacyDetailView(action:)
                        )
                    ) { scopedStore in
                        PharmacyDetailView(store: scopedStore, isRedeemRecipe: isRedeemRecipe)
                            .navigationBarTitle(L10n.phaDetailTxtTitle, displayMode: .inline)
                    },
                    tag: PharmacySearchDomain.Route.Tag.pharmacy,
                    selection: viewStore.binding(
                        get: { $0.route?.tag },
                        send: { .setNavigation(tag: $0) }
                    )
                ) {}
                    .hidden()
                    .accessibility(hidden: true)
            }
        }
    }

    private struct ResultsView: View {
        @ObservedObject
        var viewStore: ViewStore<ViewState, PharmacySearchDomain.Action>

        var body: some View {
            SingleElementSectionContainer {
                ForEach(viewStore.pharmacies, id: \.self) { pharmacyViewModel in
                    Button(
                        action: { viewStore.send(.showDetails(pharmacyViewModel)) },
                        label: { Label(title: {
                            PharmacySearchCell(
                                pharmacy: pharmacyViewModel,
                                showDistance: viewStore.showDistance
                            )
                        }, icon: {})
                        }
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibility(identifier: A11y.pharmacySearch.phaSearchTxtResultListEntry)
                    .buttonStyle(.navigation(showSeparator: true))
                    .modifier(SectionContainerCellModifier(last: false))
                }
            }
            .sectionContainerStyle(.inline)
            .accessibility(identifier: A11y.pharmacySearch.phaSearchTxtResultList)
        }
    }

    private struct SearchRunningView: View {
        var body: some View {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    ProgressView()

                    Text(L10n.phaSearchTxtProgressSearch)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabelSecondary)
                }
                .padding()
                .background(Colors.systemBackgroundSecondary)
                .cornerRadius(8)

                Spacer()
            }
            .transition(.opacity)
        }
    }

    private struct LocalizingDeviceView: View {
        var body: some View {
            VStack {
                Spacer()

                HStack(spacing: 16) {
                    Spacer()

                    ProgressView()

                    Text(L10n.phaSearchTxtProgressLocating)

                    Spacer()
                }

                Spacer()
            }
            .transition(.opacity)
        }
    }

    private struct NoResultsView: View {
        var body: some View {
            VStack {
                Spacer()

                Text(L10n.phaSearchTxtNoResultsTitle)
                    .font(.headline)
                    .padding(.bottom, 1)
                Text(L10n.phaSearchTxtNoResults)
                    .font(.subheadline)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
        }
    }

    private struct ErrorView: View {
        let buttonAction: () -> Void

        var body: some View {
            VStack {
                Spacer()

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

                Spacer()
            }
        }
    }
}

struct PharmacySearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PharmacySearchView(store: PharmacySearchDomain.Dummies.store,
                               profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Dummies.store,
                               isRedeemRecipe: false)
        }
        .accentColor(Colors.primary700)
    }
}
