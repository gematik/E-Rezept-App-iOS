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
        @Bindable var store: StoreOf<PractitionerDomain>

        var body: some View {
            ScrollView(.vertical) {
                SectionContainer {
                    LabeledContent {
                        Text(store.practitioner.name ?? L10n.prscFdTxtNa.text)
                    } label: {
                        Text(L10n.prscFdTxtPractitionerName)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrName)

                    LabeledContent {
                        Text(store.practitioner.qualification ?? L10n.prscFdTxtNa.text)
                    } label: {
                        Text(L10n.prscFdTxtPractitionerQualification)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrQualification)

                    LabeledContent {
                        Text(store.practitioner.lanr ?? L10n.prscFdTxtNa.text)
                    } label: {
                        Text(L10n.prscFdTxtPractitionerId)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrLanr)

                    LabeledContent {
                        Text(store.practitioner.address ?? L10n.prscFdTxtNa.text)
                    } label: {
                        Text(L10n.prscDtlPrTxtAddress)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrAddress)

                    LabeledContent {
                        Text(store.practitioner.email ?? L10n.prscFdTxtNa.text)
                    } label: {
                        Text(L10n.prscDtlPrTxtEmail)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlPrEmail)
                }.sectionContainerStyle(.inline)
            }
            .navigationBarTitle(Text(L10n.prscFdTxtPractitionerTitle), displayMode: .inline)
        }
    }
}
