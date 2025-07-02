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

/// sourcery: StringAssetInitialized
struct MedicationRedeemView: View {
    let text: LocalizedStringKey
    let a11y: String
    var isEnabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Spacer()
            Text(text, bundle: .module)
                .fontWeight(.semibold)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(isEnabled ? Colors.primary700 : Colors.systemColorWhite)
                .padding()
            Spacer()
        }
        .background(isEnabled ? Colors.systemGray6 : Colors.primary700)
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                isEnabled ? Colors.systemGray6 : Colors.primary700,
                lineWidth: 1
            )
        )
        .cornerRadius(16)
        .padding([.leading, .trailing])
    }
}

struct MedicationRedeemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                MedicationRedeemView(
                    text: L10n.dtlBtnToogleMarkRedeemed,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: false
                ) {}
                Spacer()
            }
            .background(Color.white)

            VStack {
                Spacer()
                MedicationRedeemView(
                    text: L10n.dtlBtnToogleMarkedRedeemed,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: true
                ) {}
                Spacer()
            }
            .background(Color.white)

            VStack {
                Spacer()
                MedicationRedeemView(
                    text: L10n.dtlBtnToogleMarkRedeemed,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: false
                ) {}
                    .preferredColorScheme(.dark)
                Spacer()
            }
            .background(Color.black)

            VStack {
                Spacer()
                MedicationRedeemView(
                    text: L10n.dtlBtnToogleMarkedRedeemed,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: true
                ) {}
                    .preferredColorScheme(.dark)
                Spacer()
            }
            .background(Color.black)
        }.previewLayout(.fixed(width: 400.0, height: 150.0))
    }
}
