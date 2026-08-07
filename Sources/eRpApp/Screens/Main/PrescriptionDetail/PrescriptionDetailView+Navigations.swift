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
import FeatureEURedeem
import SwiftUI

extension PrescriptionDetailView {
    // swiftlint:disable:next type_body_length
    struct Navigations: View {
        @Bindable var store: StoreOf<PrescriptionDetailDomain>

        var body: some View {
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
                    EmergencyServiceFeeDrawerView(store: store)
                }
                .accessibility(hidden: true)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet($store
                    .scope(state: \.destination?.selfPayerInfo,
                           action: \.destination.selfPayerInfo)) { _ in
                    SelDrawerView(store: store)
                }
                .accessibility(hidden: true)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet($store
                    .scope(state: \.destination?.tPrescriptionInfo,
                           action: \.destination.tPrescriptionInfo)) { _ in
                    TPrescriptionDrawerView(store: store)
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

            // TeratogenicInfoView
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .navigationDestination(
                    item: $store.scope(state: \.destination?.teratogenicInfo, action: \.destination.teratogenicInfo)
                ) { store in
                    PrescriptionDetailView.TeratogenicInfoView(store: store)
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

        struct CoPaymentDrawerView: View {
            @Bindable var store: StoreOf<CoPaymentDomain>

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()

                        CloseButton {
                            store.send(.delegate(.close))
                        }
                    }
                    .padding([.top, .horizontal])

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.title)
                                .font(.headline)
                                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerCoPaymentInfoTitle)

                            Text(store.description)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .accessibilityIdentifier(A11y.prescriptionDetails
                                    .prscDtlDrawerCoPaymentInfoDescription)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerCoPaymentInfo)
            }
        }

        struct EmergencyServiceFeeDrawerView: View {
            let store: StoreOf<PrescriptionDetailDomain>

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()

                        CloseButton {
                            store.send(.setNavigation(tag: .none))
                        }
                    }
                    .padding([.top, .horizontal])

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.prscDtlDrEmergencyServiceFeeInfoTitle)
                                .font(.headline)
                                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerTitle)

                            Text(L10n.prscDtlDrEmergencyServiceFeeInfoDescription)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerDescription)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerEmergencyServiceFeeInfo)
            }
        }

        struct SelDrawerView: View {
            let store: StoreOf<PrescriptionDetailDomain>

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()

                        CloseButton {
                            store.send(.setNavigation(tag: .none))
                        }
                    }
                    .padding([.top, .horizontal])

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.prscDtlDrawerSelfPayerInfoHeader)
                                .font(.headline)

                            Text(L10n.prscDtlDrawerSelfPayerInfoMessage)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerSelfPayerInfo)
            }
        }

        struct TPrescriptionDrawerView: View {
            let store: StoreOf<PrescriptionDetailDomain>

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()

                        CloseButton {
                            store.send(.setNavigation(tag: .none))
                        }
                    }
                    .padding([.top, .horizontal])

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.prscDtlDrawerTprescriptionInfoHeader)
                                .font(.headline)

                            Text(L10n.prscDtlDrawerTprescriptionInfoMessage)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerTPrescriptionInfo)
            }
        }

        struct DosageInstructionsDrawerView: View {
            @Bindable var store: StoreOf<PrescriptionDosageInstructionsDomain>

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()

                        CloseButton {
                            store.send(.delegate(.close))
                        }
                    }
                    .padding([.top, .horizontal])

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.title)
                                .font(.headline)
                                .accessibilityIdentifier(A11y.prescriptionDetails
                                    .prscDtlDrawerDosageInstructionsInfoTitle)

                            Text(store.description)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .accessibilityIdentifier(A11y.prescriptionDetails
                                    .prscDtlDrawerDosageInstructionsInfoDescription)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfo)
            }
        }
    }
}
