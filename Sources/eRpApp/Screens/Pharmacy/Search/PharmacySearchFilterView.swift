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
import SwiftUI

struct PharmacySearchFilterView: View {
    @Perception.Bindable var store: StoreOf<PharmacySearchFilterDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 24) {
                Text(L10n.psfTxtTitle)
                    .font(.subheadline.weight(.bold))

                VStack(alignment: .leading, spacing: 8) {
                    FilterRow(store: store)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {
                    store.send(.delegate(.close), animation: .easeInOut)
                }, label: {
                    Text(L10n.psfBtnAccept)
                })
                    .frame(idealWidth: 120, alignment: .center)
                    .buttonStyle(.secondaryAlt)
            }
            .padding()
            .background(Colors.systemBackground.ignoresSafeArea(.all, edges: .bottom))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct FilterView: View {
        let title: LocalizedStringKey
        @Binding var isEnabled: Bool

        var body: some View {
            Button(action: {
                isEnabled.toggle()
            }, label: {
                Text(title, bundle: .module)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .foregroundColor(isEnabled ? Colors.systemBackground : Colors.systemLabelSecondary)
                    .background(isEnabled ? Colors.primary : Colors.systemBackgroundSecondary)
                    .cornerRadius(8)
            })
        }
    }

    struct FilterRow: View {
        @Perception.Bindable var store: StoreOf<PharmacySearchFilterDomain>

        var body: some View {
            WithPerceptionTracking {
                HStack {
                    ForEach(store.pharmacyFilterShow[0 ..< 2], id: \.self) { filterOption in
                        WithPerceptionTracking {
                            let isEnabled = store.pharmacyFilterOptions.contains(filterOption)
                            FilterView(
                                title: filterOption.localizedStringKey,
                                isEnabled: Binding { isEnabled }
                                set: { _ in
                                    store.send(.toggleFilter(filterOption))
                                }
                            )
                        }
                    }
                }
                HStack {
                    ForEach(store.pharmacyFilterShow[2 ..< store.pharmacyFilterShow.count],
                            id: \.self) { filterOption in
                        WithPerceptionTracking {
                            let isEnabled = store.pharmacyFilterOptions.contains(filterOption)
                            FilterView(
                                title: filterOption.localizedStringKey,
                                isEnabled: Binding { isEnabled }
                                set: { _ in
                                    store.send(.toggleFilter(filterOption))
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    private struct PharmacyFilterCell: View {
        let filter: PharmacySearchFilterDomain.PharmacyFilterOption
        let isActive: Bool

        var body: some View {
            HStack {
                Text(filter.localizedStringKey, bundle: .module)
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

        PharmacySearchFilterView(store: PharmacySearchFilterDomain.Dummies.store)
            .preferredColorScheme(.dark)
    }
}
