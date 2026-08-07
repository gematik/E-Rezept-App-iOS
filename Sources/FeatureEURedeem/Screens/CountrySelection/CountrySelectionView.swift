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
import eRpResources
import eRpStyleKit
import SwiftUI

public struct CountrySelectionView: View {
    @Bindable var store: StoreOf<CountrySelectionDomain>

    public init(store: StoreOf<CountrySelectionDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            if store.countries.isEmpty, !store.isCountryLoading {
                VStack(spacing: 8) {
                    Image(decorative: Asset.EUReedem.euLogo)
                        .padding(.bottom, 28)
                        .padding(.top, 86)
                    Text(L10n.euredeemCountryEmptyTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .accessibilityIdentifier(A11y.redeem.eu.countrySelection.eurdmTxtCountryEmptyTitle)
                    Text(L10n.euredeemCountryEmptySubtitle)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .accessibilityIdentifier(A11y.redeem.eu.countrySelection.eurdmTxtCountryEmptySubtitle)

                    Spacer()
                }
                .padding(.top, 32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0, green: 0.2, blue: 0.6)) // #003399
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.euredeemCountrySelectionTitle)
                        .font(.title3.bold())
                        .foregroundStyle(Colors.systemLabel)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier(A11y.redeem.eu.countrySelection.eurdmTxtCountryTitle)
                    Text(L10n.euredeemCountrySelectionSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(Colors.systemLabelSecondary)
                        .padding(.bottom, 8)
                        .accessibilityIdentifier(A11y.redeem.eu.countrySelection.eurdmTxtCountrySubtitle)

                    SearchBar(
                        searchText: $store.searchText,
                        prompt: L10n.euredeemCountrySelectionSearchPrompt.text
                    ) {}
                        .padding(.top, 24)

                    HStack {
                        Spacer()
                        Button {
                            store.send(.toggleLocation)
                        } label: {
                            HStack {
                                Image(systemName: store.locationFilterIsEnabled
                                    ? SFSymbolName.cross
                                    : SFSymbolName.scope)
                                Text(store.locationFilterIsEnabled
                                    ? L10n.euredeemCountrySelectionBtnNoLocation
                                    : L10n.euredeemCountrySelectionBtnLocation)
                            }
                            .font(.subheadline.weight(.semibold))
                        }
                        .accessibilityIdentifier(A11y.redeem.eu.countrySelection.eurdmBtnCountryLocation)
                        .padding(.bottom)
                    }
                }
                .padding(.horizontal)

                if store.locationFilterIsEnabled, store.filteredCountries.isEmpty {
                    VStack {
                        Spacer()
                        Text(store.currentRegion?.locationSearchEmpty
                            ?? L10n.euredeemCountrySelectionTxtLocationEmpty.text)
                            .font(.subheadline)
                            .foregroundStyle(Colors.systemLabelSecondary)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier(
                                A11y.redeem.eu.countrySelection.eurdmTxtCountryLocationEmpty
                            )
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                } else {
                    List {
                        ForEach(store.filteredCountries) { country in
                            Button {
                                store.send(.selectCountry(country))
                            } label: {
                                HStack {
                                    Text(country.flag)
                                        .font(.title)
                                        .foregroundStyle(Colors.systemLabel)
                                        .accessibilityHidden(true)
                                    Text(country.displayName ?? country.name)
                                }
                                .alignmentGuide(.listRowSeparatorLeading) { $0[.listRowSeparatorLeading] + 40 }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        .task {
            store.send(.loadAllCountries)
        }
        .task {
            await store.send(.task).finish()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview("Countries") {
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

#Preview("No Countries") {
    NavigationStack {
        CountrySelectionView(
            store: .init(initialState: CountrySelectionDomain.State()) {
                CountrySelectionDomain()
            }
        )
    }
}
