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
import Foundation
import IDP

/// A client that provides profile-based sessions and related services
@DependencyClient
public struct ProfileBasedSessionProvider {
    /// Returns the IDP session for the given profile ID
    public var idpSession: (_ profileId: UUID) throws -> IDPSession
    /// Returns the IDP session for biometric authentication for the given profile ID
    public var biometrieIdpSession: (_ profileId: UUID) throws -> IDPSession
    /// Returns the secure user data store for the given profile ID
    public var userDataStore: (_ profileId: UUID) throws -> SecureUserDataStore
    /// Returns a publisher that provides the ID token validator for the given profile ID
    public var idTokenValidator: (_ profileId: UUID) throws -> AnyPublisher<IDTokenValidator, IDTokenValidatorError>
    /// Returns the secure enclave signature provider for the given profile ID
    public var signatureProvider: (_ profileId: UUID) throws -> SecureEnclaveSignatureProvider
}

extension ProfileBasedSessionProvider: TestDependencyKey {
    public static var previewValue: ProfileBasedSessionProvider = .init()

    public static var testValue: ProfileBasedSessionProvider = .init()
}

extension DependencyValues {
    /// Accessor for the ProfileBasedSessionProvider dependency
    public var profileBasedSessionProvider: ProfileBasedSessionProvider {
        get { self[ProfileBasedSessionProvider.self] }
        set { self[ProfileBasedSessionProvider.self] = newValue }
    }
}
