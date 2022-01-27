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

import SwiftUI

struct MedicationWorkAccidentView: View {
    let accidentDate: String?
    let number: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                text: L10n.prscFdTxtAccidentTitle,
                a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
            )
            .padding([.top, .horizontal])

            VStack(alignment: .leading, spacing: 12) {
                Divider()

                MedicationDetailCellView(value: accidentDate,
                                         title: L10n.prscFdTxtAccidentDate)
                MedicationDetailCellView(value: number,
                                         title: L10n.prscFdTxtAccidentId,
                                         isLastInSection: true)
            }
        }
    }
}

struct MedicationWorkAccidentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationWorkAccidentView(
                accidentDate: "24.12.2020",
                number: "1234567890"
            )
            MedicationWorkAccidentView(
                accidentDate: "24.12.2020",
                number: "1234567890"
            )
            .preferredColorScheme(.dark)
        }
    }
}
