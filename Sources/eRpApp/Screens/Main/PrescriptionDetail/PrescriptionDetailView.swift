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
import eRpKit
import eRpStyleKit
import SwiftUI
import WebKit

struct PrescriptionDetailView: View {
    let store: StoreOf<PrescriptionDetailDomain>
    @ObservedObject
    var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

    init(store: PrescriptionDetailDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        ScrollView(.vertical) {
            HeaderView(store: store)

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
                            title: viewStore.hasEmergencyServiceFee ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo,
                            description: L10n.prscDtlTxtEmergencyServiceFee
                        )
                        .subTitleStyle(.info)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnEmergencyServiceFee)

                    Button(action: { /* DH.TODO: //swiftlint:disable:this todo  */ }, label: {
                        SubTitle(title: viewStore.medicationName, details: L10n.prscDtlTxtMedication)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnMedication)

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

                    Button(action: { viewStore.send(.setNavigation(tag: .accidentInfo)) }, label: {
                        SubTitle(title: L10n.prscDtlBtnWorkRelatedAccident)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnWorkRelatedAccident)

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
        .toolbarShareSheet(store: store)
        .navigationBarTitle(Text(L10n.prscFdTxtNavigationTitle), displayMode: .inline)
    }

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

    struct Navigations: View {
        let store: StoreOf<PrescriptionDetailDomain>
        @ObservedObject
        var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

        init(store: PrescriptionDetailDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
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
                        store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.coPaymentInfo),
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

            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.technicalInformations),
                    then: TechnicalInformationsView.init(store:)
                ),
                tag: PrescriptionDetailDomain.Destinations.State.Tag.technicalInformations,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: PrescriptionDetailDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.patient),
                    then: PatientView.init(store:)
                ),
                tag: PrescriptionDetailDomain.Destinations.State.Tag.patient,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: PrescriptionDetailDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

            // PractitionerView
            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.practitioner),
                    then: PractitionerView.init(store:)
                ),
                tag: PrescriptionDetailDomain.Destinations.State.Tag.practitioner,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: PrescriptionDetailDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

            // OrganisationView
            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.organization),
                    then: OrganizationView.init(store:)
                ),
                tag: PrescriptionDetailDomain.Destinations.State.Tag.organization,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: PrescriptionDetailDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)

            // AccidentInfoView
            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.accidentInfo),
                    then: AccidentInfoView.init(store:)
                ),
                tag: PrescriptionDetailDomain.Destinations.State.Tag.accidentInfo,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: PrescriptionDetailDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)
        }

        struct CoPaymentDrawerView: View {
            @ObservedObject
            var viewStore: ViewStore<
                PrescriptionDetailDomain.Destinations.CoPaymentState,
                PrescriptionDetailDomain.Action
            >

            init(store: Store<PrescriptionDetailDomain.Destinations.CoPaymentState, PrescriptionDetailDomain.Action>) {
                viewStore = ViewStore(store)
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
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerSubstitutionInfo)
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
    }
}

extension PrescriptionDetailView {
    struct ViewState: Equatable {
        let isDeleteButtonDisabled: Bool
        let hasEmergencyServiceFee: Bool
        let coPaymentStatusText: String
        let showErrorBanner: Bool
        let isScannedPrescription: Bool
        let medicationName: String
        let patientName: String
        let practitionerName: String
        let institutionName: String
        let medicationRedeemButtonTitle: LocalizedStringKey
        let isManualRedeemEnabled: Bool
        let isRedeemable: Bool
        let destinationTag: PrescriptionDetailDomain.Destinations.State.Tag?

        init(state: PrescriptionDetailDomain.State) {
            medicationName = state.prescription.title
            isDeleteButtonDisabled = !state.prescription.isDeleteabel
            hasEmergencyServiceFee = state.prescription.medicationRequest.hasEmergencyServiceFee
            coPaymentStatusText = state.prescription.coPaymentStatusText
            showErrorBanner = state.prescription.viewStatus.isError
            isScannedPrescription = state.prescription.type == .scanned
            patientName = state.prescription.patient?.name ?? L10n.prscFdTxtNa.text
            practitionerName = state.prescription.practitioner?.name ?? L10n.prscFdTxtNa.text
            institutionName = state.prescription.organization?.name ?? L10n.prscFdTxtNa.text
            medicationRedeemButtonTitle = state.prescription.isArchived ? L10n.dtlBtnToogleMarkedRedeemed.key : L10n
                .dtlBtnToogleMarkRedeemed.key
            isManualRedeemEnabled = state.prescription.isManualRedeemEnabled
            isRedeemable = state.prescription.isRedeemable
            destinationTag = state.destination?.tag
        }

        // DH.TODO: move into alert after tapping delete //swiftlint:disable:this todo
//        var deletionNote: String? {
//            guard !prescription.isDeleteabel else { return nil }
//
//            if prescription.type == .directAssignment {
//                return L10n.prscDeleteNoteDirectAssignment.text
//            }
//
//            if prescription.erxTask.status == .inProgress {
//                return L10n.dtlBtnDeleteDisabledNote.text
//            }
//            return nil
//        }
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
                            prescription: .Dummies.scanned, isArchived: false
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
