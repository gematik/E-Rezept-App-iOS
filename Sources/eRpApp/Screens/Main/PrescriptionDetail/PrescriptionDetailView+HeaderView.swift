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
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    // swiftlint:disable:next type_body_length
    struct HeaderView: View {
        @Perception.Bindable var store: StoreOf<PrescriptionDetailDomain>
        @FocusState var focus: PrescriptionDetailDomain.State.Field?

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    if store.prescription.type == .scanned {
                        HStack {
                            TextField(
                                store.prescription.title,
                                text: $store.prescription.title.sending(\.setName)
                            )
                            .multilineTextAlignment(.center)
                            .font(.title2.weight(.bold))
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtTitleInput)
                            .fixedSize(horizontal: true, vertical: false)
                            .focused($focus, equals: .medicationName)
                            .bind(
                                $store.focus.sending(\.setFocus),
                                to: self.$focus
                            )

                            Button {
                                store.send(.pencilButtonTapped)
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
                        Text(store.medicationName)
                            .multilineTextAlignment(.center)
                            .font(.title2.weight(.bold))
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtTitle)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if store.prescription.erxTask.patient?.coverageType == .SEL {
                        Button(
                            action: { store.send(.setNavigation(tag: .selfPayerInfo)) },
                            label: {
                                Label(L10n.prscDtlBtnSelfPayer, systemImage: SFSymbolName.info)
                                    .labelStyle(.blueFlag)
                            }
                        )
                        .padding(8)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnSelfPayerInfo)
                    }

                    // Flag/Hints for the prescription type
                    switch store.type {
                    case .directAssignment:
                        Button(
                            action: { store.send(.setNavigation(tag: .directAssignmentInfo)) },
                            label: {
                                Label(L10n.prscDtlBtnDirectAssignment, systemImage: SFSymbolName.info)
                                    .labelStyle(.blueFlag)
                            }
                        )
                        .padding(8)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnDirectAssignmentInfo)
                    case .regular, .multiplePrescription:
                        if store.prescription.viewStatus.isError {
                            Button(
                                action: { store.send(.setNavigation(tag: .errorInfo)) }, label: {
                                    Label(L10n.prscDtlDrErrorInfoTitle, systemImage: SFSymbolName.exclamationMark)
                                        .labelStyle(.redFlag)
                                }
                            )
                            .padding(8)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnErrorInfo)

                        } else if !store.isSubstitutionAllowed {
                            Button(
                                action: { store.send(.setNavigation(tag: .substitutionInfo)) }, label: {
                                    Label(L10n.prscDtlTxtNoSubstitution, systemImage: SFSymbolName.info)
                                        .labelStyle(.blueFlag)
                                }
                            )
                            .padding(8)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnHeadlineSubstitutionInfo)
                        }
                    case .scanned:
                        Button(
                            action: { store.send(.setNavigation(tag: .scannedPrescriptionInfo)) }, label: {
                                Label(L10n.prscDtlDrScannedPrescriptionInfoTitle, systemImage: SFSymbolName.info)
                                    .labelStyle(.blueFlag)
                            }
                        )
                        .padding(8)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnScannedPrescriptionInfo)
                    }

                    // Status message about validity and prescription status
                    let message = store.statusMessage
                    if !message.isEmpty {
                        Button(
                            action: { store.send(.setNavigation(tag: .prescriptionValidityInfo)) },
                            label: {
                                HStack {
                                    Text(message)
                                        .padding(.vertical, 8)
                                        .multilineTextAlignment(.center)
                                        .font(Font.subheadline)
                                        .foregroundColor(Colors.systemLabelSecondary)

                                    if store.showStatusMessageAsButton {
                                        Image(systemName: SFSymbolName.info)
                                            .foregroundColor(Colors.primary700)
                                            .font(.subheadline.weight(.semibold))
                                    }
                                }
                                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlTxtPrescriptionValidity)
                            }
                        )
                        .disabled(!store.showStatusMessageAsButton)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPrescriptionValidityInfo)
                    }

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .smallSheet($store.scope(
                            state: \.destination?.prescriptionValidityInfo,
                            action: \.destination.prescriptionValidityInfo
                        )) { store in
                            PrescriptionValidityView(store: store)
                        }
                        .accessibility(hidden: true)

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .smallSheet($store
                            .scope(state: \.destination?.substitutionInfo,
                                   action: \.destination.substitutionInfo)) { store in
                                PrescriptionDetailView.HeaderView.SubstitutionAllowedDrawerView(store: store)
                        }
                        .accessibility(hidden: true)

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .smallSheet($store
                            .scope(state: \.destination?.errorInfo, action: \.destination.errorInfo)) { _ in
                                ErrorInfoDrawerView()
                        }
                        .accessibility(hidden: true)

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .smallSheet($store
                            .scope(state: \.destination?.scannedPrescriptionInfo,
                                   action: \.destination.scannedPrescriptionInfo)) { _ in
                                ScannedPrescriptionInfoDrawerView()
                        }
                        .accessibility(hidden: true)

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .smallSheet($store
                            .scope(state: \.destination?.directAssignmentInfo,
                                   action: \.destination.directAssignmentInfo)) { _ in
                                DirectAssignmentDrawerView()
                        }
                        .accessibility(hidden: true)
                }
                .padding(.horizontal)
                .padding(.top)
            }
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
                .frame(maxWidth: .infinity)
                .background(Colors.systemBackground.ignoresSafeArea())
            }
        }

        struct SubstitutionAllowedDrawerView: View {
            @Perception.Bindable var store: StoreOf<SubstitutionInfoDomain>

            var body: some View {
                WithPerceptionTracking {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.title)
                            .font(.headline)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerTitle)

                        Text(store.description)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerDescription)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.systemBackground.ignoresSafeArea())
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlDrawerSubstitutionInfo)
                }
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
            @Perception.Bindable var store: StoreOf<PrescriptionValidityDomain>

            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.prscDtlDrPrescriptionValidityInfoTitle)
                        .font(.headline)
                        .padding(.vertical, 8)

                    DateView(
                        fromDate: store.acceptBeginDisplayDate,
                        toDate: store.acceptEndDisplayDate
                    )

                    Text(L10n.prscDtlDrPrescriptionValidityInfoAcceptDateDescription)
                        .font(Font.body)
                        .padding(.bottom)
                        .foregroundColor(Colors.systemLabelSecondary)

                    if !store.isMVO {
                        DateView(
                            fromDate: store.expiresBeginDisplayDate,
                            toDate: store.expiresEndDisplayDate
                        )

                        Text(L10n.prscDtlDrPrescriptionValidityInfoExpireDateDescription)
                            .font(Font.body)
                            .foregroundColor(Colors.systemLabelSecondary)
                    }

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
                            .foregroundColor(Colors.primary700)
                        Text(toDate ?? L10n.prscFdTxtNa.text)
                    }
                }
            }
        }
    }
}

extension PrescriptionDetailDomain.State {
    var medicationName: String {
        prescription.title
    }

    var statusMessage: String {
        prescription.statusMessage
    }

    var showStatusMessageAsButton: Bool {
        prescription.status == .ready && prescription.type != .directAssignment
    }

    var type: Prescription.PrescriptionType {
        prescription.type
    }
}

struct PrescriptionDetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
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
