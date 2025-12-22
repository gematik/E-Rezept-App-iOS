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
import eRpStyleKit
import SwiftUI

public struct SelectEUPrescriptionsView: View {
    var store: StoreOf<SelectEUPrescriptionsDomain>

    public init(store: StoreOf<SelectEUPrescriptionsDomain>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section(content: {
                selectAllPrescriptionCell
                prescriptionCells
            }, header: {
                patientHeader
            })
                .headerProminence(.increased)
        }
        .navigationTitle(L10n.euredeemPrscSelectionTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var patientHeader: some View {
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
        .listRowInsets(.init(top: 16, leading: 0, bottom: 16, trailing: 0))
    }

    private var selectAllPrescriptionCell: some View {
        Button {
            store.send(.toggleSelectAll)
        } label: {
            HStack(alignment: .center, spacing: 16) {
                SelectionCheckmark(isSelected: store.selectAllEnabled)
                Text(L10n.euredeemPrscSelectionTxtSelectAll)
                    .font(.body)
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .buttonStyle(.plain)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
    }

    private var prescriptionCells: some View {
        ForEach(store.prescriptions) { prescription in
            Button {
                store.send(.togglePrescription(prescription))
            } label: {
                HStack(alignment: .center, spacing: 16) {
                    if prescription.isRedeemableInEU {
                        SelectionCheckmark(isSelected: prescription.isSelected)
                    } else {
                        Image(systemName: SFSymbolName.crossIconPlain)
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(prescription.name)
                            .font(.body)
                            .foregroundColor(.primary)

                        if prescription.isRedeemableInEU, let expiresOn = prescription.expiresOn {
                            Text(L10n.euredeemPrscSelectionTxtRedeemUntil(
                                expiresOn.formatted(date: .numeric, time: .omitted)
                            ))
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
        }
    }
}

struct SelectionCheckmark: View {
    let isSelected: Bool

    var body: some View {
        if isSelected {
            Image(systemName: SFSymbolName.checkmarkCircleFill)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.accentColor)
        } else {
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 2)
                .frame(width: 24, height: 24)
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
