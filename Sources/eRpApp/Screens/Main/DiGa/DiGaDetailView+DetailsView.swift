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
        @Bindable var store: StoreOf<DiGaDetailDomain>

        var body: some View {
            if store.bfarmDiGaDetails == nil {
                BfArMErrorHintView()
                    .padding()
            }

            SectionContainer(
                content: {
                    LabeledContent {
                        Text(store.diGaTask.appName ?? L10n.digaDtlTxtNa.text)
                    } label: {
                        Text(L10n.digaDtlTxtDigaName)
                    }
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtAppName)

                    LabeledContent {
                        Text(store.bfArMDisplayInfo?.languages ?? L10n.digaDtlTxtBfarmNa.text)
                    } label: {
                        Text(L10n.digaDtlTxtLanguages)
                    }
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtLanguages)

                    LabeledContent {
                        Text(store.bfArMDisplayInfo?.platform ?? L10n.digaDtlTxtBfarmNa.text)
                    } label: {
                        Text(L10n.digaDtlTxtPlatform)
                    }
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtPlatform)

                    LabeledContent {
                        Text(store.bfArMDisplayInfo?.contractMedicalService ?? L10n.digaDtlTxtBfarmNa.text)
                    } label: {
                        Text(L10n.digaDtlTxtMedicalService)
                    }
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtMedicalService)

                    LabeledContent {
                        Text(store.bfArMDisplayInfo?.additionalDevices ?? L10n.digaDtlTxtBfarmNa.text)
                    } label: {
                        Text(L10n.digaDtlTxtAdditionalDevices)
                    }
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtAdditionalDevices)

                    Button(action: { store.send(.setNavigation(tag: .duesInfo)) }, label: {
                        LabeledContent {
                            Text(L10n.digaDtlTxtPatientCostZero.text)
                        } label: {
                            Text(L10n.digaDtlTxtPatientCost)
                        }
                    })
                    .labeledContentStyle(.vertical(icon: SFSymbolName.info))
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtPatientCost)

                    LabeledContent {
                        Text(store.bfArMDisplayInfo?.manufacturerCost ?? L10n.digaDtlTxtBfarmNa.text)
                    } label: {
                        Text(L10n.digaDtlTxtProducerCost)
                    }
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtProductionCost)

                    Button(action: { store.send(.setNavigation(tag: .patient)) }, label: {
                        LabeledContent {
                            Text(store.diGaTask.patientName ?? L10n.digaDtlTxtNa.text)
                        } label: {
                            Text(L10n.prscDtlTxtPractitionerPerson)
                        }
                    })
                    .buttonStyle(.navigation)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)

                    Button(action: { store.send(.setNavigation(tag: .practitioner)) }, label: {
                        LabeledContent {
                            Text(store.diGaTask.practitioner ?? L10n.digaDtlTxtNa.text)
                        } label: {
                            Text(L10n.prscDtlTxtPractitionerPerson)
                        }
                    })
                    .buttonStyle(.navigation)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)

                    Button(action: { store.send(.setNavigation(tag: .organization)) }, label: {
                        LabeledContent {
                            Text(store.diGaTask.organization ?? L10n.digaDtlTxtNa.text)
                        } label: {
                            Text(L10n.prscDtlTxtPractitionerPerson)
                        }
                    })
                    .buttonStyle(.navigation)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)
                }, moreContent: {
                    LabeledContent {
                        Text(store.diGaTask.authoredOnDate ?? L10n.digaDtlTxtNa.text)
                    } label: {
                        Text(L10n.digaDtlTxtAuthoredDate)
                    }
                    .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtAuthoredOn)

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
            .accessibilityIdentifier(A11y.diga.detail.digaDtlTxtHintNoConnection)
            .border(Colors.yellow300, width: 0.5, cornerRadius: 12)
        }
    }
}

#Preview {
    NavigationStack {
        DiGaDetailView.DetailsView(store: DiGaDetailDomain.Dummies.store)
    }
}
