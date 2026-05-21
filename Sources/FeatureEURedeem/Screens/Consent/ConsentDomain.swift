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
import ConsentService
import eRpStyleKit
import FeatureHelpers
import Foundation

/// Domain for handling user consent in EU redemption flow
@Reducer
public struct ConsentDomain {
    /// Affects the available actions the user can perform
    public enum ConsentType {
        /// Consent was granted
        case granted
        /// Consent was reclaimed
        case notGranted
        /// Consent is unknown
        case unknown
    }

    /// State for consent screen
    @ObservableState
    public struct State: Equatable {
        /// Selected user profile ID
        public var profileID: UUID
        /// Consent type
        public var consentType: ConsentType
        /// Navigation destinations
        @Presents public var destination: Destination.State?

        public init(
            profileID: UUID,
            consentType: ConsentType = .unknown
        ) {
            self.profileID = profileID
            self.consentType = consentType
        }
    }

    /// Actions for consent screen
    public enum Action: Equatable {
        /// Accept consent
        case accept
        /// Decline consent
        case decline
        /// Response actions
        case response(Response)
        /// Delegate actions to parent
        case delegate(Delegate)
        /// Destination actions to parent
        case destination(PresentationAction<Destination.Action>)
    }

    /// Response actions
    public enum Response: Equatable {
        case grantConsentReceived(ConsentService.GrantResult)
        case revokedConsentReceived(ConsentService.RevokeResult)
    }

    /// Delegate actions
    public enum Delegate: Equatable {
        /// Consent was accepted
        case consentAccepted
        /// Consent was declined
        case consentDeclined
        /// Show CardWall when unauthenticated
        case showCardWall
        /// Close Redeem Flow without consent
        case close
    }

    /// Destination actions
    @Reducer
    public enum Destination: Equatable {
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

        public enum Alert: Equatable {
            case dismiss
        }
    }

    /// Initialize the domain
    public init() {}

    @Dependency(\.consentService) var consentService: ConsentService

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .accept:
                return .run { [profileID = state.profileID] send in
                    let result = try await consentService.grantConsent(category: .euDispense, profileID: profileID)
                    await send(.response(.grantConsentReceived(result)))
                }
            case let .response(.grantConsentReceived(result)):
                switch result {
                case .success, .conflict:
                    return .send(.delegate(.consentAccepted))
                case .notAuthenticated:
                    return .send(.delegate(.showCardWall))
                case let .error(error):
                    state.destination = .alert(.init(for: error, title: L10n.errTitleGeneric))
                    return .none
                }
            case .decline:
                return .run { [profileID = state.profileID] send in
                    do {
                        let result = try await consentService.revokeConsent(category: .euDispense, profileID: profileID)
                        await send(.response(.revokedConsentReceived(result)))
                    } catch let error as ConsentService.Error {
                        await send(.response(.revokedConsentReceived(.error(error))))
                    }
                }
            case let .response(.revokedConsentReceived(result)):
                switch result {
                case .success, .conflict:
                    return .send(.delegate(.consentDeclined))
                case .notAuthenticated:
                    return .send(.delegate(.showCardWall))
                case let .error(error):
                    guard error.fhirClientOperationOutcomeMissingConsent else {
                        return .send(.delegate(.consentDeclined))
                    }
                    state.destination = .alert(.init(for: error, title: L10n.errTitleGeneric))
                    return .none
                }
            case .delegate,
                 .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConsentService.Error {
    var fhirClientOperationOutcomeMissingConsent: Bool {
        guard case let .erxRepository(.remote(.fhirClient(.http(fhirClientError)))) = self,
              let operationOutcome = fhirClientError.operationOutcome else {
            return true
        }
        let missingConsentForKVNRMessage = "Could not find any consent for given KVNR "
        return operationOutcome.issue.first?.details?.text?.value?.string != missingConsentForKVNRMessage
    }
}

// MARK: - Dummies

extension ConsentDomain {
    /// Mock data for testing and previews
    enum Dummies {
        /// Sample state for testing
        static let state = ConsentDomain.State(profileID: UUID())

        /// Sample store for testing
        static let store = Store(initialState: state) {
            ConsentDomain()
        }
    }
}

extension ConsentDomain.Destination.State: Equatable {}
extension ConsentDomain.Destination.Action: Equatable {}
