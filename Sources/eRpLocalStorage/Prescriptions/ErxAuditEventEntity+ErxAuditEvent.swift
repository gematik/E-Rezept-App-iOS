//
//  Copyright (c) 2022 gematik GmbH
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

import CoreData
import eRpKit

extension ErxAuditEventEntity {
    static func from(auditEvent: ErxAuditEvent,
                     in context: NSManagedObjectContext) -> ErxAuditEventEntity {
        ErxAuditEventEntity(auditEvent: auditEvent,
                            in: context)
    }

    convenience init(auditEvent: ErxAuditEvent,
                     in context: NSManagedObjectContext) {
        self.init(context: context)

        identifier = auditEvent.identifier
        locale = auditEvent.locale
        text = auditEvent.text
        timestamp = auditEvent.timestamp
    }
}

extension ErxAuditEvent {
    init(entity: ErxAuditEventEntity) {
        self.init(
            identifier: entity.identifier ?? "",
            locale: entity.locale,
            text: entity.text,
            timestamp: entity.timestamp,
            taskId: entity.task?.identifier,
            title: entity.task?.medication?.name
        )
    }
}
