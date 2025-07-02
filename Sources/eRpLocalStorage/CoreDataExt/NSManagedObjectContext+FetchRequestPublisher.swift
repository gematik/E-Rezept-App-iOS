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

import Combine
import CoreData
import Foundation

extension NSManagedObjectContext {
    /// Combine Publisher for ManagerObjectContext that can be used without SwiftUI View
    /// This class wraps a Custom Publisher around a NSFetchedResultsController to keep itself
    /// and downstream Subscription updated on changes on the NSFetchRequest in the given NSManagedObjectContext.
    struct FetchRequestPublisher<Entity: NSManagedObject> {
        private let fetchRequest: NSFetchRequest<Entity>
        private let managedObjectContext: NSManagedObjectContext

        init(fetchRequest: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
            self.fetchRequest = fetchRequest
            managedObjectContext = context
        }
    }
}

extension NSManagedObjectContext.FetchRequestPublisher: Publisher {
    typealias Output = [Entity]
    typealias Failure = Error

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Inner<S>(
            fetchRequest: fetchRequest,
            context: managedObjectContext,
            subscriber: subscriber
        )
        subscriber.receive(subscription: subscription)
    }
}

extension NSManagedObjectContext.FetchRequestPublisher {
    private class Inner<Downstream: Subscriber>: NSObject, Subscription, NSFetchedResultsControllerDelegate
        where Downstream.Input == Output, Downstream.Failure == Failure {
        typealias Input = Downstream.Input
        typealias Failure = Downstream.Failure

        private var fetchedResultsController: NSFetchedResultsController<Entity>?

        private var demand: Subscribers.Demand
        private var last: Input?
        private var downstream: Downstream?

        private let lock = NSLock()
        // This lock can only be held for the duration of downstream callouts
        private let downstreamLock = NSRecursiveLock()

        init(
            fetchRequest: NSFetchRequest<Entity>,
            context: NSManagedObjectContext,
            subscriber: Downstream
        ) {
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            downstream = subscriber
            demand = .max(0)
            super.init()
            fetchedResultsController?.delegate = self
            do {
                try fetchedResultsController?.performFetch()
                last = fetchedResultsController?.fetchedObjects ?? []
            } catch {
                downstream?.receive(completion: .failure(error))
                cancel()
            }
        }

        deinit {
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
        }

        func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
            let fetchedObjects = fetchedResultsController?.fetchedObjects ?? []
            guard let downstream = self.downstream else { return }
            lock.lock()
            if demand > 0 {
                demand -= 1
                lock.unlock()

                downstreamLock.lock()
                let additional = downstream.receive(fetchedObjects)
                downstreamLock.unlock()

                lock.lock()
                demand += additional
                lock.unlock()
            } else {
                // Store updated value for a later request
                last = fetchedObjects
                lock.unlock()
            }
        }

        func request(_ requestDemand: Subscribers.Demand) {
            guard let downstream = self.downstream else { return }
            lock.lock()
            demand += requestDemand
            if demand > 0, let lastFetchedObjects = last {
                demand -= 1
                last = nil
                lock.unlock()

                downstreamLock.lock()
                let additional = downstream.receive(lastFetchedObjects)
                downstreamLock.unlock()

                lock.lock()
                demand += additional
                lock.unlock()
            } else {
                demand -= 1
                last = nil
                lock.unlock()
            }
        }

        func cancel() {
            demand = .none
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
            last = nil
            downstream = nil
        }
    }
}
