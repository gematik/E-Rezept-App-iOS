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

/// Store for fetching, creating, updating or deleting `AVSTransactionEntity`s on the provided `CoreDataController`
public class AVSTransactionCoreDataStore: AVSTransactionDataStore, CoreDataCrudable {
    let coreDataControllerFactory: CoreDataControllerFactory
    let foregroundQueue: AnySchedulerOf<DispatchQueue>
    let backgroundQueue: AnySchedulerOf<DispatchQueue>

    /// Initialize a AVSTransaction Core Data Store
    /// - Parameters:
    ///   - coreDataControllerFactory: Factory that is capable of providing a CoreDataController
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///     other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "profile-queue", qos: .userInitiated))
    public init(
        coreDataControllerFactory: CoreDataControllerFactory,
        foregroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "avsTransaction-queue",
                                                                       qos: .userInitiated)
            .eraseToAnyScheduler()
    ) {
        self.coreDataControllerFactory = coreDataControllerFactory
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
    }

    public func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        let request: NSFetchRequest<AVSTransactionEntity> = AVSTransactionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [#keyPath(AVSTransactionEntity.transactionID), identifier]
        )
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(AVSTransactionEntity.transactionID), ascending: true)]
        return fetch(request)
            .map { results in
                guard let avsTransactionEntity = results.first else {
                    return nil
                }
                if results.count > 1 {
                    assertionFailure("error: there should always be just one AVSTransaction per id in store")
                }
                return AVSTransaction(entity: avsTransactionEntity)
            }
            .eraseToAnyPublisher()
    }

    public func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        let request: NSFetchRequest<AVSTransactionEntity> = AVSTransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(AVSTransactionEntity.transactionID), ascending: true)]

        return fetch(request)
            .map { list in list.compactMap(AVSTransaction.init) }
            .eraseToAnyPublisher()
    }

    public func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        save(mergePolicy: NSMergePolicy.mergeByPropertyObjectTrump) { moc in
            for avsTransaction in avsTransactions {
                let transaction = AVSTransactionEntity.from(avsTransaction: avsTransaction, in: moc)

                let request = ErxTaskEntity.fetchRequest()
                guard let taskId = avsTransaction.taskId else { return }
                request.predicate = .init(format: "%K == %@", #keyPath(ErxTaskEntity.identifier), taskId)

                let result = try moc.fetch(request)

                guard let task = result.first else { continue }
                transaction.erxTask = task
            }
        }
        .map { _ in avsTransactions }
        .eraseToAnyPublisher()
    }

    public func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        let request: NSFetchRequest<AVSTransactionEntity> = AVSTransactionEntity.fetchRequest()
        let ids = avsTransactions.map(\.transactionID)
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(AVSTransactionEntity.transactionID), ids)
        return delete(resultsOf: request)
            .map { _ in avsTransactions }
            .eraseToAnyPublisher()
    }

    public enum Error: Swift.Error {
        case noMatchingEntity
        case internalError
    }
}
