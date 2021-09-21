//
//  Copyright (c) 2021 gematik GmbH
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

                MedicationNameView(medicationText: viewStore.state.erxTask.medicationName,
                                   expirationDate: uiFormattedDate(dateString: viewStore.state.erxTask.expiresOn),
                                   redeemedOnDate: uiFormattedDate(dateString: viewStore.state.erxTask.redeemedOn))

                MedicationRedeemView(
                    text: viewStore.state.isRedeemed ? L10n.dtlBtnToogleMarkedRedeemed : L10n.dtlBtnToogleMarkRedeemed,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: viewStore.state.isRedeemed
                ) {
                    viewStore.send(.toggleRedeemPrescription)
                }

                if !viewStore.state.erxTask.isRedeemed {
                    HintView<PrescriptionDetailDomain.Action>(
                        hint: Hint(id: A11y.prescriptionDetails.prscDtlHntKeepOverview,
                                   title: NSLocalizedString("dtl_txt_hint_overview_title", comment: ""),
                                   message: NSLocalizedString("dtl_txt_hint_overview_message", comment: ""),
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
                    protocolEvents: [(uiFormattedDate(dateString: viewStore.state.erxTask.authoredOn),
                                      NSLocalizedString("dtl_txt_scanned_on", comment: ""))],
                    lastUpdated: uiFormattedDate(dateString: viewStore.state.erxTask.redeemedOn)
                )

                MedicationInfoView(codeInfos: [
                    MedicationInfoView.CodeInfo(
                        code: viewStore.state.erxTask.accessCode,
                        codeTitle: L10n.dtlTxtAccessCode
                    ),
                    MedicationInfoView.CodeInfo(
                        code: viewStore.state.erxTask.id,
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
           let date = AppContainer.shared.fhirDateFormatter.date(from: dateString, format: .yearMonthDay) {
            return AppContainer.shared.uiDateFormatter.string(from: date)
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
