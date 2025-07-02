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
import ComposableArchitecture
import eRpKit
import Foundation
import IdentifiedCollections
import Pharmacy

protocol InternalCommunicationProtocol {
    func load() async throws -> IdentifiedArray<String, InternalCommunication>

    func loadUnreadInternalCommunicationsCount() -> AsyncThrowingStream<Int, Swift.Error>
}

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

// sourcery: CodedError = "038"
enum InternalCommunicationError: Error, Equatable {
    // sourcery: errorCode = "01"
    case decodingError(Error)
    // sourcery: errorCode = "02"
    case invalidURL
    // sourcery: errorCode = "03"
    case emptyOnboardingDate
    // sourcery: errorCode = "04"
    case unknownError

    var errorDescription: String? {
        switch self {
        case let .decodingError(error): return error.localizedDescription
        case .invalidURL: return L10n.internMsgErrorInvalidUrl.text
        case .emptyOnboardingDate: return L10n.internMsgErrorEmptyOnboardingDate.text
        case .unknownError: return L10n.internMsgErrorUnknownError.text
        }
    }

    static func ==(lhs: InternalCommunicationError, rhs: InternalCommunicationError) -> Bool {
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

final class DefaultInternalCommunication: InternalCommunicationProtocol {
    private let userDataStore: UserDataStore
    private let internalCommunicationsRepository: InternalCommunicationsRepository

    init(
        userDataStore: UserDataStore,
        internalCommunicationsRepository: InternalCommunicationsRepository
    ) {
        self.userDataStore = userDataStore
        self.internalCommunicationsRepository = internalCommunicationsRepository
    }

    func load() async throws -> IdentifiedArray<String, InternalCommunication> {
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

        var messages = internalCommunications.compactMap { (internalCommunication: InternalCommunication.Message) in
            if onboardingTimestamp < internalCommunication.timestamp {
                // return decoded messages and set isRead
                var newMessage = internalCommunication
                newMessage.isRead = readMessages.contains(internalCommunication.id)
                return newMessage
            }
            return nil
        }

        let hideWelcomeMessage = try await userDataStore.hideWelcomeMessage.async()

        // create and append welcome message (only possible when new installation)
        if !hideWelcomeMessage {
            let welcomeMessage = InternalCommunication.Message(
                id: "1",
                timestamp: onboardingTimestamp,
                text: L10n.internMsgWelcome.text,
                // welcome message has version number 0.0.0
                version: "0.0.0",
                isRead: readMessages.contains("1")
            )
            messages.insert(welcomeMessage, at: 0)
        }
        let emptyArray: [InternalCommunication] = []
        return IdentifiedArray(uniqueElements: messages
            .isEmpty ? emptyArray : [InternalCommunication(messages: messages)])
    }

    func loadUnreadInternalCommunicationsCount() -> AsyncThrowingStream<Int, Swift.Error> {
        AsyncThrowingStream { continuation in
            Task { [userDataStore] in
                do {
                    let internalCommunications = try await load().elements
                    for try await readIds in userDataStore.readInternalCommunications.buffer(
                        size: 1,
                        prefetch: .byRequest,
                        whenFull: .dropOldest
                    ).values {
                        // get all the ids from all messages from the IdentifiedArray
                        let allMessagesIds = internalCommunications.map(\.messages).flatMap { $0 }.map(\.id)
                        // check if any ids are not included in the readIds array
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
}
