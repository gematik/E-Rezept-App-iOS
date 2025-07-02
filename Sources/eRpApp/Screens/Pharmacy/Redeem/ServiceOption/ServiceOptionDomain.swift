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

@Reducer
struct ServiceOptionDomain {
    @ObservableState
    struct State: Equatable {
        @Shared var prescriptions: [Prescription]
        var selectedOption: RedeemOption?
        var availableOptions: Set<RedeemOption>
        var redeemOptionProvider: RedeemOptionProvider?

        init(
            prescriptions: Shared<[Prescription]>,
            selectedOption: RedeemOption? = nil,
            availableOptions: Set<RedeemOption> = [],
            redeemOptionProvider: RedeemOptionProvider? = nil
        ) {
            _prescriptions = prescriptions
            self.selectedOption = selectedOption
            self.availableOptions = availableOptions
            self.redeemOptionProvider = redeemOptionProvider
        }
    }

    enum Action: Equatable {
        case redeemOptionTapped(RedeemOption)
    }

    var body: some ReducerOf<Self> {
        Reduce(self.core)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .redeemOptionTapped(option):
            state.selectedOption = option
            return .none
        }
    }
}
