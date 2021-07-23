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

struct MedicationRemoveButton: View {
    @ScaledMetric var iconSize: CGFloat = 24
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                HStack {
                    Image(systemName: SFSymbolName.trash)
                        .font(Font.headline.weight(.semibold))
                        .padding([.leading], 15)
                    Text(L10n.dtlBtnDeleteMedication)
                        .padding([.trailing, .top, .bottom], 15)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: iconSize)
            }
            .accessibility(identifier: A18n.prescriptionDetails.prscDtlBtnDeleteMedication)
            .font(Font.body.weight(.semibold))
            .foregroundColor(colorScheme == .dark ? Colors.systemLabel : Colors.systemColorWhite)
            .background(Colors.red600)
            .cornerRadius(16)
            .padding()
        }
    }
}

struct MedicationRemoveButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MedicationRemoveButton {}
            MedicationRemoveButton {}
                .preferredColorScheme(.dark)
        }
    }
}
