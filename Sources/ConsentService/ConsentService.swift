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
import Dependencies
import DependenciesMacros
import eRpKit
import Foundation

/// Service for handling user consent
@DependencyClient
public struct ConsentService {
    /// Check if user consent has been granted for a profile
    public var checkForConsent: @Sendable (_ category: ErxConsent.Category, _ profileID: UUID) async throws
        -> CheckResult
    /// Grant user consent for a profile
    public var grantConsent: @Sendable (_ category: ErxConsent.Category, _ profileID: UUID) async throws -> GrantResult
    /// Revoke user consent for a profile
    public var revokeConsent: @Sendable (_ category: ErxConsent.Category, _ profileID: UUID) async throws
        -> RevokeResult
}

extension ConsentService {
    /// Result of checking for consent
    public enum CheckResult: Equatable {
        // successful
        case granted // 200
        case notGranted // 200

        // login handler
        case notAuthenticated

        case error(ConsentService.Error)
    }

    /// Result of granting consent
    public enum GrantResult: Equatable {
        // successful
        case success // 201
        case conflict // 409 the user's consent has already been given

        // login handler
        case notAuthenticated

        case error(ConsentService.Error)
    }

    /// Result of revoking consent
    public enum RevokeResult: Equatable {
        case success
        case conflict
        case notAuthenticated
        case error(ConsentService.Error)
    }
}

extension ConsentService: TestDependencyKey {
    public static var previewValue: ConsentService {
        .init(
            checkForConsent: { _, _ in .granted },
            grantConsent: { _, _ in .success },
            revokeConsent: { _, _ in .success }
        )
    }

    public static var testValue = ConsentService()
}

extension DependencyValues {
    /// Access to the charge item consent service dependency
    public var consentService: ConsentService {
        get { self[ConsentService.self] }
        set { self[ConsentService.self] = newValue }
    }
}
