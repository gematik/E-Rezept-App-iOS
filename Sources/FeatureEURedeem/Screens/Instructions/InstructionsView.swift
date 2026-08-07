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

public struct InstructionsView: View {
    var store: StoreOf<InstructionsDomain>

    public init(store: StoreOf<InstructionsDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.euredeemInstructionsTitle)
                            .font(.title.bold())
                            .foregroundColor(Colors.systemLabel)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsTitle)

                        UIKitTextView(
                            attributedString: attributedSubtitle,
                            font: .preferredFont(forTextStyle: .body),
                            foregroundColor: .label
                        ) { _ in }
                            .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsSubtitle)
                    }

                    // Instructions steps
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionStepView(
                            stepNumber: L10n.euredeemInstructionsStep1Title,
                            description: L10n.euredeemInstructionsStep1Description(
                                stringFor(
                                    rawKey: L10n.euredeemInstructionsStep1RegionalDescription.rawKey,
                                    countryCode: store.countryCode
                                ) ?? L10n.euredeemInstructionsStep1RegionalDescription.text
                            )
                        )
                        .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsStep1Title)

                        InstructionStepView(
                            stepNumber: L10n.euredeemInstructionsStep2Title,
                            description: L10n.euredeemInstructionsStep2Description
                        )
                        .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsStep2Title)

                        InstructionStepView(
                            stepNumber: L10n.euredeemInstructionsStep3Title,
                            description: L10n.euredeemInstructionsStep3Description
                        )
                        .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsStep3Title)

                        InstructionStepView(
                            stepNumber: L10n.euredeemInstructionsStep4Title,
                            description: L10n.euredeemInstructionsStep4Description(
                                stringFor(
                                    rawKey: L10n.euredeemInstructionsStep4RegionalDescription.rawKey,
                                    countryCode: store.countryCode
                                ) ?? L10n.euredeemInstructionsStep4RegionalDescription.text
                            )
                        )
                        .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsStep4Title)

                        InstructionStepView(
                            stepNumber: L10n.euredeemInstructionsStep5Title,
                            description: L10n.euredeemInstructionsStep5Description
                        )
                        .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsStep5Title)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            if store.isRedeeming {
                // Bottom section with button and disclaimer
                VStack(spacing: 10) {
                    GreyDivider()

                    Text(L10n.euredeemInstructionsDisclaimer)
                        .font(.caption)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmTxtInstructionsDisclaimer)

                    Button(L10n.euredeemInstructionsGenerateCodeButton) {
                        // Handle generate code action
                        store.send(.delegate(.continueButtonTapped))
                    }
                    .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: false))
                    .accessibilityIdentifier(A11y.redeem.eu.instructions.eurdmBtnInstructionsGenerateCode)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Colors.systemBackground)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    store.send(.delegate(.close))
                }, label: {
                    Text(L10n.euredeemInstructionsBtnClose)
                })
                .accessibility(identifier: A11y.redeem.eu.instructions.eurdmBtnInstructionsClose)
            }
        }
        .navigationTitle(L10n.euredeemInstructionsNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var attributedSubtitle: AttributedString {
        let text = L10n.euredeemInstructionsSubtitleWith(L10n.euredeemInstructionsLink.text).text
        return (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

extension InstructionsView {
    /// Localizes a raw key for a specific country code if supported, otherwise returns nil
    private func stringFor(rawKey: String, countryCode: String?) -> String? {
        guard let bundlePath = Bundle.resourceBundle.path(
            forResource: findPrimaryLocale(for: countryCode),
            ofType: "lproj"
        ),
            let bundle = Bundle(path: bundlePath)
        else { return nil }
        return String(format: NSLocalizedString(rawKey, bundle: bundle, comment: ""), arguments: [])
    }

    /// Finds the closest local for a given country code in all app supported localizations,
    /// otherwise returns default (en-GB)
    private func findPrimaryLocale(for countryCode: String?) -> String {
        let defaultLocal = "en-GB"
        guard let countryCode else { return defaultLocal }
        let bestMatch = Bundle.main.localizations.first { identifier in
            let locale = Locale(identifier: identifier)
            let isLanguageMatch = locale.language.languageCode?.identifier.lowercased() == countryCode.lowercased()
            let isRegionMatch = locale.region?.identifier.uppercased() == countryCode.uppercased()

            return isLanguageMatch || isRegionMatch
        }
        return bestMatch ?? defaultLocal
    }
}

struct InstructionStepView: View {
    let stepNumber: StringAsset
    let description: StringAsset

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stepNumber)
                .font(.headline)
                .foregroundColor(Colors.systemLabel)

            Text(description)
                .font(.body)
                .foregroundColor(Colors.systemLabelSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        InstructionsView(
            store: StoreOf<InstructionsDomain>(
                initialState: InstructionsDomain.State(isRedeeming: true, countryCode: "DE")
            ) {
                InstructionsDomain()
            }
        )
    }
}
