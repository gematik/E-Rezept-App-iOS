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
import eRpKit
import eRpStyleKit
import SwiftUI

struct MedicationOverview: View {
    @Perception.Bindable var store: StoreOf<MedicationOverviewDomain>

    var body: some View {
        WithPerceptionTracking {
            ScrollView(.vertical) {
                SingleElementSectionContainer(
                    header: {
                        Label(L10n.prscDtlMedOvTxtSubscribedHeader)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedOvSubscribedHeader)
                    }, content: {
                        Button(action: { store.send(.showSubscribedMedication) }, label: {
                            SubTitle(title: store.subscribed.displayName)
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
                        ForEach(store.dispensed.indices, id: \.self) { index in
                            Button(
                                action: { store.send(.showDispensedMedication(store.dispensed[index])) },
                                label: {
                                    SubTitle(title: store.dispensed[index].displayName)
                                        .sectionContainerIsLastElement(index == store.dispensed.count - 1)
                                }
                            )
                            .buttonStyle(.navigation)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedOvBtnDispensedMedication)
                        }
                    }
                ).sectionContainerStyle(.inline)
            }
            .navigationBarTitle(Text(L10n.prscDtlTxtMedication), displayMode: .inline)
            // MedicationView
            .navigationDestination(
                item: $store.scope(state: \.destination?.medication, action: \.destination.medication)
            ) { store in
                MedicationView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.epaMedication, action: \.destination.epaMedication)
            ) { store in
                EpaMedicationView(store: store)
            }
        }
    }
}

extension ErxMedicationDispense {
    var displayName: String {
        if let epaMedication = epaMedication {
            return epaMedication.displayName ?? L10n.prscTxtFallbackName.text
        } else {
            return medication?.displayName ?? L10n.prscTxtFallbackName.text
        }
    }
}

#Preview("EpaMedication Rezeptur (FHIR>=1.4)") {
    NavigationStack {
        MedicationOverview(
            store: .init(
                initialState: .init(
                    subscribed: ErxTask.Demo.pznMedication,
                    dispensed: [ErxMedicationDispense.Dummies.epaMedicationDispenseRezeptur]
                )
            ) {
                MedicationOverviewDomain()
            }
        )
    }
}

#Preview("EpaMedication Kombipackung (FHIR>=1.4)") {
    NavigationStack {
        MedicationOverview(
            store: .init(
                initialState: .init(
                    subscribed: ErxTask.Demo.pznMedication,
                    dispensed: [ErxMedicationDispense.Dummies.epaMedicationDispenseKombipackung]
                )
            ) {
                MedicationOverviewDomain()
            }
        )
    }
}

#Preview("PZN") {
    NavigationStack {
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
}

#Preview("one medication dispense") {
    NavigationStack {
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
}

#Preview("two medication dispenses") {
    NavigationStack {
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
