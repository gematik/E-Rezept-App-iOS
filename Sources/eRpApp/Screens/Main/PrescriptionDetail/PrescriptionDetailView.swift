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
import eRpStyleKit
import SwiftUI
import WebKit

// swiftlint:disable:next type_body_length
struct PrescriptionDetailView: View {
    @Bindable var store: StoreOf<PrescriptionDetailDomain>

    var body: some View {
        ScrollView(.vertical) {
            HeaderView(store: store)

            if store.profile?.profile.insuranceType.canReceiveChargeItems ?? false
                && store.chargeItem != nil
                || store.chargeItemConsentState != .notAuthenticated {
                ChargeItemHintView(store: store)
            }

            if store.prescription.isRedeemable {
                HStack {
                    Button {
                        store.send(.redeemPressed)
                    } label: {
                        Label {
                            Text(L10n.prscDtlBtnRedeem)
                        } icon: {
                            Image(asset: Asset.Pharmacy.btnApoSmall)
                                .resizable()
                        }
                    }
                    .buttonStyle(.picture(isActive: true))
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnRedeem)

                    Button {
                        store.send(.setNavigation(tag: .matrixCode))
                    } label: {
                        Label {
                            Text(L10n.prscDtlBtnShowMatrixCode)
                        } icon: {
                            Image(asset: Asset.Prescriptions.datamatrix)
                                .resizable()
                        }
                    }
                    .buttonStyle(.picture(isActive: true))
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnShowMatrixCode)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }

            if store.prescription.isManualRedeemEnabled {
                MedicationRedeemView(
                    text: store.medicationRedeemButtonTitle,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: store.prescription.isRedeemable
                ) {
                    store.send(.toggleRedeemPrescription)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
            }

            if store.prescription.type != .scanned {
                EmptyView()
                SectionContainer(
                    header: {
                        Text(L10n.prscDtlTxtSectionDetailsHeader)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)
                            .font(.title2.bold())
                            .accessibilityIdentifier(A11y.prescriptionDetails
                                .prscDtlTxtSectionDetailsHeader)
                    },
                    footer: {
                        FooterView { store.send(.openUrlGesundBundDe) }
                    },
                    content: {
                        Button(
                            action: { store.send(.setNavigation(tag: .medicationReminder)) },
                            label: {
                                LabeledContent {
                                    Text(store.medicationReminderState)
                                } label: {
                                    LabeledContent {
                                        Text(L10n.prscDtlTxtMedicationReminder.text)
                                    } label: {
                                        Text(L10n.prscDtlBtnMedicationReminder.text)
                                    }
                                    .labeledContentStyle(.vertical)
                                }
                                .labeledContentStyle(.horizontal)
                            }
                        )
                        .buttonStyle(.navigation)
                        .accessibilityValue(store.medicationReminderState)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnMedicationReminder)

                        Button(
                            action: { store.send(.setNavigation(tag: .dosageInstructionsInfo)) },
                            label: {
                                LabeledContent {
                                    Text(store.dosageInstructions)
                                } label: {
                                    Text(L10n.prscDtlTxtDosageInstructions)
                                }
                            }
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtDosageInstructions)
                        .labeledContentStyle(.vertical(icon: SFSymbolName.info))

                        Button(action: { store.send(.setNavigation(tag: .coPaymentInfo)) }, label: {
                            LabeledContent {
                                Text(store.prescription.coPaymentStatusText)
                            } label: {
                                Text(L10n.prscDtlTxtAdditionalFee)
                            }
                        })
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnScannedPrescriptionInfo)
                        .labeledContentStyle(.vertical(icon: SFSymbolName.info))

                        Button(
                            action: { store.send(.setNavigation(tag: .emergencyServiceFeeInfo)) },
                            label: {
                                LabeledContent {
                                    Text(store.prescription.medicationRequest.hasEmergencyServiceFee ? L10n
                                        .prscDtlTxtEmergencyServiceFeeCovered : L10n
                                        .prscDtlTxtEmergencyServiceFeeNotCovered)
                                } label: {
                                    Text(L10n.prscDtlTxtEmergencyServiceFee)
                                }
                            }
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnEmergencyServiceFee)
                        .labeledContentStyle(.vertical(icon: SFSymbolName.info))

                        Button(
                            action: { store.send(.setNavigation(tag: .substitutionInfo)) },
                            label: {
                                LabeledContent {
                                    Text(store.isSubstitutionAllowed ? L10n
                                        .prscDtlTxtSubstitutionPossible : L10n
                                        .prscDtlTxtNoSubstitution)
                                } label: {
                                    Text(L10n.prscDtlTxtSubstitution)
                                }
                            }
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnSubstitutionInfo)
                        .labeledContentStyle(.vertical(icon: SFSymbolName.info))

                        LabeledContent {
                            Text(store.quantity)
                        } label: {
                            Text(L10n.prscDtlTxtQuantity)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtQuantity)

                        Button(action: { store.send(.setNavigation(tag: .medication)) }, label: {
                            LabeledContent { Text(store.prescription.title) } label: { Text(L10n.prscDtlTxtMedication) }
                        })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnMedication)

                        if let number = store.multiplePrescriptionNumber {
                            LabeledContent { Text(number) } label: { Text(L10n.prscDtlTxtMultiPrescription) }
                                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtMultiPrescription)
                        }

                        Button(action: { store.send(.setNavigation(tag: .patient)) }, label: {
                            LabeledContent { Text(store.patientName) } label: { Text(L10n.prscDtlTxtInsuredPerson) }
                        })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnInsuredPerson)

                        Button(action: { store.send(.setNavigation(tag: .practitioner)) }, label: {
                            LabeledContent {
                                Text(store.practitionerName)
                            } label: {
                                Text(L10n.prscDtlTxtPractitionerPerson)
                            }
                        })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)

                    }, moreContent: {
                        Button(action: { store.send(.setNavigation(tag: .organization)) }, label: {
                            LabeledContent { Text(store.institutionName) } label: { Text(L10n.prscDtlTxtInstitution) }
                        })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnInstitution)

                        if let accidentReason = store.accidentReason {
                            Button(action: { store.send(.setNavigation(tag: .accidentInfo)) }, label: {
                                LabeledContent { Text(accidentReason) } label: { Text(L10n.prscDtlTxtAccidentReason) }
                            })
                            .buttonStyle(.navigation)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnWorkRelatedAccident)
                        }

                        if store.hasTeratogenicInfo {
                            Button(action: { store.send(.setNavigation(tag: .teratogenicInfo)) }, label: {
                                SubTitle(title: L10n.prscDtlTxtTeratogenicInfo)
                            })
                            .buttonStyle(.navigation)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnTeratogenicInfo)
                        }

                        LabeledContent {
                            Text(store.ser ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                        } label: {
                            Text(L10n.prscDtlTxtBvg)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtBvg)

                        LabeledContent {
                            Text(store.authoredOnDate)
                        } label: {
                            Text(L10n.prscDtlTxtAuthoredOnDate)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtAuthoredOn)

                        Button(
                            action: { store.send(.setNavigation(tag: .technicalInformations)) },
                            label: {
                                SubTitle(title: L10n.prscDtlBtnTechnicalInformations)
                            }
                        )
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails
                            .prscDtlBtnTechnicalInformations)
                    }
                )
                .sectionContainerStyle(.inline)
            } else {
                SectionContainer(
                    footer: { FooterView { store.send(.openUrlGesundBundDe) } },
                    content: {
                        Button(
                            action: { store.send(.setNavigation(tag: .medicationReminder)) },
                            label: {
                                LabeledContent {
                                    Text(store.medicationReminderState)
                                } label: {
                                    LabeledContent {
                                        Text(L10n.prscDtlTxtMedicationReminder.text)
                                    } label: {
                                        Text(L10n.prscDtlBtnMedicationReminder.text)
                                    }
                                    .labeledContentStyle(.vertical)
                                }
                                .labeledContentStyle(.horizontal)
                            }
                        )
                        .buttonStyle(.navigation)
                        .accessibilityValue(store.medicationReminderState)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnMedicationReminder)

                        Button(action: { store.send(.setNavigation(tag: .technicalInformations)) }, label: {
                            SubTitle(title: L10n.prscDtlBtnTechnicalInformations)
                                .subTitleStyle(.navigation)
                        })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnTechnicalInformations)
                    }
                ).sectionContainerStyle(.inline)
            }

            Navigations(store: store)
        }
        .redacted(reason: store.isDeleting ? .placeholder : .init())
        .prescriptionDetailToolbarItem(store: store)
        .task {
            await store.send(.task).finish()
        }
        .onAppear {
            store.send(.startHandoffActivity)
        }
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        .toast($store.scope(state: \.destination?.toast, action: \.destination.toast))
        .navigationBarTitle(Text(L10n.prscFdTxtNavigationTitle), displayMode: .inline)
    }
}

extension PrescriptionDetailView {
    struct FooterView: View {
        let action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.prscDtlTxtFooter)

                Button {
                    action()
                } label: {
                    Text(L10n.prscDtlBtnFooter)
                        .underline()
                }
            }
            .padding(.top, 20)
        }
    }
}

extension PrescriptionDetailDomain.State {
    var patientName: String {
        prescription.patient?.name ?? L10n.prscFdTxtNa.text
    }

    var practitionerName: String {
        prescription.practitioner?.name ?? L10n.prscFdTxtNa.text
    }

    var institutionName: String {
        prescription.organization?.name ?? L10n.prscFdTxtNa.text
    }

    var medicationRedeemButtonTitle: LocalizedStringKey {
        prescription.isArchived ? L10n.dtlBtnToogleMarkedRedeemed.key : L10n.dtlBtnToogleMarkRedeemed.key
    }

    var authoredOnDate: String {
        prescription.authoredOnDate ?? L10n.prscFdTxtNa.text
    }

    var medicationReminderState: String {
        if prescription.erxTask.medicationSchedule?.isActive == true {
            return L10n.prscDtlTxtMedicationReminderOn.text
        } else {
            return L10n.prscDtlTxtMedicationReminderOff.text
        }
    }

    var dosageInstructions: String {
        prescription.medicationRequest.dosageInstructions ?? L10n.prscFdTxtNa.text
    }

    var ser: Bool {
        prescription.medicationRequest.ser
    }

    var accidentReason: String? {
        prescription.medicationRequest.accidentInfo?.localizedReason.text
    }

    var quantity: String {
        if let quantity = prescription.medicationRequest.quantity {
            return quantity.value
        } else {
            return L10n.prscFdTxtNa.text
        }
    }

    var multiplePrescriptionNumber: String? {
        if prescription.medicationRequest.multiplePrescription?.mark == true,
           let number = prescription.medicationRequest.multiplePrescription?.numbering,
           let totalNumber = prescription.medicationRequest.multiplePrescription?.totalNumber {
            return "\(number) / \(totalNumber)"
        } else {
            return nil
        }
    }

    var isSubstitutionAllowed: Bool {
        prescription.medicationRequest.substitutionAllowed
    }

    var hasTeratogenicInfo: Bool {
        prescription.medicationRequest.teratogenicRelatedInformation != nil
    }
}

struct PrescriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Substitution allowed
            NavigationStack {
                PrescriptionDetailView(store: PrescriptionDetailDomain.Dummies.store)
            }

            // Direct assignment
            NavigationStack {
                PrescriptionDetailView(
                    store: PrescriptionDetailDomain.Dummies.storeFor(
                        PrescriptionDetailDomain.State(
                            prescription: .Dummies.prescriptionDirectAssignment, isArchived: false
                        )
                    )
                )
            }
            .preferredColorScheme(.dark)

            // Error Prescription
            NavigationStack {
                PrescriptionDetailView(
                    store: PrescriptionDetailDomain.Dummies.storeFor(
                        PrescriptionDetailDomain.State(
                            prescription: .Dummies.prescriptionError, isArchived: false
                        )
                    )
                )
            }

            // Scanned Prescription
            NavigationStack {
                PrescriptionDetailView(
                    store: PrescriptionDetailDomain.Dummies.storeFor(
                        PrescriptionDetailDomain.State(
                            prescription: .Dummies.scanned,
                            profile: UserProfile.Dummies.profileA,
                            isArchived: false
                        )
                    )
                )
            }

            // Prescription with pkv invoice
            NavigationStack {
                PrescriptionDetailView(
                    store: PrescriptionDetailDomain.Dummies.storeFor(
                        PrescriptionDetailDomain.State(
                            prescription: .Dummies.prescriptionReady,
                            profile: UserProfile.Dummies.profileE,
                            chargeItem: ErxChargeItem.Dummies.dummy.sparseChargeItem,
                            isArchived: true
                        )
                    )
                )
            }

            // dark appearance Scanned
            NavigationStack {
                PrescriptionDetailView(
                    store: PrescriptionDetailDomain.Dummies.storeFor(
                        PrescriptionDetailDomain.State(
                            prescription: .Dummies.scanned, isArchived: false
                        )
                    )
                )
            }.preferredColorScheme(.dark)
        }
    }
}
