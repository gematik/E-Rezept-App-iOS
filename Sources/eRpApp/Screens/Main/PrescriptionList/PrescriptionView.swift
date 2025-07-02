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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct PrescriptionView: View {
    var prescription: Prescription
    let action: () -> Void
    var displayName: String {
        if let appName = prescription.erxTask.deviceRequest?.appName {
            return appName
        }
        return prescription.medication?.displayName ?? L10n.erxTxtMedicationPlaceholder.text
    }

    var body: some View {
        Button(
            action: {
                action()
            },
            label: {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(displayName)
                            .foregroundColor(Colors.systemLabel)
                            .font(Font.body.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .accessibilityIdentifier(A11y.mainScreen.erxDetailedPrescriptionName)
                            .padding(.bottom, 4)
                        if !(prescription.type == .directAssignment && !prescription.isArchived) {
                            Text(prescription.statusMessage)
                                .font(Font.subheadline.weight(.regular))
                                .foregroundColor(Color(.secondaryLabel))
                                .accessibilityIdentifier(A11y.mainScreen.erxDetailedPrescriptionValidity)
                        }
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
        .overlay(alignment: .topTrailing) {
            if let diGaInfo = prescription.erxTask.deviceRequest?.diGaInfo, !diGaInfo.isRead {
                HStack(alignment: .center, spacing: 4) {
                    Text(L10n.erxDetailedTxtDiGaBadge)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.9, green: 0.24, blue: 0.24))
                .cornerRadius(16)
                .offset(x: 8, y: -8)
            }
        }
    }

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

                    if prescription.isLoading {
                        ProgressView()
                            .scaleEffect(0.85)
                            .tint(prescription.imageTint)
                            .background(prescription.backgroundTint)
                    }
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

                if prescription.erxTask.patient?.coverageType == .SEL {
                    Image(systemName: SFSymbolName.euroSign)
                        .font(Font.subheadline.weight(.regular))
                        .padding(8)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .background(Colors.backgroundSecondary)
                        .cornerRadius(8)
                        .accessibilityLabel(L10n.erxTxtSelfPayer)
                        .accessibility(identifier: A11y.mainScreen.erxDetailedSelfPayer)
                }

                if prescription.erxTask.deviceRequest?.authoredOn != nil {
                    Image(systemName: SFSymbolName.iPhoneGen2)
                        .font(Font.subheadline.weight(.regular))
                        .padding(8)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .background(Colors.backgroundSecondary)
                        .cornerRadius(8)
                        .accessibilityLabel(L10n.erxDetailedTxtDiGaStatus)
                        .accessibility(identifier: A11y.mainScreen.erxDetailedDiGaBage)
                }
            }
            .padding(.top, 8)
        }
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
