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

extension PrescriptionDetailView {
    struct Navigations: View {
        @Perception.Bindable var store: StoreOf<PrescriptionDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(state: \.destination?.coPaymentInfo, action: \.destination.coPaymentInfo)
                    ) { store in
                        CoPaymentDrawerView(store: store)
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet($store
                        .scope(state: \.destination?.emergencyServiceFeeInfo,
                               action: \.destination.emergencyServiceFeeInfo)) { _ in
                            EmergencyServiceFeeDrawerView()
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet($store
                        .scope(state: \.destination?.selfPayerInfo,
                               action: \.destination.selfPayerInfo)) { _ in
                            SelDrawerView()
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(
                            state: \.destination?.dosageInstructionsInfo,
                            action: \.destination.dosageInstructionsInfo
                        )
                    ) { store in
                        DosageInstructionsDrawerView(store: store)
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.chargeItem, action: \.destination.chargeItem)
                    ) { store in
                        ChargeItemView(store: store)
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(
                            state: \.destination?.technicalInformations,
                            action: \.destination.technicalInformations
                        )
                    ) { store in
                        TechnicalInformationsView(store: store)
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.patient, action: \.destination.patient)
                    ) { store in
                        PrescriptionDetailView.PatientView(store: store)
                    }
                    .accessibility(hidden: true)

                // PractitionerView
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.practitioner, action: \.destination.practitioner)
                    ) { store in
                        PrescriptionDetailView.PractitionerView(store: store)
                    }
                    .accessibility(hidden: true)

                // OrganisationView
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.organization, action: \.destination.organization)
                    ) { store in
                        PrescriptionDetailView.OrganizationView(store: store)
                    }
                    .accessibility(hidden: true)

                // AccidentInfoView
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.accidentInfo, action: \.destination.accidentInfo)
                    ) { store in
                        PrescriptionDetailView.AccidentInfoView(store: store)
                    }
                    .accessibility(hidden: true)

                // MedicationView
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.medication, action: \.destination.medication)
                    ) { store in
                        MedicationView(store: store)
                    }
                    .accessibility(hidden: true)

                // MedicationOverview
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(
                            state: \.destination?.medicationOverview,
                            action: \.destination.medicationOverview
                        )
                    ) { store in
                        MedicationOverview(store: store)
                    }
                    .accessibility(hidden: true)

                // MedicationReminder
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(
                            state: \.destination?.medicationReminder,
                            action: \.destination.medicationReminder
                        )
                    ) { store in
                        MedicationReminderSetupView(store: store)
                    }
                    .accessibility(hidden: true)

                // MatrixCode
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.matrixCode, action: \.destination.matrixCode)
                    ) { store in
                        MatrixCodeView(store: store)
                    }
                    .accessibility(hidden: true)
            }
        }

        struct CoPaymentDrawerView: View {
            @Perception.Bindable var store: StoreOf<CoPaymentDomain>

            var body: some View {
                WithPerceptionTracking {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.title)
                            .font(.headline)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerCoPaymentInfoTitle)

                        Text(store.description)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerCoPaymentInfoDescription)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.systemBackground.ignoresSafeArea())
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerCoPaymentInfo)
                }
            }
        }

        struct EmergencyServiceFeeDrawerView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrEmergencyServiceFeeInfoTitle)
                        .font(.headline)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerTitle)

                    Text(L10n.prscDtlDrEmergencyServiceFeeInfoDescription)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerDescription)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerEmergencyServiceFeeInfo)
            }
        }

        struct SelDrawerView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrawerSelfPayerInfoHeader)
                        .font(.headline)

                    Text(L10n.prscDtlDrawerSelfPayerInfoMessage)
                        .foregroundColor(Colors.systemLabelSecondary)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerSelfPayerInfo)
            }
        }

        struct DosageInstructionsDrawerView: View {
            @Perception.Bindable var store: StoreOf<PrescriptionDosageInstructionsDomain>

            var body: some View {
                WithPerceptionTracking {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.title)
                            .font(.headline)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfoTitle)

                        Text(store.description)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibilityIdentifier(A11y.prescriptionDetails
                                .prscDtlDrawerDosageInstructionsInfoDescription)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.systemBackground.ignoresSafeArea())
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfo)
                }
            }
        }
    }
}
