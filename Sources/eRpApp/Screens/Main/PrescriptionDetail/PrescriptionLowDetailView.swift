//
//  Copyright (c) 2022 gematik GmbH
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
import SwiftUI

struct PrescriptionLowDetailView: View {
    let store: PrescriptionDetailDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.vertical) {
                VStack {
                    if let image = viewStore.loadingState.value {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .background(Colors.systemColorWhite) // No darkmode to get contrast
                            .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                            .accessibility(identifier: A18n.redeem.matrixCode.rphImgMatrixcode)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity)
                    .border(Colors.systemGray3, cornerRadius: 16)
                    .padding()

                MedicationNameView(medicationText: viewStore.state.prescription.actualMedication?.name,
                                   dateString: viewStore.state.prescription.statusMessage)

                MedicationRedeemView(
                    text: viewStore.state.isArchived ? L10n.dtlBtnToogleMarkedRedeemed : L10n.dtlBtnToogleMarkRedeemed,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: viewStore.state.isArchived
                ) {
                    viewStore.send(.toggleRedeemPrescription)
                }

                if !viewStore.state.prescription.isArchived {
                    HintView<PrescriptionDetailDomain.Action>(
                        hint: Hint(id: A11y.prescriptionDetails.prscDtlHntKeepOverview,
                                   title: L10n.dtlTxtHintOverviewTitle.text,
                                   message: L10n.dtlTxtHintOverviewMessage.text,
                                   actionText: nil,
                                   action: nil,
                                   imageName: Asset.Prescriptions.Details.apothekerin.name,
                                   closeAction: nil,
                                   style: .neutral,
                                   buttonStyle: .tertiary,
                                   imageStyle: .topAligned),
                        textAction: {},
                        closeAction: nil
                    )
                    .padding()
                }

                MedicationProtocolView(
                    protocolEvents: [(uiFormattedDate(dateString: viewStore.state.prescription.authoredOn),
                                      L10n.dtlTxtScannedOn.text)],
                    lastUpdated: uiFormattedDate(dateString: viewStore.state.prescription.redeemedOn)
                )

                MedicationInfoView(codeInfos: [
                    MedicationInfoView.CodeInfo(
                        code: viewStore.state.prescription.accessCode,
                        codeTitle: L10n.dtlTxtAccessCode
                    ),
                    MedicationInfoView.CodeInfo(
                        code: viewStore.state.prescription.id,
                        codeTitle: L10n.dtlTxtTaskId
                    ),
                ])

                MedicationRemoveButton {
                    viewStore.send(.delete)
                }
            }
            .alert(
                self.store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
            .onAppear {
                viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
            }
            .navigationBarTitle(L10n.dtlTxtTitle, displayMode: .inline)
        }
    }

    private func uiFormattedDate(dateString: String?) -> String? {
        if let dateString = dateString,
           let date = globals.fhirDateFormatter.date(from: dateString, format: .yearMonthDay) {
            return globals.uiDateFormatter.string(from: date)
        }
        return dateString
    }
}

struct PrescriptionLowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrescriptionLowDetailView(store: PrescriptionDetailDomain.Dummies.store)
        }
    }
}
