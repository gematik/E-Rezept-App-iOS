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

/// A dependency that detects phone numbers in a given string using `NSDataDetector`.
@DependencyClient
public struct DataDetector {
    /// Detects phone numbers in the provided string and returns an array of detected phone numbers.
    public var phoneNumbers: (String) throws -> [String] = { _ in [] }
}

extension DataDetector: DependencyKey {
    public static var liveValue: DataDetector {
        DataDetector { phoneNumbers in
            let detectionTypes: NSTextCheckingResult.CheckingType = [.phoneNumber]
            let detector = try NSDataDetector(types: detectionTypes.rawValue)
            var detectionResult = [String]()
            detector.enumerateMatches(
                in: phoneNumbers,
                options: [],
                range: NSMakeRange(0, phoneNumbers.count) // swiftlint:disable:this legacy_constructor
            ) { result, _, _ in
                guard let result else { return }
                if case .phoneNumber = result.resultType,
                   let number = result.phoneNumber {
                    detectionResult.append(number)
                }
            }
            return detectionResult
        }
    }

    public static var testValue = Self.liveValue
}

extension DependencyValues {
    /// A dependency that detects phone numbers in a given string using `NSDataDetector`.
    public var dataDetector: DataDetector {
        get { self[DataDetector.self] }
        set { self[DataDetector.self] = newValue }
    }
}
