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
import Perception
import Pharmacy
import SwiftUI
import SwiftUIIntrospect

struct PharmacyPrescriptionSelectionView: View {
    @Bindable var store: StoreOf<PharmacyPrescriptionSelectionDomain>

    var body: some View {
        VStack {
            ScrollView {
                SectionContainer(header: {
                    if let profile = store.profile {
                        HStack(spacing: 16) {
                            ProfilePictureView(profile: profile)
                                .frame(width: 40, height: 40, alignment: .center)
                                .accessibilityHidden(true)
                            Text(profile.name).bold()
                        }
                        .padding(.leading, 8)
                    }
                }, content: {
                    Button(
                        action: { store.send(.selectAllPrescriptionsButtonTapped) },
                        label: {
                            Label {
                                SubTitle(title: L10n.phaRedeemTxtSelectAll)
                            } icon: {
                                store.allPrescriptionsSelected ?
                                    Image(systemName: SFSymbolName.checkmarkCircleFill) :
                                    Image(systemName: SFSymbolName.circle)
                            }
                        }
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(A11y.pharmacyPrescriptionList
                        .phaPrescriptionListBtnSelectAll)
                    .accessibilityValue(
                        store.allPrescriptionsSelected ? L10n
                            .sectionTxtIsActiveValue.text : L10n.sectionTxtIsInactiveValue.text
                    )

                    ForEach(Array(store.prescriptions.enumerated()), id: \.element) { index, prescription in
                        Button(
                            action: { store.send(.didSelect(prescription.id)) },
                            label: {
                                TitleWithSubtitleCellView(
                                    title: prescription.title,
                                    subtitle: prescription.statusMessage,
                                    isSelected: store.selectedPrescriptionsCopy.contains(prescription)
                                )
                                .multilineTextAlignment(.leading)
                            }
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityValue(
                            store.selectedPrescriptionsCopy.contains(prescription) ? L10n
                                .sectionTxtIsActiveValue.text : L10n.sectionTxtIsInactiveValue.text
                        )
                        .buttonStyle(.simple(showSeparator: index != store.prescriptions.count - 1))
                    }
                })
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.phaRedeemTxtPrescriptionHeader)
        .task {
            store.send(.updateRedeemablePrescriptions)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    store.send(.saveSelection(store.selectedPrescriptionsCopy))
                }, label: {
                    Text(L10n.phaRedeemTxtSelectedPrescriptionSave)
                })
                    .accessibility(identifier: A11y.pharmacyPrescriptionList.phaPrescriptionListBtnSave)
            }
        }
    }

    private struct TitleWithSubtitleCellView: View {
        var title: String
        var subtitle: String
        var isSelected: Bool
        var imageName: String = SFSymbolName.circle
        var selectedImageName: String = SFSymbolName.checkmarkCircleFill

        var body: some View {
            Label {
                SubTitle(title: title, description: subtitle)
            } icon: {
                isSelected ? Image(systemName: selectedImageName) : Image(systemName: imageName)
            }
        }
    }
}

struct PharmacyPrescriptionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacyPrescriptionSelectionView(store: PharmacyPrescriptionSelectionDomain.Dummies.store)
    }
}
