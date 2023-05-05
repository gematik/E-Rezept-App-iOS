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

import Dependencies
import eRpKit
import Foundation
import SwiftUI
import WebKit

extension PrescriptionFullDetailView {
    struct DataMatrixCodeView: View {
        let uiImage: UIImage?

        var body: some View {
            VStack {
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .background(Colors.systemColorWhite) // No darkmode to get contrast
                        .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                        .accessibility(identifier: A11y.redeem.matrixCode.rphImgMatrixcode)
                } else {
                    ProgressView()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .border(Colors.separator, width: 0.5, cornerRadius: 16)
        }
    }

    struct SubstitutionInfoWebView: View {
        var body: some View {
            WebView()
        }

        struct WebView: UIViewRepresentable {
            let navigationController = NoJSNavigationDelegate()

            func makeUIView(context _: Context) -> WKWebView {
                let wkWebView = WKWebView()
                wkWebView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false

                if let url = URL(string: L10n.prscFdTxtSubstitutionReadFurtherLink.text) {
                    wkWebView.load(URLRequest(url: url))
                }
                wkWebView.navigationDelegate = navigationController
                return wkWebView
            }

            func updateUIView(_: WKWebView, context _: UIViewRepresentableContext<WebView>) {}

            class NoJSNavigationDelegate: NSObject, WKNavigationDelegate {
                func webView(_ webView: WKWebView,
                             decidePolicyFor navigationAction: WKNavigationAction,
                             preferences _: WKWebpagePreferences,
                             decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
                    guard let url = navigationAction.request.url,
                          url.scheme?.lowercased() == "https" else {
                        decisionHandler(.cancel, webView.configuration.defaultWebpagePreferences)
                        return
                    }
                    decisionHandler(.allow, webView.configuration.defaultWebpagePreferences)
                }
            }
        }
    }

    struct DosageHint: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.prscDtlHntGesundBundDeText)
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)

                HStack {
                    Spacer(minLength: 0)

                    Button(action: {
                        guard let url = URL(string: "https://gesund.bund.de"),
                              UIApplication.shared.canOpenURL(url) else { return }

                        UIApplication.shared.open(url)
                    }, label: {
                        Text(L10n.prscDtlHntGesundBundDeBtn)
                            .foregroundColor(Colors.primary)
                            .multilineTextAlignment(.trailing)
                    })
                }
            }
            .font(.footnote)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    struct MedicationDetails: View {
        // TODO: move dependency into domain and do formatting in the view model // swiftlint:disable:this todo
        @Dependency(\.uiDateFormatter) var uiDateFormatter
        var title: String?
        let prescription: Prescription
        let medication: Medication?

        var actualTitle: String {
            if let title = title {
                return title
            }

            return medication?.displayName ?? L10n.prscTxtFallbackName.text
        }

        var body: some View {
            MedicationDetailsView(
                title: actualTitle,
                dosageForm: localizedStringForDosageFormKey(medication?
                    .dosageForm),
                dose: composedDoseInfoFrom(
                    doseKey: medication?.dose,
                    amount: medication?.amount?.description,
                    dosageKey: medication?.dosageForm
                ),
                pzn: medication?.pzn,
                isArchived: prescription.isArchived,
                lot: medication?.lot,
                expiresOn: uiDateFormatter.relativeDate(medication?.expiresOn)
            )

            // Dosage instructions
            Group {
                SectionHeaderView(
                    text: L10n.prscFdTxtDosageInstructionsTitle,
                    a11y: A11y.prescriptionDetails.prscDtlTxtMedDosageInstructions
                )
                HintView(
                    hint: Hint<PrescriptionDetailDomain.Action>(
                        id: A11y.prescriptionDetails.prscDtlHntDosageInstructions,
                        message: medication?
                            .dosageInstruction ?? L10n.prscFdTxtDosageInstructionsNa.text,
                        image: AccessibilityImage(
                            name: Asset.Illustrations.practitionerf1.name,
                            accessibilityName: L10n.prscFdHintDosageInstructionsPic.text
                        ),
                        style: .neutral,
                        buttonStyle: .tertiary,
                        imageStyle: .topAligned
                    ),
                    textAction: nil,
                    closeAction: nil
                )
            }
            .padding([.horizontal, .top])
        }

        private func localizedStringForDosageFormKey(_ key: String?) -> String? {
            guard let key = key,
                  let string = PrescriptionKBVKeyMapping.localizedStringKeyForDosageFormKey(key) else { return nil }
            return NSLocalizedString(string, comment: "")
        }

        private func composedDoseInfoFrom(doseKey: String?,
                                          amount: String?,
                                          dosageKey: String?) -> String? {
            guard let doseKey = doseKey,
                  let amount = amount,
                  let dosageKey = dosageKey,
                  let dosageString = PrescriptionKBVKeyMapping.localizedStringKeyForDosageFormKey(dosageKey)
            else { return nil }
            return "\(doseKey) \(amount) \(NSLocalizedString(dosageString, comment: ""))"
        }
    }
}
