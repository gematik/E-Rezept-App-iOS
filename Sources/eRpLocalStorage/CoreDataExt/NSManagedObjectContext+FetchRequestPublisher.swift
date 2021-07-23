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
import Foundation

extension NSManagedObjectContext {
    /// Combine Publisher for ManagerObjectContext that can be used without SwiftUI View
    /// This class wraps a Custom Publisher around a NSFetchedResultsController to keep itself
    /// and downstream Subscription updated on changes on the NSFetchRequest in the given NSManagedObjectContext.
    struct FetchRequestPublisher<Entity: NSManagedObject>: Publisher {
        typealias Output = [Entity]
        typealias Failure = Error
        private let fetchRequest: NSFetchRequest<Entity>
        private let moc: NSManagedObjectContext

        init(fetchRequest: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
            self.fetchRequest = fetchRequest
            moc = context
        }

        func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Self.Failure == S.Failure {
            subscriber.receive(subscription: ActualSubscription(
                downstream: subscriber,
                fetchRequest: fetchRequest,
                context: moc
            ))
        }
    }
}

extension NSManagedObjectContext.FetchRequestPublisher {
    private final class ActualSubscription<Downstream: Subscriber>: NSObject, Subscription,
        NSFetchedResultsControllerDelegate where Downstream.Input == [Entity], Downstream.Failure == Error {
        private let downstream: Downstream
        private var fetchedResultsController: NSFetchedResultsController<Entity>?

        init(downstream: Downstream, fetchRequest: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
            self.downstream = downstream
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            fetchedResultsController?.delegate = self
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                downstream.receive(completion: .failure(error))
                cancel()
            }
        }

        deinit {
            fetchedResultsController?.delegate = nil
        }

        /// PRAGMA MARK: Combine Subscription

        private var demand: Subscribers.Demand = .none

        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
            fulfillDemand()
        }

        func cancel() {
            demand = .none
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
        }

        /// PRAGMA MARK: NSFetchedResultsControllerDelegate

        func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
            fulfillDemand()
        }

        private func fulfillDemand() {
            // fulfill when demand > 0
            if demand > 0 {
                // delete current demand
                demand -= 1
                let fetchedObjects = fetchedResultsController?.fetchedObjects ?? []
                // `moreDemand` is the downstream's way of letting us know, how many *more* than the initial demand
                // it wishes to receive after this fulfilment.
                let moreDemand = downstream.receive(fetchedObjects)
                // addition before subtraction so we don't inadvertently go below demand threshold
                demand += moreDemand
            }
        }
    }
}
