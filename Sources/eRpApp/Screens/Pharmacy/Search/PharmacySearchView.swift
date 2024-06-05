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
import eRpStyleKit
import Perception
import Pharmacy
import SwiftUI
import UIKit

struct PharmacySearchView: View {
    @Perception.Bindable var store: StoreOf<PharmacySearchDomain>
    let isRedeemRecipe: Bool

    init(store: StoreOf<PharmacySearchDomain>) {
        self.init(store: store, isRedeemRecipe: true)
    }

    init(
        store: StoreOf<PharmacySearchDomain>,
        isRedeemRecipe: Bool
    ) {
        self.store = store
        self.isRedeemRecipe = isRedeemRecipe
    }

    @State var scrollOffset: CGFloat = 0

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                DebugPharmacies(store: store)

                ZStack {
                    switch store.searchState {
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
                                store.send(.showPharmacyFilter, animation: .default)
                            }, removeFilter: { option in
                                store.send(.removeFilterOption(option.element), animation: .default)
                            }, elements: filter)
                                .padding(.horizontal)
                                .transition(.move(edge: .top).combined(with: .opacity))

                            NoResultsView()
                                .accessibility(identifier: A11y.pharmacySearch.phaSearchNoResults)
                                .padding(.horizontal, 30)
                        }
                    case .error:
                        ErrorView { store.send(.performSearch) }
                            .accessibility(identifier: A11y.pharmacySearch.phaSearchError)
                    case .searchRunning,
                         .searchResultOk:
                        ScrollViewWithStickyHeader(header: {
                            PharmacyFilterBar(openFiltersAction: {
                                store.send(.showPharmacyFilter, animation: .default)
                            }, removeFilter: { option in
                                store.send(.removeFilterOption(option.element), animation: .default)
                            }, elements: filter)
                                .padding(.horizontal)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }, content: {
                            ResultsView(store: store)
                        })
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(VStack {
                    if store.searchState == .searchRunning {
                        SearchRunningView()
                            .accessibility(identifier: A11y.pharmacySearch.phaSearchSearchRunning)
                            .transition(.slide)
                            .padding(.top, 80)
                    }
                }, alignment: .top)

                Spacer(minLength: 0)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet($store.scope(
                        state: \.destination?.pharmacyFilter,
                        action: \.destination.pharmacyFilter
                    )) { store in
                        PharmacySearchFilterView(store: store)
                            .accentColor(Colors.primary600)
                    }
                    .accessibility(hidden: true)

                if isRedeemRecipe {
                    NavigationLink(item: $store.scope(
                        state: \.destination?.pharmacyMapSearch,
                        action: \.destination.pharmacyMapSearch
                    )) { store in
                        PharmacySearchMapView(store: store, isRedeemRecipe: isRedeemRecipe)
                    } label: {
                        EmptyView()
                    }
                    .accessibility(hidden: true)
                } else {
                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .fullScreenCover(item: $store.scope(
                            state: \.destination?.pharmacyMapSearch,
                            action: \.destination.pharmacyMapSearch
                        )) { store in
                            NavigationView {
                                PharmacySearchMapView(store: store, isRedeemRecipe: isRedeemRecipe)
                                    .navigationViewStyle(StackNavigationViewStyle())
                            }
                        }
                        .accessibility(hidden: true)
                }

                NavigationLink(
                    item: $store.scope(
                        state: \.destination?.pharmacyDetail,
                        action: \.destination.pharmacyDetail
                    )
                ) { store in
                    PharmacyDetailView(store: store, isRedeemRecipe: isRedeemRecipe)
                        .navigationBarTitle(L10n.phaDetailTxtTitle, displayMode: .inline)
                } label: {
                    EmptyView()
                }
                .accessibility(hidden: true)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isRedeemRecipe {
                        NavigationBarCloseItem {
                            store.send(.closeButtonTouched)
                        }
                    }
                }
            }
            .navigationTitle(L10n.tabTxtPharmacySearch)
            .searchable(
                text: searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: L10n.phaSearchTxtSearchHint.text
            ) {
                Suggestions(store: store)
            }
            .onSubmit(of: .search) {
                store.send(.performSearch, animation: .default)
            }
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .task {
                await store.send(.task).finish()
            }
            .task {
                await store.send(.onAppear).finish()
            }
            .onReceive(NotificationCenter.default
                .publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    store.send(.task)
            }
        }
    }

    struct Suggestions: View {
        @Perception.Bindable var store: StoreOf<PharmacySearchDomain>

        struct Suggestion: View {
            internal init(_ text: String) {
                self.text = text
            }

            let text: String

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    Text(text)
                        .searchCompletion(text)
                        .padding(.vertical, 8)
                        .foregroundColor(Colors.systemLabel)
                }
            }
        }

        var body: some View {
            WithPerceptionTracking {
                let searchHistory = store.searchText.isEmpty ? store.searchHistory : []
                if !searchHistory.isEmpty {
                    Text(L10n.phaSearchTxtHistoryTitle)
                        .font(.headline)
                        .padding(.bottom)
                        .padding(.top, 24)

                    ForEach(searchHistory, id: \.hash) { item in
                        Suggestion(item)
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }

    var filter: [PharmacyFilterBar<PharmacySearchFilterDomain.PharmacyFilterOption>.Filter] {
        store.pharmacyFilterOptions.map { option in
            PharmacyFilterBar<PharmacySearchFilterDomain.PharmacyFilterOption>.Filter(
                element: option,
                key: option.localizedStringKey,
                accessibilityIdentifier: option.rawValue
            )
        }
    }

    var searchText: Binding<String> {
        Binding {
            store.searchText
        } set: {
            store.send(.searchTextChanged($0))
        }
    }

    var forceCancelButtonVisible: Binding<Bool> {
        Binding {
            store.searchState.isNotStartView
        } set: { value in
            if !value {
                store.send(.searchTextChanged(""), animation: .default)
            }
        }
    }
}

extension PharmacySearchView {
    struct DebugPharmacies: View {
        @AppStorage("debug_pharmacies") var debugPharmacies: [DebugPharmacy] = []
        @AppStorage("show_debug_pharmacies") var showDebugPharmacies = false

        @Perception.Bindable var store: StoreOf<PharmacySearchDomain>

        var body: some View {
            WithPerceptionTracking {
                if showDebugPharmacies, !debugPharmacies.isEmpty {
                    List {
                        ForEach(debugPharmacies) { debugPharmacy in
                            let viewModel = debugPharmacy.asPharmacyViewModel()
                            Button(
                                action: { store.send(.showDetails(viewModel)) },
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
}

extension PharmacySearchView {
    private struct ResultsView: View {
        @Perception.Bindable var store: StoreOf<PharmacySearchDomain>

        var body: some View {
            WithPerceptionTracking {
                SingleElementSectionContainer {
                    LazyVStack(spacing: 0) {
                        ForEach(store.pharmacies) { pharmacyViewModel in
                            Button(
                                action: { store.send(.showDetails(pharmacyViewModel)) },
                                label: { Label(title: {
                                    let showDistance = store.pharmacyFilterOptions.contains { $0 == .currentLocation }
                                    PharmacySearchCell(
                                        pharmacy: pharmacyViewModel,
                                        showDistance: showDistance
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
                }
                .sectionContainerStyle(.inline)
                .accessibilityElement(children: .contain)
                .accessibility(identifier: A11y.pharmacySearch.phaSearchTxtResultList)
            }
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
                               isRedeemRecipe: false)
        }
        .accentColor(Colors.primary700)

        NavigationView {
            PharmacySearchView(
                store: PharmacySearchDomain.Dummies.storeOf(PharmacySearchDomain.Dummies.stateSearchResultOk),
                isRedeemRecipe: false
            )
        }
        .preferredColorScheme(.dark)
    }
}
