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

public struct CodeView: View {
    @Bindable var store: StoreOf<CodeDomain>

    public init(store: StoreOf<CodeDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n.euredeemCodeStep2)
                                .font(.headline)
                                .foregroundColor(Colors.systemLabel)
                                .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtStep2)

                            Spacer()
                        }

                        Text(L10n.euredeemCodeStepDescription)
                            .font(.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .multilineTextAlignment(.leading)
                            .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtStepDescription)
                    }

                    ZStack(alignment: .topTrailing) {
                        if store.isLoading {
                            LoadingView(store: store)
                        } else {
                            CodeContentView(store: store)

                            Button(
                                action: {
                                    store.send(.toggleDisplayMode)
                                },
                                label: {
                                    Image(
                                        systemName: store.displayMode == .manual ? SFSymbolName.qrCode : SFSymbolName
                                            .textFormat123
                                    )
                                    .font(.subheadline.bold())
                                    .foregroundColor(Colors.backgroundNeutral)
                                    .frame(width: 40, height: 40)
                                    .background(Colors.primary700)
                                    .clipShape(Circle())
                                    .accessibilityLabel(store.displayMode == .manual
                                        ? L10n.euredeemCodeToggleModeQr.text
                                        : L10n.euredeemCodeToggleModeManual.text)
                                }
                            )
                            .offset(x: 6, y: -17)
                            .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeToggleDisplayModeButton)
                        }
                    }
                    .padding(.top, 24)

                    Spacer()
                }
                .padding()
            }

            VStack(spacing: 8) {
                GreyDivider()

                CodeActionButtons(store: store)
            }
        }
        .task {
            await store.send(.task).finish()
        }
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    store.send(.delegate(.close))
                }, label: {
                    Text(L10n.euredeemCodeBtnClose)
                })
                .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeCloseButton)
            }
        }
        .navigationTitle(L10n.euredeemCodeTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Action Buttons

private struct CodeActionButtons: View {
    @Bindable var store: StoreOf<CodeDomain>

    var body: some View {
        if store.isExpired {
            Button(
                action: {
                    store.send(.refreshCode)
                },
                label: {
                    HStack {
                        Image(systemName: SFSymbolName.refresh)
                            .font(.body)

                        Text(L10n.euredeemCodeGenerateNewButton)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Colors.primary)
                    .cornerRadius(12)
                }
            )
            .padding()
            .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeGenerateNewButton)
        } else {
            Button(
                action: {
                    store.send(.delegate(.takeReceipt))
                },
                label: {
                    Text(L10n.euredeemCodeTakeReceiptButton)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Colors.primary)
                        .cornerRadius(12)
                }
            )
            .padding()
            .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTakeReceiptButton)
        }
    }
}

struct LoadingView: View {
    @Bindable var store: StoreOf<CodeDomain>

    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .controlSize(.extraLarge)
                .progressViewStyle(.circular)
                .tint(Colors.primary)

            Text(L10n.euredeemCodeLoadingTxt)
                .foregroundStyle(Colors.primary900)
                .frame(maxWidth: .infinity)
        }
        .frame(minHeight: 300)
        .padding()
        .background(Colors.systemBackground)
        .cornerRadius(16)
        .shadow(color: Colors.systemGray4, radius: 3, x: 0, y: 2)
    }
}

struct CodeContentView: View {
    @Bindable var store: StoreOf<CodeDomain>

    var body: some View {
        VStack(spacing: 4) {
            switch store.displayMode {
            case .manual:
                ManualCodeView(store: store)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing))
                        .animation(.easeInOut(duration: 0.5)))
            case .qrCode:
                QRCodeView(store: store)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading))
                        .animation(.easeInOut(duration: 0.5)))
            }
        }
        .padding()
        .background(Colors.systemBackground)
        .cornerRadius(16)
        .shadow(color: Colors.systemGray4, radius: 3, x: 0, y: 2)
        .transition(.opacity)
        .animation(.default, value: store.displayMode)
    }
}

struct ManualCodeView: View {
    @Bindable var store: StoreOf<CodeDomain>

    var body: some View {
        VStack(spacing: 20) {
            // Insurance Number Section
            VStack(alignment: .leading, spacing: 8) {
                let codeInsuranceLabel = L10n.euredeemCodeInsuranceNumberLabel.rawKey
                    .localizedStringFor(countryCode: store.countryCode)
                    ?? L10n.euredeemCodeInsuranceNumberLabel.text
                let insuranceId = store.insuranceId ?? ""
                HStack {
                    Button {
                        store.send(.speechButtonTapped(
                            text: codeInsuranceLabel
                                + insuranceId.split(separator: "").joined(separator: " ")
                        ))
                    } label: {
                        Image(systemName: SFSymbolName.speakerWave2Circle)
                            .foregroundColor(Colors.primary)
                            .font(.title.weight(.thin))
                            .accessibilityLabel(L10n.euredeemCodeBtnInsuranceIdVoice.text)
                    }
                    .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeSpeechInsuranceNumberButton)

                    Text(codeInsuranceLabel)
                        .font(.body)
                        .foregroundColor(Colors.primary900)
                        .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtInsuranceNumberLabel)
                }

                Text(insuranceId)
                    .font(.system(.title, design: .monospaced))
                    .kerning(10)
                    .fontWeight(.bold)
                    .foregroundColor(Colors.systemLabel)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.systemBackgroundSecondary)
                    .cornerRadius(8)
                    .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtInsuranceNumber)
            }

            // Exchange Code Section
            VStack(alignment: .leading, spacing: 8) {
                let codeExchangeLabel = L10n.euredeemCodeExchangeCodeLabel.rawKey
                    .localizedStringFor(countryCode: store.countryCode)
                    ?? L10n.euredeemCodeExchangeCodeLabel.text
                let codeForDisplay = formatCodeForDisplay(store.euAccessCode?.accessCode ?? "")

                HStack {
                    Button {
                        store.send(.speechButtonTapped(
                            text: codeExchangeLabel
                                + codeForDisplay
                        ))
                    } label: {
                        Image(systemName: SFSymbolName.speakerWave2Circle)
                            .foregroundColor(Colors.primary)
                            .font(.title.weight(.thin))
                            .accessibilityLabel(L10n.euredeemCodeBtnAccessCodeVoice.text)
                    }
                    .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeSpeechExchangeCodeButton)

                    Text(codeExchangeLabel)
                        .font(.body)
                        .foregroundColor(Colors.primary900)
                        .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtExchangeCodeLabel)
                }

                Text(store.isExpired ? L10n.euredeemCodeExpiredTitle.text
                    : codeForDisplay)
                    .font(.system(.title, design: .monospaced).bold())
                    .foregroundColor(store.isExpired ? Colors.red900 : Colors.systemLabel)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 54,
                        maxHeight: 54,
                        alignment: .center
                    )
                    .background(store.isExpired ? Colors.red100 : Colors.primary100)
                    .cornerRadius(8)
                    .overlay(
                        store.isExpired ?
                            RoundedRectangle(cornerRadius: 8)
                            .inset(by: 0.5)
                            .stroke(
                                Colors.red700,
                                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                            )
                            : nil
                    )
                    .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtExchangeCode)
            }

            if store.minutesRemaining > 0, !store.isExpired {
                Text(L10n.euredeemCodeValidityManual(String(store.minutesRemaining)))
                    .font(.caption)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtValidityManual)
            }

            Button(
                action: {
                    store.send(.refreshCode)
                },
                label: {
                    Label {
                        Text(L10n.euredeemCodeRefreshButton)
                    } icon: {
                        Image(systemName: SFSymbolName.refresh)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            )
            .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeManualRefreshButton)
        }
    }

    private func formatCodeForDisplay(_ code: String) -> String {
        // Add spaces between characters for better readability
        code.map { String($0) }.joined(separator: " ")
    }
}

struct QRCodeView: View {
    @Bindable var store: StoreOf<CodeDomain>

    var body: some View {
        VStack(spacing: 12) {
            Group {
                if let qrImage = store.qrCodeImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .background(Colors.systemBackground)
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                        .cornerRadius(8)
                        .id("qrcodeimageorplaceholder")
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Colors.systemBackground)
                        .frame(width: 200, height: 200)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                        .id("qrcodeimageorplaceholder")
                }
            }
            .onAppear {
                store.send(.generateQRCode(screenSize: CGSize(width: 200, height: 200)))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay {
                if store.isExpired {
                    Text(L10n.euredeemCodeExpiredTitle.text)
                        .font(.title3.bold())
                        .foregroundColor(Colors.red900)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .frame(height: 54)
                        .background(Colors.red100)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 0.5)
                                .stroke(Colors.red700, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        )
                        .rotationEffect(.degrees(-27))
                        .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtQrExpired)
                }
            }

            if store.minutesRemaining > 0, !store.isExpired {
                Text(L10n.euredeemCodeQrDescription(String(store.minutesRemaining)))
                    .font(.caption)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeTxtValidityQr)
            }

            Button(
                action: {
                    store.send(.refreshCode)
                },
                label: {
                    Label {
                        Text(L10n.euredeemCodeRefreshButton)
                    } icon: {
                        Image(systemName: SFSymbolName.refresh)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }
            )
            .accessibilityIdentifier(A11y.redeem.eu.code.eurdmCodeQrRefreshButton)
        }
    }
}

#Preview("Loading...") {
    NavigationStack {
        CodeView(store: CodeDomain.Dummies.storeFor(
            CodeDomain.State(
                displayMode: .qrCode,
                insuranceId: "M123456789",
                countryCode: "De"
            )
        ))
    }
}

#Preview("Manual Mode") {
    NavigationStack {
        CodeView(store: CodeDomain.Dummies.store)
    }
}

#Preview("QR Code Mode") {
    NavigationStack {
        CodeView(store: CodeDomain.Dummies.storeFor(
            CodeDomain.State(
                displayMode: .qrCode,
                insuranceId: "M123456789",
                euAccessCode: .init(),
                countryCode: "De",
                isLoading: false
            )
        ))
    }
}

#Preview("Expired Manual Mode") {
    NavigationStack {
        CodeView(store: CodeDomain.Dummies.expiredStore)
    }
}

#Preview("Expired QR Code Mode") {
    NavigationStack {
        CodeView(store: CodeDomain.Dummies.storeFor(
            CodeDomain.State(
                displayMode: .qrCode,
                insuranceId: "M123456789",
                countryCode: "De",
                isLoading: false
            )
        ))
    }
}
