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

extension ErxTaskCommunicationEntity {
    static func from(communication: ErxTask.Communication,
                     in context: NSManagedObjectContext) -> ErxTaskCommunicationEntity {
        ErxTaskCommunicationEntity(communication: communication, in: context)
    }

    convenience init(
        communication: ErxTask.Communication,
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)

        identifier = communication.identifier
        taskId = communication.taskId
        profile = communication.profile.rawValue
        telematikId = communication.telematikId
        orderId = communication.orderId
        timestamp = communication.timestamp
        insuranceId = communication.insuranceId
        payload = communication.payloadJSON
        isRead = communication.isRead
        // task relationship is set threw loadAllCommunications call
    }
}

extension ErxTask.Communication {
    init(entity: ErxTaskCommunicationEntity) {
        self.init(
            identifier: entity.identifier ?? "",
            profile: Profile(rawValue: entity.profile ?? "") ?? Profile.none,
            taskId: entity.taskId ?? entity.task?.identifier ?? "",
            userId: entity.insuranceId ?? "",
            telematikId: entity.telematikId ?? "",
            orderId: entity.orderId,
            timestamp: entity.timestamp ?? "",
            payloadJSON: entity.payload ?? "",
            isRead: entity.isRead
        )
    }
}
