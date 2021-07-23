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

import SwiftUI

struct MedicationNameView: View {
    let medicationText: String?
    let expirationDate: String?
    let redeemedOnDate: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionViewString(
                text: medicationText ?? NSLocalizedString("prsc_fd_txt_na", comment: ""),
                a11y: medicationText ?? ""
            )
            .fixedSize(horizontal: false, vertical: true)

            .padding([.top, .horizontal])

            HStack {
                if redeemedOnDate != nil {
                    Text(L10n.dtlTxtMedRedeemedOn)
                        + Text(" ")
                        + Text(redeemedOnDate ?? NSLocalizedString("prsc_fd_txt_na", comment: ""))
                    Spacer()
                } else if expirationDate != nil {
                    Text(L10n.dtlTxtMedRedeemableUntil)
                        + Text(" ")
                        + Text(expirationDate ?? NSLocalizedString("prsc_fd_txt_na", comment: ""))
                    Spacer()
                }
            }
            .font(Font.subheadline)
            .padding([.bottom, .horizontal])
            .foregroundColor(Colors.systemLabelSecondary)
        }
    }
}

struct MedicationNameView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationNameView(medicationText: "Medication 3",
                           expirationDate: "Noch einlösbar bis zum 16.01.2021",
                           redeemedOnDate: nil)
    }
}
