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
import eRpStyleKit
import SwiftUI

struct CountrySelectionView: View {
    let store: StoreOf<CountrySelectionDomain>

    var body: some View {
        List(store.countries) { country in
            Button {
                store.send(.selectCountry(country))
            } label: {
                HStack {
                    Text(country.name)
                    Spacer()
                    if store.selectedCountry == country {
                        Image(systemName: SFSymbolName.checkmark)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationTitle("Select Country")
    }
}

#Preview {
    CountrySelectionView(
        store: .init(initialState: CountrySelectionDomain.State(
            countries: [
                Country(id: "DE", name: "Germany"),
                Country(id: "FR", name: "France"),
                Country(id: "IT", name: "Italy"),
            ]
        )) {
            CountrySelectionDomain()
        }
    )
}
