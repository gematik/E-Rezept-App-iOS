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

struct PrescriptionStatusView: View {
    let prescription: GroupedPrescription.Prescription

    var body: some View {
        HStack(spacing: 4) {
            Text(prescription.title)
                .foregroundColor(prescription.titleTint)
            prescription.image
                .font(Font.caption2.weight(.semibold))
                .foregroundColor(prescription.imageTint)
        }
        .font(Font.footnote)
        .padding(.init(top: 2, leading: 8, bottom: 2, trailing: 8))
        .background(prescription.backgroundTint)
        .cornerRadius(8)
    }
}
