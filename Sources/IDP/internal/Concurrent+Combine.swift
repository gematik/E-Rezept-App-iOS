// swiftlint:disable:this file_name
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

import CasePaths
import Combine
import Foundation

enum AsyncError: Error, Equatable {
    static func ==(lhs: AsyncError, rhs: AsyncError) -> Bool {
        switch (lhs, rhs) {
        case (.finishedWithoutValue, .finishedWithoutValue):
            return true
        case let (.error(lhsError), .error(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }

    case finishedWithoutValue
    case error(Swift.Error)
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
    func async<E2: Swift.Error>(_ transformError: CaseKeyPath<E2, Self.Failure>) async throws -> Output {
        do {
            return try await _async()
        } catch let error as Self.Failure {
            throw transformError(error)
        } catch {
            throw error
        }
    }

    @available(*, deprecated, message: "use CaseKeyPath version")
    func async<E2: Swift.Error>(_ transformError: AnyCasePath<E2, Self.Failure>) async throws -> Output {
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
    func asyncResult<E2: Swift.Error>(_ transformError: CaseKeyPath<E2, Self.Failure>) async throws
        -> Result<Self.Output, E2> {
        do {
            let result = try await _async()
            return .success(result)
        } catch let error as Self.Failure {
            return .failure(transformError(error))
        } catch {
            throw error
        }
    }

    /// Bridges from AnyPublisher to structured concurrent code.
    /// Use for awaiting exactly one value (as with `Publisher.first()`)
    /// - Returns: Results a `Result` type of the output or an `AsyncError`
    func asyncResult() async -> Result<Self.Output, AsyncError> {
        await _asyncResult()
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
                    cancellable?.cancel()
                }
        }
    }

    private func _asyncResult() async -> Result<Output, AsyncError> {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(returning: .failure(AsyncError.finishedWithoutValue))
                        }
                    case let .failure(error):
                        continuation.resume(returning: .failure(AsyncError.error(error)))
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(returning: .success(value))
                    cancellable?.cancel()
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
