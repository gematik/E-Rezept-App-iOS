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

import Combine
import ComposableArchitecture
import eRpKit
import Foundation

struct ChargeItemDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        let chargeItem: ErxChargeItem
    }

    enum Action: Equatable {
        case nothing
    }

    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
    }

    func core(into _: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .nothing:
            return .none
        }
    }
}

extension ErxChargeItem {
    var totalGrossPrice: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "EUR"
        currencyFormatter.locale = Locale(identifier: "DE")

        guard let totalGross = invoice?.totalGross.doubleValue,
              let price = currencyFormatter.string(for: totalGross) else {
            return "-"
        }
        return price
    }
}
