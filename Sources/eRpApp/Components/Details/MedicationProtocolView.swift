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

import SwiftUI

struct MedicationProtocolView: View {
    var protocolEvents = [(String?, String?)]()
    var lastUpdated: String?
    var errorText: String?

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 16) {
                SectionView(
                    text: L10n.dtlTxtMedProtocol,
                    a11y: A18n.prescriptionDetails.prscDtlTxtMedInfo
                )
                .padding([.top, .horizontal])

                if let errorText = errorText {
                    WarningView(text: errorText)
                        .padding([.top, .horizontal])
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(protocolEvents.indices, id: \.self) { index in
                        MedicationDetailCellView(
                            value: protocolEvents[index].0,
                            subtitle: protocolEvents[index].1,
                            isLastInSection: index == protocolEvents.count - 1
                        )
                    }
                }
            }

            if let lastUpdated = lastUpdated {
                HStack {
                    Text(L10n.prscFdTxtProtocolLastUpdated)
                        + Text(" ")
                        + Text(lastUpdated)
                }
                .font(.subheadline)
                .foregroundColor(Colors.systemLabelSecondary)
            }
        }
    }

    private struct WarningView: View {
        var text: String

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: SFSymbolName.crossIcon)
                    .foregroundColor(Colors.red900)
                    .font(.title3)
                    .padding(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(Font.subheadline)
                        .foregroundColor(Colors.red900)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 16).fill(Colors.red100))
            .border(Colors.red300, width: 0.5, cornerRadius: 16)
        }
    }
}

struct MedicationProtocolView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationProtocolView(lastUpdated: "2020-02-03")
    }
}
