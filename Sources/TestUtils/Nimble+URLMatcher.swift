//
//  Copyright (c) 2023 gematik GmbH
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

import CustomDump
import Foundation
import Nimble

/// Checks a URL for a set of matching GET parameters.
/// - Parameter parameters: Expected parameters for the match
/// - Returns: Predicate indicating the result
public func containsParameters(_ parameters: [String: String]) -> Nimble.Predicate<URL> {
    Predicate { actualExpression throws -> PredicateResult in
        let msg = ExpectationMessage.expectedActualValueTo("equal <\(parameters)>")
        if let actualValue = try actualExpression.evaluate() {
            let comps = NSURLComponents(url: actualValue, resolvingAgainstBaseURL: true)
            if let queryItems = comps?.queryItems {
                for (paramKey, paramValue) in parameters
                    where queryItems.filter({ item in item.name == paramKey && item.value == paramValue }).isEmpty {
                    return PredicateResult(
                        bool: false,
                        message: msg.appended(message: "Missing or unmatched parameter \(paramKey)")
                    )
                }
                return PredicateResult(
                    bool: true,
                    message: msg
                )
            }
        }
        return PredicateResult(
            status: .fail,
            message: msg.appendedBeNilHint()
        )
    }
}

/// Helper function to assert by diffing data structures
public func nodiff<T: Equatable>(_ expectedValue: T?) -> Nimble.Predicate<T> {
    nodiff(expectedValue, by: ==)
}

/// Helper function to assert by diffing data structures
public func nodiff<T>(
    _ expectedValue: T?,
    by areEquivalent: @escaping (T, T) -> Bool
) -> Nimble.Predicate<T> {
    Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case let (expected?, actual?):
            let matches = areEquivalent(expected, actual)
            var msg = msg
            if !matches,
               let difference = diff(actualValue, expectedValue, format: DiffFormat.proportional) {
                msg = .fail(difference)
            }
            return PredicateResult(bool: matches, message: msg)
        }
    }
}
