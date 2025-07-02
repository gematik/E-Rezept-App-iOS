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
    struct OrganizationView: View {
        @Perception.Bindable var store: StoreOf<OrganizationDomain>

        var body: some View {
            WithPerceptionTracking {
                ScrollView(.vertical) {
                    SectionContainer {
                        SubTitle(
                            title: store.organization.name ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationName
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrName)

                        SubTitle(
                            title: store.organization.identifier ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationId
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrIdentifier)

                        SubTitle(
                            title: store.organization.address ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationAddress
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrAddress)

                        SubTitle(
                            title: store.organization.phone ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationPhone
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrPhone)

                        SubTitle(
                            title: store.organization.email ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationEmail
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrEmail)
                    }.sectionContainerStyle(.inline)
                }
                .navigationBarTitle(Text(L10n.prscFdTxtOrganizationTitle), displayMode: .inline)
            }
        }
    }
}
