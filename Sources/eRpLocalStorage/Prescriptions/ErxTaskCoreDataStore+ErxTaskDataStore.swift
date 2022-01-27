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

extension ErxTaskCoreDataStore: ErxTaskDataStore {
    public func fetchTask(by taskID: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        subPredicates.append(NSPredicate(format: "%K == %@", #keyPath(ErxTaskEntity.identifier), taskID))
        if let accessCode = accessCode {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxTaskEntity.accessCode),
                accessCode
            )
            subPredicates.append(predicate)
        }
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false)]

        return fetch(request)
            .map { results in
                guard let task = results.first else {
                    return nil
                }
                return ErxTask(entity: task)
            }
            .eraseToAnyPublisher()
    }

    public func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.lastModified), ascending: false)]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskEntity.profile.identifier), identifier]
            )
        }
        return fetch(request)
            .map { $0.first?.lastModified }
            .eraseToAnyPublisher()
    }

    public func listAllTasks(after _: String? = nil) -> AnyPublisher<[ErxTask], Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false)]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskEntity.profile.identifier), identifier]
            )
        }
        return fetch(request)
            .map { list in list.compactMap(ErxTask.init) }
            .eraseToAnyPublisher()
    }

    public func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false)]
        request.predicate = NSPredicate(format: "%K == nil", #keyPath(ErxTaskEntity.profile))
        return fetch(request)
            .map { list in list.compactMap(ErxTask.init) }
            .eraseToAnyPublisher()
    }

    public func save(tasks: [ErxTask]) -> AnyPublisher<Bool, Error> {
        save(mergePolicy: .mergeByPropertyObjectTrump) { moc in
            _ = tasks.map { [weak self] task in
                let taskEntity = ErxTaskEntity.from(task: task, in: moc)

                let request: NSFetchRequest<ErxTaskMedicationDispenseEntity> = ErxTaskMedicationDispenseEntity
                    .fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(ErxTaskMedicationDispenseEntity.taskId),
                    task.identifier
                )
                taskEntity.medicationDispense = try? request.execute().first
                taskEntity.profile = self?.fetchProfile(in: moc)
            }
        }
    }

    public func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, Error> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false)]
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        let ids = tasks.map(\.id)
        subPredicates.append(NSPredicate(format: "%K in %@", #keyPath(ErxTaskEntity.identifier), ids))
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)

        return delete(resultsOf: request)
    }

    public func redeem(orders _: [ErxTaskOrder]) -> AnyPublisher<Bool, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }
}
