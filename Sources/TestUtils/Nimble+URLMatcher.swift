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

import Foundation
import Nimble

/// Checks a URL for a set of matching GET parameters.
/// - Parameter parameters: Expected parameters for the match
/// - Returns: Predicate indicating the result
public func containsParameters(_ parameters: [String: String]) -> Predicate<URL> {
    Predicate { actualExpression throws -> PredicateResult in
        let msg = ExpectationMessage.expectedActualValueTo("equal <\(parameters)>")
        if let actualValue = try actualExpression.evaluate() {
            let comps = NSURLComponents(url: actualValue, resolvingAgainstBaseURL: true)
            if let queryItems = comps?.queryItems {
                for (paramKey, paramValue) in parameters {
                    if queryItems.filter({ item in item.name == paramKey && item.value == paramValue }).isEmpty {
                        return PredicateResult(
                            bool: false,
                            message: msg.appended(message: "Missing or unmatched parameter \(paramKey)")
                        )
                    }
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
