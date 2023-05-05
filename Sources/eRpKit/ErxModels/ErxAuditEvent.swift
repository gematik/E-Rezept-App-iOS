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

import Foundation

/// Represents audit events related to Erx Tasks.
public struct ErxAuditEvent: Identifiable, Hashable {
    /// ErxAuditEvent default initializer
    public init(
        identifier: String,
        locale: String? = nil,
        text: String? = nil,
        timestamp: String? = nil,
        taskId: String? = nil,
        title: String? = nil
    ) {
        self.identifier = identifier
        self.locale = locale
        self.text = text
        self.timestamp = timestamp
        self.taskId = taskId
        self.title = title
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
}
