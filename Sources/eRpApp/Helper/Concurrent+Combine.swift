// swiftlint:disable:this file_name
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

import CasePaths
import Combine
import Dependencies
import Foundation

enum AsyncError: Error {
    case finishedWithoutValue
}

extension Publisher where Self.Failure == Never {
    /// Bridges from AnyPublisher to structured concurrent code.
    /// Use for awaiting exactly one value (as with `Publisher.first()`)
    func async() async throws -> Output {
        try await _async()
    }
}

extension Publisher {
    /// Bridges from AnyPublisher to structured concurrent code.
    /// Use for awaiting exactly one value (as with `Publisher.first()`)
    ///
    /// - Parameter: use `transformError` to try to embed the thrown error into another one
    func async<E2: Swift.Error>(_ transformError: CasePath<E2, Self.Failure>) async throws -> Output {
        do {
            return try await _async()
        } catch let error as Self.Failure {
            throw transformError.embed(error)
        } catch {
            throw error
        }
    }

    /// Bridges from AnyPublisher to structured concurrent code.
    /// Use for awaiting exactly one value (as with `Publisher.first()`)
    ///
    /// - Parameter: use `transformError` to try to embed the thrown error into another one
    /// - Returns: Result type of output and transformed error or throws if unable to transform the error
    func asyncResult<E2: Swift.Error>(_ transformError: CasePath<E2, Self.Failure>) async throws
        -> Result<Self.Output, E2> {
        do {
            let result = try await _async()
            return .success(result)
        } catch let error as Self.Failure {
            return .failure(transformError.embed(error))
        } catch {
            throw error
        }
    }

    /// Bridges from AnyPublisher to structured concurrent code.
    /// Use for awaiting exactly one value (as with `Publisher.first()`)
    ///
    /// - Warning: This loses the error-nesting structure.
    func async() async throws -> Output {
        try await _async()
    }
}

extension Publisher {
    private func _async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}

extension Future where Failure == Error {
    /// Bridges from  structured concurrent code to `Publisher`.
    convenience init(operation: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let output = try await operation()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

extension Future where Failure == Never {
    /// Bridges from  structured concurrent code to `Publisher`.
    convenience init(operation: @escaping () async -> Output) {
        self.init { promise in
            Task {
                let result = await operation()
                promise(.success(result))
            }
        }
    }
}

extension Future where Failure == Error {
    /// Bridges from  structured concurrent code to `Publisher`.
    static func createWithEscapedDependencies(operation: @escaping () async throws -> Output) -> Self {
        withEscapedDependencies { continuation in
            Self { promise in
                Task {
                    do {
                        try await continuation.yield {
                            let output = try await operation()
                            promise(.success(output))
                        }
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

extension Future where Failure == Never {
    /// Bridges from  structured concurrent code to `Publisher`.
    static func createWithEscapedDependencies(operation: @escaping () async -> Output) -> Self {
        withEscapedDependencies { continuation in
            Self { promise in
                Task {
                    await continuation.yield {
                        let output = await operation()
                        promise(.success(output))
                    }
                }
            }
        }
    }
}
