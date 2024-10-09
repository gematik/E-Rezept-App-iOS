//
//  Copyright (c) 2024 gematik GmbH
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

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct DataDetector {
    var phoneNumbers: (String) throws -> [String] = { _ in [] }
}

extension DataDetector: DependencyKey {
    static var liveValue: DataDetector {
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
}

extension DataDetector: TestDependencyKey {
    static let testValue = Self.liveValue
}

extension DependencyValues {
    var dataDetector: DataDetector {
        get { self[DataDetector.self] }
        set { self[DataDetector.self] = newValue }
    }
}
