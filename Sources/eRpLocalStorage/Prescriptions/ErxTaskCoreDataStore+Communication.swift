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

import Combine
import CoreData
import eRpKit

/// Communication related local store interfaces
extension ErxTaskCoreDataStore {
    /// Fetch the most recent `timestamp` of all `Communication`s
    public func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, LocalStoreError> {
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

    /// List all communications for the given profile contained in the store
    /// - Parameter profile: Filters for the passed Profile type
    /// - Returns: array of the fetched communications or error
    public func listAllCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
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
            .map { list in
                list.map(ErxTask.Communication.init(entity:))
            }
            .eraseToAnyPublisher()
    }

    /// Returns all unread communications for the given profile
    /// - Parameter profile: profile for which you want to have the count
    public func allUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
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
            .map { list in
                list.map(ErxTask.Communication.init(entity:))
            }
            .eraseToAnyPublisher()
    }

    /// Creates or updates the passes sequence of `ErxTaskCommunication`s
    /// - Parameter communications: Array of communications that should be stored
    /// - Returns: `true` if save operation was successful
    public func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, LocalStoreError> {
        save(mergePolicy: .error) { [weak self] moc in
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

                    // stores the oderId of a dispReq communication in the related reply communication
                    // swiftlint:disable:next todo
                    // FIXME: This is potentially broken. Currently it`s possible to redeem a task several times.
                    // That can cause a wrong match between the dispReq and the reply
                    if newCommunicationEntity.profile == ErxTask.Communication.Profile.reply.rawValue {
                        // check if in the new communications is also the related disp req
                        var communicationDispReq = communications
                            .first { $0.profile == .dispReq &&
                                $0.taskId == newCommunicationEntity.taskId &&
                                $0.telematikId == newCommunicationEntity.telematikId
                            }
                        if communicationDispReq == nil {
                            communicationDispReq = self?.fetchCommunication(
                                for: .dispReq,
                                with: erxTaskCommunication.taskId,
                                telematikId: erxTaskCommunication.telematikId,
                                on: moc
                            )
                        }
                        newCommunicationEntity.orderId = communicationDispReq?.orderId
                    }

                    let requestTask: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
                    requestTask.predicate = NSPredicate(
                        format: "%K == %@",
                        #keyPath(ErxTaskEntity.identifier),
                        erxTaskCommunication.taskId
                    )
                    let taskEntity = try? moc.fetch(requestTask).first
                    taskEntity?.addToCommunications(newCommunicationEntity)
                    return newCommunicationEntity
                }
            }
        }
    }

    private func fetchCommunication(for profile: ErxTask.Communication.Profile,
                                    with taskId: ErxTask.ID,
                                    telematikId: String,
                                    on moc: NSManagedObjectContext) -> ErxTask.Communication? {
        let request: NSFetchRequest<ErxTaskCommunicationEntity> = ErxTaskCommunicationEntity.fetchRequest()

        var predicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskCommunicationEntity.task.profile.identifier), identifier]
            )
            predicates.append(profilePredicate)
        }
        predicates.append(
            NSPredicate(
                format: "%K == %@ AND %K == %@ AND %K == %@",
                argumentArray: [
                    #keyPath(ErxTaskCommunicationEntity.taskId),
                    taskId,
                    #keyPath(ErxTaskCommunicationEntity.telematikId),
                    telematikId,
                    #keyPath(ErxTaskCommunicationEntity.profile),
                    profile.rawValue,
                ]
            )
        )
        let entity = try? moc.fetch(request).first
        return entity.map(ErxTask.Communication.init(entity:))
    }
}
