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
import eRpResources
import eRpStyleKit
import SwiftUI

public struct EURedeemSelectionView: View {
    @Bindable var store: StoreOf<EURedeemSelectionDomain>
    @State var calculatedHeight = CGFloat(1)

    public init(store: StoreOf<EURedeemSelectionDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                // Illustration placeholder
                ZStack {
                    Colors.primary100
                    // Replace with actual illustration asset
                    Image(asset: Asset.EUReedem.banner)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.yellow)
                }
                .cornerRadius(32, corners: [.bottomLeft, .bottomRight])
                .frame(height: 240)

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.euredeemSelectionTitle)
                        .font(.title)
                        .bold()
                        .padding(.top, 8)

                    UIKitTextView(
                        attributedString: attributedSubtitle,
                        calculatedHeight: $calculatedHeight,
                        font: .preferredFont(forTextStyle: .body),
                        foregroundColor: .label
                    ) { _ in
                        store.send(.delegate(.selectInstructionButtonTapped))
                    }
                    .frame(height: calculatedHeight)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 32)

                VStack(spacing: 16) {
                    prescriptionCell
                    countryCell
                }
                .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 8) {
                GreyDivider()

                let isDisabled = store.selectedPrescriptions.isEmpty || store.selectedCountry == nil
                Button(
                    action: { store.send(.delegate(.redeemButtonTapped)) },
                    label: { Text(L10n.euredeemSelectionBtnRedeem) }
                )
                .buttonStyle(.primary(isEnabled: !isDisabled, width: .wideHugging))
                .disabled(isDisabled)
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom)
            }
        }
        .sheet(item: $store.scope(state: \.destination?.consent, action: \.destination.consent)) { store in
            ConsentView(store: store)
        }
        .sheet(item: $store.scope(state: \.destination?.consent, action: \.destination.consent)) { store in
            ConsentView(store: store)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    store.send(.delegate(.close))
                }, label: {
                    Text(L10n.euredeemSelectionBtnClose)
                })
                    .accessibility(identifier: "euredeem_selection_close_button")
            }
        }
        .toolbarBackground(.visible)
        .toolbarBackground(Colors.primary100, for: .navigationBar)
    }

    private var prescriptionCell: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                store.send(.delegate(.selectPrescriptionsButtonTapped))
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if store.prescriptions.isEmpty {
                            Text(L10n.euredeemSelectionPrescriptionTitleNone)
                                .font(.body)
                                .foregroundColor(.red)
                        } else {
                            if store.selectedPrescriptions.isEmpty {
                                Text(L10n.euredeemSelectionPrescriptionTitleNone)
                                    .font(.body)
                            } else {
                                Text(L10n.euredeemSelectionPrescriptionTitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                // Show selected prescriptions
                                ForEach(store.selectedPrescriptions) { prescription in
                                    Text(prescription.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }

                    Spacer()
                    Image(systemName: SFSymbolName.chevronForward)
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
                Text(L10n.euredeemSelectionPrescriptionCaptionNone)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading)
                    .padding(.top, 8)
            }
        }
    }

    private var countryCell: some View {
        Button(
            action: { store.send(.delegate(.selectCountryButtonTapped)) },
            label: {
                HStack {
                    if let country = store.selectedCountry {
                        Text(country.flag)
                            .font(.largeTitle)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.euredeemSelectionCountryTitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(store.selectedCountry?.name ?? "")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    } else {
                        let euCountry = Country(id: "EU", name: "European Union", telematikId: "")
                        Text(euCountry.flag)
                            .font(.largeTitle)
                        Text(L10n.euredeemSelectionTxtNoCountry)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: SFSymbolName.chevronForward)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .contentShape(Rectangle())
            }
        )
        .buttonStyle(PlainButtonStyle())
    }

    private var attributedSubtitle: AttributedString {
        let text = L10n.euredeemSelectionSubtitleWithLink(
            Markdown.instructionsView(L10n.euredeemSelectionSubtitleLink.text).link
        ).text
        return (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }

    enum Markdown: Equatable {
        case instructionsView(_ name: String)

        var link: String {
            switch self {
            case let .instructionsView(name):
                return "[\(name)](screen://InstructionsView)"
            }
        }
    }
}

// Preview
#Preview {
    NavigationStack {
        EURedeemSelectionView(store: EURedeemSelectionDomain.Dummies.store)
    }
}
