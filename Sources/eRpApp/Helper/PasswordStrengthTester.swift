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
import Zxcvbn

// tag::PasswordStrengthTester[]
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

    var passesMinimumThreshold: Bool {
        rawValue >= PasswordStrength.medium.rawValue
    }
}

struct DefaultPasswordStrengthTester: PasswordStrengthTester {
    func passwordStrength(for password: String) -> PasswordStrength {
        password.passwordStrength()
    }
}

private class LazyZxcvbnDB {
    private(set) lazy var zxcvbn = DBZxcvbn()

    // [REQ:BSI-eRp-ePA:O.Pass_1#2,O.Pass_2#2] We use an additional german word list to check against common passwords
    private(set) lazy var wordList: [String] = {
        guard let url = Bundle.module.url(forResource: "german_dictionary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode(List.self, from: data) else {
            return []
        }
        return list.words
    }()

    struct List: Codable {
        let words: [String]
    }
}

private var lazyZxcvbnDB = LazyZxcvbnDB()

extension String {
    func passwordStrength() -> PasswordStrength {
        switch lazyZxcvbnDB.zxcvbn.passwordStrength(self, userInputs: lazyZxcvbnDB.wordList)?.score {
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

// end::PasswordStrengthTester[]

// MARK: TCA Dependency

extension DefaultPasswordStrengthTester {
    static let live: Self = DefaultPasswordStrengthTester()
}

struct PasswordStrengthTesterDependencyKey: DependencyKey {
    static let liveValue: PasswordStrengthTester = DefaultPasswordStrengthTester.live
    static let previewValue: PasswordStrengthTester = DefaultPasswordStrengthTester.live
    static let testValue: PasswordStrengthTester = UnimplementedPasswordStrengthTester()
}

extension DependencyValues {
    var passwordStrengthTester: PasswordStrengthTester {
        get { self[PasswordStrengthTesterDependencyKey.self] }
        set { self[PasswordStrengthTesterDependencyKey.self] = newValue }
    }
}
