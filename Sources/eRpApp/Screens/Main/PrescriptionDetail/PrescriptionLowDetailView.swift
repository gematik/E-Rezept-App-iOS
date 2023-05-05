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
import SwiftUI

struct PrescriptionLowDetailView: View {
    let store: PrescriptionDetailDomain.Store
    @ObservedObject
    var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>
    // TODO: move dependency into domain and do formatting in the view model // swiftlint:disable:this todo
    @Dependency(\.uiDateFormatter) var uiDateFormatter

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

        var title: String {
            L10n.prscTxtFallbackName.text
        }

        var isDeleteButtonDisabled: Bool {
            isDeleting || !prescription.isDeleteabel
        }

        var showNavigateToPharmacySearch: Bool {
            prescription.isRedeemable
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
            .padding()

            if viewStore.prescription.type != .directAssignment {
                DataMatrixCodeView(uiImage: viewStore.dataMatrixCode)
                    .padding(.horizontal)
            }

            if viewStore.prescription.isManualRedeemEnabled {
                MedicationRedeemView(
                    text: viewStore.prescription.isArchived ? L10n.dtlBtnToogleMarkedRedeemed : L10n
                        .dtlBtnToogleMarkRedeemed,
                    a11y: A11y.prescriptionDetails.prscDtlBtnToggleRedeem,
                    isEnabled: viewStore.prescription.isRedeemable
                ) {
                    viewStore.send(.toggleRedeemPrescription)
                }
            }

            if !viewStore.prescription.isArchived {
                HintView<PrescriptionDetailDomain.Action>(
                    hint: Hint(id: A11y.prescriptionDetails.prscDtlHntKeepOverview,
                               title: L10n.dtlTxtHintOverviewTitle.text,
                               message: L10n.dtlTxtHintOverviewMessage.text,
                               actionText: nil,
                               action: nil,
                               image: .init(name: Asset.Prescriptions.Details.apothekerin.name),
                               closeAction: nil,
                               style: .neutral,
                               buttonStyle: .tertiary,
                               imageStyle: .topAligned),
                    textAction: {},
                    closeAction: nil
                )
                .padding()
            }

            MedicationProtocolView(
                protocolEvents: [(uiDateFormatter.relativeDate(viewStore.prescription.authoredOn),
                                  L10n.dtlTxtScannedOn.text)],
                lastUpdated: uiDateFormatter.relativeDate(viewStore.prescription.redeemedOn)
            )

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

            Button(
                action: { viewStore.send(.delete) },
                label: {
                    if viewStore.isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Label(L10n.dtlBtnDeleteMedication, systemImage: SFSymbolName.trash)
                    }
                }
            )
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
        .alert(
            store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.alert),
            dismiss: .setNavigation(tag: .none)
        )
        .toolbarShareSheet(store: store)
        .onAppear {
            viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
        }
        .navigationBarTitle(L10n.dtlTxtTitle, displayMode: .inline)
    }

    struct DataMatrixCodeView: View {
        let uiImage: UIImage?

        var body: some View {
            VStack {
                if let image = uiImage {
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
        }
    }
}

struct PrescriptionLowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrescriptionLowDetailView(store: PrescriptionDetailDomain.Dummies.store)
        }
        NavigationView {
            PrescriptionLowDetailView(
                store: PrescriptionDetailDomain.Dummies.storeFor(
                    PrescriptionDetailDomain.State(
                        prescription: .Dummies.prescriptionError, isArchived: false
                    )
                )
            )
        }
    }
}
