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
import FeatureCardWall
import SwiftUI

public struct EURedeemSelectionView: View {
    @Bindable var store: StoreOf<EURedeemSelectionDomain>

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
                        .accessibilityLabel(L10n.euredeemSelectionBannerVoice.text)
                        .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmImgSelectionBanner)
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
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmTxtSelectionTitle)

                    UIKitTextView(
                        attributedString: attributedSubtitle,
                        font: .preferredFont(forTextStyle: .body),
                        foregroundColor: .label
                    ) { _ in
                        store
                            .send(.delegate(.selectInstructionButtonTapped(countryCode: store.selectedCountry?
                                    .countryCode)))
                    }
                    .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmTxtSelectionSubtitle)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 32)

                VStack(spacing: 16) {
                    PrescriptionCell(store: store)
                    CountryCell(store: store)
                }
                .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 8) {
                GreyDivider()

                Button(
                    action: { store.send(.redeemButtonTapped) },
                    label: { Text(L10n.euredeemSelectionBtnRedeem) }
                )
                .buttonStyle(.primaryHugging)
                .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmBtnSelectionRedeem)
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom)
            }
        }
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        .navigationDestination(item: $store.scope(
            state: \.destination?.consent,
            action: \.destination.consent
        )) { store in
            ConsentView(store: store)
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.cardWall,
                action: \.destination.cardWall
            )
        ) { store in
            CardWallIntroductionView(store: store)
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
                .accessibility(identifier: A11y.redeem.eu.selection.eurdmBtnSelectionClose)
            }
        }
        .toolbarBackground(.visible)
        .toolbarBackground(Colors.primary100, for: .navigationBar)
        .task {
            await store.send(.task).finish()
        }
    }

    struct PrescriptionCell: View {
        @Bindable var store: StoreOf<EURedeemSelectionDomain>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    store.send(.delegate(.selectPrescriptionsButtonTapped))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if store.selectedPrescriptions.isEmpty {
                                Text(L10n.euredeemSelectionPrescriptionTitleNone)
                                    .font(.body)
                                    .foregroundStyle(
                                        store.validation == .emptyPrescription
                                            ? Colors.red700 : Colors.systemLabel
                                    )
                                    .accessibilityIdentifier(
                                        A11y.redeem.eu.selection.eurdmTxtSelectionPrescriptionTitle
                                    )
                            } else {
                                Text(L10n.euredeemSelectionPrescriptionTitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .accessibilityIdentifier(
                                        A11y.redeem.eu.selection.eurdmTxtSelectionPrescriptionTitle
                                    )
                                // Show selected prescriptions
                                ForEach(store.selectedPrescriptions) { prescription in
                                    Text(prescription.name)
                                        .font(.body)
                                        .foregroundColor(Colors.systemLabel)
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
                                store.validation == .emptyPrescription
                                    ? Colors.red700 : Color.gray.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmBtnSelectionPrescriptions)

                if store.validation == .emptyPrescription {
                    Text(L10n.euredeemSelectionPrescriptionCaptionNone)
                        .font(.caption)
                        .foregroundColor(Colors.red700)
                        .padding(.leading)
                        .padding(.top, 8)
                        .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmTxtSelectionPrescriptionCaption)
                }
            }
        }
    }

    struct CountryCell: View {
        @Bindable var store: StoreOf<EURedeemSelectionDomain>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Button(
                    action: { store.send(.delegate(.selectCountryButtonTapped)) },
                    label: {
                        HStack {
                            if let country = store.selectedCountry {
                                Text(country.flag)
                                    .font(.largeTitle)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(L10n.euredeemSelectionCountryTitle)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .accessibilityIdentifier(
                                            A11y.redeem.eu.selection.eurdmTxtSelectionCountryTitle
                                        )
                                    Text(store.selectedCountry?.displayName ?? "")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            } else {
                                let euCountry = Country(id: "EU", name: "European Union", telematikId: "")
                                Text(euCountry.flag)
                                    .font(.largeTitle)
                                    .accessibilityHidden(true)

                                Text(L10n.euredeemSelectionTxtNoCountry)
                                    .font(.body)
                                    .foregroundColor(
                                        store.validation == .emptyCountry
                                            ? Colors.red700 : Colors.systemLabel
                                    )
                                    .accessibilityIdentifier(
                                        A11y.redeem.eu.selection.eurdmTxtSelectionCountryNoSelection
                                    )
                            }
                            Spacer()
                            Image(systemName: SFSymbolName.chevronForward)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    store.validation == .emptyCountry
                                        ? Colors.red700 : Color.gray.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                        .contentShape(Rectangle())
                    }
                )
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmBtnSelectionCountry)

                if store.validation == .emptyCountry {
                    Text(L10n.euredeemSelectionCountryCaptionNone)
                        .font(.caption)
                        .foregroundColor(Colors.red700)
                        .padding(.leading)
                        .padding(.top, 8)
                        .accessibilityIdentifier(A11y.redeem.eu.selection.eurdmTxtSelectionCountryCaption)
                }
            }
        }
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
