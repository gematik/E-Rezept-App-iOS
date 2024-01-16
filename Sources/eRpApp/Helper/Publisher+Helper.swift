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

extension Publisher {
    /// Transforms the values/failure emitted by `self` to an `Result`.
    func catchToPublisher() -> AnyPublisher<Result<Self.Output, Self.Failure>, Never> {
        map(Result.success)
            .catch { Just(Result.failure($0)) }
            .eraseToAnyPublisher()
    }

    func onSubscribe(_ onSubscription: @escaping (Subscription) -> Void) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveSubscription: onSubscription).eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
