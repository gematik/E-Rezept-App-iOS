//
//  Copyright (c) 2022 gematik GmbH
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

struct NavigateToPharmacySearchView: View {
    let store: PrescriptionDetailDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryTextButton(
                text: L10n.dtlBtnPharmacySearch,
                a11y: A11y.prescriptionDetails.prscDtlHntSubstitution
            ) {
                viewStore.send(.showPharmacySearch)
            }
            .fullScreenCover(isPresented: viewStore.binding(
                get: { $0.pharmacySearchState != nil },
                send: PrescriptionDetailDomain.Action.dismissPharmacySearch
            )) {
                IfLetStore(store.scope(
                    state: { $0.pharmacySearchState },
                    action: PrescriptionDetailDomain.Action.pharmacySearch(action:)
                )) { scopedStore in
                    NavigationView {
                        PharmacySearchView(store: scopedStore)
                    }
                    .accentColor(Colors.primary600)
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
        }
    }
}
