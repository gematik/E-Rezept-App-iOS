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
import eRpResources
import eRpStyleKit
import SwiftUI

public struct EURedeemSelectionView: View {
    @Bindable var store: StoreOf<EURedeemSelectionDomain>

    public init(store: StoreOf<EURedeemSelectionDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Illustration placeholder
            ZStack {
                Colors.primary100
                // Replace with actual illustration asset
                Image(asset: Asset.EUReedem.banner)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.yellow)
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Im EU Ausland einlösen")
                        .font(.title)
                        .bold()
                        .padding(.top, 8)
                    Text("Wie Sie im EU Ausland Rezepte einlösen können, lesen Sie in der ")

                    Button {
                        store.send(.selectInstructionButtonTapped)
                    } label: {
                        Text("Anleitung.")
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .font(.body)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                VStack(spacing: 16) {
                    prescriptionCell
                    countryCell
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Spacer()

            VStack(spacing: 8) {
                GreyDivider()

                Button(
                    action: { store.send(.redeemButtonTapped) },
                    label: { Text("Einlösen") }
                )
                .buttonStyle(.primaryHugging)
                .disabled(store.selectedPrescriptions.isEmpty || store.selectedCountry == nil)
                .padding([.horizontal, .bottom])
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .ignoresSafeArea(edges: .top)
        }
        .sheet(item: $store.scope(state: \.destination?.consent, action: \.destination.consent)) { store in
            ConsentView(store: store)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var prescriptionCell: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                store.send(.selectPrescriptionsButtonTapped)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if store.prescriptions.isEmpty {
                            Text("Keine Rezepte")
                                .font(.body)
                                .foregroundColor(.red)
                        } else {
                            Text("Rezepte")
                                .font(.caption)
                                .foregroundColor(.gray)
                            if store.selectedPrescriptions.isEmpty {
                                // Show all prescriptions if none selected
                                ForEach(store.prescriptions.prefix(2)) { prescription in
                                    Text(prescription.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                if store.prescriptions.count > 2 {
                                    Text("+\(store.prescriptions.count - 2) weitere")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                // Show selected prescriptions
                                ForEach(store.selectedPrescriptions.prefix(2)) { prescription in
                                    Text(prescription.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                if store.selectedPrescriptions.count > 2 {
                                    Text("+\(store.selectedPrescriptions.count - 2) weitere")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            store.prescriptions.isEmpty
                                ? Color.red : Color.gray.opacity(0.3),
                            lineWidth: 1
                        )
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            if store.prescriptions.isEmpty {
                Text("Sie haben keine einlöbaren Rezepte")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading)
                    .padding(.top, 8)
            }
        }
    }

    private var countryCell: some View {
        Button(
            action: { store.send(.selectCountryButtonTapped) },
            label: {
                HStack {
                    if let country = store.selectedCountry {
                        Image(country.id.lowercased()) // expects asset named by country code
                            .resizable()
                            .frame(width: 32, height: 22)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Land")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(store.selectedCountry?.name ?? "")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .contentShape(Rectangle())
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview
#Preview {
    NavigationStack {
        EURedeemSelectionView(store: EURedeemSelectionDomain.Dummies.store)
    }
}
