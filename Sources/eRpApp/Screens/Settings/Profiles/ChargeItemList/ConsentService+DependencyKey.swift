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

import AsyncHelpers
import CasePaths
import ConsentService
import Dependencies
import DependenciesMacros
import eRpKit
import ErxTaskRepository
import Foundation
import Sharing

extension ConsentService: DependencyKey {
    public static var liveValue: ConsentService = .init { category, profileId in
        @Shared(.isDemoMode) var demoMode
        if demoMode {
            return .granted
        } else {
            return try await Self.defaultValue.checkForConsent(category: category, profileID: profileId)
        }
    } grantConsent: { category, profileId in
        @Shared(.isDemoMode) var demoMode
        if demoMode {
            return .success
        } else {
            return try await Self.defaultValue.grantConsent(category: category, profileID: profileId)
        }
    } revokeConsent: { category, profileId in
        @Shared(.isDemoMode) var demoMode
        if demoMode {
            return .success
        } else {
            return try await Self.defaultValue.revokeConsent(category: category, profileID: profileId)
        }
    }

    public static var defaultValue: ConsentService = {
        @Dependency(\.userSessionProvider) var userSessionProvider
        @Dependency(\.erxTaskRepository) var erxTaskRepository

        return ConsentService { category, profileId in
            let userSession = userSessionProvider.userSession(for: profileId)
            let loginHandler = userSession.idpSessionLoginHandler

            let isAuthenticatedResult = try await loginHandler.isAuthenticated().async()

            switch isAuthenticatedResult {
            case .success(true):
                let profile = try await userSession.profile()
                    .async(\ConsentService.Error.Cases.localStore)
                guard let insuranceId = profile.insuranceId
                else {
                    // At this point, we expect the profile to be associated with an insuranceId
                    throw Error.unexpected
                }
                let receivedErxConsents = try await erxTaskRepository.fetchConsents(profileId)
                let isValidChargeItemsConsentResult = Self.checkForValidChargeItemsConsent(
                    expecting: category,
                    receivedErxConsents,
                    for: insuranceId
                )
                if isValidChargeItemsConsentResult {
                    return .granted
                } else {
                    return .notGranted
                }

            case .success(false):
                return .notAuthenticated

            case let .failure(error):
                throw Error.loginHandler(error)
            }
        } grantConsent: { category, profileId in
            let userSession = userSessionProvider.userSession(for: profileId)
            let loginHandler = userSession.idpSessionLoginHandler

            let isAuthenticatedResult = try await loginHandler.isAuthenticated().async()

            switch isAuthenticatedResult {
            case .success(true):
                let profile = try await userSession.profile()
                    .async(\ConsentService.Error.Cases.localStore)
                guard let insuranceId = profile.insuranceId
                else {
                    // At this point, we expect the profile to be associated with an insuranceId
                    throw Error.unexpected
                }
                let chargeItemsConsent = Self.createChargeItemsConsent(category: category, insuranceId: insuranceId)
                let receivedConsent: ErxConsent?
                do {
                    receivedConsent = try await erxTaskRepository.grantConsent(chargeItemsConsent, profileId)
                } catch let error as ErxRepositoryError {
                    // we handle the URL return code 409 (conflict) especially as it's not a serious outcome
                    if case let .remote(.fhirClient(.http(fhirClientHttpError))) = error,
                       case let .httpError(urlError) = fhirClientHttpError.httpClientError,
                       urlError.code.rawValue == 409 {
                        return .conflict
                    }
                    throw ConsentService.Error.erxRepository(error)
                }
                let receivedConsentCheck = Self.checkForValidChargeItemsConsent(
                    expecting: category, receivedConsent, for: insuranceId
                )
                if receivedConsentCheck {
                    return .success
                } else {
                    throw Error.unexpectedGrantConsentResponse
                }

            case .success(false):
                return .notAuthenticated

            case let .failure(error):
                throw Error.loginHandler(error)
            }
        } revokeConsent: { category, profileId in
            let userSession = userSessionProvider.userSession(for: profileId)
            let loginHandler = userSession.idpSessionLoginHandler

            let isAuthenticatedResult = try await loginHandler.isAuthenticated().async()

            switch isAuthenticatedResult {
            case .success(true):
                do {
                    try await erxTaskRepository.revokeConsent(category, profileId)
                    return .success
                } catch let error as ErxRepositoryError {
                    // we handle the URL return code 409 (conflict) especially as it's not a serious outcome
                    if case let .remote(.fhirClient(.http(fhirClientHttpError))) = error,
                       case let .httpError(urlError) = fhirClientHttpError.httpClientError,
                       urlError.code.rawValue == 409 {
                        return .conflict
                    }
                    throw ConsentService.Error.erxRepository(error)
                }
            case .success(false):
                return .notAuthenticated
            case let .failure(error):
                throw Error.loginHandler(error)
            }
        }
    }()

    private static func checkForValidChargeItemsConsent(
        expecting category: ErxConsent.Category,
        _ erxConsents: [ErxConsent],
        for insuranceId: String
    ) -> Bool {
        erxConsents.contains { erxConsent in
            checkForValidChargeItemsConsent(expecting: category, erxConsent, for: insuranceId)
        }
    }

    private static func checkForValidChargeItemsConsent(
        expecting category: ErxConsent.Category,
        _ erxConsent: ErxConsent?,
        for insuranceId: String
    ) -> Bool {
        guard let erxConsent else { return false }
        return erxConsent.category == category && erxConsent.insuranceId == insuranceId
    }

    private static func createChargeItemsConsent(category: ErxConsent.Category, insuranceId: String) -> ErxConsent {
        ErxConsent(
            identifier: "\(category.rawValue)-\(insuranceId)",
            insuranceId: insuranceId,
            timestamp: FHIRDateFormatter.shared.string(from: Date(), format: .yearMonthDay),
            scope: .patientPrivacy,
            category: category,
            policyRule: .optIn
        )
    }
}
