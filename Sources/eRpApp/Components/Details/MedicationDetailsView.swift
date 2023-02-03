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

import SwiftUI

struct MedicationDetailsView: View {
    let title: String?
    let dosageForm: String?
    let dose: String?
    let pzn: String?
    let isArchived: Bool
    let lot: String?
    let expiresOn: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                SectionHeaderView(
                    text: LocalizedStringKey(title),
                    a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
                )
                .padding([.top, .horizontal])
            }
            VStack(alignment: .leading, spacing: 12) {
                Divider()

                MedicationDetailCellView(value: dosageForm,
                                         title: L10n.prscFdTxtDetailsDosageForm)
                MedicationDetailCellView(value: dose,
                                         title: L10n.prscFdTxtDetailsDose)
                MedicationDetailCellView(value: pzn,
                                         title: L10n.prscFdTxtDetailsPzn,
                                         isLastInSection: !isArchived)
                if isArchived {
                    MedicationDetailCellView(value: lot,
                                             title: L10n.prscFdTxtDetailsLot)
                    MedicationDetailCellView(value: expiresOn,
                                             title: L10n.prscFdTxtDetailsExpiresOn,
                                             isLastInSection: true)
                }
            }
        }
    }
}

struct MedicationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationDetailsView(title: "Details about this medicine",
                                  dosageForm: "Filmtabletten",
                                  dose: "N1 12 Stück",
                                  pzn: "06876512",
                                  isArchived: false,
                                  lot: "TOTO-5236-VL",
                                  expiresOn: "12.12.2024")
            MedicationDetailsView(title: "Details about this medicine",
                                  dosageForm: "Filmtabletten",
                                  dose: "N1 12 Stück",
                                  pzn: "06876512",
                                  isArchived: true,
                                  lot: "TOTO-5236-VL",
                                  expiresOn: "12.12.2024")
                .preferredColorScheme(.dark)
        }
    }
}
