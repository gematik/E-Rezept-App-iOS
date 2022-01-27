//
//  Copyright (c) 2022 gematik GmbH
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

import Combine
@testable import eRpApp
import LocalAuthentication

// MARK: - MockSecurityPolicyEvaluator -

final class MockSecurityPolicyEvaluator: NSObject, SecurityPolicyEvaluator {
    // MARK: - canEvaluatePolicy

    var canEvaluatePolicyErrorCallsCount = 0
    var canEvaluatePolicyErrorCalled: Bool {
        canEvaluatePolicyErrorCallsCount > 0
    }

    var canEvaluatePolicyErrorReceivedArguments: (policy: LAPolicy, error: NSErrorPointer)?
    var canEvaluatePolicyErrorReceivedInvocations: [(policy: LAPolicy, error: NSErrorPointer)] = []
    var canEvaluatePolicyErrorReturnValue: Bool!
    var canEvaluatePolicyErrorClosure: ((LAPolicy, NSErrorPointer) -> Bool)?

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        canEvaluatePolicyErrorCallsCount += 1
        canEvaluatePolicyErrorReceivedArguments = (policy: policy, error: error)
        canEvaluatePolicyErrorReceivedInvocations.append((policy: policy, error: error))
        return canEvaluatePolicyErrorClosure.map { $0(policy, error) } ?? canEvaluatePolicyErrorReturnValue
    }
}
