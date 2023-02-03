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

import eRpKit
import eRpStyleKit
import SwiftUI

struct PharmacySearchCell: View {
    var pharmacy: PharmacyLocationViewModel
    var isFavorite = false
    let showDistance: Bool
    var loading = false

    var body: some View {
        HStack(spacing: 16) {
            Image(Asset.Pharmacy.pharmacyPlaceholder)
                .frame(width: 64, height: 64, alignment: .center)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(pharmacy.pharmacyLocation.name ?? "")
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.systemLabel)
                    .padding([.top, .bottom], 1)
                    .accessibilitySortPriority(100)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text(pharmacy.pharmacyLocation.address?.fullAddress ?? "")
                        .lineLimit(1)
                }
                .accessibilitySortPriority(90)
                .foregroundColor(Colors.systemLabelSecondary)

                ColoredOpeningHours(openingState: pharmacy.todayOpeningState)
                    .padding(.top, 1)
                    .accessibilitySortPriority(80)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilitySortPriority(1000)
            .padding(.trailing, showDistance && pharmacy.distanceInM != nil ? 0 : 16)

            if showDistance,
               let distance = pharmacy.formattedDistance {
                Text(distance)
                    .font(Font.footnote.weight(.semibold))
                    .foregroundColor(Colors.systemLabelSecondary)
                    .accessibilitySortPriority(50)
                    .padding(.trailing, 4)
            }

            if isFavorite {
                Image(systemName: SFSymbolName.starFill).foregroundColor(Colors.starYellow)
                    .accessibilitySortPriority(60)
            }

            if loading {
                ProgressView()
            }
        }
        .accessibilityElement(children: .combine)
    }

    struct ColoredOpeningHours: View {
        let openingState: PharmacyOpenHoursCalculator.TodaysOpeningState

        var body: some View {
            Group {
                switch openingState {
                case let .open(closingDateTime: time):
                    Group {
                        Text(L10n.phaSearchTxtOpenUntil) +
                            Text(" \(time)")
                    }.foregroundColor(Colors.secondary600)
                case let .closingSoon(closingDateTime: time):
                    Group {
                        Text(L10n.phaSearchTxtClosingSoon) +
                            Text(" - \(time)")
                    }.foregroundColor(Colors.yellow700)
                case let .willOpen(_, openingDateTime):
                    Group {
                        Text(L10n.phaSearchTxtOpensAt) +
                            Text(" \(openingDateTime)")
                    }.foregroundColor(Colors.yellow700)
                case .closed:
                    Text(L10n.phaSearchTxtClosed)
                        .foregroundColor(Colors.systemLabelSecondary)
                default:
                    EmptyView()
                }
            }

            .font(Font.subheadline.weight(.semibold))
        }
    }
}

struct PharmacySearchCell_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            SingleElementSectionContainer(
                header: {
                    Text("container")
                },
                content: {
                    ForEach(PharmacyLocationViewModel.Dummies.pharmacies, id: \.self) { pharmacyViewModel in
                        Button(
                            action: {},
                            label: {
                                Label(
                                    title: {
                                        PharmacySearchCell(pharmacy: pharmacyViewModel, showDistance: true)
                                    },
                                    icon: {}
                                )
                            }
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibility(identifier: A11y.pharmacySearch.phaSearchTxtResultListEntry)
                        .buttonStyle(.navigation(showSeparator: true, minChevronSpacing: 0))
                        .modifier(SectionContainerCellModifier(last: false))
                    }
                }
            )
            .sectionContainerStyle(.inline)
        }
        .background(Colors.backgroundSecondary)
        .environment(\.locale, Locale(identifier: "de_DE"))
    }
}
