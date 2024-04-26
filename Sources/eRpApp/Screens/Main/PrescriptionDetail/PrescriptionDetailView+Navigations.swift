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
        let store: StoreOf<PrescriptionDetailDomain>
        @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

        init(store: PrescriptionDetailDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let destinationTag: PrescriptionDetailDomain.Destinations.State.Tag?

            init(state: PrescriptionDetailDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        var body: some View {
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .coPaymentInfo },
                    set: { if !$0 { viewStore.send(.setNavigation(tag: nil), animation: .easeInOut) } }
                )) {
                    IfLetStore(
                        store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                        state: /PrescriptionDetailDomain.Destinations.State.coPaymentInfo,
                        action: PrescriptionDetailDomain.Destinations.Action.coPaymentInfo,
                        then: CoPaymentDrawerView.init(store:)
                    )
                }
                .accessibility(hidden: true)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .emergencyServiceFeeInfo },
                    set: { if !$0 { viewStore.send(.setNavigation(tag: nil), animation: .easeInOut) } }
                ), content: EmergencyServiceFeeDrawerView.init)
                .accessibility(hidden: true)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .dosageInstructionsInfo },
                    set: { if !$0 { viewStore.send(.setNavigation(tag: nil), animation: .easeInOut) } }
                )) {
                    IfLetStore(
                        store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                        state: /PrescriptionDetailDomain.Destinations.State.dosageInstructionsInfo,
                        action: PrescriptionDetailDomain.Destinations.Action.dosageInstructionsInfo,
                        then: DosageInstructionsDrawerView.init(store:)
                    )
                }
                .accessibility(hidden: true)

            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.chargeItem,
                action: PrescriptionDetailDomain.Destinations.Action.chargeItem(action:),
                onTap: { viewStore.send(.setNavigation(tag: .chargeItem)) },
                destination: ChargeItemView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.technicalInformations,
                action: PrescriptionDetailDomain.Destinations.Action.technicalInformations,
                onTap: { viewStore.send(.setNavigation(tag: .technicalInformations)) },
                destination: TechnicalInformationsView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.patient,
                action: PrescriptionDetailDomain.Destinations.Action.patient,
                onTap: { viewStore.send(.setNavigation(tag: .patient)) },
                destination: PrescriptionDetailView.PatientView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // PractitionerView
            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.practitioner,
                action: PrescriptionDetailDomain.Destinations.Action.practitioner,
                onTap: { viewStore.send(.setNavigation(tag: .practitioner)) },
                destination: PrescriptionDetailView.PractitionerView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // OrganisationView
            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.organization,
                action: PrescriptionDetailDomain.Destinations.Action.organization,
                onTap: { viewStore.send(.setNavigation(tag: .organization)) },
                destination: PrescriptionDetailView.OrganizationView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // AccidentInfoView
            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.accidentInfo,
                action: PrescriptionDetailDomain.Destinations.Action.accidentInfo,
                onTap: { viewStore.send(.setNavigation(tag: .accidentInfo)) },
                destination: PrescriptionDetailView.AccidentInfoView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // MedicationView
            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.medication,
                action: PrescriptionDetailDomain.Destinations.Action.medication(action:),
                onTap: { viewStore.send(.setNavigation(tag: .medication)) },
                destination: MedicationView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // MedicationOverview
            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.medicationOverview,
                action: PrescriptionDetailDomain.Destinations.Action.medicationOverview(action:),
                onTap: { viewStore.send(.setNavigation(tag: .medicationOverview)) },
                destination: MedicationOverview.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // MedicationReminder
            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.medicationReminder,
                action: PrescriptionDetailDomain.Destinations.Action.medicationReminder(action:),
                onTap: { viewStore.send(.setNavigation(tag: .medicationReminder)) },
                destination: MedicationReminderSetupView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // MatrixCode
            NavigationLinkStore(
                store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                state: /PrescriptionDetailDomain.Destinations.State.matrixCode,
                action: PrescriptionDetailDomain.Destinations.Action.matrixCode(action:),
                onTap: {},
                destination: MatrixCodeView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)
        }

        struct CoPaymentDrawerView: View {
            @ObservedObject var viewStore: ViewStore<
                PrescriptionDetailDomain.Destinations.CoPaymentState,
                PrescriptionDetailDomain.Destinations.Action.None
            >

            init(store: Store<
                PrescriptionDetailDomain.Destinations.CoPaymentState,
                PrescriptionDetailDomain.Destinations.Action.None
            >) {
                viewStore = ViewStore(store) { $0 }
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.title)
                        .font(.headline)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerCoPaymentInfoTitle)

                    Text(viewStore.description)
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

        struct EmergencyServiceFeeDrawerView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrEmergencyServiceFeeInfoTitle)
                        .font(.headline)

                    Text(L10n.prscDtlDrEmergencyServiceFeeInfoDescription)
                        .foregroundColor(Colors.systemLabelSecondary)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerEmergencyServiceFeeInfo)
            }
        }

        struct DosageInstructionsDrawerView: View {
            @ObservedObject var viewStore: ViewStore<
                PrescriptionDetailDomain.Destinations.DosageInstructionsState,
                PrescriptionDetailDomain.Destinations.Action.None
            >

            init(store: Store<
                PrescriptionDetailDomain.Destinations.DosageInstructionsState,
                PrescriptionDetailDomain.Destinations.Action.None
            >) {
                viewStore = ViewStore(store) { $0 }
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.title)
                        .font(.headline)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerDosageInstructionsInfoTitle)

                    Text(viewStore.description)
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
