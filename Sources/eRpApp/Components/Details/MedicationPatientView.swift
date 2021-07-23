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

struct MedicationPatientView: View {
    let name: String?
    let address: String?
    let dateOfBirth: String?
    let phone: String?
    let healthInsurance: String?
    let healthInsuranceState: String?
    let healthInsuranceNumber: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionView(
                text: L10n.prscFdTxtPatientTitle,
                a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
            )
            .padding([.top, .horizontal])

            VStack(alignment: .leading, spacing: 12) {
                Divider()

                MedicationDetailCellView(value: name,
                                         title: L10n.prscFdTxtPatientName)
                MedicationDetailCellView(value: address,
                                         title: L10n.prscFdTxtPatientAddress)
                MedicationDetailCellView(value: dateOfBirth,
                                         title: L10n.prscFdTxtPatientBirthdate)
                MedicationDetailCellView(value: phone,
                                         title: L10n.prscFdTxtPatientPhone)
                MedicationDetailCellView(value: healthInsurance,
                                         title: L10n.prscFdTxtPatientInsurance)
                MedicationDetailCellView(value: localizedStringForInsuranceStatusKey(healthInsuranceState),
                                         title: L10n.prscFdTxtPatientStatus)
                MedicationDetailCellView(value: healthInsuranceNumber,
                                         title: L10n.prscFdTxtPatientInsuranceId,
                                         isLastInSection: true)
            }
        }
    }

    private func localizedStringForInsuranceStatusKey(_ key: String?) -> String? {
        guard let key = key,
              let string = PrescriptionKBVKeyMapping.localizedStringKeyForMemberStatusKey(key) else { return nil }
        return NSLocalizedString(string, comment: "")
    }
}

struct MedicationPatientView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationPatientView(
                name: "Thomas Muster",
                address: "Musterstraße 7 - 12099 Berlin",
                dateOfBirth: "01.10.1981",
                phone: "030 345 567 890",
                healthInsurance: "Grafikerkrankenkasse",
                healthInsuranceState: "Mitglied",
                healthInsuranceNumber: "A123456789"
            )
            MedicationPatientView(
                name: "Thomas Muster",
                address: "Musterstraße 7 - 12099 Berlin",
                dateOfBirth: "01.10.1981",
                phone: "030 345 567 890",
                healthInsurance: "Grafikerkrankenkasse",
                healthInsuranceState: "Mitglied",
                healthInsuranceNumber: "A123456789"
            )
            .preferredColorScheme(.dark)
        }
    }
}
