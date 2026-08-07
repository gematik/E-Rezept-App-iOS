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

import eRpResources
import eRpStyleKit
import SwiftUI
import SwiftUIIntrospect

extension PharmacyFilterBar.Filter: Equatable where FilterType: Equatable {}

struct PharmacyFilterBar<FilterType: Identifiable>: View {
    var openFiltersAction: () -> Void
    var removeFilter: (Filter) -> Void
    var elements: [Filter]

    struct Filter: Identifiable {
        var id: FilterType.ID {
            element.id
        }

        let element: FilterType
        let key: LocalizedStringKey
        let accessibilityIdentifier: String
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: openFiltersAction) {
                    HStack(spacing: 4) {
                        Image(systemName: SFSymbolName.filter)
                            .font(.footnote)

                        Text(L10n.phaSearchBtnFilterTitle)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .background(Colors.systemBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Colors.systemLabelSecondary, lineWidth: 1)
                    )
                }
                .accessibility(identifier: A11y.pharmacySearch.phaFilterOpenFilter)

                ForEach(elements) { element in
                    FilterChip(
                        title: element.key,
                        style: .dismissible
                    ) {
                        removeFilter(element)
                    }
                    .accessibility(identifier: element.accessibilityIdentifier)
                }
                .accessibilityElement(children: .contain)
                .accessibility(identifier: A11y.pharmacySearch.phaFilterFilterList)
            }
            .padding(8)
            .background(Colors.systemBackground)
            .clipShape(Capsule())
            .padding(.horizontal)
        }
        .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18, .v26)) { scrollView in
            scrollView.clipsToBounds = false
            scrollView.alwaysBounceHorizontal = false
        }
        .accessibility(identifier: A11y.pharmacySearch.phaFilterBar)
        .tint(Colors.primary)
        .preventSnapshotClipping()
    }
}

extension View {
    /// This is a workaround to prevent the filter bar from being clipped when it is placed in a scroll view.
    func preventSnapshotClipping() -> some View {
        #if DEBUG
        offset(x: 0, y: 1)
        #else
        return self
        #endif
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
