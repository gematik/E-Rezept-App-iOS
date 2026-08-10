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

import Dependencies
import DependenciesMacros
import Foundation
import HTTPClient

@DependencyClient
public struct FHIRClientServiceFactory: Sendable {
    public var client: @Sendable () async throws -> FHIRClient
    /// Returns a FHIRClient configured for the given profile, independent of the currently selected profile.
    public var erpClientForProfile: @Sendable (_ profileId: UUID) -> FHIRClient = { _ in
        { fatalError("Unimplemented") }()
    }
}

extension FHIRClientServiceFactory: TestDependencyKey {
    public static let testValue: FHIRClientServiceFactory = Self()
}

extension DependencyValues {
    /// Access to fhirClientServiceFactory
    public var fhirClientServiceFactory: FHIRClientServiceFactory {
        get { self[FHIRClientServiceFactory.self] }
        set { self[FHIRClientServiceFactory.self] = newValue }
    }
}
