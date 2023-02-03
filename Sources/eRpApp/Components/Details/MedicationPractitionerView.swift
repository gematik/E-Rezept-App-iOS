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

struct MedicationPractitionerView: View {
    let name: String?
    let medicalSpeciality: String?
    let lanr: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                text: L10n.prscFdTxtPractitionerTitle,
                a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
            )
            .padding([.top, .horizontal])

            VStack(alignment: .leading, spacing: 12) {
                Divider()

                MedicationDetailCellView(value: name,
                                         title: L10n.prscFdTxtPractitionerName)
                MedicationDetailCellView(value: medicalSpeciality,
                                         title: L10n.prscFdTxtPractitionerQualification)
                MedicationDetailCellView(value: lanr,
                                         title: L10n.prscFdTxtPractitionerId,
                                         isLastInSection: true)
            }
        }
    }
}

struct MedicationPractitionerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationPractitionerView(
                name: "Dr. Manuela Muster",
                medicalSpeciality: "Allgemeinmedizin",
                lanr: "635293893"
            )
            MedicationPractitionerView(
                name: "Dr. Manuela Muster",
                medicalSpeciality: "Allgemeinmedizin",
                lanr: "635293893"
            )
            .preferredColorScheme(.dark)
        }
    }
}
