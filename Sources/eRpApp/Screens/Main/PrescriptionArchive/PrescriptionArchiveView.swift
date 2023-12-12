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

struct PrescriptionArchiveView: View {
    let store: PrescriptionArchiveDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionArchiveDomain.Action>

    init(store: PrescriptionArchiveDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let prescriptions: [Prescription]
        let destinationTag: PrescriptionArchiveDomain.Destinations.State.Tag?

        init(state: PrescriptionArchiveDomain.State) {
            prescriptions = state.prescriptions
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    ForEach(viewStore.prescriptions) { prescription in
                        PrescriptionView(
                            prescription: prescription
                        ) {
                            viewStore.send(.prescriptionDetailViewTapped(
                                selectedPrescription: prescription
                            ))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(Text(L10n.prscArchTxtTitle), displayMode: .inline)
        .task {
            await viewStore.send(.loadLocalPrescriptions).finish()
        }

        // Navigation into details
        NavigationLinkStore(
            store.scope(state: \.$destination, action: PrescriptionArchiveDomain.Action.destination),
            state: /PrescriptionArchiveDomain.Destinations.State.prescriptionDetail,
            action: PrescriptionArchiveDomain.Destinations.Action.prescriptionDetail,
            onTap: { viewStore.send(.setNavigation(tag: .prescriptionDetail)) },
            destination: PrescriptionDetailView.init(store:),
            label: { EmptyView() }
        ).accessibility(hidden: true)
    }
}

struct PrescriptionArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrescriptionArchiveView(store: PrescriptionArchiveDomain.Dummies.store)
        }
    }
}
