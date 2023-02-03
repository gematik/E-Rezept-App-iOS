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

enum DeviceSecurityDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        let warningType: DeviceSecurityWarningType
    }

    enum Action: Equatable {
        case close
        case acceptRootedDevice
        case acceptMissingPin(permanently: Bool)
    }

    struct Environment {
        let deviceSecurityManager: DeviceSecurityManager
    }

    static let domainReducer = Reducer { _, action, environment in
        switch action {
        case .acceptRootedDevice:
            environment.deviceSecurityManager.set(ignoreRootedDeviceWarningForSession: true)
            return Effect(value: .close)
        case let .acceptMissingPin(permanently):
            environment.deviceSecurityManager.set(ignoreDeviceSystemPinWarningForSession: true)
            environment.deviceSecurityManager
                .set(ignoreDeviceSystemPinWarningPermanently: permanently)
            return Effect(value: .close)
        case .close: // Handled by parent domain
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension DeviceSecurityDomain {
    enum Dummies {
        static let state = State(warningType: .devicePinMissing)

        static let environment = Environment(
            deviceSecurityManager: DummyDeviceSecurityManager()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
