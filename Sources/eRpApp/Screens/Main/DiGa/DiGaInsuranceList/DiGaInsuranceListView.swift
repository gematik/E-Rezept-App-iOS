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

struct DiGaInsuranceListView: View {
    @Perception.Bindable var store: StoreOf<DiGaInsuranceListDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.digaInsuranceListTxtHeader)
                        .multilineTextAlignment(.leading)
                        .font(Font.title.weight(.bold))
                        .accessibility(identifier: A11y.digaInsuranceList.digaInsuranceListTxtSubheader)

                    Text(L10n.digaInsuranceListTxtSubtext)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                        .accessibility(identifier: A11y.digaInsuranceList.digaInsuranceListTxtSubheader)
                }.padding()

                SearchBar(
                    searchText: $store.searchText.sending(\.searchList),
                    prompt: L10n.orderEgkTxtSearchPrompt.key
                ) {}.padding()

                if store.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        if !store.filteredinsurances.isEmpty {
                            ForEach(store.filteredinsurances) { insurance in
                                Button(action: {
                                    store.send(.selectInsurance(insurance))
                                }, label: {
                                    HStack {
                                        Image(asset: Asset.InsuranceLogo.imageAsset(for: insurance.telematikId))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 42, height: 42)
                                        Text(insurance.name ?? L10n.digaDtlTxtNa.text)
                                    }
                                })
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
                            .padding()
                            .frame(maxHeight: .infinity, alignment: .center)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .task {
                store.send(.task)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DiGaInsuranceListView(store: DiGaInsuranceListDomain.Dummies.store)
    }
}
