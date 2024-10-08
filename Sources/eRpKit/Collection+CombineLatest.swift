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

import Combine
import Foundation

extension Collection where Element: Publisher {
    /// Subscribes to multiple additional publisher and publishes a collection
    /// upon receiving output from either publisher.
    ///
    /// Use combineLatest() when you want the downstream subscriber to receive a collection
    /// of the most-recent element from multiple publishers when any of them emit a value.
    public func combineLatest() -> AnyPublisher<[Element.Output], Element.Failure> {
        reduce(
            Just<[Element.Output]>([]).setFailureType(to: Element.Failure.self).eraseToAnyPublisher()
        ) { acc, next in
            acc.combineLatest(next)
                .map { $0 + [$1] }
                .eraseToAnyPublisher()
        }
    }
}
