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

import CasePaths
import CodedError
import eRpKit
import eRpResources
import FeatureCardWall
import FeatureHelpers
import Foundation
import SwiftUI
import SwiftUINavigation

extension ConsentService {
    @CodedError("041")
    @CasePathable
    public enum Error: LocalizedError, Equatable, Swift.Error {
        @ErrorCode("01")
        case localStore(LocalStoreError)
        @ErrorCode("02")
        case loginHandler(LoginHandlerError)
        @ErrorCode("03")
        case erxRepository(ErxRepositoryError)
        @ErrorCode("04")
        case unexpectedGrantConsentResponse
        @ErrorCode("05")
        case unexpected
        @ErrorCode("06")
        case unexpectedRevokeConsentResponse

        // TOOD: assuming this translates to Alert Title
        public var errorDescription: String? {
            // https://github.com/gematik/api-erp/blob/master/docs/erp_consent.adoc
            if case let .erxRepository(.remote(.fhirClient(.http(fhirClientHttpError)))) = self,
               case let .httpError(urlError) = fhirClientHttpError.httpClientError {
                switch urlError.code.rawValue {
                case 400: return L10n.serviceTxtConsentErrorHttp400Description.text
                case 401: return L10n.serviceTxtConsentErrorHttp401Description.text
                case 403: return L10n.serviceTxtConsentErrorHttp403Description.text
                case 404: return L10n.serviceTxtConsentErrorHttp404Description.text
                case 405: return L10n.serviceTxtConsentErrorHttp405Description.text
                case 408: return L10n.serviceTxtConsentErrorHttp408Description.text
                // case 409 is treated as an successful result by the service
                case 429: return L10n.serviceTxtConsentErrorHttp429Description.text
                case 500: return L10n.serviceTxtConsentErrorHttp500Description.text
                default: return urlError.localizedDescription
                }
            }
            switch self {
            case let .localStore(localStoreError): return localStoreError.errorDescription
            case let .loginHandler(loginHandlerError): return loginHandlerError.errorDescription
            case let .erxRepository(erxRepositoryError): return erxRepositoryError.errorDescription
            case .unexpectedGrantConsentResponse,
                 .unexpectedRevokeConsentResponse,
                 .unexpected: return nil // rely on CodedError mechanisms for error presentation
            }
        }

        public var recoverySuggestion: String? {
            // https://github.com/gematik/api-erp/blob/master/docs/erp_consent.adoc
            if case let .erxRepository(.remote(.fhirClient(.http(fhirClientHttpError)))) = self,
               case let .httpError(urlError) = fhirClientHttpError.httpClientError {
                switch urlError.code.rawValue {
                case 400: return L10n.serviceTxtConsentErrorHttp400Recovery.text
                case 401: return L10n.serviceTxtConsentErrorHttp401Recovery.text
                case 403: return L10n.serviceTxtConsentErrorHttp403Recovery.text
                case 404: return L10n.serviceTxtConsentErrorHttp404Recovery.text
                case 405: return L10n.serviceTxtConsentErrorHttp405Recovery.text
                case 408: return L10n.serviceTxtConsentErrorHttp408Recovery.text
                // case 409 is treated as an successful result by the service
                case 429: return L10n.serviceTxtConsentErrorHttp429Recovery.text
                case 500: return L10n.serviceTxtConsentErrorHttp500Recovery.text
                default: return L10n.serviceTxtConsentErrorHttpDefaultRecovery.text
                }
            }
            switch self {
            case let .localStore(localStoreError): return localStoreError.recoverySuggestion
            case let .loginHandler(loginHandlerError): return loginHandlerError.recoverySuggestion
            case let .erxRepository(erxRepositoryError): return erxRepositoryError.recoverySuggestion
            case .unexpectedGrantConsentResponse,
                 .unexpectedRevokeConsentResponse,
                 .unexpected: return nil // rely on CodedError mechanisms for error presentation
            }
        }

        public var alertState: ConsentService.AlertState? {
            guard let title = errorDescription,
                  let message = recoverySuggestion,
                  let actionIntends = alertIntends
            else { return nil }
            return ConsentService.AlertState(title: title, message: message, actionIntends: actionIntends)
        }

        public var alertIntends: ConsentService.AlertState.ActionIntends? {
            if case let .erxRepository(.remote(.fhirClient(.http(fhirClientHttpError)))) = self,
               case let .httpError(urlError) = fhirClientHttpError.httpClientError {
                switch urlError.code.rawValue {
                case 400: return .okay
                case 401: return .okayAndLogin
                case 403: return .okay
                case 404: return .okay
                case 405: return .okay
                case 408: return .okayAndRetry
                // case 409 is treated as an successful result by the service
                case 429: return .okayAndRetry
                case 500: return .okayAndRetry
                default: return nil
                }
            }
            return nil
        }
    }
}

extension ConsentService {
    /// Represents an alert state for consent service operations
    public struct AlertState {
        let title: String
        let message: String
        let actionIntends: ActionIntends

        /// Defines the available action intents for alert states
        public enum ActionIntends {
            /// Simple okay action
            case okay
            /// Okay action with retry option
            case okayAndRetry
            /// Okay action with login option
            case okayAndLogin
        }

        /// Creates an ERP alert state with the specified actions
        public func erpAlertState<Action>(
            actionForOkay: Action,
            actionForRetry: Action,
            actionForLogin: Action
        ) -> ErpAlertState<Action> {
            let title: StringAsset = .init(title, bundle: .main)
            let message: StringAsset = .init(message, bundle: .main)

            let buttonStates: [ButtonState<Action>]
            let buttonStateOkay = ButtonState(role: .cancel, action: actionForOkay) {
                .init(L10n.serviceTxtConsentAlertOkay)
            }
            let buttonStateLogin = ButtonState(role: .none, action: actionForLogin) {
                .init(L10n.serviceTxtConsentAlertLogin)
            }
            let buttonStateRetry = ButtonState(role: .none, action: actionForRetry) {
                .init(L10n.serviceTxtConsentAlertRetry)
            }

            switch actionIntends {
            case .okay: buttonStates = [buttonStateOkay]
            case .okayAndLogin: buttonStates = [buttonStateOkay, buttonStateLogin]
            case .okayAndRetry: buttonStates = [buttonStateOkay, buttonStateRetry]
            }

            let actionsBuilder: () -> [ButtonState<Action>] = { buttonStates }
            return ErpAlertState<Action>(title: title, actions: actionsBuilder, message: message)
        }
    }

    /// Represents toast states for consent service operations
    public enum ToastState {
        /// Consent was successfully granted
        case successfullyGranted
        /// Conflict occurred - consent has already been granted for this user's ID (409)
        case conflict

        /// Localized message for the toast state
        public var message: LocalizedStringKey {
            switch self {
            case .successfullyGranted: return L10n.serviceTxtConsentToastSuccessfullyGrantedMessage.key
            case .conflict: return L10n.serviceTxtConsentToastConflictMessage.key
            }
        }

        /// Message for routing to charge items list
        public static let routeToChargeItemsListMessage: StringAsset = L10n.serviceTxtConsentToastRouteToListMessage
    }
}
