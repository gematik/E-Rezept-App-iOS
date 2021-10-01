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

struct MedicationDetailsView: View {
    let dosageForm: String?
    let dose: String?
    let pzn: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                text: L10n.prscFdTxtDetailsTitle,
                a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
            )
            .padding([.top, .horizontal])

            VStack(alignment: .leading, spacing: 12) {
                Divider()

                MedicationDetailCellView(value: dosageForm,
                                         title: L10n.prscFdTxtDetailsDosageForm)
                MedicationDetailCellView(value: dose,
                                         title: L10n.prscFdTxtDetailsDose)
                MedicationDetailCellView(value: pzn,
                                         title: L10n.prscFdTxtDetailsPzn,
                                         isLastInSection: true)
            }
        }
    }
}

struct MedicationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationDetailsView(dosageForm: "Filmtabletten",
                                  dose: "N1 12 Stück",
                                  pzn: "06876512")
            MedicationDetailsView(dosageForm: "Filmtabletten",
                                  dose: "N1 12 Stück",
                                  pzn: "06876512")
                .preferredColorScheme(.dark)
        }
    }
}
