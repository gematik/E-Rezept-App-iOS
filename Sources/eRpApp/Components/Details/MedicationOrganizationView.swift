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

struct MedicationOrganizationView: View {
    let name: String?
    let address: String?
    let bsnr: String?
    let phone: String?
    let email: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionView(
                text: L10n.prscFdTxtOrganizationTitle,
                a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
            )
            .padding([.top, .horizontal])

            VStack(alignment: .leading, spacing: 12) {
                Divider()

                MedicationDetailCellView(value: name,
                                         title: L10n.prscFdTxtOrganizationName)
                MedicationDetailCellView(value: address,
                                         title: L10n.prscFdTxtOrganizationAddress)
                MedicationDetailCellView(value: bsnr,
                                         title: L10n.prscFdTxtOrganizationId)
                MedicationDetailCellView(value: phone,
                                         title: L10n.prscFdTxtOrganizationPhone)
                MedicationDetailCellView(value: email,
                                         title: L10n.prscFdTxtOrganizationEmail,
                                         isLastInSection: true)
            }
        }
    }
}

struct MedicationInstituteView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationOrganizationView(
                name: "Muster, Muster & Muster",
                address: "Musterweg 1\n86163 Augsburg",
                bsnr: "999666999",
                phone: "635293893",
                email: "info@mustermustermuster.de"
            )
            MedicationOrganizationView(
                name: "Muster, Muster & Muster",
                address: "Musterweg 1\n86163 Augsburg",
                bsnr: "999666999",
                phone: "635293893",
                email: "info@mustermustermuster.de"
            )
            .preferredColorScheme(.dark)
        }
    }
}
