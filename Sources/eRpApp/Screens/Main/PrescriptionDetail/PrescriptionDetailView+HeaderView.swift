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
import SwiftUI

extension PrescriptionDetailView {
    // swiftlint:disable:next type_body_length
    struct HeaderView: View {
        let store: StoreOf<PrescriptionDetailDomain>
        @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>
        @FocusState var focus: PrescriptionDetailDomain.State.Field?

        init(store: PrescriptionDetailDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        var body: some View {
            VStack {
                if viewStore.type == .scanned {
                    HStack {
                        TextField(
                            viewStore.medicationName,
                            text: viewStore.binding(
                                get: \.medicationName,
                                send: PrescriptionDetailDomain.Action.setName
                            )
                        )
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtTitleInput)
                        .fixedSize(horizontal: true, vertical: false)
                        .focused($focus, equals: .medicationName)
                        .bind(
                            viewStore.binding(
                                get: \.focus,
                                send: PrescriptionDetailDomain.Action.setFocus
                            ),
                            to: self.$focus
                        )

                        Button {
                            viewStore.send(.pencilButtonTapped)
                        } label: {
                            Image(systemName: SFSymbolName.pencil)
                                .font(.title3.weight(.bold))
                                .foregroundColor(Colors.primary700)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnEditTitle)
                        .hidden(focus == .medicationName)
                    }.padding()
                } else {
                    Text(viewStore.medicationName)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtTitle)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Flag/Hints for the prescription type
                switch viewStore.type {
                case .directAssignment:
                    Button(
                        action: { viewStore.send(.setNavigation(tag: .directAssignmentInfo)) },
                        label: {
                            Label(L10n.prscDtlBtnDirectAssignment, systemImage: SFSymbolName.info)
                                .labelStyle(.blueFlag)
                        }
                    )
                    .padding(8)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnDirectAssignmentInfo)
                case .regular, .multiplePrescription:
                    if viewStore.prescription.viewStatus.isError {
                        Button(
                            action: { viewStore.send(.setNavigation(tag: .errorInfo)) }, label: {
                                Label(L10n.prscDtlDrErrorInfoTitle, systemImage: SFSymbolName.exclamationMark)
                                    .labelStyle(.redFlag)
                            }
                        )
                        .padding(8)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnErrorInfo)

                    } else if viewStore.isSubstitutionAllowed {
                        Button(
                            action: { viewStore.send(.setNavigation(tag: .substitutionInfo)) }, label: {
                                Label(L10n.prscDtlDrSubstitutionInfoTitle, systemImage: SFSymbolName.info)
                                    .labelStyle(.blueFlag)
                            }
                        )
                        .padding(8)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnSubstitutionInfo)
                    }
                case .scanned:
                    Button(
                        action: { viewStore.send(.setNavigation(tag: .scannedPrescriptionInfo)) }, label: {
                            Label(L10n.prscDtlDrScannedPrescriptionInfoTitle, systemImage: SFSymbolName.info)
                                .labelStyle(.blueFlag)
                        }
                    )
                    .padding(8)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnScannedPrescriptionInfo)
                }

                // Status message about validity and prescription status
                let message = viewStore.statusMessage
                if !message.isEmpty {
                    Button(
                        action: { viewStore.send(.setNavigation(tag: .prescriptionValidityInfo)) },
                        label: {
                            HStack {
                                Text(message)
                                    .padding(.vertical, 8)
                                    .multilineTextAlignment(.center)
                                    .font(Font.subheadline)
                                    .foregroundColor(Colors.systemLabelSecondary)

                                if viewStore.showStatusMessageAsButton {
                                    Image(systemName: SFSymbolName.info)
                                        .foregroundColor(Colors.primary600)
                                        .font(.subheadline.weight(.semibold))
                                }
                            }
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtPrescriptionValidity)
                        }
                    )
                    .disabled(!viewStore.showStatusMessageAsButton)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPrescriptionValidityInfo)
                }

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .prescriptionValidityInfo },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    )) {
                        IfLetStore(
                            store.scope(state: \.$destination, action: PrescriptionDetailDomain.Action.destination),
                            state: /PrescriptionDetailDomain.Destinations.State.prescriptionValidityInfo,
                            action: PrescriptionDetailDomain.Destinations.Action.prescriptionValidityInfo,
                            then: PrescriptionValidityView.init(store:)
                        )
                    }
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .substitutionInfo },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ), content: SubstitutionAllowedDrawerView.init)
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .errorInfo },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ), content: ErrorInfoDrawerView.init)
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .scannedPrescriptionInfo },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ), content: ScannedPrescriptionInfoDrawerView.init)
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .directAssignmentInfo },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }
                    ), content: DirectAssignmentDrawerView.init)
                    .accessibility(hidden: true)
            }
            .padding(.horizontal)
            .padding(.top)
        }

        struct DirectAssignmentDrawerView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.davTxtDirectAssignmentTitle)
                        .font(.headline)
                        .accessibilityIdentifier(A11y.directAssignment.davTxtDirectAssignmentTitle)
                    Text(L10n.davTxtDirectAssignmentHint)
                        .font(Font.body)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .accessibilityIdentifier(A11y.directAssignment.davTxtDirectAssignmentHint)
                    Spacer()
                }
                .padding()
                .background(Colors.systemBackground.ignoresSafeArea())
            }
        }

        struct SubstitutionAllowedDrawerView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrSubstitutionInfoTitle)
                        .font(.headline)

                    Text(L10n.prscDtlDrSubstitutionInfoDescription)
                        .foregroundColor(Colors.systemLabelSecondary)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerSubstitutionInfo)
            }
        }

        struct ErrorInfoDrawerView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrErrorInfoTitle)
                        .font(.headline)

                    Text(L10n.prscDtlDrErrorInfoDescription)
                        .foregroundColor(Colors.systemLabelSecondary)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerErrorInfo)
            }
        }

        struct ScannedPrescriptionInfoDrawerView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrScannedPrescriptionInfoTitle)
                        .font(.headline)

                    Text(L10n.prscDtlDrScannedPrescriptionInfoDescription)
                        .foregroundColor(Colors.systemLabelSecondary)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerScannedPrescriptionInfo)
            }
        }

        struct PrescriptionValidityView: View {
            @ObservedObject var viewStore: ViewStore<
                PrescriptionDetailDomain.Destinations.PrescriptionValidityState?,
                PrescriptionDetailDomain.Destinations.Action.None
            >

            init(store: Store<
                PrescriptionDetailDomain.Destinations.PrescriptionValidityState?,
                PrescriptionDetailDomain.Destinations.Action.None
            >) {
                viewStore = ViewStore(store) { $0 }
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrPrescriptionValidityInfoTitle)
                        .font(.headline)
                        .padding(.vertical, 8)

                    DateView(
                        fromDate: viewStore.state?.acceptBeginDisplayDate,
                        toDate: viewStore.state?.acceptEndDisplayDate
                    )

                    Text(L10n.prscDtlDrPrescriptionValidityInfoAcceptDateDescription)
                        .font(Font.body)
                        .padding(.bottom)
                        .foregroundColor(Colors.systemLabelSecondary)

                    DateView(
                        fromDate: viewStore.state?.expiresBeginDisplayDate,
                        toDate: viewStore.state?.expiresEndDisplayDate
                    )

                    Text(L10n.prscDtlDrPrescriptionValidityInfoExpireDateDescription)
                        .font(Font.body)
                        .foregroundColor(Colors.systemLabelSecondary)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerPrescriptionValidityInfo)
            }

            struct DateView: View {
                let fromDate: String?
                let toDate: String?

                var body: some View {
                    HStack {
                        Text(fromDate ?? L10n.prscFdTxtNa.text)
                        Image(systemName: SFSymbolName.arrowRight)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Colors.primary600)
                        Text(toDate ?? L10n.prscFdTxtNa.text)
                    }
                }
            }
        }

        struct ViewState: Equatable {
            let prescription: Prescription
            let medicationName: String
            let statusMessage: String
            let showStatusMessageAsButton: Bool
            let isDirectAssignment: Bool
            let isSubstitutionAllowed: Bool
            var destinationTag: PrescriptionDetailDomain.Destinations.State.Tag?
            let type: Prescription.PrescriptionType
            let isManualRedeemEnabled: Bool
            let focus: PrescriptionDetailDomain.State.Field?

            init(state: PrescriptionDetailDomain.State) {
                prescription = state.prescription
                medicationName = state.prescription.title
                statusMessage = state.prescription.statusMessage
                showStatusMessageAsButton = state.prescription.status == .ready && state.prescription
                    .type != .directAssignment
                isDirectAssignment = state.prescription.type == .directAssignment
                isSubstitutionAllowed = state.prescription.medicationRequest.substitutionAllowed
                destinationTag = state.destination?.tag
                type = state.prescription.type
                isManualRedeemEnabled = state.prescription.isManualRedeemEnabled
                focus = state.focus
            }
        }
    }
}

struct PrescriptionDetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrescriptionDetailView.HeaderView(store: PrescriptionDetailDomain.Dummies.store)
        }

        PrescriptionDetailView.HeaderView(
            store: Store(
                initialState: .init(
                    prescription: Prescription.Dummies.scanned,
                    isArchived: false
                )
            ) {
                PrescriptionDetailDomain()
            }
        )

        PrescriptionDetailView.HeaderView(store: PrescriptionDetailDomain.Dummies.store)
            .previewLayout(.fixed(width: 480, height: 3200))
            .preferredColorScheme(.dark)

        PrescriptionDetailView.HeaderView(
            store: PrescriptionDetailDomain.Dummies.storeFor(
                PrescriptionDetailDomain.State(
                    prescription: .Dummies.prescriptionDirectAssignment, isArchived: false
                )
            )
        )

        PrescriptionDetailView.HeaderView(
            store: PrescriptionDetailDomain.Dummies.storeFor(
                PrescriptionDetailDomain.State(
                    prescription: .Dummies.prescriptionError, isArchived: false
                )
            )
        )

        PrescriptionDetailView.HeaderView(
            store: PrescriptionDetailDomain.Dummies.storeFor(
                PrescriptionDetailDomain.State(
                    prescription: .Dummies.scanned, isArchived: false
                )
            )
        )
    }
}
