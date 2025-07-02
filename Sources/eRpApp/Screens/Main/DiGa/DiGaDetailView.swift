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

struct DiGaDetailView: View {
    @Perception.Bindable var store: StoreOf<DiGaDetailDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    HeaderView(store: store)

                    // Causing an Perceptible Warning https://github.com/pointfreeco/swift-perception/issues/100
                    _Picker(selection: $store.selectedView.sending(\.changePickerView)) {
                        ForEach(DiGaDetailDomain.DiGaDetailSegments.allCases, id: \.self) { viewOption in
                            WithPerceptionTracking {
                                Text(viewOption.displayText).tag(viewOption)
                            }
                        }
                    }

                    switch store.selectedView {
                    case .overview:
                        OverviewView(store: store)
                    case .details:
                        DetailsView(store: store)
                    }
                }

                if store.showMainButton {
                    Spacer()

                    GreyDivider()

                    if !store.showSelectInsurance {
                        if let buttonText = store.diGaInfo.diGaState.buttonText {
                            PrimaryTextButton(text: LocalizedStringKey(buttonText),
                                              a11y: A11y.digaDetail.digaDtlBtnMainAction) {
                                store.send(.mainButtonTapped)
                            }.padding()
                        }
                    } else {
                        PrimaryTextButton(text: store.isLoading ? L10n.digaDtlBtnMainRequest : L10n
                            .digaDtlBtnMainSelectInsurance,
                            a11y: A11y.digaDetail.digaDtlBtnMainSelectInsurance,
                            isEnabled: !store.isLoading) {
                                store.send(.setNavigation(tag: .insuranceList))
                        }.padding()

                        if store.isLoading {
                            HStack(spacing: 4) {
                                Text(L10n.digaDtlTxtLoadingInsurance)
                                    .font(.subheadline)
                                    .foregroundColor(Color(.secondaryLabel))

                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }.padding([.horizontal, .bottom], 8)
                        }
                    }

                    if store.showRelatedInsurance {
                        HStack(spacing: 4) {
                            Text(L10n.digaDtlTxtSelectedInsurance)
                                .fixedSize()
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))

                            if let selectedInsuranceName = store.selectedInsurance?.name {
                                Button {
                                    store.send(.setNavigation(tag: .insuranceList))
                                } label: {
                                    Text(selectedInsuranceName)
                                        .font(.subheadline)
                                        .foregroundColor(Colors.primary700)
                                        .underline()
                                }.accessibility(identifier: A11y.digaDetail.digaDtlBtnMainSelectedInsurance)
                            }
                        }.padding([.horizontal, .bottom], 8)
                    }
                }
            }.task {
                store.send(.task)
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu(
                        content: { ToolbarMenu(store: store) },
                        label: { Image(systemName: SFSymbolName.ellipsis).foregroundStyle(Colors.primary700) }
                    )
                    .accessibility(identifier: A11y.digaDetail.digaDtlBtnToolbarItem)
                    .contentShape(Rectangle())
                }
            }
            .destinations(store: $store)
        }
    }

    private struct HeaderView: View {
        @Perception.Bindable var store: StoreOf<DiGaDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(decorative: Asset.Prescriptions.DiGa.diGaImage)
                            .accessibilityHidden(true)
                        Spacer()
                    }

                    Text(store.diGaTask.appName ?? L10n.digaDtlTxtNa.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .font(Font.title.weight(.bold))
                        .accessibility(identifier: A11y.digaDetail.digaDtlTxtNameHeader)

                    Text(store.diGaTask.patientName ?? L10n.digaDtlTxtNa.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                        .accessibility(identifier: A11y.digaDetail.digaDtlTxtPatientHeader)
                }.padding()
            }
        }
    }

    private struct ToolbarMenu: View {
        @Perception.Bindable var store: StoreOf<DiGaDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    if case .archived = store.diGaTask.prescription.viewStatus {
                    } else {
                        if store.diGaInfo.diGaState.archivable {
                            Button(
                                action: { store.send(.archive) },
                                label: { Text(L10n.digaDtlBtnTbmArchive) }
                            )
                            .accessibility(identifier: A11y.digaDetail.digaDtlBtnArchiveToolbar)
                        }
                        if store.diGaInfo.diGaState.unarchivable {
                            Button(
                                action: { store.send(.unarchive) },
                                label: { Text(L10n.digaDtlBtnTbmUnarchive) }
                            )
                            .accessibility(identifier: A11y.digaDetail.digaDtlBtnUnarchiveToolbar)
                        }
                    }

                    if store.diGaInfo.diGaState == .insurance {
                        Button(
                            action: { store.send(.redeem) },
                            label: { Text(L10n.digaDtlBtnTbmRedeemAgain) }
                        )
                        .accessibility(identifier: A11y.digaDetail.digaDtlBtnRedeemAgainToolbar)
                    }

                    if store.diGaTask.erxTask.status == .ready {
                        Button(
                            action: { store.send(.redeem) },
                            label: { Text(L10n.digaDtlBtnTbmRequest) }
                        )
                        .accessibility(identifier: A11y.digaDetail.digaDtlBtnRequestToolbar)
                    }
                    Button(
                        role: .destructive,
                        action: { store.send(.delete) },
                        label: { Text(L10n.digaDtlBtnTbmDelete) }
                    )
                    .accessibility(identifier: A11y.digaDetail.digaDtlBtnDeleteToolbar)
                }
            }
        }
    }
}

extension View {
    func destinations(
        store: Perception.Bindable<StoreOf<DiGaDetailDomain>>
    ) -> some View {
        navigationDestination(
            item: store.scope(state: \.destination?.patient, action: \.destination.patient)
        ) { store in
            PrescriptionDetailView.PatientView(store: store)
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.practitioner, action: \.destination.practitioner)
        ) { store in
            PrescriptionDetailView.PractitionerView(store: store)
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.organization, action: \.destination.organization)
        ) { store in
            PrescriptionDetailView.OrganizationView(store: store)
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.technicalInformations, action: \.destination.technicalInformations)
        ) { store in
            PrescriptionDetailView.TechnicalInformationsView(store: store)
        }
        .fullScreenCover(
            item: store.scope(state: \.destination?.cardWall, action: \.destination.cardWall)
        ) { store in
            CardWallIntroductionView(store: store)
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.insuranceList, action: \.destination.insuranceList)
        ) { store in
            DiGaInsuranceListView(store: store)
        }
    }
}

// Workaround based on: https://github.com/pointfreeco/swift-perception/issues/100#issuecomment-2419870624
public struct _Picker<SelectionValue, Content>: View
    where SelectionValue: Hashable, Content: View {
    let content: Content
    let selection: Binding<SelectionValue>

    public init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.selection = selection
    }

    public var body: some View {
        _PerceptionLocals.$skipPerceptionChecking.withValue(true) {
            Picker(selection: selection, content: { content }, label: { Text("") })
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
        }
    }
}

#Preview {
    NavigationStack {
        DiGaDetailView(store: DiGaDetailDomain.Dummies.store)
    }
}
