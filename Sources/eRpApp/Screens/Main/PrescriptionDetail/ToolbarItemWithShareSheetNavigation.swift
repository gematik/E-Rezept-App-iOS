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

struct ToolbarItemWithShareSheetNavigation: ViewModifier {
    @AppStorage("enable_prescription_sharing") var isPrescriptionSharingEnabled = false
    let store: PrescriptionDetailDomain.Store
    @ObservedObject
    var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

    init(store: PrescriptionDetailDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: PrescriptionDetailDomain.Route.Tag?
        let shareImage: UIImage?

        init(state: PrescriptionDetailDomain.State) {
            routeTag = state.route?.tag
            shareImage = state.loadingState.value
        }
    }

    func body(content: Content) -> some View {
        if isPrescriptionSharingEnabled {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewStore.send(.setNavigation(tag: .sharePrescription))
                        }, label: {
                            Image(systemName: SFSymbolName.share)
                        })
                            .accessibility(label: Text(L10n.prscDtlBtnShareTitle))
                            .accessibility(identifier: A11y.prescriptionDetails.prscDtlBtnShare)
                    }
                }
                .sheet(isPresented: Binding<Bool>(
                    get: { viewStore.routeTag == .sharePrescription },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                )) {
                    IfLetStore(
                        store.scope(
                            state: (\PrescriptionDetailDomain.State.route)
                                .appending(path: /PrescriptionDetailDomain.Route.sharePrescription)
                                .extract(from:)
                        )
                    ) { scopedStore in
                        WithViewStore(scopedStore) { routeState in
                            ShareViewController(
                                itemsToShare: ["E-Rezept-App", routeState.state, viewStore.shareImage].compactMap { $0 }
                            )
                        }
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func toolbarShareSheet(store: PrescriptionDetailDomain.Store) -> some View {
        modifier(
            ToolbarItemWithShareSheetNavigation(store: store)
        )
    }
}

struct ToolbarItemWithShareSheetNavigation_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                Text("Share toolbar item 👆")
                    .toolbarShareSheet(store: PrescriptionDetailDomain.Dummies.store)
            }
        }
    }
}
