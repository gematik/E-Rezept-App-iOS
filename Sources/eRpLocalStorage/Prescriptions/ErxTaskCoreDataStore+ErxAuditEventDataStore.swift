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

extension ErxTaskCoreDataStore: ErxAuditEventDataStore {
    public func fetchAuditEvent(by auditEventID: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, Error> {
        let request: NSFetchRequest<ErxAuditEventEntity> = ErxAuditEventEntity.fetchRequest()
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxAuditEventEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(ErxAuditEventEntity.task.identifier), auditEventID)
        subPredicates.append(idPredicate)
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxAuditEventEntity.timestamp), ascending: false)]
        return fetch(request)
            .map { results in
                guard let auditEvent = results.first else {
                    return nil
                }
                return ErxAuditEvent(entity: auditEvent)
            }
            .eraseToAnyPublisher()
    }

    public func fetchLatestTimestampForAuditEvents() -> AnyPublisher<String?, Error> {
        let request: NSFetchRequest<ErxAuditEventEntity> = ErxAuditEventEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxAuditEventEntity.timestamp), ascending: false)]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxAuditEventEntity.profile.identifier), identifier]
            )
        }
        return fetch(request)
            .map { $0.first?.timestamp }
            .eraseToAnyPublisher()
    }

    public func listAllAuditEvents(after referenceDate: String? = nil,
                                   for locale: String?) -> AnyPublisher<[ErxAuditEvent], Error> {
        let request: NSFetchRequest<ErxAuditEventEntity> = ErxAuditEventEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxAuditEventEntity.timestamp), ascending: false)]

        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxAuditEventEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
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

        return fetch(request)
            .map { list in list.map(ErxAuditEvent.init) }
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

        return fetch(request)
            .map { list in list.map(ErxAuditEvent.init) }
            .eraseToAnyPublisher()
    }

    public func save(auditEvents: [ErxAuditEvent]) -> AnyPublisher<Bool, Error> {
        save(mergePolicy: .mergeByPropertyObjectTrump) { moc in
            // Insert the ErxAuditEvents (Prescriptions)
            _ = auditEvents.map { [weak self] auditEvent -> ErxAuditEventEntity in
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
                auditEventEntity.profile = self?.fetchProfile(in: moc)
                return auditEventEntity
            }
        }
    }
}
