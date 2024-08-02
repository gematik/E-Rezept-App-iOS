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
                        ZStack(alignment: .bottomTrailing) {
                            ScrollViewWithStickyHeader(header: {
                                PharmacyFilterBar(openFiltersAction: {
                                    store.send(.showPharmacyFilter, animation: .default)
                                }, removeFilter: { option in
                                    store.send(
                                        .removeFilterOption(option.element),
                                        animation: .default
                                    )
                                }, elements: filter)
                                    .padding(.horizontal)
                                    .transition(.move(edge: .top)
                                        .combined(with: .opacity))
                            }, content: {
                                ResultsView(store: store)
                            })

                            Button(action: { store.send(.switchToMapView) }, label: {
                                Image(systemName: SFSymbolName.map)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Colors.primary)
                                    .padding(16)
                                    .background(Circle().foregroundColor(Colors.systemColorWhite))
                                    .padding(.all, 26)
                                    .shadow(color: Colors.separator, radius: 4)
                            }).accessibility(identifier: A11y.pharmacySearch.phaSearchSwitchResultMap)
                        }
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

                if store.inRedeemProcess {
                    NavigationLink(item: $store.scope(
                        state: \.destination?.pharmacyMapSearch,
                        action: \.destination.pharmacyMapSearch
                    )) { store in
                        PharmacySearchMapView(store: store)
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                    .accessibility(hidden: true)
                } else {
                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .fullScreenCover(item: $store.scope(
                            state: \.destination?.pharmacyMapSearch,
                            action: \.destination.pharmacyMapSearch
                        )) { store in
                            NavigationView {
                                PharmacySearchMapView(store: store)
                                    .navigationViewStyle(StackNavigationViewStyle())
                            }
                        }
                        .hidden()
                        .accessibility(hidden: true)
                }

                NavigationLink(
                    item: $store.scope(
                        state: \.destination?.pharmacyDetail,
                        action: \.destination.pharmacyDetail
                    )
                ) { store in
                    PharmacyDetailView(store: store)
                } label: {
                    EmptyView()
                }
                .hidden()
                .accessibility(hidden: true)

                NavigationLink(
                    item: $store.scope(
                        state: \.destination?.redeemViaAVS,
                        action: \.destination.redeemViaAVS
                    )
                ) { store in
                    PharmacyRedeemView(store: store)
                } label: {
                    EmptyView()
                }
                .hidden()
                .accessibility(hidden: true)

                NavigationLink(
                    item: $store.scope(
                        state: \.destination?.redeemViaErxTaskRepository,
                        action: \.destination.redeemViaErxTaskRepository
                    )
                ) { store in
                    PharmacyRedeemView(store: store)
                } label: {
                    EmptyView()
                }
                .hidden()
                .accessibility(hidden: true)
            }
            .smallSheet($store.scope(
                state: \.destination?.pharmacyFilter,
                action: \.destination.pharmacyFilter
            )) { store in
                PharmacySearchFilterView(store: store)
                    .accentColor(Colors.primary600)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if store.inRedeemProcess {
                        NavigationBarCloseItem {
                            store.send(.closeButtonTouched)
                        }
                    }
                }
            }
            .navigationTitle(L10n.tabTxtPharmacySearch)
            .searchable(text: $store.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: L10n.phaSearchTxtSearchHint.text) {
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

    var screen: Binding<Bool> {
        Binding {
            store.destination == nil
        } set: {
            store.send(.nothing($0))
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
                            WithPerceptionTracking {
                                Button(
                                    action: { store.send(.showDetails(pharmacyViewModel)) },
                                    label: { Label(title: {
                                        let showDistance = store.pharmacyFilterOptions
                                            .contains { $0 == .currentLocation }
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
            PharmacySearchView(store: PharmacySearchDomain.Dummies.store)
        }
        .accentColor(Colors.primary700)

        NavigationView {
            PharmacySearchView(
                store: PharmacySearchDomain.Dummies.storeOf(PharmacySearchDomain.Dummies.stateSearchResultOk)
            )
        }
        .preferredColorScheme(.dark)
    }
}
