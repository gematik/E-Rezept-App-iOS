//
//  Copyright (c) 2022 gematik GmbH
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

import ComposableArchitecture
import SwiftUI
import WebKit

struct PrescriptionFullDetailView: View {
    let store: PrescriptionDetailDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            EmptyView()
                .sheet(isPresented: viewStore.binding(
                    get: { $0.isSubstitutionReadMorePresented },
                    send: PrescriptionDetailDomain.Action.dismissSubstitutionInfo
                )) {
                    SubstitutionInfoWebView()
                }

            ScrollView(.vertical) {
                // Noctu fee waiver hint
                if viewStore.state.prescription.noctuFeeWaiver {
                    HintView(
                        hint: Hint<PrescriptionDetailDomain.Action>(
                            id: A11y.prescriptionDetails.prscDtlHntNoctuFeeWaiver,
                            title: NSLocalizedString("prsc_fd_txt_noctu_title", comment: ""),
                            message: NSLocalizedString("prsc_fd_txt_noctu_description", comment: ""),
                            imageName: Asset.Illustrations.pharmacistf1.name,
                            style: .neutral,
                            buttonStyle: .tertiary,
                            imageStyle: .bottomAligned
                        ),
                        textAction: nil,
                        closeAction: nil
                    )
                    .padding([.top, .horizontal])
                }

                Group {
                    // QR Code
                    VStack {
                        if let image = viewStore.loadingState.value {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .background(Colors.systemColorWhite) // No darkmode to get contrast
                                .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                                .accessibility(identifier: A18n.redeem.matrixCode.rphImgMatrixcode)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .border(Colors.separator, width: 0.5, cornerRadius: 16)
                    .padding([.top, .horizontal])

                    // Medication name
                    MedicationNameView(medicationText: viewStore.state.prescription.actualMedication?.name,
                                       dateString: viewStore.state.prescription.statusMessage)

                    if !viewStore.state.prescription.isArchived {
                        NavigateToPharmacySearchView(store: store)
                            .padding([.leading, .trailing, .bottom])
                    }

                    // Substitution hint
                    if viewStore.state.prescription.substitutionAllowed {
                        HintView(
                            hint: Hint(
                                id: A11y.prescriptionDetails.prscDtlHntSubstitution,
                                title: NSLocalizedString("prsc_fd_txt_substitution_title", comment: ""),
                                message: NSLocalizedString("prsc_fd_txt_substitution_description", comment: ""),
                                actionText: L10n.prscFdTxtSubstitutionReadFurther,
                                action: PrescriptionDetailDomain.Action.openSubstitutionInfo,
                                imageName: Asset.Illustrations.practitionerm1.name,
                                style: .neutral,
                                buttonStyle: .tertiary,
                                imageStyle: .topAligned
                            ),
                            textAction: { viewStore.send(PrescriptionDetailDomain.Action.openSubstitutionInfo) },
                            closeAction: nil
                        )
                        .padding(.horizontal)
                    }
                }

                Group {
                    // Medication details
                    MedicationDetailsView(
                        dosageForm: localizedStringForDosageFormKey(viewStore.state.prescription.actualMedication?
                            .dosageForm),
                        dose: composedDoseInfoFrom(
                            doseKey: viewStore.state.prescription.actualMedication?.dose,
                            amount: viewStore.state.prescription.actualMedication?.amount,
                            dosageKey: viewStore.state.prescription.actualMedication?.dosageForm
                        ),
                        pzn: viewStore.state.prescription.actualMedication?.pzn
                    )

                    // Dosage instructions
                    Group {
                        SectionHeaderView(
                            text: L10n.prscFdTxtDosageInstructionsTitle,
                            a11y: A18n.prescriptionDetails.prscDtlTxtMedDosageInstructions
                        )
                        HintView(
                            hint: Hint<PrescriptionDetailDomain.Action>(
                                id: A11y.prescriptionDetails.prscDtlHntDosageInstructions,
                                message: viewStore.state.prescription.actualMedication?
                                    .dosageInstruction ?? NSLocalizedString(
                                        "prsc_fd_txt_dosage_instructions_na",
                                        comment: ""
                                    ),
                                imageName: Asset.Illustrations.practitionerf1.name,
                                style: .neutral,
                                buttonStyle: .tertiary,
                                imageStyle: .topAligned
                            ),
                            textAction: nil,
                            closeAction: nil
                        )
                    }
                    .padding([.horizontal, .top])

                    DosageHint()

                    // Patient details
                    MedicationPatientView(
                        name: viewStore.state.prescription.patient?.name,
                        address: viewStore.state.prescription.patient?.address,
                        dateOfBirth: uiFormattedDate(dateString: viewStore.state.prescription.patient?.birthDate),
                        phone: viewStore.state.prescription.patient?.phone,
                        healthInsurance: viewStore.state.prescription.patient?.insurance,
                        healthInsuranceState: viewStore.state.prescription.patient?.status,
                        healthInsuranceNumber: viewStore.state.prescription.patient?.insuranceIdentifier
                    )

                    // Practitioner details
                    MedicationPractitionerView(
                        name: viewStore.state.prescription.practitioner?.name,
                        medicalSpeciality: viewStore.state.prescription.practitioner?.qualification,
                        lanr: viewStore.state.prescription.practitioner?.lanr
                    )

                    // Organization details
                    MedicationOrganizationView(
                        name: viewStore.state.prescription.organization?.name,
                        address: viewStore.state.prescription.organization?.address,
                        bsnr: viewStore.state.prescription.organization?.identifier,
                        phone: viewStore.state.prescription.organization?.phone,
                        email: viewStore.state.prescription.organization?.email
                    )

                    // Work-related accident details
                    MedicationWorkAccidentView(
                        accidentDate: uiFormattedDate(dateString: viewStore.state.prescription.workRelatedAccident?
                            .date),
                        number: viewStore.state.prescription.workRelatedAccident?.workPlaceIdentifier
                    )

                    MedicationProtocolView(
                        protocolEvents: viewStore.state.prescription.auditEvents.map {
                            ($0.text, uiFormattedDateTime(dateTimeString: $0.timestamp))
                        },
                        lastUpdated: uiFormattedDate(dateString: viewStore.state.auditEventsLastUpdated),
                        errorText: viewStore.state.auditEventsErrorText
                    )

                    // Task information details
                    MedicationInfoView(codeInfos: [
                        MedicationInfoView.CodeInfo(
                            code: viewStore.state.prescription.accessCode,
                            codeTitle: L10n.dtlTxtAccessCode
                        ),
                        MedicationInfoView.CodeInfo(
                            code: viewStore.state.prescription.id,
                            codeTitle: L10n.dtlTxtTaskId
                        ),
                    ])
                }

                // Task delete button
                MedicationRemoveButton {
                    viewStore.send(.delete)
                }
                .padding(.top, 16)
            }
            .alert(
                self.store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
            .onAppear {
                viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
            }
            .navigationBarTitle(Text(L10n.prscFdTxtNavigationTitle), displayMode: .inline)
        }
    }

    private struct NavigateToPharmacySearchView: View {
        let store: PrescriptionDetailDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                PrimaryTextButton(
                    text: L10n.dtlBtnPharmacySearch,
                    a11y: A11y.prescriptionDetails.prscDtlHntSubstitution
                ) {
                    viewStore.send(.showPharmacySearch)
                }
                .fullScreenCover(isPresented: viewStore.binding(
                    get: { $0.pharmacySearchState != nil },
                    send: PrescriptionDetailDomain.Action.dismissPharmacySearch
                )) {
                    IfLetStore(store.scope(
                        state: { $0.pharmacySearchState },
                        action: PrescriptionDetailDomain.Action.pharmacySearch(action:)
                    )) { scopedStore in
                        NavigationView {
                            PharmacySearchView(store: scopedStore)
                        }
                        .accentColor(Colors.primary700)
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
            }
        }
    }

    private func localizedStringForDosageFormKey(_ key: String?) -> String? {
        guard let key = key,
              let string = PrescriptionKBVKeyMapping.localizedStringKeyForDosageFormKey(key) else { return nil }
        return NSLocalizedString(string, comment: "")
    }

    private func composedDoseInfoFrom(doseKey: String?,
                                      amount: Decimal?,
                                      dosageKey: String?) -> String? {
        guard let doseKey = doseKey,
              let amount = amount,
              let dosageKey = dosageKey,
              let dosageString = PrescriptionKBVKeyMapping.localizedStringKeyForDosageFormKey(dosageKey)
        else { return nil }
        return "\(doseKey) \(amount) \(NSLocalizedString(dosageString, comment: ""))"
    }

    private func uiFormattedDate(dateString: String?) -> String? {
        if let dateString = dateString,
           let date = globals.fhirDateFormatter.date(from: dateString,
                                                     format: .yearMonthDay) {
            return globals.uiDateFormatter.string(from: date)
        }
        return dateString
    }

    private func uiFormattedDateTime(dateTimeString: String?) -> String? {
        if let dateTimeString = dateTimeString,
           let dateTime = globals.fhirDateFormatter.date(from: dateTimeString,
                                                         format: .yearMonthDayTimeMilliSeconds) {
            return uiDateFormatter.string(from: dateTime)
        }
        return dateTimeString
    }

    var uiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private struct SubstitutionInfoWebView: View {
        var body: some View {
            WebView()
        }

        struct WebView: UIViewRepresentable {
            let navigationController = NoJSNavigationDelegate()

            func makeUIView(context _: Context) -> WKWebView {
                let wkWebView = WKWebView()
                wkWebView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false

                if let url = URL(string: NSLocalizedString("prsc_fd_txt_substitution_read_further_link", comment: "")) {
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
}

extension PrescriptionFullDetailView {
    private struct DosageHint: View {
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
}

struct PrescriptionFullDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                PrescriptionFullDetailView(store: PrescriptionDetailDomain.Dummies.store)
            }.previewLayout(.fixed(width: 480, height: 4000))
            NavigationView {
                PrescriptionFullDetailView(store: PrescriptionDetailDomain.Dummies.store)
            }.previewLayout(.fixed(width: 480, height: 4000))
                .preferredColorScheme(.dark)
        }
    }
}
