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
import Foundation

enum LoadingState<Value, Failure: Error>: Equatable where Failure: Equatable, Value: Equatable {
    case idle
    case loading(Value? = nil)
    case value(Value)
    case error(Failure)

    var isIdle: Bool {
        if case .idle = self {
            return true
        }
        return false
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var value: Value? {
        switch self {
        case let .value(value):
            return value
        case let .loading(value):
            return value
        default:
            return nil
        }
    }

    var error: Failure? {
        if case let .error(error) = self {
            return error
        }
        return nil
    }

    var isValue: Bool {
        if case .value = self {
            return true
        }
        return false
    }

    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }

    static func ==(lhs: LoadingState<Value, Failure>, rhs: LoadingState<Value, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (idle, idle): return true
        case let (loading(lhsValue), loading(rhsValue)): return lhsValue == rhsValue
        case let (value(lhsValue), value(rhsValue)): return lhsValue == rhsValue
        case let (error(lhsError), error(rhsError)): return lhsError == rhsError
        default:
            return false
        }
    }
}

extension Publisher where Output: Equatable, Failure: Equatable {
    func catchToLoadingStateEffect() -> AnyPublisher<LoadingState<Output, Failure>, Never> {
        map(LoadingState.value)
            .catch { Just(LoadingState.error($0)) }
            .eraseToAnyPublisher()
    }
}
