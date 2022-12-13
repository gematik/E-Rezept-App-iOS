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

struct OrderCellView: View {
    let title: String?
    let subtitle: String

    var isNew: Bool
    var prescriptionCount: Int

    let action: () -> Void

    init(title: String?,
         subtitle: String,
         isNew: Bool = false,
         prescriptionCount: Int = 0,
         action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isNew = isNew
        self.prescriptionCount = prescriptionCount
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title ?? L10n.ordTxtNoPharmacyName.text)
                            .font(Font.body.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Colors.systemLabel)

                        Text(subtitle)
                            .font(Font.subheadline.weight(.light))
                            .foregroundColor(Colors.systemLabelSecondary)
                    }

                    Spacer(minLength: 8)

                    if isNew {
                        StatusView(title: L10n.ordListStatusNew, backgroundColor: Colors.primary100)
                    } else {
                        StatusView(
                            title: L10n.ordListStatusCount(prescriptionCount),
                            foregroundColor: Colors.systemLabelSecondary
                        )
                    }

                    Image(systemName: SFSymbolName.chevronForward)
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.body.weight(.semibold))
                }
                .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)
                    .padding(.leading)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct OrderRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OrderCellView(title: "Albrecht Apotheke ", subtitle: "02.09.2022", prescriptionCount: 1) {}
            OrderCellView(title: "Albrecht Apotheke", subtitle: "01.09.2022", isNew: true) {}
        }
    }
}
