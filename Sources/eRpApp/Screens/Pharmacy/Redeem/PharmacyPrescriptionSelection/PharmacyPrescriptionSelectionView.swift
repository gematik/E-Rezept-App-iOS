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
import Introspect
import Pharmacy
import SwiftUI

struct PharmacyPrescriptionSelectionView: View {
    let store: PharmacyPrescriptionSelectionDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PharmacyPrescriptionSelectionDomain.Action>

    init(store: PharmacyPrescriptionSelectionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let prescriptions: [Prescription]
        let selectedPrescriptions: Set<ErxTask>
        var profile: Profile?

        init(state: PharmacyPrescriptionSelectionDomain.State) {
            prescriptions = state.erxTasks.map {
                let isSelected = state.selectedErxTasks.contains($0)
                return Prescription($0, isSelected: isSelected)
            }
            selectedPrescriptions = state.selectedErxTasks
            profile = state.profile
        }

        struct Prescription: Equatable, Identifiable {
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
    }

    var body: some View {
        VStack {
            ScrollView {
                SingleElementSectionContainer(header: {
                    if let profile = viewStore.profile {
                        HStack {
                            ProfilePictureView(profile: profile)
                                .frame(width: 40, height: 40, alignment: .center)
                            Text(profile.name).bold()
                        }
                    }
                }, content: {
                    ForEach(viewStore.prescriptions.indices, id: \.self) { index in
                        Button(action: { viewStore.send(.didSelect(viewStore.prescriptions[index].taskID)) },
                               label: {
                                   TitleWithSubtitleCellView(
                                       title: viewStore.prescriptions[index].title,
                                       subtitle: "",
                                       isSelected: viewStore.prescriptions[index].isSelected
                                   ).multilineTextAlignment(.leading)
                               })
                            .sectionContainerIsLastElement(index == viewStore.prescriptions.count - 1)
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
                    store.send(.saveSelection(viewStore.selectedPrescriptions))
                }, label: {
                    Text(L10n.phaRedeemTxtSelectedPrescriptionSave)
                })
                    .accessibility(identifier: A11y.pharmacyPrescriptionList.phaPrescriptionListBtnSave)
            }
        }
    }
}

struct PharmacyPrescriptionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacyPrescriptionSelectionView(store: PharmacyPrescriptionSelectionDomain.Dummies.store)
    }
}
