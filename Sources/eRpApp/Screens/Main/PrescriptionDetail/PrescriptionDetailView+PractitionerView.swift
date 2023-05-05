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
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    struct PractitionerView: View {
        let store: Store<PrescriptionDetailDomain.Destinations.PractitionerState, PrescriptionDetailDomain.Action>

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical) {
                    SectionContainer {
                        SubTitle(
                            title: viewStore.practitioner.name ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPractitionerName
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrName)

                        SubTitle(
                            title: viewStore.practitioner.qualification ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPractitionerQualification
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrQualification)

                        SubTitle(
                            title: viewStore.practitioner.lanr ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPractitionerId
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrLanr)

                        SubTitle(
                            title: viewStore.practitioner.address ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscDtlPrTxtAddress
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrAddress)

                        SubTitle(
                            title: viewStore.practitioner.email ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscDtlPrTxtEmail
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrEmail)
                    }.sectionContainerStyle(.inline)
                }
                .navigationBarTitle(Text(L10n.prscFdTxtPractitionerTitle), displayMode: .inline)
            }
        }
    }
}
