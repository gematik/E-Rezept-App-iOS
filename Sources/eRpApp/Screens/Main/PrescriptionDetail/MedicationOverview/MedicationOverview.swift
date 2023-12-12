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
import eRpKit
import eRpStyleKit
import SwiftUI

struct MedicationOverview: View {
    let store: StoreOf<MedicationOverviewDomain>
    @ObservedObject var viewStore: ViewStore<MedicationOverviewDomain.State, MedicationOverviewDomain.Action>

    init(store: StoreOf<MedicationOverviewDomain>) {
        self.store = store
        viewStore = ViewStore(store) { $0 }
    }

    var body: some View {
        ScrollView(.vertical) {
            SingleElementSectionContainer(
                header: {
                    Label(L10n.prscDtlMedOvTxtSubscribedHeader)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedOvSubscribedHeader)
                }, content: {
                    Button(action: { viewStore.send(.showSubscribedMedication) }, label: {
                        SubTitle(title: viewStore.subscribed.displayName)
                    })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedOvBtnSubscribedMedication)
                }
            ).sectionContainerStyle(.inline)

            SingleElementSectionContainer(
                header: {
                    Label(L10n.prscDtlMedOvTxtDispensedHeader)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedOvDispensedHeader)
                }, content: {
                    ForEach(viewStore.dispensed.indices, id: \.self) { index in
                        Button(
                            action: { viewStore.send(.showDispensedMedication(viewStore.dispensed[index])) },
                            label: {
                                SubTitle(title: viewStore.dispensed[index].displayName)
                                    .sectionContainerIsLastElement(index == viewStore.dispensed.count - 1)
                            }
                        )
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedOvBtnDispensedMedication)
                    }
                }
            ).sectionContainerStyle(.inline)

            // MedicationView
            NavigationLinkStore(
                store.scope(state: \.$destination, action: MedicationOverviewDomain.Action.destination),
                state: /MedicationOverviewDomain.Destinations.State.medication,
                action: MedicationOverviewDomain.Destinations.Action.medication(action:),
                onTap: { viewStore.send(.setNavigation(tag: .medication)) },
                destination: MedicationView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)
        }
        .navigationBarTitle(Text(L10n.prscDtlTxtMedication), displayMode: .inline)
    }
}

extension ErxMedicationDispense {
    var displayName: String {
        medication?.displayName ?? L10n.prscTxtFallbackName.text
    }
}

struct MedicationOverview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // PZN
            NavigationView {
                MedicationOverview(
                    store: .init(
                        initialState: .init(
                            subscribed: ErxTask.Demo.pznMedication,
                            dispensed: [ErxMedicationDispense.Demo.demoMedicationDispense,
                                        ErxMedicationDispense.Demo.demoMedicationDispense]
                        )
                    ) {
                        EmptyReducer()
                    }
                )
            }

            // With one medication dispense
            NavigationView {
                MedicationOverview(
                    store: .init(
                        initialState: .init(
                            subscribed: ErxTask.Demo.freeTextMedication,
                            dispensed: [ErxMedicationDispense.Demo.demoMedicationDispense]
                        )
                    ) {
                        EmptyReducer()
                    }
                )
            }

            // With two medication dispenses
            NavigationView {
                MedicationOverview(
                    store: .init(
                        initialState: .init(
                            subscribed: ErxTask.Demo.compoundingMedication,
                            dispensed: [ErxMedicationDispense]()
                        )
                    ) {
                        EmptyReducer()
                    }
                )
            }.preferredColorScheme(.dark)
        }
    }
}
