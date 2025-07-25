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
import Foundation

@Reducer
struct DeviceSecurityDomain {
    typealias Store = StoreOf<Self>

    @ObservableState
    struct State: Equatable {
        let warningType: DeviceSecurityWarningType
    }

    enum Action: Equatable {
        case acceptRootedDevice
        case acceptMissingPin(permanently: Bool)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.deviceSecurityManager) var deviceSecurityManager: DeviceSecurityManager

    var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    private func core(state _: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .acceptRootedDevice:
            deviceSecurityManager.set(ignoreRootedDeviceWarningForSession: true)
            return Effect.send(.delegate(.close))
        case let .acceptMissingPin(permanently):
            deviceSecurityManager.set(ignoreDeviceSystemPinWarningForSession: true)
            deviceSecurityManager
                .set(ignoreDeviceSystemPinWarningPermanently: permanently)
            return Effect.send(.delegate(.close))
        case .delegate(.close):
            // Handled by parent domain
            return .none
        }
    }
}

extension DeviceSecurityDomain {
    enum Dummies {
        static let state = State(warningType: .devicePinMissing)

        static let store = Store(
            initialState: state
        ) {
            DeviceSecurityDomain()
        }
    }
}
