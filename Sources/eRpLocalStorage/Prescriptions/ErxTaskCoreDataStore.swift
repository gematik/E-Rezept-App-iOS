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

import CombineSchedulers
import CoreData
import eRpKit
import Foundation
import GemCommonsKit

// tag::ErxTaskCoreDataStoreDescription[]
/// Store for fetching, creating, updating or deleting `ErxTask`s and it‘s underlying types. Access to most entities is
/// tied to the given profileId.
public class ErxTaskCoreDataStore: CoreDataCrudable, ErxLocalDataStore {
    // end::ErxTaskCoreDataStoreDescription[]

    let coreDataControllerFactory: CoreDataControllerFactory
    let foregroundQueue: AnySchedulerOf<DispatchQueue>
    let backgroundQueue: AnySchedulerOf<DispatchQueue>
    let profileId: UUID?
    let dateProvider: () -> Date

    /// Initialize an ErxTask Core Data Store
    /// - Parameters:
    ///   - profileId: Identifier of the `Profile` for which the api calls should filter.
    ///     `nil` if it should not be filtering by `Profile`
    ///   - coreDataControllerFactory: Factory that is capable of returning a CoreDataController instance
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///     other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "erx-task-data-source-queue", qos: .userInitiated))
    public init(
        profileId: UUID?,
        coreDataControllerFactory: CoreDataControllerFactory,
        foregroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "erx-task-data-source-queue",
                                                                       qos: .userInitiated).eraseToAnyScheduler(),
        dateProvider: @escaping () -> Date = { Date() }
    ) {
        self.profileId = profileId
        self.coreDataControllerFactory = coreDataControllerFactory
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
        self.dateProvider = dateProvider
    }

    func fetchProfile(in context: NSManagedObjectContext) -> ProfileEntity? {
        guard let identifier = profileId else { return nil }
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [#keyPath(ProfileEntity.identifier),
                            identifier]
        )
        var results: [ProfileEntity] = []
        do {
            results = try context.fetch(request)
        } catch {
            DLog("Error loading profile entity")
        }

        guard let result = results.first else { return nil }
        return result
    }
}

extension ErxTaskCoreDataStore {
    /// Initializes an instance of `ErxTaskCoreDataStore`with a failing CoreDataController
    public static let failing = ErxTaskCoreDataStore(
        profileId: nil,
        coreDataControllerFactory: LocalStoreFactory.failing
    )
}
