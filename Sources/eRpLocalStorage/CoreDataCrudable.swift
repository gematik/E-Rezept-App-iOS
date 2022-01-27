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
import CombineSchedulers
import CoreData
import eRpKit

protocol CoreDataCrudable {
    /// Dispatch queue used for fetch operations
    var foregroundQueue: AnySchedulerOf<DispatchQueue> { get }
    /// Dispatch queue used for create, update and delete operations
    var backgroundQueue: AnySchedulerOf<DispatchQueue> { get }
    /// Factory that provides the underlying CoreDataController with a NSPersistentContainer
    var coreDataControllerFactory: CoreDataControllerFactory { get }

    /// Saves all NSManagedObjects that have been created or updated on the passed NSManagedObjectContext
    /// and retunes the success or failure state of the operation in a publisher
    /// - Parameters:
    ///   - mergePolicy: The merge policy to use during save
    ///   - context: Closure that provides a  background context which can be used to do the work
    func save(
        mergePolicy: NSMergePolicy,
        in context: @escaping (NSManagedObjectContext) throws -> Void
    ) -> AnyPublisher<Bool, LocalStoreError>

    /// Deletes all results of the passed NSFetchRequest on a background context
    /// and returns the success or failure state of the operation in a publisher
    /// - Parameter fetchRequest: NSFetchRequest of the entities that should be deleted
    func delete<Entity: NSManagedObject>(
        resultsOf fetchRequest: NSFetchRequest<Entity>
    ) -> AnyPublisher<Bool, LocalStoreError>

    /// Executes the passed NSFetchRequest on the `viewContext` and returns the results in a publisher
    /// - Parameter request: NSFetchRequest for the entities to fetch
    func fetch<Entity: NSManagedObject>(
        _ request: NSFetchRequest<Entity>
    ) -> AnyPublisher<[Entity], LocalStoreError>
}

extension CoreDataCrudable {
    typealias Error = LocalStoreError
    func fetch<Entity: NSManagedObject>(_ request: NSFetchRequest<Entity>) -> AnyPublisher<[Entity], Error> {
        let viewContext: NSManagedObjectContext
        do {
            let coreData = try coreDataControllerFactory.loadCoreDataController()
            viewContext = coreData.container.viewContext
        } catch {
            return Fail(error: Error.initialization(error: error)).eraseToAnyPublisher()
        }
        return viewContext
            .publisher(for: request)
            .subscribe(on: foregroundQueue)
            .mapError(Error.read)
            .eraseToAnyPublisher()
    }

    func save(
        mergePolicy: NSMergePolicy,
        in context: @escaping (NSManagedObjectContext) throws -> Void
    ) -> AnyPublisher<Bool, Error> {
        let coreData: CoreDataController
        do {
            coreData = try coreDataControllerFactory.loadCoreDataController()
        } catch {
            return Fail(error: Error.initialization(error: error)).eraseToAnyPublisher()
        }

        return Deferred {
            Future { promise in
                let moc = coreData.container.newBackgroundContext()
                moc.mergePolicy = mergePolicy
                moc.performAndWait {
                    do {
                        try context(moc)
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

    func delete<Entity: NSManagedObject>(resultsOf fetchRequest: NSFetchRequest<Entity>) -> AnyPublisher<Bool, Error> {
        let coreData: CoreDataController
        do {
            coreData = try coreDataControllerFactory.loadCoreDataController()
        } catch {
            return Fail(error: Error.initialization(error: error)).eraseToAnyPublisher()
        }

        return Deferred {
            Future { promise in
                let moc = coreData.container.newBackgroundContext()
                moc.performAndWait {
                    do {
                        let entities = try moc.fetch(fetchRequest)
                        for entity in entities {
                            moc.delete(entity)
                        }
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
        .mapError(Error.delete)
        .eraseToAnyPublisher()
    }
}
