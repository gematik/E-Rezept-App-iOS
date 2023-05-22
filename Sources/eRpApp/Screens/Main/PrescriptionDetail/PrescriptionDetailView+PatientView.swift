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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    struct PatientView: View {
        let store: Store<PrescriptionDetailDomain.Destinations.PatientState, PrescriptionDetailDomain.Action>

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical) {
                    SectionContainer {
                        SubTitle(
                            title: viewStore.patient.name ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPatientName
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPaName)

                        SubTitle(
                            title: viewStore.patient.insuranceId ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPatientInsuranceId
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPaInsuranceId)

                        SubTitle(
                            title: viewStore.patient.address ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPatientAddress
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPaAddress)

                        SubTitle(
                            title: viewStore.patient.birthDate ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPatientBirthdate
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPaBirthDate)

                        SubTitle(
                            title: viewStore.patient.phone ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPatientPhone
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPaPhone)

                        SubTitle(
                            title: viewStore.patient.insurance ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPatientInsurance
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPaInsurance)

                        SubTitle(
                            title: viewStore.patient.localizedStausMember ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPatientStatus
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPaStatus)

                    }.sectionContainerStyle(.inline)
                }
                .navigationBarTitle(Text(L10n.prscFdTxtPatientTitle), displayMode: .inline)
            }
        }
    }
}

extension ErxPatient {
    var localizedStausMember: String? {
        let patientMemberStatusKeys: [String: String] = [
            "1": "kbv_member_status_1",
            "3": "kbv_member_status_3",
            "5": "kbv_member_status_5",
        ]

        guard let statusKey = status,
              let localizedStringKey = patientMemberStatusKeys[statusKey.lowercased()] else {
            return status
        }
        return NSLocalizedString(localizedStringKey, comment: "")
    }
}
