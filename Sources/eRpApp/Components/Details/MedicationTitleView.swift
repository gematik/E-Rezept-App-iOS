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

struct MedicationTitleView: View {
    let title: String
    let statusMessage: String?

    init(title: String, statusMessage: String? = nil) {
        self.title = title
        self.statusMessage = statusMessage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionViewString(
                text: title,
                a11y: A11y.prescriptionDetails.prscDtlTxtTitle
            )
            .fixedSize(horizontal: false, vertical: true)

            if let message = statusMessage {
                HStack {
                    Text(message)
                    Spacer()
                }
                .font(Font.subheadline)
                .foregroundColor(Colors.systemLabelSecondary)
            }
        }
    }
}

struct MedicationTitleView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationTitleView(title: "Medication 3",
                            statusMessage: "Noch einlösbar bis zum 16.01.2021")

        MedicationTitleView(title: "Medication 4")
    }
}
