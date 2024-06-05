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

import Combine
import ComposableArchitecture
import Dependencies
import eRpKit
import SwiftUI

@Reducer
struct MedicationOverviewDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = prescriptionDetail_medication
        case medication(MedicationDomain)
    }

    @ObservableState
    struct State: Equatable {
        let subscribed: ErxMedication
        let dispensed: [ErxMedicationDispense]
        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case showSubscribedMedication
        case showDispensedMedication(ErxMedicationDispense)
        case resetNavigation
    }

    @Dependency(\.uiDateFormatter) var uiDateFormatter

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showSubscribedMedication:
                let medicationState = MedicationDomain.State(subscribed: state.subscribed)
                state.destination = .medication(medicationState)
                return .none
            case let .showDispensedMedication(medicationDispense):
                let medicationState = MedicationDomain.State(
                    dispensed: medicationDispense,
                    dateFormatter: uiDateFormatter
                )
                state.destination = .medication(medicationState)
                return .none
            case .resetNavigation:
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
