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
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    struct ToolbarViewModifier: ViewModifier {
        @Perception.Bindable var store: StoreOf<PrescriptionDetailDomain>

        func body(content: Content) -> some View {
            WithPerceptionTracking {
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
                    .sheet(item: $store
                        .scope(state: \.destination?.sharePrescription,
                               action: \.destination.sharePrescription)) { store in
                            ShareViewController(store: store)
                    }
            }
        }

        private struct ToolbarMenu: View {
            @Perception.Bindable var store: StoreOf<PrescriptionDetailDomain>

            var body: some View {
                WithPerceptionTracking {
                    VStack {
                        Button(
                            action: { store.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size)) },
                            label: { Label(L10n.prscDtlBtnShare, systemImage: SFSymbolName.share) }
                        )
                        .accessibility(identifier: A11y.prescriptionDetails.prscDtlToolbarMenuBtnShare)
                        if store.prescription.type == .scanned {
                            Button(
                                action: { store.send(.toggleRedeemPrescription) },
                                label: {
                                    if store.prescription.isArchived {
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
                            action: { store.send(.delete) },
                            label: { Label(L10n.prscDtlBtnDelete, systemImage: SFSymbolName.trash) }
                        )
                        .accessibility(identifier: A11y.prescriptionDetails.prscDtlToolbarMenuBtnDelete)
                    }
                }
            }
        }
    }
}

extension View {
    func prescriptionDetailToolbarItem(store: StoreOf<PrescriptionDetailDomain>) -> some View {
        modifier(
            PrescriptionDetailView.ToolbarViewModifier(store: store)
        )
    }
}

struct PrescriptionDetailViewToolbarItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
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
