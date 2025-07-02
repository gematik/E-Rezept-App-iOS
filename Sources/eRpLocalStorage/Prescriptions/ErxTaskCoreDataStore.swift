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

import CombineSchedulers
import CoreData
import eRpKit
import Foundation
import OSLog

public protocol ErxTaskCoreDataStore: ErxLocalDataStore {}

// tag::ErxTaskCoreDataStoreDescription[]
/// Store for fetching, creating, updating or deleting `ErxTask`s and it‘s underlying types. Access to most entities is
/// tied to the given profileId.
/// [REQ:BSI-eRp-ePA:O.Source_2#3] CoreDataStore adapter for `ErxTask`s
public class DefaultErxTaskCoreDataStore: ErxTaskCoreDataStore {
    let profileId: UUID?
    let coreDataCrudable: CoreDataCrudable
    let dateProvider: () -> Date
    // end::ErxTaskCoreDataStoreDescription[]

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
        foregroundQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        dateProvider: @escaping () -> Date
    ) {
        self.profileId = profileId
        coreDataCrudable = DefaultCoreDataCrudable(
            foregroundQueue: foregroundQueue,
            backgroundQueue: backgroundQueue,
            coreDataControllerFactory: coreDataControllerFactory
        )
        self.dateProvider = dateProvider
    }

    public convenience init(
        profileId: UUID?,
        coreDataControllerFactory: CoreDataControllerFactory
    ) {
        self.init(
            profileId: profileId,
            coreDataControllerFactory: coreDataControllerFactory,
            foregroundQueue: AnyScheduler.main,
            backgroundQueue: DispatchQueue(
                label: "erx-task-data-source-queue",
                qos: .userInitiated
            ).eraseToAnyScheduler()
        ) { Date() }
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
            Logger.eRpLocalStorage.debug("Error loading profile entity")
        }

        guard let result = results.first else { return nil }
        return result
    }
}

extension DefaultErxTaskCoreDataStore {
    /// Initializes an instance of `ErxTaskCoreDataStore`with a failing CoreDataController
    public static let failing = DefaultErxTaskCoreDataStore(
        profileId: nil,
        coreDataControllerFactory: LocalStoreFactory.failing
    )
}
