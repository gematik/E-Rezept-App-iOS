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
    @Perception.Bindable var store: StoreOf<PharmacyPrescriptionSelectionDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    SingleElementSectionContainer(header: {
                        WithPerceptionTracking {
                            if let profile = store.profile {
                                HStack {
                                    ProfilePictureView(profile: profile)
                                        .frame(width: 40, height: 40, alignment: .center)
                                    Text(profile.name).bold()
                                }
                            }
                        }
                    }, content: {
                        ForEach(Array(store.prescriptions.enumerated()), id: \.element) { index, prescription in
                            WithPerceptionTracking {
                                Button(action: { store.send(.didSelect(prescription.id)) },
                                       label: {
                                           TitleWithSubtitleCellView(
                                               title: prescription.title,
                                               subtitle: "",
                                               isSelected: store.selectedPrescriptionsCopy.contains(prescription)
                                           ).multilineTextAlignment(.leading)
                                       })
                                    .sectionContainerIsLastElement(index == store.prescriptions.count - 1)
                                    .padding(.horizontal)
                            }
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
    }
}

struct PharmacyPrescriptionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacyPrescriptionSelectionView(store: PharmacyPrescriptionSelectionDomain.Dummies.store)
    }
}
