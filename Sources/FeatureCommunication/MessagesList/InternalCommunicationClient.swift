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
import CodedError
import Combine
import Dependencies
import DependenciesMacros
import eRpKit
import eRpResources
import Foundation
import IdentifiedCollections

// MARK: - @DependencyClient struct

@DependencyClient
public struct InternalCommunicationClient: Sendable {
    public var load: @Sendable () async throws -> IdentifiedArray<String, InternalCommunication> = {
        IdentifiedArray()
    }

    public var loadUnreadInternalCommunicationsCount: @Sendable () -> AsyncThrowingStream<Int, Swift.Error> = {
        .finished()
    }
}

// MARK: - TestDependencyKey + DependencyValues

extension InternalCommunicationClient: TestDependencyKey {
    public static let testValue: InternalCommunicationClient = Self()
}

extension DependencyValues {
    /// A client for loading internal communications. Default implementation returns an empty array.
    public var internalCommunicationClient: InternalCommunicationClient {
        get { self[InternalCommunicationClient.self] }
        set { self[InternalCommunicationClient.self] = newValue }
    }
}

// MARK: - Live factory

extension InternalCommunicationClient {
    /// Creates a live `InternalCommunicationClient`.
    /// `userDataStore` must be provided because its `DependencyValues` extension lives in the app module.
    public static func live(userDataStore: UserDataStore) -> Self { // swiftlint:disable:this function_body_length
        @Dependency(\.internalCommunicationsRepository) var internalCommunicationsRepository

        return Self(
            load: {
                let internalCommunications = try await internalCommunicationsRepository.load()

                let readMessages = try await userDataStore.readInternalCommunications.async()
                let onboardingDate = try await userDataStore.onboardingDate.async()
                #if DEBUG
                guard let onboardingTimestamp = onboardingDate else {
                    throw InternalCommunicationError.emptyOnboardingDate
                }
                #else
                let onboardingTimestamp = onboardingDate ?? Date.distantPast
                #endif

                var messages = internalCommunications
                    .compactMap { (internalCommunication: InternalCommunication.Message) in
                        if onboardingTimestamp < internalCommunication.timestamp {
                            var newMessage = internalCommunication
                            newMessage.isRead = readMessages.contains(internalCommunication.id)
                            return newMessage
                        }
                        return nil
                    }
                    .sorted { $0.timestamp > $1.timestamp }

                let hideWelcomeMessage = try await userDataStore.hideWelcomeMessage.async()

                if !hideWelcomeMessage {
                    let welcomeMessage = InternalCommunication.Message(
                        id: "1",
                        timestamp: onboardingTimestamp,
                        text: L10n.internMsgWelcome.text,
                        version: "0.0.0",
                        isRead: readMessages.contains("1")
                    )
                    messages.append(welcomeMessage)
                }
                let emptyArray: [InternalCommunication] = []
                return IdentifiedArray(uniqueElements: messages
                    .isEmpty ? emptyArray : [InternalCommunication(messages: messages)])
            },
            loadUnreadInternalCommunicationsCount: {
                AsyncThrowingStream { continuation in
                    Task {
                        do {
                            @Dependency(\.internalCommunicationClient) var client
                            let internalCommunications = try await client.load().elements
                            for try await readIds in userDataStore.readInternalCommunications.buffer(
                                size: 1,
                                prefetch: .byRequest,
                                whenFull: .dropOldest
                            ).values {
                                let allMessagesIds = internalCommunications.map(\.messages).flatMap { $0 }.map(\.id)
                                let unreadMessagesCount = allMessagesIds.filter { !readIds.contains($0) }.count

                                continuation.yield(unreadMessagesCount)
                            }
                            continuation.finish()
                        } catch {
                            continuation.finish(throwing: error)
                        }
                    }
                }
            }
        )
    }
}

// MARK: - Error

extension Swift.Error {
    /// Map any Error to an InternalCommunicationError
    func asInternalCommunicationError() -> InternalCommunicationError {
        if let error = self as? InternalCommunicationError {
            return error
        } else {
            return InternalCommunicationError.unknownError
        }
    }
}

@CodedError("038")
public enum InternalCommunicationError: Error, Equatable {
    @ErrorCode("01")
    case decodingError(Error)
    @ErrorCode("02")
    case invalidURL
    @ErrorCode("03")
    case emptyOnboardingDate
    @ErrorCode("04")
    case unknownError

    public var errorDescription: String? {
        switch self {
        case let .decodingError(error): return error.localizedDescription
        case .invalidURL: return L10n.internMsgErrorInvalidUrl.text
        case .emptyOnboardingDate: return L10n.internMsgErrorEmptyOnboardingDate.text
        case .unknownError: return L10n.internMsgErrorUnknownError.text
        }
    }

    public static func ==(lhs: InternalCommunicationError, rhs: InternalCommunicationError) -> Bool {
        switch (lhs, rhs) {
        case let (.decodingError(lhsError), .decodingError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.invalidURL, .invalidURL): return true
        case (.emptyOnboardingDate, .emptyOnboardingDate): return true
        case (.unknownError, .unknownError): return true
        default:
            return false
        }
    }
}
