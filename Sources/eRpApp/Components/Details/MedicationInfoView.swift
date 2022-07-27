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

import SwiftUI

struct MedicationInfoView: View {
    /// sourcery: StringAssetInitialized
    struct CodeInfo {
        let code: String?
        let codeTitle: LocalizedStringKey
        let accessibilityId: String
    }

    let codeInfos: [CodeInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                text: L10n.dtlTxtMedInfo,
                a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
            )
            .padding([.top, .horizontal])

            VStack(alignment: .leading, spacing: 12) {
                Divider()

                ForEach(codeInfos.indices, id: \.self) { index in
                    MedicationDetailCellView(value: codeInfos[index].code,
                                             title: codeInfos[index].codeTitle,
                                             isLastInSection: index == codeInfos.count - 1)
                        .accessibilityIdentifier(codeInfos[index].accessibilityId)
                        .contextMenu {
                            Button(
                                action: {
                                    UIPasteboard.general.string = "\(codeInfos[index].code ?? "")"
                                }, label: {
                                    Label(L10n.dtlBtnCopyClipboard,
                                          systemImage: SFSymbolName.copy)
                                }
                            )
                        }
                }
            }
        }
    }
}

struct MedicationInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationInfoView(codeInfos: [
            MedicationInfoView.CodeInfo(
                code: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                codeTitle: "Access-Code",
                accessibilityId: ""
            ),
            MedicationInfoView.CodeInfo(
                code: "0390f983-1e67-11b2-8555-63bf44e44fb8",
                codeTitle: "Task-ID",
                accessibilityId: ""
            ),
        ])
    }
}
