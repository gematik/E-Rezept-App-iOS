//
//  Copyright (c) 2022 gematik GmbH
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
import SwiftUI

struct PharmacySearchFilterView: View {
    let store: PharmacySearchFilterDomain.Store
    @ObservedObject
    var viewStore: ViewStore<PharmacySearchFilterDomain.State, PharmacySearchFilterDomain.Action>

    init(store: PharmacySearchFilterDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                SingleElementSectionContainer(
                    header: {
                        Text(L10n.psfTxtCommonSubheadline)
                    }, content: {
                        ForEach(PharmacySearchFilterDomain.PharmacyFilterOption.allCases, id: \.self) { filterOption in
                            Toggle(isOn: viewStore.binding(get: { state in
                                state.pharmacyFilterOptions.contains(filterOption)
                            }, send: { _ in
                                PharmacySearchFilterDomain.Action.toggleFilter(filterOption)
                            })) {
                                Label(title: { Text(filterOption.localizedStringKey) }, icon: {})
                            }
                            .toggleStyle(.radio(showSeparator: filterOption != PharmacySearchFilterDomain
                                    .PharmacyFilterOption.allCases.last))
                            .modifier(SectionContainerCellModifier())
                        }
                    }
                )
            }
        }
        .navigationTitle(L10n.psfTxtTitle)
        .background(Color(.secondarySystemBackground).ignoresSafeArea(.all, edges: .bottom))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewStore.send(.close(viewStore.state.pharmacyFilterOptions))
                }, label: {
                    Text(L10n.psfBtnAccept)
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct PharmacyFilterCell: View {
        let filter: PharmacySearchFilterDomain.PharmacyFilterOption
        let isActive: Bool

        var body: some View {
            HStack {
                Text(filter.localizedStringKey)
                Spacer()
                Image(systemName: isActive ? SFSymbolName.checkmarkCircleFill : SFSymbolName.circle)
                    .foregroundColor(isActive ? Colors.primary600 : Colors.systemGray)
            }.padding([.top, .bottom], 8)
        }
    }
}

struct PharmacySearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        Text("abc")
            .sheet(
                isPresented: .constant(true),
                onDismiss: {},
                content: {
                    NavigationView {
                        PharmacySearchFilterView(store: PharmacySearchFilterDomain.Dummies.store)
                    }
                    .accentColor(Colors.primary700)
                }
            )
    }
}
