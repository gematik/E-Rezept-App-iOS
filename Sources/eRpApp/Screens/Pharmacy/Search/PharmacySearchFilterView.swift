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
import eRpResources
import eRpStyleKit
import SwiftUI

struct PharmacySearchFilterView: View {
    @Bindable var store: StoreOf<PharmacySearchFilterDomain>

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()

                        CloseButton {
                            store.send(.delegate(.close), animation: .easeInOut)
                        }
                        .accessibility(identifier: A11y.pharmacySearchFilter.psfBtnClose)
                    }
                    .padding(.top, 8)

                    Text(L10n.psfTxtTitle)
                        .font(.title3.weight(.bold))
                        .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 48) {
                        FilterSection(
                            title: L10n.psfTxtSectionPreferences.key,
                            filters: store.preferenceFilters,
                            activeFilters: store.pharmacyFilterOptions,
                            store: store
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            FilterSection(
                                title: L10n.psfTxtSectionRedeemMethod.key,
                                filters: store.redeemMethodFilters,
                                activeFilters: store.pharmacyFilterOptions,
                                store: store
                            )

                            if store.pharmacyFilterOptions.contains(.delivery) {
                                Text(L10n.psfTxtDeliveryHint)
                                    .font(.caption)
                                    .foregroundColor(Colors.systemLabelSecondary)
                            }
                        }

                        FilterSection(
                            title: L10n.psfTxtSectionPhysicalFeature.key,
                            filters: store.physicalFeatureFilters,
                            activeFilters: store.pharmacyFilterOptions,
                            store: store
                        )

                        ServiceSection(store: store)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                .padding(.bottom, 56)
            }

            Divider()

            VStack(spacing: 8) {
                Button(action: {
                    store.send(.delegate(.close), animation: .easeInOut)
                }, label: {
                    Text(L10n.psfBtnSearch)
                })
                .buttonStyle(.primaryHugging)

                Button(action: {
                    store.send(.resetFilters)
                }, label: {
                    Label(L10n.psfBtnReset, systemImage: SFSymbolName.rollback)
                        .font(.body.weight(.semibold))
                        .foregroundColor(Colors.primary)
                })
                .frame(minHeight: 52)
            }
            .padding(.top, 16)
            .padding(.horizontal)
        }
        .background(Colors.systemBackground.ignoresSafeArea(.all, edges: .bottom))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Filter Chip Section

    struct FilterSection: View {
        let title: LocalizedStringKey
        let filters: [PharmacySearchFilterDomain.PharmacyFilterOption]
        let activeFilters: [PharmacySearchFilterDomain.PharmacyFilterOption]
        let store: StoreOf<PharmacySearchFilterDomain>

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title, bundle: .module)
                        .font(.headline)
                        .foregroundColor(Colors.systemLabel)
                        .accessibilityAddTraits(.isHeader)
                        .padding([.top])
                    Spacer()
                }

                PharmacySearchFlowLayout(spacing: 8) {
                    ForEach(filters, id: \.self) { filterOption in
                        let isEnabled = activeFilters.contains(filterOption)
                        FilterChip(
                            title: filterOption.localizedStringKey,
                            isSelected: isEnabled
                        ) {
                            store.send(.toggleFilter(filterOption))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Service Section

    struct ServiceSection: View {
        let store: StoreOf<PharmacySearchFilterDomain>

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // Header row: "Services" + "Erklären"/"Nicht erklären" toggle
                HStack {
                    Text(L10n.psfTxtSectionServices)
                        .font(.headline)
                        .foregroundColor(Colors.systemLabel)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()

                    Button {
                        store.send(.toggleServiceDescriptions, animation: .default)
                    } label: {
                        HStack(spacing: 4) {
                            Text(
                                store.showServiceDescriptions
                                    ? L10n.psfBtnNotExplain
                                    : L10n.psfBtnExplain
                            )
                            .font(.subheadline.weight(.semibold))
                            Image(
                                systemName: store.showServiceDescriptions
                                    ? SFSymbolName.eyeSlash
                                    : SFSymbolName.eye
                            )
                            .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(Colors.primary700)
                    }
                    .accessibility(identifier: A11y.pharmacySearchFilter.psfBtnExplainToggle)
                }
                .padding(.top)

                // Service list
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(store.serviceFilters, id: \.self) { filterOption in
                        ServiceRow(
                            filterOption: filterOption,
                            isSelected: store.pharmacyFilterOptions.contains(filterOption),
                            showDescription: store.showServiceDescriptions
                        ) {
                            store.send(.toggleFilter(filterOption))
                        }
                    }
                }
                .accessibility(identifier: A11y.pharmacySearchFilter.psfServiceList)

                // Footnote legend
                VStack(alignment: .trailing, spacing: 2) {
                    Text(L10n.psfTxtServiceFootnoteStatutory)
                    Text(L10n.psfTxtServiceFootnoteAll)
                }
                .font(.caption)
                .foregroundColor(Colors.systemLabel)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.vertical, 4)
                .accessibility(identifier: A11y.pharmacySearchFilter.psfServiceFootnote)
            }
            .accessibility(identifier: A11y.pharmacySearchFilter.psfServiceSection)
        }
    }

    // MARK: - Service Row

    struct ServiceRow: View {
        let filterOption: PharmacySearchFilterDomain.PharmacyFilterOption
        let isSelected: Bool
        let showDescription: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(alignment: .center, spacing: 16) {
                    Image(
                        systemName: isSelected
                            ? SFSymbolName.checkmarkCircleFill
                            : SFSymbolName.circle
                    )
                    .font(.body.weight(.semibold))
                    .foregroundColor(Colors.primary700)
                    .frame(width: 22)
                    .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 0) {
                            Text(filterOption.localizedStringKey, bundle: .module)
                                .font(.body)
                                .foregroundColor(Colors.systemLabel)
                                .fixedSize(horizontal: false, vertical: true)

                            if let footnote = filterOption.costFootnote {
                                Text(footnote)
                                    .font(.body)
                                    .foregroundColor(Colors.systemLabel)
                            }
                        }

                        if showDescription,
                           let descKey = filterOption.localizedDescriptionKey {
                            Text(descKey, bundle: .module)
                                .font(.caption)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isToggle)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        }
    }
}

struct PharmacySearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacySearchFilterView(store: PharmacySearchFilterDomain.Dummies.store)
            .previewDisplayName("Default (open + delivery + parking)")

        PharmacySearchFilterView(
            store: Store(
                initialState: .init(pharmacyFilterOptions: Shared(value: [
                    PharmacySearchFilterDomain.PharmacyFilterOption.delivery,
                    .publicTransport,
                    .barrierFree,
                ]))
            ) { EmptyReducer() }
        )
        .previewDisplayName("Delivery hint + on-site")

        PharmacySearchFilterView(
            store: Store(
                initialState: .init(
                    pharmacyFilterOptions: Shared<[PharmacySearchFilterDomain
                            .PharmacyFilterOption]>(value: [.allergyTest, .vaccination]),
                    showServiceDescriptions: true
                )
            ) { PharmacySearchFilterDomain() }
        )
        .previewDisplayName("Services expanded")

        PharmacySearchFilterView(store: PharmacySearchFilterDomain.Dummies.store)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark mode")
    }
}
