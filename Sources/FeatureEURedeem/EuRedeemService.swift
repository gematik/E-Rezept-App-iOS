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
import Dependencies
import DependenciesMacros
import eRpKit
import SwiftUI

/// Handler for generating eu accessCodes
@DependencyClient
public struct EuRedeemService {
    /// Grant accessCode for eu redeem
    public var grantEuAccessCode: @Sendable (_ countryCode: String, _ profileId: UUID) async throws -> EuAccessCode?
    /// Marks the `ErxTask` by its id as EU redeemable by a patient
    public var markTaskEURedeemable: @Sendable (_ taskId: ErxTask.ID,
                                                _ byPatientAuthorization: Bool,
                                                _ profileId: UUID) async throws -> Void
    /// Delete the active accessCode from server and local communication
    public var deleteEuAccessCode: @Sendable (_ profileId: UUID) async throws -> Void
}

// MARK: - TCA Dependency

extension EuRedeemService: TestDependencyKey {
    public static let testValue = Self()
}

extension DependencyValues {
    /// Access point for the EuRedeemService dependency
    public var euRedeemService: EuRedeemService {
        get { self[EuRedeemService.self] }
        set { self[EuRedeemService.self] = newValue }
    }
}
