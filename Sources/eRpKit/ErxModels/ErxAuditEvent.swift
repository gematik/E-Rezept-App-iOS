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

/// Represents audit events related to Erx Tasks.
public struct ErxAuditEvent: Identifiable, Hashable, Codable {
    /// ErxAuditEvent default initializer
    public init(
        identifier: String,
        locale: String? = nil,
        text: String? = nil,
        timestamp: String? = nil,
        taskId: String? = nil,
        title: String? = nil,
        agentName: String? = nil,
        agentTelematikId: String? = nil
    ) {
        self.identifier = identifier
        self.locale = locale
        self.text = text
        self.timestamp = timestamp
        self.taskId = taskId
        self.title = title
        self.agentName = agentName
        self.agentTelematikId = agentTelematikId
    }

    /// Id of the audit event
    public var id: String { identifier }

    /// Identifier of the audit event
    public let identifier: String
    /// Locale of the audit event
    public let locale: String?
    /// Human-readable text of the audit event
    public let text: String?
    /// Timestamp of the audit event
    public let timestamp: String?
    /// Identifier of the referenced task in the audit event
    public let taskId: String?
    /// Title for the AuditEvent, typically ErxTask name
    public let title: String?
    /// The name of the agent performing this event
    public let agentName: String?
    /// TelematikId of the agent performing this event
    public let agentTelematikId: String?
}
