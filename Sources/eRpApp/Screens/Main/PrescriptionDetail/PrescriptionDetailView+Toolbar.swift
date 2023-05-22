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

extension PrescriptionDetailView {
    struct ToolbarViewModifier: ViewModifier {
        let store: PrescriptionDetailDomain.Store
        @ObservedObject
        var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

        init(store: PrescriptionDetailDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let destinationTag: PrescriptionDetailDomain.Destinations.State.Tag?

            init(state: PrescriptionDetailDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        func body(content: Content) -> some View {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu(
                            content: { ToolbarMenu(store: store) },
                            label: { Image(systemName: SFSymbolName.ellipsis).padding() }
                        )
                        .accessibility(identifier: A11y.prescriptionDetails.prscDtlBtnToolbarItem)
                    }
                }
                .sheet(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .sharePrescription },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                )) {
                    IfLetStore(
                        store.destinationsScope(state: /PrescriptionDetailDomain.Destinations.State.sharePrescription)
                    ) { scopedStore in
                        WithViewStore(scopedStore) { routeState in
                            ShareViewController(
                                itemsToShare: [
                                    "E-Rezept-App",
                                    routeState.state.url,
                                    routeState.state.dataMatrixCodeImage as Any?,
                                ]
                                .compactMap { $0 }
                            )
                        }
                    }
                }
        }

        private struct ToolbarMenu: View {
            @AppStorage("enable_prescription_sharing") var isPrescriptionSharingEnabled = false
            @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

            init(store: PrescriptionDetailDomain.Store) {
                viewStore = ViewStore(store.scope(state: ViewState.init))
            }

            struct ViewState: Equatable {
                let isScannedTask: Bool
                let isArchived: Bool
                let medicationRedeemButtonTitle: LocalizedStringKey

                init(state: PrescriptionDetailDomain.State) {
                    isScannedTask = state.prescription.type == .scanned
                    isArchived = state.prescription.isArchived
                    medicationRedeemButtonTitle = state.prescription.isArchived ? L10n.dtlBtnToogleMarkedRedeemed
                        .key : L10n
                        .dtlBtnToogleMarkRedeemed.key
                }
            }

            var body: some View {
                VStack {
                    if isPrescriptionSharingEnabled {
                        Button(
                            action: { viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size)) },
                            label: { Label(L10n.prscDtlBtnShare, systemImage: SFSymbolName.share) }
                        )
                        .accessibility(identifier: A11y.prescriptionDetails.prscDtlToolbarMenuBtnShare)
                    }
                    if viewStore.isScannedTask {
                        Button(
                            action: { viewStore.send(.toggleRedeemPrescription) },
                            label: {
                                if viewStore.isArchived {
                                    Label(L10n.dtlBtnToogleMarkedRedeemed, systemImage: SFSymbolName.cross)
                                } else {
                                    Label(L10n.dtlBtnToogleMarkRedeemed, systemImage: SFSymbolName.checkmark)
                                }
                            }
                        )
                        .accessibility(identifier: A11y.prescriptionDetails.prscDtlToolbarMenuBtnRedeem)
                    }
                    Button(
                        role: .destructive,
                        action: { viewStore.send(.delete) },
                        label: { Label(L10n.prscDtlBtnDelete, systemImage: SFSymbolName.trash) }
                    )
                    .accessibility(identifier: A11y.prescriptionDetails.prscDtlToolbarMenuBtnDelete)
                }
                .accessibility(identifier: A11y.prescriptionDetails.prscDtlToolbarMenu)
            }
        }
    }
}

extension View {
    func prescriptionDetailToolbarItem(store: PrescriptionDetailDomain.Store) -> some View {
        modifier(
            PrescriptionDetailView.ToolbarViewModifier(store: store)
        )
    }
}

struct PrescriptionDetailViewToolbarItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                VStack(alignment: .trailing) {
                    Text("PrescriptionDetailView toolbar item 👆")
                        .prescriptionDetailToolbarItem(store: PrescriptionDetailDomain.Dummies.storeFor(
                            .init(prescription: Prescription.Dummies.scanned, isArchived: false)
                        ))
                    Spacer()
                }
            }
        }
    }
}
