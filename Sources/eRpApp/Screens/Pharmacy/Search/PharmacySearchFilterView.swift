//
//  Copyright (c) 2021 gematik GmbH
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
import SwiftUI

struct PharmacySearchFilterView: View {
    let store: PharmacySearchFilterDomain.Store

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                VStack(alignment: .center, spacing: 16) {
                    Text(L10n.phaSearchFilterTxtTitle)
                        .font(Font.headline.weight(.semibold))
                    ForEach(PharmacySearchFilterDomain.PharmacyFilterOption.allCases, id: \.self) { filterOption in
                        Button(
                            action: { viewStore.send(.toggleFilter(filterOption)) },
                            label: {
                                PharmacyFilterCell(
                                    filter: filterOption,
                                    isActive: viewStore.state.pharmacyFilterOptions.contains(filterOption)
                                )
                            }
                        )
                        .foregroundColor(Colors.systemLabel)
                        .padding([.leading, .trailing])

                        Divider().padding(.leading)
                    }
                    Spacer()
                }
                .navigationBarItems(
                    trailing: CloseButton { viewStore.send(.close(viewStore.state.pharmacyFilterOptions)) }
                        .accessibility(identifier: A18n.redeem.overview.rdmBtnCloseButton)
                )
                .navigationBarTitleDisplayMode(.inline)
                .introspectNavigationController { navigationController in
                    let navigationBar = navigationController.navigationBar
                    navigationBar.barTintColor = UIColor(Colors.systemBackground)
                    let navigationBarAppearance = UINavigationBarAppearance()
                    navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                    navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                    navigationBar.standardAppearance = navigationBarAppearance
                }
            }
        }
        .accentColor(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private struct PharmacyFilterCell: View {
        let filter: PharmacySearchFilterDomain.PharmacyFilterOption
        let isActive: Bool

        var body: some View {
            HStack {
                Text(filter.localizedString())
                Spacer()
                Image(systemName: isActive ? SFSymbolName.checkmarkCircleFill : SFSymbolName.circle)
                    .foregroundColor(isActive ? Colors.primary600 : Colors.systemGray)
            }.padding([.top, .bottom], 8)
        }
    }
}

struct PharmacySearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacySearchFilterView(store: PharmacySearchFilterDomain.Dummies.store)
    }
}
