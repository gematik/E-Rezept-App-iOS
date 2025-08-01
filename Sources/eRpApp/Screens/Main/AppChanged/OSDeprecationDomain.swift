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
import Foundation

/// A reusable domain for displaying iOS version deprecation notices.
///
/// Usage example:
/// ```swift
/// // For iOS 16 deprecation
/// let state = OSDeprecationDomain.forIOSVersion("16")
/// let store = Store(initialState: state) { OSDeprecationDomain() }
///
/// // For iOS 17 deprecation (future use)
/// let state = OSDeprecationDomain.forIOSVersion("17")
/// let store = Store(initialState: state) { OSDeprecationDomain() }
/// ```
///
/// The screen displays localized content using the version parameter:
/// - Title: "Kein Support für iOS {version} mehr"
/// - Subtitle: "Ab sofort erhält diese App auf iOS {version} keine Updates mehr."
@Reducer
struct OSDeprecationDomain {
    @ObservableState
    struct State: Equatable {
        let version: String
    }

    enum Action: Equatable {
        case continueButtonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case continueWithAppButtonTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .continueButtonTapped:
                return .send(.delegate(.continueWithAppButtonTapped))
            case .delegate:
                return .none
            }
        }
    }
}

extension OSDeprecationDomain {
    enum Dummies {
        static let state = State(version: "16")
        static let iOS16State = State(version: "16")
        static let iOS17State = State(version: "17")

        static let store = Store(initialState: state) {
            OSDeprecationDomain()
        }

        static let iOS16Store = Store(initialState: iOS16State) {
            OSDeprecationDomain()
        }

        static let iOS17Store = Store(initialState: iOS17State) {
            OSDeprecationDomain()
        }
    }

    // MARK: - Convenience Initializers

    static func forIOSVersion(_ version: String) -> State {
        State(version: version)
    }
}
