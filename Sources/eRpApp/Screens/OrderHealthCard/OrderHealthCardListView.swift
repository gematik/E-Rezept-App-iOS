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
import eRpKit
import SwiftUI

struct OrderHealthCardListView: View {
    let store: OrderHealthCardDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, OrderHealthCardDomain.Action>

    init(store: OrderHealthCardDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        var insuranceCompanies: [OrderHealthCardDomain.HealthInsuranceCompany]
        var searchText: String
        var searchHealthInsurance = [OrderHealthCardDomain.HealthInsuranceCompany]()
        let routeTag: OrderHealthCardDomain.Destinations.State.Tag?

        init(state: OrderHealthCardDomain.State) {
            insuranceCompanies = state.insuranceCompanies
            searchText = state.searchText
            searchHealthInsurance = state.searchHealthInsurance
            routeTag = state.destination?.tag
        }
    }

    var body: some View {
        VStack {
            SearchBar(
                searchText: viewStore.binding(
                    get: \.searchText
                ) { newText in
                    .updateSearchText(newPrompt: newText)
                },
                prompt: L10n.orderEgkTxtSearchPrompt.key
            ) {
                viewStore.send(.searchList)
            }
            .padding()
            List {
                if !viewStore.searchHealthInsurance.isEmpty {
                    ForEach(viewStore.searchHealthInsurance) { insurance in
                        Button(insurance.name) {
                            viewStore.send(.selectHealthInsurance(id: insurance.id))
                        }
                    }
                } else {
                    VStack {
                        Text(L10n.phaSearchTxtNoResultsTitle)
                            .font(.headline)
                            .padding(.bottom, 1)
                        Text(L10n.phaSearchTxtNoResults)
                            .font(.subheadline)
                            .foregroundColor(Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                }
            }.listStyle(PlainListStyle())
            NavigationLink(
                isActive: .init(
                    get: {
                        viewStore.routeTag != .searchPicker
                    },
                    set: { active in
                        if active {
                        } else {
                            viewStore.send(.setNavigation(tag: .searchPicker))
                        }
                    }
                ),
                destination: {
                    OrderHealthCardInquiryView(store: store)
                },
                label: {
                    EmptyView()
                }
            )
            .accessibility(hidden: true)
        }
        .onAppear {
            viewStore.send(.loadList)
            viewStore.send(.resetList)
        }
        .onChange(of: viewStore.searchText) { _ in
            if viewStore.searchText.isEmpty {
                viewStore.send(.resetList)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                viewStore.send(.delegate(.close))
            }
        )
    }
}

struct OrderHealthCardListView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderHealthCardListView(store: OrderHealthCardDomain.Dummies.store)
        }
    }
}
