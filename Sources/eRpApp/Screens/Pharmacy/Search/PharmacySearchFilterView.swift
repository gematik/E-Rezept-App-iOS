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

    struct FilterView: View {
        let title: LocalizedStringKey
        @Binding var isEnabled: Bool

        var body: some View {
            Button(action: {
                isEnabled.toggle()
            }, label: {
                Text(title)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .foregroundColor(isEnabled ? Colors.systemBackground : Colors.systemLabelSecondary)
                    .background(isEnabled ? Colors.primary : Colors.systemGray6)
                    .cornerRadius(8)
            })
        }
    }

    typealias Filter = PharmacySearchFilterDomain.PharmacyFilterOption

    struct FilterRow: View {
        @ObservedObject
        var viewStore: ViewStore<PharmacySearchFilterDomain.State, PharmacySearchFilterDomain.Action>

        let filters: [PharmacySearchFilterDomain.PharmacyFilterOption]

        var body: some View {
            HStack {
                ForEach(filters, id: \.self) { filterOption in
                    FilterView(
                        title: filterOption.localizedStringKey,
                        isEnabled: viewStore.binding(get: { state in
                            state.pharmacyFilterOptions.contains(filterOption)
                        }, send: { _ in
                            PharmacySearchFilterDomain.Action.toggleFilter(filterOption)
                        })
                    )
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(L10n.psfTxtTitle)
                .font(.subheadline.weight(.bold))

            VStack(alignment: .leading, spacing: 8) {
                FilterRow(viewStore: viewStore, filters: [.currentLocation, .open])
                FilterRow(viewStore: viewStore, filters: [.ready])
                FilterRow(viewStore: viewStore, filters: [.delivery, .shipment])
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: {
                viewStore.send(.close(viewStore.state.pharmacyFilterOptions))
            }, label: {
                Text(L10n.psfBtnAccept)
            })
                .frame(idealWidth: 120, alignment: .center)
                .buttonStyle(.secondaryAlt)
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea(.all, edges: .bottom))
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
            .smallSheet(
                isPresented: .constant(true),
                onDismiss: {},
                content: {
                    PharmacySearchFilterView(store: PharmacySearchFilterDomain.Dummies.store)
                }
            )
    }
}
