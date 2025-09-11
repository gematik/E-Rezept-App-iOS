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
import SwiftUI

struct SelectEUPrescriptionsView: View {
    let store: StoreOf<SelectEUPrescriptionsDomain>

    var body: some View {
        List {
            patientSection

            prescriptionsSection
        }
        .navigationTitle("Rezepte")
    }

    private var patientSection: some View {
        Section {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(store.patientName.prefix(1)))
                            .foregroundColor(.primary)
                    )

                Text(store.patientName)
                    .font(.headline)

                Spacer()
            }
            .padding(.vertical, 8)

            Button {
                store.send(.toggleSelectAll)
            } label: {
                HStack {
                    SelectionCircle(isSelected: store.selectAllEnabled)
                    Text("Alle Rezepte wählen")
                        .font(.body)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var prescriptionsSection: some View {
        ForEach(store.prescriptions) { prescription in
            Button {
                store.send(.togglePrescription(prescription))
            } label: {
                HStack(alignment: .top) {
                    if prescription.isRedeemableInEU {
                        SelectionCircle(isSelected: prescription.isSelected)
                    } else {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(prescription.name)
                            .font(.body)
                            .foregroundColor(.primary)

                        if prescription.isRedeemableInEU, let expiresOn = prescription.expiresOn {
                            Text("Im EU Ausland einlösbar bis \(formatDate(expiresOn))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else if let reason = prescription.notRedeemableReason {
                            Text(reason)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .opacity(prescription.isRedeemableInEU ? 1.0 : 0.8)
            .disabled(!prescription.isRedeemableInEU)
            .contentShape(Rectangle())
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

struct SelectionCircle: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isSelected ? Color.accentColor : Color.gray, lineWidth: 2)
                .frame(width: 24, height: 24)

            if isSelected {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SelectEUPrescriptionsView(
            store: SelectEUPrescriptionsDomain.Dummies.store
        )
    }
}
