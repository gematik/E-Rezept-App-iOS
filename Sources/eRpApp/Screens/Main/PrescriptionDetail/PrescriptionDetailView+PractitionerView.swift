//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    struct PractitionerView: View {
        @Perception.Bindable var store: StoreOf<PractitionerDomain>

        var body: some View {
            WithPerceptionTracking {
                ScrollView(.vertical) {
                    SectionContainer {
                        SubTitle(
                            title: store.practitioner.name ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPractitionerName
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrName)

                        SubTitle(
                            title: store.practitioner.qualification ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPractitionerQualification
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrQualification)

                        SubTitle(
                            title: store.practitioner.lanr ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtPractitionerId
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrLanr)

                        SubTitle(
                            title: store.practitioner.address ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscDtlPrTxtAddress
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrAddress)

                        SubTitle(
                            title: store.practitioner.email ?? L10n.prscFdTxtNa.text,
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
