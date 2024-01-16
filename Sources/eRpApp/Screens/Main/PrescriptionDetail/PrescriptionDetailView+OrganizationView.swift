//
//  Copyright (c) 2024 gematik GmbH
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
    struct OrganizationView: View {
        let store: Store<
            PrescriptionDetailDomain.Destinations.OrganizationState,
            PrescriptionDetailDomain.Destinations.Action.None
        >

        var body: some View {
            WithViewStore(store) { $0 } content: { viewStore in
                ScrollView(.vertical) {
                    SectionContainer {
                        SubTitle(
                            title: viewStore.organization.name ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationName
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrName)

                        SubTitle(
                            title: viewStore.organization.identifier ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationId
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrIdentifier)

                        SubTitle(
                            title: viewStore.organization.address ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationAddress
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrAddress)

                        SubTitle(
                            title: viewStore.organization.phone ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtOrganizationPhone
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlOrPhone)

                        SubTitle(
                            title: viewStore.organization.email ?? L10n.prscFdTxtNa.text,
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
