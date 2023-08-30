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

import eRpKit
import SwiftUI

struct OrderMedicationView: View {
    let medication: ErxMedication?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let name = medication?.displayName, !name.isEmpty {
                HStack {
                    HStack(spacing: 4) {
                        Text(name)
                            .font(Font.body.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Colors.systemLabel)
                        Spacer()
                        Image(systemName: SFSymbolName.chevronRight)
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(Colors.systemLabelTertiary)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Colors.systemBackgroundTertiary))
                    .border(Colors.separator, width: 0.5, cornerRadius: 16)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct OrderMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        OrderMedicationView(medication: ErxTask.Demo.medication1)
    }
}
