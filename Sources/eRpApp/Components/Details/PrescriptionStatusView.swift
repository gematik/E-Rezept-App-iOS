//
//  Copyright (c) 2023 gematik GmbH
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

struct PrescriptionStatusView: View {
    let prescription: Prescription

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 4) {
                Text(prescription.statusTitle)
                    .font(Font.subheadline.weight(.regular))
                    .foregroundColor(prescription.titleTint)
                prescription.image
                    .font(Font.subheadline.weight(.semibold))
                    .foregroundColor(prescription.imageTint)
            }
            .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(prescription.backgroundTint)
            .cornerRadius(8)
            .accessibility(identifier: A11y.mainScreen.erxDetailedStatus)

            if let status = prescription.multiplePrescriptionStatus {
                Text(status)
                    .font(Font.subheadline.weight(.regular))
                    .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .foregroundColor(Colors.systemLabelSecondary)
                    .background(Colors.backgroundSecondary)
                    .cornerRadius(8)
                    .accessibility(identifier: A11y.mainScreen
                        .erxDetailedMultiplePrescriptionIndex)
            }
        }
        .padding(.top, 4)
    }
}
