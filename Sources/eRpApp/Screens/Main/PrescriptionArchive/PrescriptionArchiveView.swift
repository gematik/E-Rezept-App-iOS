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
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let prescriptions: [Prescription]
        let routeTag: PrescriptionArchiveDomain.Route.Tag?

        init(state: PrescriptionArchiveDomain.State) {
            prescriptions = state.prescriptions
            routeTag = state.route?.tag
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
        .onAppear {
            viewStore.send(.loadLocalPrescriptions)
        }

        // Navigation into details
        NavigationLink(
            destination: IfLetStore(
                store.scope(
                    state: (\PrescriptionArchiveDomain.State.route)
                        .appending(path: /PrescriptionArchiveDomain.Route.prescriptionDetail)
                        .extract(from:),
                    action: PrescriptionArchiveDomain.Action.prescriptionDetailAction(action:)
                )
            ) { scopedStore in
                WithViewStore(scopedStore) { $0.prescription.source } content: { viewStore in
                    switch viewStore.state {
                    case .scanner: PrescriptionLowDetailView(store: scopedStore)
                    case .server: PrescriptionFullDetailView(store: scopedStore)
                    }
                }
            },
            tag: PrescriptionArchiveDomain.Route.Tag.prescriptionDetail,
            selection: viewStore.binding(
                get: \.routeTag,
                send: PrescriptionArchiveDomain.Action.setNavigation
            )
        ) {
            EmptyView()
        }.accessibility(hidden: true)
    }
}

struct PrescriptionArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrescriptionArchiveView(store: PrescriptionArchiveDomain.Dummies.store)
        }
    }
}
