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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct PrescriptionView: View {
    var prescription: Prescription
    let action: () -> Void

    var body: some View {
        Button(
            action: {
                action()
            },
            label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            prescription.prescribedMedication?.displayName,
                            placeholder: L10n.erxTxtMedicationPlaceholder
                        )
                        .foregroundColor(Colors.systemLabel)
                        .font(Font.body.weight(.semibold))
                        .multilineTextAlignment(.leading)
                        .accessibilityIdentifier(A11y.mainScreen.erxDetailedPrescriptionName)
                        Text(prescription.statusMessage)
                            .font(Font.subheadline.weight(.regular))
                            .foregroundColor(Color(.secondaryLabel))
                            .accessibilityIdentifier(A11y.mainScreen.erxDetailedPrescriptionValidity)
                        PrescriptionStatusView(prescription: prescription)
                    }
                    .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)
                    Image(systemName: SFSymbolName.rightDisclosureIndicator)
                        .font(Font.headline.weight(.semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                        .padding(8)
                }
            }
        )
        .buttonStyle(DefaultButtonStyle())
        .padding()
        .background(Colors.systemBackgroundTertiary)
        .border(Colors.separator, width: 0.5, cornerRadius: 16)
    }
}

struct PrescriptionView_Previews: PreviewProvider {
    static let prescription = Prescription.Dummies.prescriptions[0]
    static let scannedPrescription = Prescription.Dummies.prescriptionsScanned[0]

    static var previews: some View {
        Group {
            ScrollView {
                PrescriptionView(
                    prescription: prescription
                ) {}
            }

            ScrollView {
                PrescriptionView(
                    prescription: scannedPrescription
                ) {}
            }
        }
    }
}
