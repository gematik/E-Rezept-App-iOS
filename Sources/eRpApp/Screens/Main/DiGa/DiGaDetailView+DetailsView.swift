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
import eRpKit
import eRpStyleKit
import SwiftUI

extension DiGaDetailView {
    struct DetailsView: View {
        @Perception.Bindable var store: StoreOf<DiGaDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                if store.bfarmDiGaDetails == nil {
                    BfArMErrorHintView()
                        .padding()
                }

                SectionContainer(
                    content: {
                        SubTitle(
                            title: store.diGaTask.appName ?? L10n.digaDtlTxtNa.text,
                            description: L10n.digaDtlTxtDigaName
                        )
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtAppName)

                        SubTitle(
                            title: store.bfArMDisplayInfo?.languages ?? L10n.digaDtlTxtNa.text,
                            description: L10n.digaDtlTxtLanguages
                        )
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtLanguages)

                        SubTitle(
                            title: store.bfArMDisplayInfo?.platform ?? L10n.digaDtlTxtNa.text,
                            description: L10n.digaDtlTxtPlatform
                        )
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtPlatform)

                        SubTitle(
                            title: store.bfArMDisplayInfo?.contractMedicalService ?? L10n.digaDtlTxtNa.text,
                            description: L10n.digaDtlTxtMedicalService
                        )
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtMedicalService)

                        SubTitle(
                            title: store.bfArMDisplayInfo?.additionalDevices ?? L10n.digaDtlTxtNa.text,
                            description: L10n.digaDtlTxtAdditionalDevices
                        )
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtAdditionalDevices)

                        Button(action: { store.send(.setNavigation(tag: .duesInfo)) }, label: {
                            SubTitle(
                                title: L10n.digaDtlTxtPatientCostZero.text,
                                description: L10n.digaDtlTxtPatientCost
                            ).subTitleStyle(.info)
                        })
                            .buttonStyle(.navigation)
                            .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtPatientCost)

                        SubTitle(
                            title: store.bfArMDisplayInfo?.manufacturerCost ?? L10n.digaDtlTxtNa.text,
                            description: L10n.digaDtlTxtProducerCost
                        )
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtProductionCost)

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
                    }, moreContent: {
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
                )
                .sectionContainerStyle(.inline)
                .smallSheet(
                    $store.scope(state: \.destination?.duesInfo, action: \.destination.duesInfo)
                ) { _ in
                    DiGaDuesInfoView(store: store)
                }
            }
        }
    }

    struct BfArMErrorHintView: View {
        var body: some View {
            HStack(spacing: 0) {
                Image(systemName: SFSymbolName.exclamationMark)
                    .foregroundColor(Colors.yellow900)
                    .font(.title3)
                    .padding(.trailing)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.digaDtlTxtBfarmLoadingHint)
                        .font(Font.subheadline)
                        .foregroundColor(Colors.yellow900)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).fill(Colors.yellow100))
            .accessibilityElement(children: .combine)
            .border(Colors.yellow300, width: 0.5, cornerRadius: 12)
        }
    }
}

#Preview {
    NavigationStack {
        DiGaDetailView.DetailsView(store: DiGaDetailDomain.Dummies.store)
    }
}
