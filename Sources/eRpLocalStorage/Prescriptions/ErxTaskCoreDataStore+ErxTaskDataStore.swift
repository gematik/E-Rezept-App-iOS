//
//  Copyright (c) 2021 gematik GmbH
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

extension ErxTaskCoreDataStore: ErxTaskDataStore {
    public func fetchTask(by taskID: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        if let accessCode = accessCode {
            request.predicate = NSPredicate(
                format: "%K == %@ && %K == %@",
                #keyPath(ErxTaskEntity.identifier),
                taskID,
                #keyPath(ErxTaskEntity.accessCode),
                accessCode
            )
        } else {
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(ErxTaskEntity.identifier), taskID)
        }
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: true)]
        return container.viewContext
            .publisher(for: request)
            .map { results in
                guard let task = results.first else {
                    return nil
                }
                return ErxTask(entity: task)
            }
            .mapError(Error.read)
            .subscribe(on: foregroundQueue)
            .eraseToAnyPublisher()
    }

    public func listAllTasks() -> AnyPublisher<[ErxTask], Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: true)]
        return container.viewContext
            .publisher(for: request)
            .map { list in list.map(ErxTask.init) }
            .mapError(Error.read)
            .subscribe(on: foregroundQueue)
            .eraseToAnyPublisher()
    }

    public func save(tasks: [ErxTask]) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    // Note that promise will never emit
                    return
                }
                let moc = self.container.newBackgroundContext()
                moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                moc.performAndWait {
                    // Insert the ErxTasks (Prescriptions)
                    _ = tasks.map { task in
                        ErxTaskEntity.from(task: task, in: moc)
                    }
                    do {
                        try moc.save()
                        promise(.success(true))
                        moc.reset()
                    } catch {
                        promise(.failure(error))
                        moc.reset()
                    }
                }
            }
        }
        .subscribe(on: backgroundQueue)
        .mapError(Error.write)
        .eraseToAnyPublisher()
    }

    public func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: true)]
        let ids = tasks.map(\.id)
        request.predicate = NSPredicate(
            format: "%K in %@", #keyPath(ErxTaskEntity.identifier), ids
        )
        return container.viewContext
            .publisher(for: request)
            .first()
            .tryMap { erxTaskEntities in
                if !erxTaskEntities.isEmpty {
                    let moc = self.container.viewContext
                    for erxTaskEntity in erxTaskEntities {
                        moc.delete(erxTaskEntity)
                    }
                    try moc.save()
                }
                return true
            }
            .mapError(Error.delete)
            .subscribe(on: backgroundQueue)
            .eraseToAnyPublisher()
    }

    public func fetchAuditEvent(by auditEventID: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, Error> {
        let request: NSFetchRequest<ErxAuditEventEntity> = ErxAuditEventEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(ErxAuditEventEntity.task.identifier),
            auditEventID
        )
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxAuditEventEntity.timestamp), ascending: false)]
        return container.viewContext
            .publisher(for: request)
            .map { results in
                guard let auditEvent = results.first else {
                    return nil
                }
                return ErxAuditEvent(entity: auditEvent)
            }
            .mapError(Error.read)
            .subscribe(on: foregroundQueue)
            .eraseToAnyPublisher()
    }

    public func listAllAuditEvents(after referenceDate: String? = nil,
                                   for locale: String?) -> AnyPublisher<[ErxAuditEvent], Error> {
        let request: NSFetchRequest<ErxAuditEventEntity> = ErxAuditEventEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxAuditEventEntity.timestamp), ascending: false)]

        var subPredicates = [NSPredicate]()
        if let date = referenceDate {
            let datePredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxAuditEventEntity.timestamp),
                date
            )
            subPredicates.append(datePredicate)
        }
        if let locale = locale {
            let localePredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [
                    NSPredicate(
                        format: "%K == %@",
                        #keyPath(ErxAuditEventEntity.locale),
                        locale
                    ),
                    NSPredicate(
                        format: "%K == nil",
                        #keyPath(ErxAuditEventEntity.locale)
                    ),
                ]
            )
            subPredicates.append(localePredicate)
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)

        return container.viewContext
            .publisher(for: request)
            .map { list in list.map(ErxAuditEvent.init) }
            .mapError(Error.read)
            .subscribe(on: foregroundQueue)
            .eraseToAnyPublisher()
    }

    public func listAllAuditEvents(forTaskID taskID: ErxTask.ID,
                                   for locale: String?) -> AnyPublisher<[ErxAuditEvent], Error> {
        let request: NSFetchRequest<ErxAuditEventEntity> = ErxAuditEventEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxAuditEventEntity.timestamp), ascending: false)]

        var subPredicates = [NSPredicate]()
        let taskIdPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [
                NSPredicate(
                    format: "%K == %@",
                    #keyPath(ErxAuditEventEntity.task.identifier),
                    taskID
                ),
                NSPredicate(
                    format: "%K == nil",
                    #keyPath(ErxAuditEventEntity.task.identifier)
                ),
            ]
        )
        subPredicates.append(taskIdPredicate)
        if let locale = locale {
            let localePredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxAuditEventEntity.locale),
                locale
            )
            subPredicates.append(localePredicate)
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)

        return container.viewContext
            .publisher(for: request)
            .map { list in list.map(ErxAuditEvent.init) }
            .mapError(Error.read)
            .subscribe(on: foregroundQueue)
            .eraseToAnyPublisher()
    }

    public func save(auditEvents: [ErxAuditEvent]) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    // Note that promise will never emit
                    return
                }
                let moc = self.container.newBackgroundContext()
                moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                moc.performAndWait {
                    // Insert the ErxAuditEvents (Prescriptions)
                    _ = auditEvents.map { auditEvent -> ErxAuditEventEntity in
                        let auditEventEntity = ErxAuditEventEntity.from(auditEvent: auditEvent,
                                                                        in: moc)
                        if let taskID = auditEvent.taskId {
                            let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
                            request.predicate = NSPredicate(
                                format: "%K == %@",
                                #keyPath(ErxTaskEntity.identifier),
                                taskID
                            )
                            auditEventEntity.task = try? request.execute().first
                        }

                        return auditEventEntity
                    }
                    do {
                        try moc.save()
                        promise(.success(true))
                        moc.reset()
                    } catch {
                        promise(.failure(error))
                        moc.reset()
                    }
                }
            }
        }
        .subscribe(on: backgroundQueue)
        .mapError(Error.write)
        .eraseToAnyPublisher()
    }

    public func redeem(orders _: [ErxTaskOrder]) -> AnyPublisher<Bool, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func listAllCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], Error> {
        let request: NSFetchRequest<ErxTaskCommunicationEntity> = ErxTaskCommunicationEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskCommunicationEntity.timestamp),
                                                    ascending: false)]

        if !profile.isAll {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxTaskCommunicationEntity.profile),
                profile.rawValue
            )
            request.predicate = profilePredicate
        }
        return container.viewContext
            .publisher(for: request)
            .map { list in list.map(ErxTask.Communication.init(entity:)) }
            .mapError(Error.read)
            .subscribe(on: foregroundQueue)
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
        if !profile.isAll {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxTaskCommunicationEntity.profile),
                profile.rawValue
            )
            predicates.append(profilePredicate)
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return container.viewContext
            .publisher(for: request)
            .map { list in list.count }
            .mapError(Error.read)
            .subscribe(on: foregroundQueue)
            .eraseToAnyPublisher()
    }

    public func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    // Note that promise will never emit
                    return
                }
                let moc = self.container.newBackgroundContext()
                moc.performAndWait {
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
                    do {
                        try moc.save()
                        promise(.success(true))
                        moc.reset()
                    } catch {
                        promise(.failure(error))
                        moc.reset()
                    }
                }
            }
        }
        .subscribe(on: backgroundQueue)
        .mapError(Error.write)
        .eraseToAnyPublisher()
    }
}
