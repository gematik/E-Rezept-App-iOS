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
        let prescription: Prescription
        let isDeleting: Bool
        let isSubstitutionReadMorePresented: Bool
        let dataMatrixCode: UIImage?

        init(state: PrescriptionDetailDomain.State) {
            prescription = state.prescription
            isDeleting = state.isDeleting
            dataMatrixCode = state.loadingState.value
            isSubstitutionReadMorePresented = state.isSubstitutionReadMorePresented
        }

        var showFullDetailBottomBanner: Bool {
            switch prescription.viewStatus {
            case .open, .redeem, .archived, .undefined: return false
            case .error: return true
            }
        }

        var isDeleteButtonDisabled: Bool {
            isDeleting || !prescription.isDeleteabel
        }

        var showSubstitutionAllowedHint: Bool {
            !prescription.isArchived && prescription.substitutionAllowed
        }

        var showNoctFeeWaiverHint: Bool {
            prescription.hasEmergencyServiceFee
        }

        var title: String {
            if let name = prescription.prescribedMedication?.name {
                return name
            }
            if case .error = prescription.viewStatus {
                return L10n.prscTxtFallbackName.text
            }
            return L10n.prscFdTxtNa.text
        }

        var deletionNote: String? {
            guard !prescription.isDeleteabel else { return nil }

            if prescription.type == .directAssignment {
                return L10n.prscDeleteNoteDirectAssignment.text
            }

            if prescription.erxTask.status == .inProgress {
                return L10n.dtlBtnDeleteDisabledNote.text
            }
            return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 4) {
                    Text(viewStore.title)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtTitle)
                        .fixedSize(horizontal: false, vertical: true)

                    if viewStore.prescription.type == .directAssignment {
                        DirectAssignedHintView(store: store)
                            .padding(.vertical)
                    }

                    if let message = viewStore.prescription.statusMessage {
                        Text(message)
                            .multilineTextAlignment(.center)
                            .font(Font.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                    }
                }
                .padding([.horizontal, .top])

                VStack(spacing: 20) {
                    // Noctu fee waiver hint
                    if viewStore.showNoctFeeWaiverHint {
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
                        .padding(.horizontal)
                    }

                    if viewStore.prescription.type != .directAssignment {
                        DataMatrixCodeView(uiImage: viewStore.dataMatrixCode)
                            .padding(.horizontal)
                    }

                    // Substitution hint
                    if viewStore.showSubstitutionAllowedHint {
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

                VStack(alignment: .leading, spacing: 0) {
                    if !viewStore.prescription.actualMedications.isEmpty {
                        Text(L10n.prscFdTxtDetailsActualMedicationTitle(viewStore.prescription.actualMedications.count)
                            .text)
                                                    .font(.title2.weight(.bold))
                                                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtTitle)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding([.top, .horizontal])

                        // Actual medication details (multiple)
                        ForEach(viewStore.prescription.actualMedications, id: \.self) { medication in
                            MedicationDetails(prescription: viewStore.prescription, medication: medication)
                        }
                        .accessibilityElement(children: .contain)
                        .accessibility(identifier: A11y.prescriptionDetails.prscDtlTxtMedInfoList)

                        // Prescribed medication details
                        Text(L10n.prscFdTxtDetailsPrescripedMedicationTitle.text)
                            .font(.title2.weight(.bold))
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtTitle)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding([.top, .horizontal])

                        MedicationDetails(
                            prescription: viewStore.prescription,
                            medication: viewStore.prescription.prescribedMedication
                        )
                    } else {
                        MedicationDetails(
                            title: L10n.prscFdTxtDetailsPrescripedMedicationTitle.text,
                            prescription: viewStore.prescription,
                            medication: viewStore.prescription.prescribedMedication
                        )
                    }

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
                    .padding(.vertical)

                if let delitionNote = viewStore.deletionNote {
                    Text(delitionNote)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .padding([.horizontal, .bottom])
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
                    .buttonStyle(.report)
                    .accessibility(identifier: A11y.prescriptionDetails.prscDtlTxtMedError)
                    .padding()
                }
                .padding()
                .topBorder(strokeWith: 1, color: Colors.separator)
            }
        }
        .toolbarShareSheet(store: store)
        .alert(
            self.store
                .scope(state: (\PrescriptionDetailDomain.State.route)
                    .appending(path: /PrescriptionDetailDomain.Route.alert)
                    .extract(from:)),
            dismiss: .setNavigation(tag: .none)
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

    func uiFormattedDateTime(dateTimeString: String?) -> String? {
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
}

struct PrescriptionFullDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                PrescriptionFullDetailView(store: PrescriptionDetailDomain.Dummies.store)
            }
            NavigationView {
                PrescriptionFullDetailView(store: PrescriptionDetailDomain.Dummies.store)
            }.previewLayout(.fixed(width: 480, height: 3200))
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
            }
        }
    }
}
