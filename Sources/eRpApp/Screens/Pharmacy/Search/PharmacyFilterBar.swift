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

import eRpStyleKit
import Introspect
import SwiftUI

extension PharmacyFilterBar.Filter: Equatable where FilterType: Equatable {}

struct PharmacyFilterBar<FilterType: Identifiable>: View {
    var openFiltersAction: () -> Void
    var removeFilter: (Filter<FilterType>) -> Void
    var elements: [Filter<FilterType>]

    struct Filter<FilterType: Identifiable>: Identifiable {
        var id: FilterType.ID { element.id }

        let element: FilterType
        let key: LocalizedStringKey
        let accessibilityIdentifier: String
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: openFiltersAction) {
                    Label(title: {
                        Text(L10n.phaSearchBtnFilterTitle)
                    }, icon: {
                        Image(systemName: SFSymbolName.filter)
                    })
                        .padding(EdgeInsets(top: 7, leading: 8, bottom: 7, trailing: 8))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Colors.primary)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .accessibility(identifier: A11y.pharmacySearch.phaFilterOpenFilter)

                if elements.isEmpty {
                    Spacer()
                } else {
                    ForEach(elements) { element in
                        FilterElement(key: element.key,
                                      pressedAction: openFiltersAction) {
                            removeFilter(element)
                        }
                        .accessibility(identifier: element.accessibilityIdentifier)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: A11y.pharmacySearch.phaFilterFilterList)
                }
            }
            .padding(.vertical, 8)
        }
        .introspectScrollView { view in
            view.clipsToBounds = false
            view.alwaysBounceHorizontal = false
        }
        .accessibility(identifier: A11y.pharmacySearch.phaFilterBar)
        .accentColor(Colors.primary)
    }

    struct FilterElement: View {
        let key: LocalizedStringKey
        let pressedAction: () -> Void
        let closeButtonAction: () -> Void

        var body: some View {
            HStack {
                Button(action: pressedAction) {
                    Text(key)
                }

                Button(action: closeButtonAction) {
                    Image(systemName: SFSymbolName.crossIconFill)
                }
                .foregroundColor(Color(.secondaryLabel))
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .foregroundColor(Color(.label))
            .font(.subheadline)
        }
    }
}

struct PharmacyFilterBar_Preview: PreviewProvider {
    private struct DummyElement: Identifiable {
        var id = UUID()
    }

    static var previews: some View {
        VStack {
            PharmacyFilterBar<DummyElement>(
                openFiltersAction: {},
                removeFilter: { _ in },
                elements: []
            )
            .padding()

            PharmacyFilterBar<DummyElement>(
                openFiltersAction: {},
                removeFilter: { _ in },
                elements: [
                    .init(element: DummyElement(), key: "Versand", accessibilityIdentifier: "Versand"),
                    .init(
                        element: DummyElement(),
                        key: "Filter Element C",
                        accessibilityIdentifier: "Filter Element C"
                    ),
                ]
            )
            .padding()
        }
    }
}
