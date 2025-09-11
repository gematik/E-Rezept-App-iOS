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

/// Domain for handling user consent in EU redemption flow
@Reducer
public struct ConsentDomain {
    /// State for consent screen
    @ObservableState
    public struct State: Equatable {
        /// Consent status - true = accepted, false = declined, nil = not decided
        public var consentGiven: Bool?

        public init(consentGiven: Bool? = nil) {
            self.consentGiven = consentGiven
        }
    }

    /// Actions for consent screen
    public enum Action: Equatable {
        /// Accept consent
        case accept
        /// Decline consent
        case decline
        /// Cancel consent dialog
        case cancel
        /// Go back
        case back
        /// Delegate actions to parent
        case delegate(Delegate)
    }

    /// Delegate actions
    public enum Delegate: Equatable {
        /// Consent was accepted
        case consentAccepted
        /// Consent was declined
        case consentDeclined
        /// Consent was cancelled
        case consentCancelled
        /// Back button was tapped
        case backTapped
    }

    /// Initialize the domain
    public init() {}

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .accept:
                state.consentGiven = true
                return .send(.delegate(.consentAccepted))
            case .decline:
                state.consentGiven = false
                return .send(.delegate(.consentDeclined))
            case .cancel:
                return .send(.delegate(.consentCancelled))
            case .back:
                return .send(.delegate(.backTapped))
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Dummies

extension ConsentDomain {
    /// Mock data for testing and previews
    enum Dummies {
        /// Sample state for testing
        static let state = ConsentDomain.State()

        /// Sample store for testing
        static let store = Store(initialState: state) {
            ConsentDomain()
        }
    }
}
