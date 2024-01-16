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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.Bundle {
    func parseErxAuditEventsContainer() throws -> PagedContent<[ErxAuditEvent]> {
        PagedContent(content: try parseErxAuditEvents(),
                     next: parseNext())
    }

    func parseNext() -> URL? {
        link?
            .first { $0.relation.value?.string == "next" }?
            .url
            .value?
            .url
    }

    /// Parse and extract all found ErxAuditEvents from `Self`
    ///
    /// - Returns: Array with all found audit events
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxAuditEvents() throws -> [ErxAuditEvent] {
        try entry?.compactMap {
            guard let auditEvent = $0.resource?.get(if: ModelsR4.AuditEvent.self) else {
                return nil
            }
            guard let identifier = auditEvent.id?.value?.string else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse id from audit event.")
            }

            var text: String?

            if let utf8String = auditEvent.text?.div.value?.string.utf8 {
                text = try? NSAttributedString(data: Data(utf8String),
                                               options: [
                                                   .documentType: NSAttributedString.DocumentType.html,
                                                   .characterEncoding: String.Encoding.utf8.rawValue,
                                               ],
                                               documentAttributes: nil).string
            }

            /*
              Right now, references to task can come in several formats. For example:
              - https://www.example.com/Task/xxx (reference to a task with the ID xxx)
              - Task/xxx (reference to a task with the ID xxx)
              - https://www.example.com/Task (this audit event belongs to no specific task)
              - Task (this audit event belongs to no specific task)
              Therefore, we have to parse the ID from the URL (or partial URL) provided by the server,
              by looking right after the path component 'Task'.
              If the audit event does not belong to a specific task, then taskId remains nil.
             */
            var taskId: String?
            if let what = auditEvent.entity?.first?.what {
                if let identifierValue = what.identifier?.value(for: Workflow.Key.prescriptionIdKeys) {
                    taskId = identifierValue
                } else if let taskIDString = what.reference?.value?.string,
                          let pathComponents = URL(string: taskIDString)?.pathComponents,
                          let taskComponentIndex = pathComponents.firstIndex(of: "Task"),
                          taskComponentIndex + 1 < pathComponents.count {
                    taskId = pathComponents[taskComponentIndex + 1]
                }
            }

            return ErxAuditEvent(identifier: identifier,
                                 locale: auditEvent.language?.value?.string,
                                 text: text,
                                 timestamp: auditEvent.recorded.value?.description,
                                 taskId: taskId)
        } ?? []
    }
}
