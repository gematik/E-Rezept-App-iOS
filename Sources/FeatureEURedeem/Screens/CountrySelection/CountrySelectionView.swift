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

public struct CountrySelectionView: View {
    @Bindable var store: StoreOf<CountrySelectionDomain>

    public init(store: StoreOf<CountrySelectionDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.euredeemCountrySelectionTitle)
                    .font(.title3.bold())
                Text(L10n.euredeemCountrySelectionSubtitle)
                    .font(.subheadline)
                    .padding(.bottom, 8)

                SearchBar(
                    searchText: $store.searchText,
                    prompt: L10n.euredeemCountrySelectionSearchPrompt.text
                ) {
                    store.send(.serachList)
                }
                .padding(.top, 24)

                HStack {
                    Spacer()
                    Button {
                        store.send(.toggleLocation)
                    } label: {
                        HStack {
                            Image(systemName: SFSymbolName.scope)
                            Text(L10n.euredeemCountrySelectionBtnLocation)
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)

            List {
                ForEach(store.countries) { country in
                    Button {
                        store.send(.selectCountry(country))
                    } label: {
                        HStack {
                            Text(country.flag)
                                .font(.title)
                            Text(country.name)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { $0[.listRowSeparatorLeading] + 40 }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .task {
            store.send(.loadAllCountries)
        }
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    CountrySelectionView(
        store: .init(initialState: CountrySelectionDomain.State(
            countries: [
                Country(id: "DE", name: "Germany", telematikId: "010110"),
                Country(id: "FR", name: "France", telematikId: "010111"),
                Country(id: "IT", name: "Italy", telematikId: "010112"),
            ]
        )) {
            CountrySelectionDomain()
        }
    )
}
