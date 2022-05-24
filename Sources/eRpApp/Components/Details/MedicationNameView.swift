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

struct MedicationNameView: View {
    let medicationText: String
    let statusMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionViewString(
                text: medicationText,
                a11y: medicationText
            )
            .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(statusMessage)
                Spacer()
            }
            .font(Font.subheadline)
            .foregroundColor(Colors.systemLabelSecondary)
        }
    }
}

struct MedicationNameView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationNameView(medicationText: "Medication 3",
                           statusMessage: "Noch einlösbar bis zum 16.01.2021")
    }
}
