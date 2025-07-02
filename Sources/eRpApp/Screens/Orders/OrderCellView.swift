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

import eRpStyleKit
import SwiftUI

struct OrderCellView: View {
    let title: String
    let message: AttributedString
    let subtitle: String

    var isNew: Bool
    var prescriptionCount: Int

    let action: () -> Void

    init(title: String,
         message: AttributedString,
         subtitle: String,
         isNew: Bool = false,
         prescriptionCount: Int = 0,
         action: @escaping () -> Void) {
        self.title = title
        self.message = message
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
                        Text(title)
                            .lineLimit(1)
                            .font(Font.body.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Colors.systemLabel)

                        Text(message)
                            .lineLimit(1)
                            .foregroundColor(Colors.systemLabel)

                        Text(subtitle)
                            .font(Font.subheadline.weight(.light))
                            .foregroundColor(Colors.systemLabelSecondary)
                    }

                    Spacer(minLength: 8)

                    if isNew {
                        StatusView(title: L10n.ordListStatusNew, backgroundColor: Colors.primary100)
                    } else if prescriptionCount != 0 {
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
            OrderCellView(
                title: "Albrecht Apotheke ",
                message: "Ihre Bestellung ist Bereit",
                subtitle: "02.09.2022",
                prescriptionCount: 1
            ) {}
            OrderCellView(
                title: "Albrecht Apotheke",
                message: "Ihre Bestellung ist Bereit",
                subtitle: "01.09.2022",
                isNew: true
            ) {}
        }
    }
}
