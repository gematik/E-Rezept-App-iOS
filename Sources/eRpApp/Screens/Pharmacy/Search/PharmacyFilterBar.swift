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

import eRpStyleKit
import SwiftUI
import SwiftUIIntrospect

extension PharmacyFilterBar.Filter: Equatable where FilterType: Equatable {}

struct PharmacyFilterBar<FilterType: Identifiable>: View {
    var openFiltersAction: () -> Void
    var removeFilter: (Filter) -> Void
    var elements: [Filter]

    struct Filter: Identifiable {
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
        .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18)) { scrollView in
            scrollView.clipsToBounds = false
            scrollView.alwaysBounceHorizontal = false
        }
        .accessibility(identifier: A11y.pharmacySearch.phaFilterBar)
        .tint(Colors.primary)
    }

    struct FilterElement: View {
        let key: LocalizedStringKey
        let pressedAction: () -> Void
        let closeButtonAction: () -> Void

        var body: some View {
            HStack {
                Button(action: pressedAction) {
                    Text(key, bundle: .module)
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
