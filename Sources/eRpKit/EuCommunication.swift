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

import Foundation

public struct EuCommunication: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    /// related eu-accesscode
    public var euAccessCode: EuAccessCode?
    /// Indicates what kind of communication happens e.g. (created, refreshed, deleted, added, removed)
    public var eventType: EuCommunicationEvent
    /// related taskId (only used when adding or removing tasks event)
    public var taskId: String?
    /// ID from profile that created this communication
    public var profileId: UUID?
    /// Id for every order of prescriptions
    public let orderId: String?
    /// date when the communication was created
    public var timestamp: Date?
    /// Indicates if the communication has been opened by the user
    public var isRead: Bool
    /// related code of country (e.g. "De", "Fr")
    public var countryCode: String?

    /// EuCommunication with EuAccessCode
    public init(
        id: UUID = UUID(),
        eventType: EuCommunicationEvent,
        taskId: String? = nil,
        orderId: String? = nil,
        timestamp: Date? = nil,
        isRead: Bool = false,
        euAccessCode: EuAccessCode? = nil,
        profileId: UUID? = nil,
        countryCode: String? = nil

    ) {
        self.id = id
        self.eventType = eventType
        self.taskId = taskId
        self.orderId = orderId
        self.timestamp = timestamp
        self.isRead = isRead
        self.euAccessCode = euAccessCode
        self.profileId = profileId
        self.countryCode = countryCode
    }

    public enum EuCommunicationEvent: Sendable, Codable, Equatable, Hashable {
        case createdAccessCode
        case refreshedAccessCode
        case deletedAccessCode(origin: DeletionOriginEvent)
        case addedTask
        case removedTask
        case redeemedTask
        case unknown
    }

    /// The message header is based on the event origion for deletion event
    public enum DeletionOriginEvent: Sendable, Codable, Equatable, Hashable {
        case created
        case refreshed
    }
}
