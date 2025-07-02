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
