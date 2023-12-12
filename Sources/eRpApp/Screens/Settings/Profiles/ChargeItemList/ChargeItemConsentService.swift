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

import CasePaths
import Combine
import Dependencies
import eRpKit
import Foundation

struct ChargeItemConsentService {
    var checkForConsent: @Sendable (_ profileID: UUID) async throws -> CheckResult
    var grantConsent: @Sendable (_ profileID: UUID) async throws -> GrantResult
    var revokeConsent: @Sendable (_ profileID: UUID) async throws -> RevokeResult

    enum CheckResult: Equatable {
        case granted
        case notGranted
        case notAuthenticated
    }

    enum GrantResult: Equatable {
        case success
        case notAuthenticated
    }

    enum RevokeResult: Equatable {
        case success
        case notAuthenticated
    }

    // sourcery: CodedError = "036"
    enum Error: Equatable, Swift.Error {
        // sourcery: errorCode = "01"
        case localStore(LocalStoreError)
        // sourcery: errorCode = "02"
        case loginHandler(LoginHandlerError)
        // sourcery: errorCode = "03"
        case erxRepository(ErxRepositoryError)
        // sourcery: errorCode = "04"
        case unexpectedGrantConsentResponse
        // sourcery: errorCode = "05"
        case unexpected
    }
}

extension ChargeItemConsentService {
    // swiftlint:disable:next function_body_length
    init(userSessionProvider: UserSessionProvider) {
        self.init(
            checkForConsent: { profileId in
                let userSession = userSessionProvider.userSession(for: profileId)
                let loginHandler = userSession.idpSessionLoginHandler
                let erxTaskRepository = userSession.erxTaskRepository

                let isAuthenticatedResult = try await loginHandler.isAuthenticated().async()

                switch isAuthenticatedResult {
                case .success(true):
                    let profile = try await userSession.profile().async(/ChargeItemConsentService.Error.localStore)
                    guard let insuranceId = profile.insuranceId
                    else {
                        // At this point, we expect the profile to be associated with an insuranceId
                        throw Error.unexpected
                    }
                    let receivedErxConsents = try await erxTaskRepository.fetchConsents()
                        .async(/ChargeItemConsentService.Error.erxRepository)
                    let isValidChargeItemsConsentResult = Self.checkForValidChargeItemsConsent(
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
            },

            grantConsent: { profileId in
                let userSession = userSessionProvider.userSession(for: profileId)
                let loginHandler = userSession.idpSessionLoginHandler
                let erxTaskRepository = userSession.erxTaskRepository

                let isAuthenticatedResult = try await loginHandler.isAuthenticated().async()

                switch isAuthenticatedResult {
                case .success(true):
                    let profile = try await userSession.profile().async(/ChargeItemConsentService.Error.localStore)
                    guard let insuranceId = profile.insuranceId
                    else {
                        // At this point, we expect the profile to be associated with an insuranceId
                        throw Error.unexpected
                    }
                    let chargeItemsConsent = Self.createChargeItemsConsent(insuranceId: insuranceId)
                    let receivedConsent = try await erxTaskRepository.grantConsent(chargeItemsConsent)
                        .async(/ChargeItemConsentService.Error.erxRepository)
                    let receivedConsentCheck = Self.checkForValidChargeItemsConsent(receivedConsent, for: insuranceId)
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
            },

            revokeConsent: unimplemented(".revokeConsent not implemented")
        )
    }

    private static func checkForValidChargeItemsConsent(_ erxConsents: [ErxConsent], for insuranceId: String) -> Bool {
        erxConsents.contains { erxConsent in
            checkForValidChargeItemsConsent(erxConsent, for: insuranceId)
        }
    }

    private static func checkForValidChargeItemsConsent(_ erxConsent: ErxConsent?, for insuranceId: String) -> Bool {
        guard let erxConsent else { return false }
        return erxConsent.category == .chargcons && erxConsent.insuranceId == insuranceId
    }

    private static func createChargeItemsConsent(insuranceId: String) -> ErxConsent {
        ErxConsent(
            identifier: "\(ErxConsent.Category.chargcons.rawValue)-\(insuranceId)",
            insuranceId: insuranceId,
            timestamp: FHIRDateFormatter.shared.string(from: Date(), format: .yearMonthDay),
            scope: .patientPrivacy,
            category: .chargcons,
            policyRule: .optIn
        )
    }
}

// MARK: TCA Dependency

extension ChargeItemConsentService: DependencyKey {
    static var liveValue: ChargeItemConsentService = .init(userSessionProvider: UserSessionProviderDependency.liveValue)

    static var previewValue: ChargeItemConsentService {
        .init(
            checkForConsent: { _ in .granted },
            grantConsent: { _ in .success },
            revokeConsent: { _ in .success }
        )
    }

    static var testValue: ChargeItemConsentService {
        .init(
            checkForConsent: unimplemented(".checkForConsent not implemented"),
            grantConsent: unimplemented(".grantConsent not implemented"),
            revokeConsent: unimplemented(".revokeConsent not implemented")
        )
    }
}

extension DependencyValues {
    var chargeItemConsentService: ChargeItemConsentService {
        get { self[ChargeItemConsentService.self] }
        set { self[ChargeItemConsentService.self] = newValue }
    }
}
