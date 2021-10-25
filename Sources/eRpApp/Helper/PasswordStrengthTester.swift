//
//  Copyright (c) 2021 gematik GmbH
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

import Zxcvbn

protocol PasswordStrengthTester {
    func passwordStrength(for password: String) -> PasswordStrength
}

enum PasswordStrength: Int {
    case none
    case veryWeak
    case weak
    case medium
    case strong
    case veryStrong
    case excellent

    var minimumThreshold: Bool {
        rawValue >= PasswordStrength.medium.rawValue
    }
}

struct DefaultPasswordStrengthTester: PasswordStrengthTester {
    func passwordStrength(for password: String) -> PasswordStrength {
        password.passwordStrength()
    }
}

extension String {
    func passwordStrength() -> PasswordStrength {
        let zxcvbn = DBZxcvbn()
        switch zxcvbn.passwordStrength(self)?.score {
        case 0:
            return .veryWeak
        case 1:
            return .weak
        case 2:
            return .medium
        case 3:
            return .strong
        case 4:
            return .veryStrong
        case .some(5...):
            return .excellent
        default:
            return .none
        }
    }
}

// MARK: - MockPasswordStrengthTester -

final class MockPasswordStrengthTester: PasswordStrengthTester {
    // MARK: - passwordStrength

    var passwordStrengthForCallsCount = 0
    var passwordStrengthForCalled: Bool {
        passwordStrengthForCallsCount > 0
    }

    var passwordStrengthForReceivedPassword: String?
    var passwordStrengthForReceivedInvocations: [String] = []
    var passwordStrengthForReturnValue: PasswordStrength!
    var passwordStrengthForClosure: ((String) -> PasswordStrength)?

    func passwordStrength(for password: String) -> PasswordStrength {
        passwordStrengthForCallsCount += 1
        passwordStrengthForReceivedPassword = password
        passwordStrengthForReceivedInvocations.append(password)
        return passwordStrengthForClosure.map { $0(password) } ?? passwordStrengthForReturnValue
    }
}
