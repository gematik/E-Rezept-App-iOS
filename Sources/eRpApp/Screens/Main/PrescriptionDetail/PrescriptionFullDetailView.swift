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
import eRpStyleKit
import SwiftUI
import WebKit

// swiftlint:disable type_body_length
struct PrescriptionFullDetailView: View {
    let store: PrescriptionDetailDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

    init(store: PrescriptionDetailDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let prescription: GroupedPrescription.Prescription
        let isDeleting: Bool
        let isSubstitutionReadMorePresented: Bool
        let dataMatrixCode: UIImage?

        init(state: PrescriptionDetailDomain.State) {
            prescription = state.prescription
            isDeleting = state.isDeleting
            dataMatrixCode = state.loadingState.value
            isSubstitutionReadMorePresented = state.isSubstitutionReadMorePresented
        }

        var auditEventsLastUpdated: String? {
            prescription.auditEvents.first?.timestamp
        }

        var auditEventsErrorText: String? {
            prescription.auditEvents
                .isEmpty ? L10n.prscFdTxtProtocolDownloadError.text : nil
        }

        var showPrescriptionStatus: Bool {
            switch prescription.viewStatus {
            case .open, .archived, .undefined: return false
            case .error: return true
            }
        }

        var showFullDetailBottomBanner: Bool {
            switch prescription.viewStatus {
            case .open, .archived, .undefined: return false
            case .error: return true
            }
        }

        var isDeleteButtonDisabled: Bool {
            // [REQ:gemSpec_FD_eRp:A_19145] prevent deletion while task is in progress
            isDeleting || prescription.erxTask.status == .inProgress
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                // Noctu fee waiver hint
                if viewStore.prescription.noctuFeeWaiver {
                    HintView(
                        hint: Hint<PrescriptionDetailDomain.Action>(
                            id: A11y.prescriptionDetails.prscDtlHntNoctuFeeWaiver,
                            title: L10n.prscFdTxtNoctuTitle.text,
                            message: L10n.prscFdTxtNoctuDescription.text,
                            image: AccessibilityImage(
                                name: Asset.Illustrations.pharmacistf1.name,
                                accessibilityName: L10n.prscFdHintNoctuPic.text
                            ),
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
                        if let image = viewStore.dataMatrixCode {
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
                    .padding([.top, .horizontal])

                    VStack(alignment: .leading, spacing: 0) {
                        // Show PrescriptionStatus if error
                        if viewStore.showPrescriptionStatus {
                            PrescriptionStatusView(prescription: viewStore.prescription)
                        }

                        // Medication name
                        if !viewStore.prescription.isArchived {
                            MedicationTitleView(
                                title: viewStore.prescription.title(for: viewStore.prescription.prescribedMedication),
                                statusMessage: viewStore.prescription.statusMessage
                            )
                        } else if !viewStore.prescription.actualMedications.isEmpty {
                            MedicationTitleView(
                                title: L10n
                                    .prscFdTxtDetailsActualMedicationTitle(viewStore.prescription.actualMedications
                                        .count).text,
                                statusMessage: viewStore.prescription.statusMessage
                            )
                        }
                    }
                    .padding()

                    if !viewStore.prescription.isArchived {
                        NavigateToPharmacySearchView(store: store)
                            .padding([.leading, .trailing, .bottom])
                    }

                    // Substitution hint
                    if viewStore.prescription.substitutionAllowed {
                        HintView(
                            hint: Hint(
                                id: A11y.prescriptionDetails.prscDtlHntSubstitution,
                                title: L10n.prscFdTxtSubstitutionTitle.text,
                                message: L10n.prscFdTxtSubstitutionDescription.text,
                                actionText: L10n.prscFdTxtSubstitutionReadFurther,
                                action: PrescriptionDetailDomain.Action.openSubstitutionInfo,
                                image: AccessibilityImage(
                                    name: Asset.Illustrations.practitionerm1.name,
                                    accessibilityName: L10n.prscFdHintSubstitutionPic.text
                                ),
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
                    // Actual medication details (multiple)
                    ForEach(viewStore.prescription.actualMedications, id: \.self) { medication in
                        MedicationDetails(prescription: viewStore.prescription, medication: medication)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: A11y.prescriptionDetails.prscDtlTxtMedInfoList)

                    // Prescriped medication details
                    if viewStore.prescription.isArchived {
                        MedicationTitleView(title: L10n.prscFdTxtDetailsPrescripedMedicationTitle.text,
                                            statusMessage: viewStore.prescription.statusMessage)
                            .padding()
                    }

                    MedicationDetails(
                        prescription: viewStore.prescription,
                        medication: viewStore.prescription.prescribedMedication
                    )

                    DosageHint()

                    // Patient details
                    MedicationPatientView(
                        name: viewStore.prescription.patient?.name,
                        address: viewStore.prescription.patient?.address,
                        dateOfBirth: Self.uiFormattedDate(dateString: viewStore.prescription.patient?.birthDate),
                        phone: viewStore.prescription.patient?.phone,
                        healthInsurance: viewStore.prescription.patient?.insurance,
                        healthInsuranceState: viewStore.prescription.patient?.status,
                        healthInsuranceNumber: viewStore.prescription.patient?.insuranceId
                    )

                    // Practitioner details
                    MedicationPractitionerView(
                        name: viewStore.prescription.practitioner?.name,
                        medicalSpeciality: viewStore.prescription.practitioner?.qualification,
                        lanr: viewStore.prescription.practitioner?.lanr
                    )

                    // Organization details
                    MedicationOrganizationView(
                        name: viewStore.prescription.organization?.name,
                        address: viewStore.prescription.organization?.address,
                        bsnr: viewStore.prescription.organization?.identifier,
                        phone: viewStore.prescription.organization?.phone,
                        email: viewStore.prescription.organization?.email
                    )

                    // Work-related accident details
                    MedicationWorkAccidentView(
                        accidentDate: Self.uiFormattedDate(dateString: viewStore.prescription.workRelatedAccident?
                            .date),
                        number: viewStore.prescription.workRelatedAccident?.workPlaceIdentifier
                    )

                    // Task information details
                    MedicationInfoView(codeInfos: [
                        MedicationInfoView.CodeInfo(
                            code: viewStore.prescription.accessCode,
                            codeTitle: L10n.dtlTxtAccessCode,
                            accessibilityId: A11y.prescriptionDetails.prscDtlTxtAccessCode
                        ),
                        MedicationInfoView.CodeInfo(
                            code: viewStore.prescription.id,
                            codeTitle: L10n.dtlTxtTaskId,
                            accessibilityId: A11y.prescriptionDetails.prscDtlTxtTaskId
                        ),
                    ])
                }

                // Task delete button
                Button(action: { viewStore.send(.delete) }, label: {
                    if viewStore.isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Label(L10n.dtlBtnDeleteMedication, systemImage: SFSymbolName.trash)
                    }
                })
                    .disabled(viewStore.isDeleteButtonDisabled)
                    .buttonStyle(.primary(isEnabled: !viewStore.isDeleteButtonDisabled, isDestructive: true))
                    .accessibility(identifier: A11y.prescriptionDetails.prscDtlBtnDeleteMedication)
                    .padding(.top)

                if viewStore.state.prescription.erxTask.status == .inProgress {
                    Text(L10n.dtlBtnDeleteDisabledNote)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .padding(.horizontal)
                        .accessibility(identifier: A11y.prescriptionDetails.prscDtlTxtDeleteDisabledNote)
                }
            }

            // BottomBanner
            if viewStore.showFullDetailBottomBanner {
                HStack(spacing: 0) {
                    Text(L10n.prscFdTxtErrorBannerMessage)

                    Button {
                        viewStore.send(.errorBannerButtonPressed)
                    } label: {
                        Text(L10n.prscFdBtnErrorBanner)
                    }
                    .buttonStyle(BottomReportButtonStyle())
                    .accessibility(identifier: A11y.prescriptionDetails.prscDtlTxtMedError)
                    .padding()
                }
                .padding()
                .topBorder(strokeWith: 1, color: Colors.separator)
            }
        }
        .alert(
            self.store.scope(state: \.alertState),
            dismiss: .alertDismissButtonTapped
        )
        .onAppear {
            viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
        }
        .navigationBarTitle(Text(L10n.prscFdTxtNavigationTitle), displayMode: .inline)

        Rectangle()
            .frame(width: 0, height: 0)
            .sheet(isPresented: viewStore.binding(
                get: { $0.isSubstitutionReadMorePresented },
                send: PrescriptionDetailDomain.Action.dismissSubstitutionInfo
            )) {
                SubstitutionInfoWebView()
            }
            .hidden()
            .accessibility(hidden: true)
    }

    private static func localizedStringForDosageFormKey(_ key: String?) -> String? {
        guard let key = key,
              let string = PrescriptionKBVKeyMapping.localizedStringKeyForDosageFormKey(key) else { return nil }
        return NSLocalizedString(string, comment: "")
    }

    private static func composedDoseInfoFrom(doseKey: String?,
                                             amount: Decimal?,
                                             dosageKey: String?) -> String? {
        guard let doseKey = doseKey,
              let amount = amount,
              let dosageKey = dosageKey,
              let dosageString = PrescriptionKBVKeyMapping.localizedStringKeyForDosageFormKey(dosageKey)
        else { return nil }
        return "\(doseKey) \(amount) \(NSLocalizedString(dosageString, comment: ""))"
    }

    private static func uiFormattedDate(dateString: String?) -> String? {
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

    private struct MedicationDetails: View {
        let prescription: GroupedPrescription.Prescription
        let medication: GroupedPrescription.Medication?

        var title: String {
            if prescription.isArchived {
                return prescription.title(for: medication)
            } else {
                return L10n.prscFdTxtDetailsPrescripedMedicationTitle.text
            }
        }

        var body: some View {
            MedicationDetailsView(
                title: title,
                dosageForm: localizedStringForDosageFormKey(medication?
                    .dosageForm),
                dose: composedDoseInfoFrom(
                    doseKey: medication?.dose,
                    amount: medication?.amount,
                    dosageKey: medication?.dosageForm
                ),
                pzn: medication?.pzn,
                isArchived: prescription.isArchived,
                lot: medication?.lot,
                expiresOn: uiFormattedDate(dateString: medication?.expiresOn)
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
    }
}

struct BottomReportButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(.center)
            .foregroundColor(Color.white)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
            .background(Colors.red600)
            .cornerRadius(16)
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
            NavigationView {
                PrescriptionFullDetailView(
                    store: PrescriptionDetailDomain.Store(
                        initialState: PrescriptionDetailDomain.State(
                            prescription: .Dummies.prescriptionError, isArchived: false
                        ),
                        reducer: PrescriptionDetailDomain.domainReducer,
                        environment: PrescriptionDetailDomain.Dummies.environment
                    )
                )
            }.previewLayout(.fixed(width: 480, height: 4000))
        }
    }
}
