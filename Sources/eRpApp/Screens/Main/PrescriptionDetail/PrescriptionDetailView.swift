//
//  Copyright (c) 2024 gematik GmbH
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
import eRpKit
import eRpStyleKit
import SwiftUI
import WebKit

struct PrescriptionDetailView: View {
    let store: StoreOf<PrescriptionDetailDomain>
    @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

    init(store: PrescriptionDetailDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        ScrollView(.vertical) {
            HeaderView(store: store)

            if viewStore.isPKVInsured
                && viewStore.hasChargeItem
                || viewStore.chargeItemConstentState != .notAuthenticated {
                ChargeItemHintView(store: store)
            }

            if viewStore.isManualRedeemEnabled {
                MedicationRedeemView(
                    text: viewStore.medicationRedeemButtonTitle,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: viewStore.isRedeemable
                ) {
                    viewStore.send(.toggleRedeemPrescription)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 40)
            }

            if !viewStore.isScannedPrescription {
                SectionContainer(footer: {
                    FooterView { viewStore.send(.openUrlGesundBundDe) }
                }, content: {
                    Button(action: { viewStore.send(.setNavigation(tag: .medicationReminder)) }, label: {
                        SubTitle(
                            title: viewStore.reminderText,
                            description: L10n.prscDtlBtnMedicationReminder.text
                        )
                        .subTitleStyle(.navigation(
                            stateText: viewStore.medicationReminderState
                        ))
                    })
                        .buttonStyle(.navigation)
                        .accessibilityValue(viewStore.medicationReminderState)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnMedicationReminder)

                    Button(action: { viewStore.send(.setNavigation(tag: .dosageInstructionsInfo)) }, label: {
                        SubTitle(
                            title: viewStore.dosageInstructions,
                            description: L10n.prscDtlTxtDosageInstructions
                        ).subTitleStyle(.info)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtDosageInstructions)

                    Button(action: { viewStore.send(.setNavigation(tag: .coPaymentInfo)) }, label: {
                        SubTitle(
                            title: viewStore.coPaymentStatusText,
                            description: L10n.prscDtlTxtAdditionalFee
                        )
                        .subTitleStyle(.info)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnScannedPrescriptionInfo)

                    Button(action: { viewStore.send(.setNavigation(tag: .emergencyServiceFeeInfo)) }, label: {
                        SubTitle(
                            title: viewStore.hasEmergencyServiceFee ? L10n.prscDtlTxtEmergencyServiceFeeCovered : L10n
                                .prscDtlTxtEmergencyServiceFeeNotCovered,
                            description: L10n.prscDtlTxtEmergencyServiceFee
                        )
                        .subTitleStyle(.info)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnEmergencyServiceFee)

                    SubTitle(title: viewStore.quantity, description: L10n.prscDtlTxtQuantity)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtQuantity)

                    Button(action: { viewStore.send(.setNavigation(tag: .medication)) }, label: {
                        SubTitle(title: viewStore.medicationName, details: L10n.prscDtlTxtMedication)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnMedication)

                    if let number = viewStore.multiplePrescriptionNumber {
                        SubTitle(title: number, description: L10n.prscDtlTxtMultiPrescription)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtMultiPrescription)
                    }

                    Button(action: { viewStore.send(.setNavigation(tag: .patient)) }, label: {
                        SubTitle(title: viewStore.patientName, details: L10n.prscDtlTxtInsuredPerson)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnInsuredPerson)

                    Button(action: { viewStore.send(.setNavigation(tag: .practitioner)) }, label: {
                        SubTitle(title: viewStore.practitionerName, details: L10n.prscDtlTxtPractitionerPerson)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPractitioner)

                    Button(action: { viewStore.send(.setNavigation(tag: .organization)) }, label: {
                        SubTitle(title: viewStore.institutionName, details: L10n.prscDtlTxtInstitution)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnInstitution)

                }, moreContent: {
                    if let accidentReason = viewStore.accidentReason {
                        Button(action: { viewStore.send(.setNavigation(tag: .accidentInfo)) }, label: {
                            SubTitle(title: accidentReason, description: L10n.prscDtlTxtAccidentReason)
                        })
                            .buttonStyle(.navigation)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnWorkRelatedAccident)
                    }

                    SubTitle(
                        title: viewStore.bvg ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo,
                        description: L10n.prscDtlTxtBvg
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtBvg)

                    SubTitle(title: viewStore.authoredOnDate, description: L10n.prscDtlTxtAuthoredOnDate)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtAuthoredOn)

                    Button(action: { viewStore.send(.setNavigation(tag: .technicalInformations)) }, label: {
                        SubTitle(title: L10n.prscDtlBtnTechnicalInformations)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnTechnicalInformations)
                })
                    .sectionContainerStyle(.inline)
            } else {
                SingleElementSectionContainer(
                    footer: { FooterView { viewStore.send(.openUrlGesundBundDe) } },
                    content: {
                        Button(action: { viewStore.send(.setNavigation(tag: .technicalInformations)) }, label: {
                            SubTitle(title: L10n.prscDtlBtnTechnicalInformations)
                        })
                            .buttonStyle(.navigation)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnTechnicalInformations)
                    }
                ).sectionContainerStyle(.inline)
            }

            Navigations(store: store)
        }
        .redacted(reason: viewStore.isDeleting ? .placeholder : .init())
        .prescriptionDetailToolbarItem(store: store)
        .task {
            await viewStore.send(.task).finish()
        }
        .onAppear {
            viewStore.send(.startHandoffActivity)
        }
        .alert(
            store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
            state: /PrescriptionDetailDomain.Destinations.State.alert,
            action: PrescriptionDetailDomain.Destinations.Action.alert
        )
        .toast(
            store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
            state: /PrescriptionDetailDomain.Destinations.State.toast,
            action: PrescriptionDetailDomain.Destinations.Action.toast
        )
        .navigationBarTitle(Text(L10n.prscFdTxtNavigationTitle), displayMode: .inline)
    }
}

extension PrescriptionDetailView {
    struct FooterView: View {
        let action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.prscDtlTxtFooter)

                Button(L10n.prscDtlBtnFooter) {
                    action()
                }
            }
            .padding(.top, 20)
        }
    }
}

extension PrescriptionDetailView {
    struct ViewState: Equatable {
        let isDeleting: Bool
        let hasEmergencyServiceFee: Bool
        let coPaymentStatusText: String
        let isScannedPrescription: Bool
        let medicationName: String
        let patientName: String
        let practitionerName: String
        let institutionName: String
        let medicationRedeemButtonTitle: LocalizedStringKey
        let isManualRedeemEnabled: Bool
        let isRedeemable: Bool
        let dosageInstructions: String
        let medicationReminderState: String
        let authoredOnDate: String
        let bvg: Bool
        let multiplePrescriptionNumber: String?
        let accidentReason: String?
        let hasChargeItem: Bool
        let isPKVInsured: Bool
        let chargeItemConstentState: PrescriptionDetailDomain.ChargeItemConsentState
        let destinationTag: PrescriptionDetailDomain.Destinations.State.Tag?
        let quantity: String
        let reminderText: String

        init(state: PrescriptionDetailDomain.State) {
            medicationName = state.prescription.title
            isDeleting = state.isDeleting
            hasEmergencyServiceFee = state.prescription.medicationRequest.hasEmergencyServiceFee
            coPaymentStatusText = state.prescription.coPaymentStatusText
            isScannedPrescription = state.prescription.type == .scanned
            patientName = state.prescription.patient?.name ?? L10n.prscFdTxtNa.text
            practitionerName = state.prescription.practitioner?.name ?? L10n.prscFdTxtNa.text
            institutionName = state.prescription.organization?.name ?? L10n.prscFdTxtNa.text
            medicationRedeemButtonTitle = state.prescription.isArchived ? L10n.dtlBtnToogleMarkedRedeemed.key : L10n
                .dtlBtnToogleMarkRedeemed.key
            isManualRedeemEnabled = state.prescription.isManualRedeemEnabled
            isRedeemable = state.prescription.isRedeemable
            destinationTag = state.destination?.tag
            authoredOnDate = state.prescription.authoredOnDate ?? L10n.prscFdTxtNa.text
            if state.prescription.erxTask.medicationSchedule?.isActive == true {
                medicationReminderState = L10n.prscDtlTxtMedicationReminderOn.text
            } else {
                medicationReminderState = L10n.prscDtlTxtMedicationReminderOff.text
            }
            reminderText = L10n.prscDtlTxtMedicationReminder.text
            dosageInstructions = state.prescription.medicationRequest.dosageInstructions ?? L10n.prscFdTxtNa.text

            bvg = state.prescription.medicationRequest.bvg
            accidentReason = state.prescription.medicationRequest.accidentInfo?.localizedReason.text
            if let quantity = state.prescription.medicationRequest.quantity {
                self.quantity = quantity.value
            } else {
                quantity = L10n.prscFdTxtNa.text
            }
            if state.prescription.medicationRequest.multiplePrescription?.mark == true,
               let number = state.prescription.medicationRequest.multiplePrescription?.numbering,
               let totalNumber = state.prescription.medicationRequest.multiplePrescription?.totalNumber {
                multiplePrescriptionNumber = "\(number) von \(totalNumber)"
            } else {
                multiplePrescriptionNumber = nil
            }
            hasChargeItem = state.chargeItem != nil
            isPKVInsured = state.profile?.profile.insuranceType == .pKV
            chargeItemConstentState = state.chargeItemConsentState
        }
    }
}

struct PrescriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Substitution allowed
            NavigationView {
                PrescriptionDetailView(store: PrescriptionDetailDomain.Dummies.store)
            }

            // Direct assignment
            NavigationView {
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
            NavigationView {
                PrescriptionDetailView(
                    store: PrescriptionDetailDomain.Dummies.storeFor(
                        PrescriptionDetailDomain.State(
                            prescription: .Dummies.prescriptionError, isArchived: false
                        )
                    )
                )
            }

            // Scanned Prescription
            NavigationView {
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
            NavigationView {
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
            NavigationView {
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
