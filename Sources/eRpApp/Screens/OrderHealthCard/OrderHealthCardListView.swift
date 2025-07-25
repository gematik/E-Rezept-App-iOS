//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct OrderHealthCardListView: View {
    @Perception.Bindable var store: StoreOf<OrderHealthCardDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                SearchBar(
                    searchText: $store.searchText,
                    prompt: L10n.orderEgkTxtSearchPrompt.key
                ) {
                    store.send(.searchList)
                }
                .padding()
                List {
                    if !store.filteredInsuranceCompanies.isEmpty {
                        ForEach(store.filteredInsuranceCompanies) { insurance in
                            Button(insurance.name) {
                                store.send(.selectHealthInsurance(insurance))
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
                }
                .listStyle(PlainListStyle())
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.serviceInquiry, action: \.destination.serviceInquiry)
            ) { store in
                OrderHealthCardInquiryView(store: store)
            }
            .onAppear {
                store.send(.loadList)
                store.send(.resetList)
            }
            .onChange(of: store.searchText) { _ in
                if store.searchText.isEmpty {
                    store.send(.resetList)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    store.send(.delegate(.close))
                }
            )
        }
    }
}

struct OrderHealthCardListView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrderHealthCardListView(store: OrderHealthCardDomain.Dummies.store)
        }
    }
}
