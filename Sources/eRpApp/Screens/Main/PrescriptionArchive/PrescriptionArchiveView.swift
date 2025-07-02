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
import Perception
import SwiftUI

struct PrescriptionArchiveView: View {
    @Perception.Bindable var store: StoreOf<PrescriptionArchiveDomain>

    init(store: StoreOf<PrescriptionArchiveDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            ScrollView(.vertical) {
                if !store.diGaPrescriptions.isEmpty {
                    Picker(
                        selection: $store.pickerView.sending(\.selectView),
                        label: Text("")
                    ) {
                        ForEach(PrescriptionArchiveDomain.PickerView.allCases, id: \.self) { viewOption in
                            WithPerceptionTracking {
                                Text(viewOption.text).tag(viewOption)
                                    .accessibilityIdentifier(viewOption.accessibilityIdentifier)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .accessibilityIdentifier(A11y.prescriptionArchive.arcBtnSegmentedControl)
                }

                VStack(spacing: 16) {
                    switch store.pickerView {
                    case .prescriptions:
                        ForEach(store.prescriptions.filter { !$0.isDiGaPrescription }) { prescription in
                            WithPerceptionTracking {
                                PrescriptionView(
                                    prescription: prescription
                                ) {
                                    store.send(.prescriptionDetailViewTapped(
                                        selectedPrescription: prescription
                                    ))
                                }
                            }
                        }
                    case .diGa:
                        ForEach(store.diGaPrescriptions) { prescription in
                            WithPerceptionTracking {
                                PrescriptionView(
                                    prescription: prescription
                                ) {
                                    store.send(.prescriptionDetailViewTapped(
                                        selectedPrescription: prescription
                                    ))
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle(Text(L10n.prscArchTxtTitle), displayMode: .inline)
            .task {
                await store.send(.loadLocalPrescriptions).finish()
            }
            // Navigation into details
            .navigationDestination(
                item: $store.scope(state: \.destination?.prescriptionDetail, action: \.destination.prescriptionDetail)
            ) { store in
                PrescriptionDetailView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.diGaDetail, action: \.destination.diGaDetail)
            ) { store in
                DiGaDetailView(store: store)
            }
        }
    }
}

struct PrescriptionArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrescriptionArchiveView(store: PrescriptionArchiveDomain.Dummies.store)
        }
    }
}
