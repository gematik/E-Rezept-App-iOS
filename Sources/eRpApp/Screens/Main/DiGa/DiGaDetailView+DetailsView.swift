//
//  Copyright (c) 2025 gematik GmbH
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

extension DiGaDetailView {
    struct DetailsView: View {
        @Perception.Bindable var store: StoreOf<DiGaDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                SectionContainer {
                    SubTitle(
                        title: store.diGaTask.appName ?? L10n.digaDtlTxtNa.text,
                        description: L10n.digaDtlTxtDigaName
                    )
                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtAppName)

                    // Readd these rows when Bfarm is available
//                    SubTitle(
//                        title: store.bfarmDiGaDetails?.languages ?? L10n.digaDtlTxtNa.text,
//                        description: L10n.digaDtlTxtLanguages
//                    )
//                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtLanguages)
//
//                    SubTitle(
//                        title: store.bfarmDiGaDetails?.platform ?? L10n.digaDtlTxtNa.text,
//                        description: L10n.digaDtlTxtPlatform
//                    )
//                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtPlatform)
//
//                    SubTitle(
//                        title: store.bfarmDiGaDetails?.contractMedicalService?.description ?? L10n.digaDtlTxtNa.text,
//                        description: L10n.digaDtlTxtMedicalService
//                    )
//                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtMedicalService)
//
//                    SubTitle(
//                        title: store.bfarmDiGaDetails?.additionalDevice ?? L10n.digaDtlTxtNa.text,
//                        description: L10n.digaDtlTxtAdditionalDevices
//                    )
//                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtAdditionalDevices)
//
//                    SubTitle(
//                        title: store.bfarmDiGaDetails?.patientCost ?? L10n.digaDtlTxtNa.text,
//                        description: L10n.digaDtlTxtPatientCost
//                    )
//                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtPatientCost)
//
//                    SubTitle(
//                        title: store.bfarmDiGaDetails?.producerCost ?? L10n.digaDtlTxtNa.text,
//                        description: L10n.digaDtlTxtProducerCost
//                    )
//                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtProductionCost)

                    Button(action: { store.send(.setNavigation(tag: .patient)) }, label: {
                        SubTitle(
                            title: store.diGaTask.patientName ?? L10n.digaDtlTxtNa.text,
                            details: L10n.prscDtlTxtPractitionerPerson
                        )
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)

                    Button(action: { store.send(.setNavigation(tag: .practitioner)) }, label: {
                        SubTitle(
                            title: store.diGaTask.practitioner ?? L10n.digaDtlTxtNa.text,
                            details: L10n.prscDtlTxtPractitionerPerson
                        )
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)

                    Button(action: { store.send(.setNavigation(tag: .organization)) }, label: {
                        SubTitle(
                            title: store.diGaTask.organization ?? L10n.digaDtlTxtNa.text,
                            details: L10n.prscDtlTxtPractitionerPerson
                        )
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)
//                }, moreContent: {
                    SubTitle(
                        title: store.diGaTask.authoredOnDate ?? L10n.digaDtlTxtNa.text,
                        description: L10n.digaDtlTxtAuthoredDate
                    )
                    .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtAuthoredOn)

                    Button(
                        action: { store.send(.setNavigation(tag: .technicalInformations)) },
                        label: {
                            SubTitle(title: L10n.prscDtlBtnTechnicalInformations)
                        }
                    )
                    .buttonStyle(.navigation)
                    .accessibilityIdentifier(A11y.prescriptionDetails
                        .prscDtlBtnTechnicalInformations)
                }
                .sectionContainerStyle(.inline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DiGaDetailView.DetailsView(store: DiGaDetailDomain.Dummies.store)
    }
}
