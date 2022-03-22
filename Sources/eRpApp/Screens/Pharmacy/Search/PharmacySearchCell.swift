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

import Pharmacy
import SwiftUI

struct PharmacySearchCell: View {
    static let minimumOpenMinutesLeftBeforeWarn = 30

    let pharmacy: PharmacyLocationViewModel
    var timeOnlyFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        if let preferredLang = Locale.preferredLanguages.first,
           preferredLang.starts(with: "de") {
            dateFormatter.dateFormat = "HH:mm 'Uhr'"
        } else {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        return dateFormatter
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if pharmacy.pharmacyLocation.isErxReady {
                    ErxReadinessBadge(detailedText: false)
                        .padding([.top, .bottom], 1)
                }

                Text("\(pharmacy.pharmacyLocation.name ?? "")")
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.systemLabel)
                    .padding([.top, .bottom], 1)
                HStack {
                    Text(pharmacy.pharmacyLocation.address?.fullAddress ?? "")
                }
                .foregroundColor(Colors.systemLabelSecondary)

                Group {
                    if case let PharmacyOpenHoursCalculator.TodaysOpeningState
                        .open(minutesLeft, closingDateTime) = pharmacy.todayOpeningState {
                        if let minutesLeft = minutesLeft,
                           minutesLeft < Self.minimumOpenMinutesLeftBeforeWarn {
                            Group {
                                Text(L10n.phaSearchTxtClosingSoon) +
                                    Text(" - \(timeOnlyFormatter.string(from: closingDateTime))")
                            }.foregroundColor(Colors.yellow700)
                        } else {
                            Group {
                                Text(L10n.phaSearchTxtOpenUntil) +
                                    Text(" \(timeOnlyFormatter.string(from: closingDateTime))")
                            }.foregroundColor(Colors.secondary600)
                        }
                    } else if case let PharmacyOpenHoursCalculator.TodaysOpeningState
                        .willOpen(_, openingDateTime) = pharmacy.todayOpeningState {
                        Group {
                            Text(L10n.phaSearchTxtOpensAt) +
                                Text(" \(timeOnlyFormatter.string(from: openingDateTime))")
                        }.foregroundColor(Colors.yellow700)
                    } else if case PharmacyOpenHoursCalculator.TodaysOpeningState.closed =
                        pharmacy.todayOpeningState {
                        Text(L10n.phaSearchTxtClosed)
                            .foregroundColor(Colors.systemLabelSecondary)
                    }
                }
                .padding(.top, 1)
                .font(Font.subheadline.weight(.semibold))
            }
            .accessibilityElement(children: .combine)
            .padding([.top, .bottom], 8)

            Spacer()

            if let distance = pharmacy.distanceInKm {
                Text(String(format: "%.2f km", distance))
                    .font(Font.footnote.weight(.semibold))
                    .foregroundColor(Colors.systemLabelSecondary)
                    .padding([.leading, .trailing], 8)
            }

            Image(systemName: SFSymbolName.rightDisclosureIndicator)
                .foregroundColor(Colors.systemLabelTertiary)
                .unredacted()
        }
    }
}

struct PharmacySearchCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PharmacySearchCell(
                pharmacy: PharmacyLocationViewModel(
                    pharmacy: Pharmacy.PharmacyLocation.Dummies.pharmacy
                )
            )

            PharmacySearchCell(
                pharmacy: PharmacyLocationViewModel(
                    pharmacy: Pharmacy.PharmacyLocation.Dummies.pharmacyInactive
                )
            )
        }
    }
}
