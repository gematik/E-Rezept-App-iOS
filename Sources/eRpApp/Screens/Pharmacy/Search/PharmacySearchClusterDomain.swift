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
import eRpKit
import Pharmacy
import SwiftUI

@Reducer
struct PharmacySearchClusterDomain {
    @ObservableState
    struct State: Equatable {
        var clusterPharmacies: [PharmacyLocationViewModel] = []
    }

    enum Action: Equatable {
        case closeSheet
        case delegate(Delegate)

        enum Delegate: Equatable {
            case showDetails(PharmacyLocationViewModel)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    func core(into _: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .closeSheet:
            return .run { _ in

                await dismiss()
            }
        case .delegate:
            return .none
        }
    }
}
