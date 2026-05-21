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

import CoreData
import eRpKit

extension EuCommunicationEntity {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    convenience init(
        euCommunication: EuCommunication,
        encoder: JSONEncoder = EuCommunicationEntity.encoder,
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)
        let eventType = try? encoder.encode(euCommunication.eventType)

        identifier = euCommunication.id
        orderId = euCommunication.orderId
        isRead = euCommunication.isRead
        self.eventType = eventType
        taskId = euCommunication.taskId
        timestamp = euCommunication.timestamp
        countryCode = euCommunication.countryCode
        euAccessCode = EuAccessCodeEntity(euAccessCode: euCommunication.euAccessCode, in: context)
    }

    func update(
        with euCommunication: EuCommunication,
        euAccessCodeEntity: EuAccessCodeEntity?,
        profileEntity: ProfileEntity?,
        encoder: JSONEncoder = EuCommunicationEntity.encoder,
        in _: NSManagedObjectContext
    ) {
        let eventType = try? encoder.encode(euCommunication.eventType)

        identifier = euCommunication.id
        orderId = euCommunication.orderId
        if isRead == false {
            isRead = euCommunication.isRead
        }
        self.eventType = eventType
        taskId = euCommunication.taskId
        timestamp = euCommunication.timestamp
        countryCode = euCommunication.countryCode
        profile = profileEntity
        euAccessCode = euAccessCodeEntity
    }
}

extension EuCommunication {
    init?(entity: EuCommunicationEntity?,
          decoder: JSONDecoder = JSONDecoder()) {
        guard let entity,
              let identifier = entity.identifier else {
            return nil
        }

        let eventType = try? decoder.decode(EuCommunicationEvent.self, from: entity.eventType ?? Data())
        let euAccessCode = EuAccessCode(entity: entity.euAccessCode)
        self.init(
            id: identifier,
            eventType: eventType ?? .unknown,
            taskId: entity.taskId,
            orderId: entity.orderId,
            timestamp: euAccessCode?.createdAt ?? entity.timestamp,
            isRead: entity.isRead,
            euAccessCode: euAccessCode,
            profileId: entity.profile?.identifier,
            countryCode: entity.countryCode
        )
    }
}
