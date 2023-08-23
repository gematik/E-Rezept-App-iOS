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

import Combine
import CombineSchedulers
import CoreData
import eRpKit

/// Store for fetching, creating, updating or deleting `PharmacyLocation`s on the provided `CoreDataController`
/// [REQ:BSI-eRp-ePA:O.Source_2#2] CoreDataStore adapter for `PharmacyLocation`s
public class PharmacyCoreDataStore: PharmacyLocalDataStore, CoreDataCrudable {
    let coreDataControllerFactory: CoreDataControllerFactory
    let foregroundQueue: AnySchedulerOf<DispatchQueue>
    let backgroundQueue: AnySchedulerOf<DispatchQueue>

    /// Initialize a Pharmacy Core Data Store
    /// - Parameters:
    ///   - coreDataControllerFactory: Factory that is capable of providing a CoreDataController
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///     other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "pharmacy-queue", qos: .userInitiated))
    public init(
        coreDataControllerFactory: CoreDataControllerFactory,
        foregroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "pharmacy-queue", qos: .userInitiated)
            .eraseToAnyScheduler()
    ) {
        self.coreDataControllerFactory = coreDataControllerFactory
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
    }

    public func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        let request: NSFetchRequest<PharmacyEntity> = PharmacyEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [#keyPath(PharmacyEntity.telematikId), telematikId]
        )
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PharmacyEntity.name), ascending: false)]

        return fetch(request)
            .map { results in
                guard let entity = results.first else {
                    return nil
                }
                if results.count > 1 {
                    assertionFailure("error: there should always be just one pharmacy per telematik id in store")
                }
                return PharmacyLocation(entity: entity)
            }
            .eraseToAnyPublisher()
    }

    public func listPharmacies(count: Int? = nil) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        let request: NSFetchRequest<PharmacyEntity> = PharmacyEntity.fetchRequest()
        if let fetchLimit = count {
            request.fetchLimit = fetchLimit
        }
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(PharmacyEntity.isFavorite), ascending: false),
            NSSortDescriptor(key: #keyPath(PharmacyEntity.lastUsed), ascending: false),
            NSSortDescriptor(key: #keyPath(PharmacyEntity.created), ascending: false),
        ]

        return fetch(request)
            .map { list in list.compactMap(PharmacyLocation.init) }
            .eraseToAnyPublisher()
    }

    public func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        save(mergePolicy: NSMergePolicy.error) { moc in
            _ = pharmacies.map { pharmacy -> PharmacyEntity in
                let request: NSFetchRequest<PharmacyEntity> = PharmacyEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    argumentArray: [#keyPath(PharmacyEntity.identifier), pharmacy.id]
                )

                if let pharmacyEntity = try? moc.fetch(request).first {
                    pharmacyEntity.telematikId = pharmacy.telematikID
                    pharmacyEntity.name = pharmacy.name
                    pharmacyEntity.email = pharmacy.telecom?.email
                    pharmacyEntity.phone = pharmacy.telecom?.phone
                    pharmacyEntity.fax = pharmacy.telecom?.fax
                    pharmacyEntity.web = pharmacy.telecom?.web
                    pharmacyEntity.latitude = pharmacy.position?.latitude as? NSDecimalNumber
                    pharmacyEntity.longitude = pharmacy.position?.longitude as? NSDecimalNumber
                    pharmacyEntity.lastUsed = pharmacy.lastUsed
                    pharmacyEntity.street = pharmacy.address?.street
                    pharmacyEntity.zip = pharmacy.address?.zip
                    pharmacyEntity.houseNumber = pharmacy.address?.houseNumber
                    pharmacyEntity.city = pharmacy.address?.city
                    pharmacyEntity.isFavorite = pharmacy.isFavorite
                    pharmacyEntity.imagePath = pharmacy.imagePath
                    pharmacyEntity.countUsage = Int32(pharmacy.countUsage)
                    return pharmacyEntity
                } else {
                    return PharmacyEntity.from(pharmacyLocation: pharmacy, in: moc)
                }
            }
        }
    }

    public func update(telematikId: String,
                       mutating: @escaping (inout PharmacyLocation) -> Void)
        -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        save(mergePolicy: NSMergePolicy.error) { moc in
            let request: NSFetchRequest<PharmacyEntity> = PharmacyEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(PharmacyEntity.telematikId), telematikId]
            )

            guard let pharmacyEntity = try? moc.fetch(request).first,
                  var pharmacy = PharmacyLocation(entity: pharmacyEntity) else {
                throw LocalStoreError.read(error: Error.noMatchingEntity)
            }
            mutating(&pharmacy)
            pharmacyEntity.telematikId = pharmacy.telematikID
            pharmacyEntity.name = pharmacy.name
            pharmacyEntity.email = pharmacy.telecom?.email
            pharmacyEntity.phone = pharmacy.telecom?.phone
            pharmacyEntity.fax = pharmacy.telecom?.fax
            pharmacyEntity.web = pharmacy.telecom?.web
            pharmacyEntity.latitude = pharmacy.position?.latitude as? NSDecimalNumber
            pharmacyEntity.longitude = pharmacy.position?.longitude as? NSDecimalNumber
            pharmacyEntity.lastUsed = pharmacy.lastUsed
            pharmacyEntity.street = pharmacy.address?.street
            pharmacyEntity.zip = pharmacy.address?.zip
            pharmacyEntity.houseNumber = pharmacy.address?.houseNumber
            pharmacyEntity.city = pharmacy.address?.city
            pharmacyEntity.isFavorite = pharmacy.isFavorite
            pharmacyEntity.imagePath = pharmacy.imagePath
            pharmacyEntity.countUsage = Int32(pharmacy.countUsage)
            return pharmacy
        }
    }

    public func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        let request: NSFetchRequest<PharmacyEntity> = PharmacyEntity.fetchRequest()
        let ids = pharmacies.map(\.telematikID)
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(PharmacyEntity.telematikId), ids)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PharmacyEntity.name), ascending: false)]
        return delete(resultsOf: request)
    }

    // sourcery: CodedError = "505"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case noMatchingEntity
    }
}
