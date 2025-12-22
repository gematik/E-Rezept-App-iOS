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

public struct InstructionsView: View {
    var store: StoreOf<InstructionsDomain>

    public init(store: StoreOf<InstructionsDomain>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.euredeemInstructionsTitle)
                                .font(.title.bold())
                                .foregroundColor(Colors.systemLabel)

                            Button(L10n.euredeemInstructionsSubtitle) {
                                // Handle website link tap
                            }
                            .foregroundColor(Colors.systemGray2)
                            .buttonStyle(.plain)
                            .font(.body)
                        }

                        // Instructions steps
                        VStack(alignment: .leading, spacing: 16) {
                            InstructionStepView(
                                stepNumber: L10n.euredeemInstructionsStep1Title,
                                description: L10n.euredeemInstructionsStep1Description
                            )

                            InstructionStepView(
                                stepNumber: L10n.euredeemInstructionsStep2Title,
                                description: L10n.euredeemInstructionsStep2Description
                            )

                            InstructionStepView(
                                stepNumber: L10n.euredeemInstructionsStep3Title,
                                description: L10n.euredeemInstructionsStep3Description
                            )

                            InstructionStepView(
                                stepNumber: L10n.euredeemInstructionsStep4Title,
                                description: L10n.euredeemInstructionsStep4Description
                            )

                            InstructionStepView(
                                stepNumber: L10n.euredeemInstructionsStep5Title,
                                description: L10n.euredeemInstructionsStep5Description
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                if store.isRedeeming {
                    // Bottom section with button and disclaimer
                    VStack(spacing: 8) {
                        GreyDivider()

                        Button(L10n.euredeemInstructionsGenerateCodeButton) {
                            // Handle generate code action
                            store.send(.delegate(.continueButtonTapped))
                        }
                        .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: false))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        Text(L10n.euredeemInstructionsDisclaimer)
                            .font(.caption)
                            .foregroundColor(Colors.systemGray2)
                            .multilineTextAlignment(.center)
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
                        .accessibility(identifier: "euredeem_instructions_close_button")
                }
            }
            .navigationTitle(L10n.euredeemInstructionsNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
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
                .foregroundColor(Colors.systemGray2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        InstructionsView(
            store: StoreOf<InstructionsDomain>(
                initialState: InstructionsDomain.State()
            ) {
                InstructionsDomain()
            }
        )
    }
}
