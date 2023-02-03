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

/// Store for fetching, creating, updating or deleting `ShipmentInfoEntity`s on the provided `CoreDataController`
public class ShipmentInfoCoreDataStore: ShipmentInfoDataStore, CoreDataCrudable {
    private let userDefaults: UserDefaults
    let coreDataControllerFactory: CoreDataControllerFactory
    let foregroundQueue: AnySchedulerOf<DispatchQueue>
    let backgroundQueue: AnySchedulerOf<DispatchQueue>

    /// Initialize a ShipmentInfo Core Data Store
    /// - Parameters:
    ///   - coreDataControllerFactory: Factory that is capable of providing a CoreDataController
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///     other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "profile-queue", qos: .userInitiated))
    public init(
        userDefaults: UserDefaults = UserDefaults.standard,
        coreDataControllerFactory: CoreDataControllerFactory,
        foregroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "shipmentInfo-queue", qos: .userInitiated)
            .eraseToAnyScheduler()
    ) {
        self.userDefaults = userDefaults
        self.coreDataControllerFactory = coreDataControllerFactory
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
    }

    public func fetchShipmentInfo(by identifier: UUID) -> AnyPublisher<ShipmentInfo?, LocalStoreError> {
        let request: NSFetchRequest<ShipmentInfoEntity> = ShipmentInfoEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [#keyPath(ShipmentInfoEntity.identifier), identifier]
        )
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ShipmentInfoEntity.name), ascending: true)]
        return fetch(request)
            .map { results in
                guard let shipmentInfoEntity = results.first else {
                    return nil
                }
                if results.count > 1 {
                    assertionFailure("error: there should always be just one ShipmentInfo per id in store")
                }
                return ShipmentInfo(entity: shipmentInfoEntity)
            }
            .eraseToAnyPublisher()
    }

    public func set(selectedShipmentInfoId: UUID) {
        userDefaults.selectedShipmentInfoId = selectedShipmentInfoId
    }

    public var selectedShipmentInfo: AnyPublisher<ShipmentInfo?, LocalStoreError> {
        userDefaults.publisher(for: \UserDefaults.selectedShipmentInfoId)
            .setFailureType(to: LocalStoreError.self)
            .flatMap { [weak self] selectedShipmentId -> AnyPublisher<ShipmentInfo?, LocalStoreError> in
                guard let self = self,
                      let identifier = selectedShipmentId else {
                    return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
                }
                return self.fetchShipmentInfo(by: identifier)
            }
            .eraseToAnyPublisher()
    }

    public func listAllShipmentInfos() -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        let request: NSFetchRequest<ShipmentInfoEntity> = ShipmentInfoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ShipmentInfoEntity.name), ascending: true)]

        return fetch(request)
            .map { list in list.compactMap(ShipmentInfo.init) }
            .eraseToAnyPublisher()
    }

    public func save(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        save(mergePolicy: NSMergePolicy.mergeByPropertyObjectTrump) { moc in
            for shipmentInfo in shipmentInfos {
                _ = ShipmentInfoEntity.from(shipmentInfo: shipmentInfo, in: moc)
            }
        }
        .map { _ in shipmentInfos }
        .eraseToAnyPublisher()
    }

    public func delete(shipmentInfos: [ShipmentInfo]) -> AnyPublisher<[ShipmentInfo], LocalStoreError> {
        let request: NSFetchRequest<ShipmentInfoEntity> = ShipmentInfoEntity.fetchRequest()
        let ids = shipmentInfos.map(\.identifier)
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(ShipmentInfoEntity.identifier), ids)
        return delete(resultsOf: request)
            .map { _ in shipmentInfos }
            .eraseToAnyPublisher()
    }

    public func update(
        identifier: UUID,
        mutating: @escaping (inout ShipmentInfo) -> Void
    ) -> AnyPublisher<ShipmentInfo, LocalStoreError> {
        var updatedShipmentInfo: ShipmentInfo?
        return save(mergePolicy: NSMergePolicy.error) { moc in
            let request: NSFetchRequest<ShipmentInfoEntity> = ShipmentInfoEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ShipmentInfoEntity.identifier), identifier]
            )

            if let entity = try? moc.fetch(request).first,
               var shipmentInfo = ShipmentInfo(entity: entity) {
                mutating(&shipmentInfo)
                entity.name = shipmentInfo.name
                entity.street = shipmentInfo.street
                entity.zip = shipmentInfo.zip
                entity.city = shipmentInfo.city
                entity.phone = shipmentInfo.phone
                entity.mail = shipmentInfo.mail
                updatedShipmentInfo = shipmentInfo
            } else {
                throw Error.noMatchingEntity
            }
        }
        .tryMap { _ in
            guard let updatedInfo = updatedShipmentInfo else {
                throw Error.internalError
            }
            return updatedInfo
        }
        .mapError(LocalStoreError.write)
        .eraseToAnyPublisher()
    }

    // sourcery: CodedError = "504"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case noMatchingEntity
        // sourcery: errorCode = "02"
        case internalError
    }
}

extension UserDefaults {
    /// Stores the identifier of the selected `ShipmentInfo`
    public static let kSelectedShipmentInfoId = "kSelectedShipmentInfoId"

    /// Stores for the selected `ShipmentInfo` identifier
    @objc public var selectedShipmentInfoId: UUID? {
        get {
            guard let uuidString = string(forKey: Self.kSelectedShipmentInfoId) else {
                return nil
            }
            return UUID(uuidString: uuidString)
        }
        set { set(newValue?.uuidString, forKey: Self.kSelectedShipmentInfoId) }
    }
}
