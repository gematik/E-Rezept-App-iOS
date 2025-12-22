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
import LocalAuthentication

/// SecurityPolicyEvaluator provides access to LAContext functionality
@DependencyClient
public struct SecurityPolicyEvaluator {
    /// Determines if a particular policy can be evaluated. @see LAContext.canEvaluatePolicy
    public var canEvaluatePolicy: (_ policy: LAPolicy, _ error: NSErrorPointer) -> Bool = { _, _ in true }
}

/// SecurityPolicyEvaluator gives access to LAContext functionality
extension SecurityPolicyEvaluator: DependencyKey {
    /// LAContext implementation of SecurityPolicyEvaluator
    public static let liveValue = SecurityPolicyEvaluator { policy, error in
        LAContext().canEvaluatePolicy(policy, error: error)
    }

    /// Unimplemented version of SecurityPolicyEvaluator for tests
    public static let testValue = SecurityPolicyEvaluator()
}

extension DependencyValues {
    /// Access to the security policy evaluator (e.g. LAContext)
    public var securityPolicyEvaluator: SecurityPolicyEvaluator {
        get { self[SecurityPolicyEvaluator.self] }
        set { self[SecurityPolicyEvaluator.self] = newValue }
    }
}
