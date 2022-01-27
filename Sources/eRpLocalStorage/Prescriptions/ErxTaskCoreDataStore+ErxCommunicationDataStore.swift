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

import Combine
import CoreData
import eRpKit

extension ErxTaskCoreDataStore: ErxCommunicationDataStore {
    public func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, Error> {
        let request: NSFetchRequest<ErxTaskCommunicationEntity> = ErxTaskCommunicationEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(
            key: #keyPath(ErxTaskCommunicationEntity.timestamp),
            ascending: false
        )]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskCommunicationEntity.task.profile.identifier), identifier]
            )
        }
        return fetch(request)
            .map { $0.first?.timestamp }
            .eraseToAnyPublisher()
    }

    public func listAllCommunications(
        after _: String? = nil,
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], Error> {
        let request: NSFetchRequest<ErxTaskCommunicationEntity> = ErxTaskCommunicationEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskCommunicationEntity.timestamp),
                                                    ascending: false)]
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskCommunicationEntity.task.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        if !profile.isAll {
            let comProfile = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxTaskCommunicationEntity.profile),
                profile.rawValue
            )
            subPredicates.append(comProfile)
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
        return fetch(request)
            .map { list in list.map(ErxTask.Communication.init(entity:)) }
            .eraseToAnyPublisher()
    }

    public func countAllUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, Error> {
        let request: NSFetchRequest<ErxTaskCommunicationEntity> = ErxTaskCommunicationEntity.fetchRequest()
        request.sortDescriptors = []
        var predicates = [NSPredicate]()
        let isNotReadPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [
                NSPredicate(
                    format: "%K == %d",
                    #keyPath(ErxTaskCommunicationEntity.isRead),
                    false
                ),
                NSPredicate(
                    format: "%K == nil",
                    #keyPath(ErxTaskCommunicationEntity.isRead)
                ),
            ]
        )
        predicates.append(isNotReadPredicate)
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskCommunicationEntity.task.profile.identifier), identifier]
            )
            predicates.append(profilePredicate)
        }
        if !profile.isAll {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxTaskCommunicationEntity.profile),
                profile.rawValue
            )
            predicates.append(profilePredicate)
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return fetch(request)
            .map { list in list.count }
            .eraseToAnyPublisher()
    }

    public func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, Error> {
        save(mergePolicy: .error) { moc in
            _ = communications.map { erxTaskCommunication -> ErxTaskCommunicationEntity in

                let request: NSFetchRequest<ErxTaskCommunicationEntity> = ErxTaskCommunicationEntity
                    .fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(ErxTaskCommunicationEntity.identifier),
                    erxTaskCommunication.identifier
                )

                if let updatedCommunicationEntity = try? moc.fetch(request).first {
                    // when doing update, only update property isRead and only if it changes to true
                    if !updatedCommunicationEntity.isRead {
                        updatedCommunicationEntity.isRead = erxTaskCommunication.isRead
                    }
                    return updatedCommunicationEntity
                } else {
                    let newCommunicationEntity = ErxTaskCommunicationEntity.from(
                        communication: erxTaskCommunication,
                        in: moc
                    )

                    let requestTask: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
                    requestTask.predicate = NSPredicate(
                        format: "%K == %@",
                        #keyPath(ErxTaskEntity.identifier),
                        erxTaskCommunication.taskId
                    )
                    let taskEntity = try? requestTask.execute().first
                    taskEntity?.addToCommunications(newCommunicationEntity)
                    return newCommunicationEntity
                }
            }
        }
    }
}
