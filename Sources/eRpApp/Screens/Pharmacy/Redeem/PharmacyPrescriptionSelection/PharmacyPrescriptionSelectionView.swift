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
import Perception
import Pharmacy
import SwiftUI
import SwiftUIIntrospect

struct PharmacyPrescriptionSelectionView: View {
    @Perception.Bindable var store: StoreOf<PharmacyPrescriptionSelectionDomain>

    init(store: StoreOf<PharmacyPrescriptionSelectionDomain>) {
        self.store = store
    }

    struct Prescription: Hashable, Identifiable {
        var id: String { taskID }
        let taskID: String
        let title: String
        var isSelected = false

        init(_ task: ErxTask, isSelected: Bool) {
            taskID = task.id
            title = task.medication?.displayName ?? L10n.prscFdTxtNa.text
            self.isSelected = isSelected
        }
    }

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
                        let prescriptions = store.erxTasks.map {
                            Prescription($0,
                                         isSelected: store.selectedErxTasks.contains($0))
                        }
                        ForEach(Array(prescriptions.enumerated()), id: \.element) { index, prescription in
                            Button(action: { store.send(.didSelect(prescription.taskID)) },
                                   label: {
                                       TitleWithSubtitleCellView(
                                           title: prescription.title,
                                           subtitle: "",
                                           isSelected: prescription.isSelected
                                       ).multilineTextAlignment(.leading)
                                   })
                                .sectionContainerIsLastElement(index == prescriptions.count - 1)
                                .padding(.horizontal)
                        }
                    })
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(L10n.phaRedeemTxtPrescriptionHeader)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        store.send(.saveSelection(store.selectedErxTasks))
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
