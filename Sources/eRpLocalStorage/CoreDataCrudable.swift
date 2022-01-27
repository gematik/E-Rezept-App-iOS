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

protocol CoreDataCrudable {
    /// Dispatch queue used for fetch operations
    var foregroundQueue: DispatchQueue { get }
    /// Dispatch queue used for create, update and delete operations
    var backgroundQueue: DispatchQueue { get }
    /// Factory that provides the underlying CoreDataController with a NSPersistentContainer
    var coreDataControllerFactory: CoreDataControllerFactory { get }

    /// Saves all NSManagedObjects that have been created or updated on the passed NSManagedObjectContext
    /// and retunes the success or failure state of the operation in a publisher
    /// - Parameters:
    ///   - mergePolicy: The merge policy to use during save
    ///   - context: Closure that provides a  background context which can be used to do the work
    func save(
        mergePolicy: NSMergePolicy,
        in context: @escaping (NSManagedObjectContext) -> Void
    ) -> AnyPublisher<Bool, CoreDataStoreError>

    /// Deletes all results of the passed NSFetchRequest on a background context
    /// and returns the success or failure state of the operation in a publisher
    /// - Parameter fetchRequest: NSFetchRequest of the entities that should be deleted
    func delete<Entity: NSManagedObject>(
        resultsOf fetchRequest: NSFetchRequest<Entity>
    ) -> AnyPublisher<Bool, CoreDataStoreError>

    /// Executes the passed NSFetchRequest on the `viewContext` and returns the results in a publisher
    /// - Parameter request: NSFetchRequest for the entities to fetch
    func fetch<Entity: NSManagedObject>(
        _ request: NSFetchRequest<Entity>
    ) -> AnyPublisher<[Entity], CoreDataStoreError>
}

extension CoreDataCrudable {
    typealias Error = CoreDataStoreError
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
        in context: @escaping (NSManagedObjectContext) -> Void
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
                    context(moc)
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

public enum CoreDataStoreError: Swift.Error, LocalizedError, Equatable {
    case notImplemented
    case initialization(error: Swift.Error)
    case write(error: Swift.Error)
    case delete(error: Swift.Error)
    case read(error: Swift.Error)

    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "missing interface implementation"
        case let .initialization(error: error):
            return error.localizedDescription
        case let .write(error: error):
            return error.localizedDescription
        case let .delete(error: error):
            return error.localizedDescription
        case let .read(error: error):
            return error.localizedDescription
        }
    }

    public static func ==(lhs: CoreDataStoreError, rhs: CoreDataStoreError) -> Bool {
        switch (lhs, rhs) {
        case (notImplemented, notImplemented): return true
        case let (initialization(error: lhsError), initialization(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (write(error: lhsError), write(error: rhsError)): return lhsError.localizedDescription == rhsError
            .localizedDescription
        case let (delete(error: lhsError), delete(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (read(error: lhsError), read(error: rhsError)): return lhsError.localizedDescription == rhsError
            .localizedDescription
        default: return false
        }
    }
}
