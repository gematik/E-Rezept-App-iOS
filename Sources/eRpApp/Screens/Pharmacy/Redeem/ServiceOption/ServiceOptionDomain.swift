//
//  Copyright (c) 2025 gematik GmbH
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
