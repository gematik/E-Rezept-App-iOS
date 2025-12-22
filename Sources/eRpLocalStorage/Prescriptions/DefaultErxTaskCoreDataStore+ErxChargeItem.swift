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
import eRpKit

/// ChargeItems related local store interfaces
extension DefaultErxTaskCoreDataStore {
    /// Fetch the ErxChargeItem by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - profileId: The profile identifier to which the item belongs to or nil if all data should be considered
    ///   - id: the ErxChargeItem ID
    /// - Returns: Publisher for the fetch request
    public func fetchChargeItem(
        of profileId: UUID?,
        by chargeItemID: ErxChargeItem.ID
    ) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        let request: NSFetchRequest<ErxChargeItemEntity> = ErxChargeItemEntity.fetchRequest()
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxChargeItemEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(ErxChargeItemEntity.identifier), chargeItemID)
        subPredicates.append(idPredicate)
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxChargeItemEntity.enteredDate), ascending: false)]
        return coreDataCrudable.fetch(request)
            .map { results in
                guard let chargeItem = results.first else {
                    return nil
                }
                return ErxSparseChargeItem(entity: chargeItem)
            }
            .mapError(LocalStoreError.read(error:))
            .eraseToAnyPublisher()
    }

    /// Fetch the most recent `enteredDate` of all `ChargeItem`s
    /// - Parameter profileId: The profile identifier to which the item belongs to or nil if all data should be
    /// considered
    /// - Returns: The latest timestamp as `String` or error
    public func fetchLatestTimestampForChargeItems(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        let request: NSFetchRequest<ErxChargeItemEntity> = ErxChargeItemEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxChargeItemEntity.enteredDate), ascending: false)]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxChargeItemEntity.profile.identifier), identifier]
            )
        }
        return coreDataCrudable.fetch(request)
            .map { $0.first?.enteredDate }
            .eraseToAnyPublisher()
    }

    /// List all charge items with the given local contained in the store
    /// - Parameter profileId: The profile identifier to which the item belongs to or nil if all data should be
    /// considered
    /// - Returns: Array of the fetched charge items or error
    public func listAllChargeItems(
        of profileId: UUID?
    ) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        let request: NSFetchRequest<ErxChargeItemEntity> = ErxChargeItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            key: #keyPath(ErxChargeItemEntity.enteredDate),
            ascending: false
        )]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxChargeItemEntity.profile.identifier), identifier]
            )
        }
        return coreDataCrudable.fetch(request)
            .map { list in list.compactMap { ErxSparseChargeItem(entity: $0) }}
            .eraseToAnyPublisher()
    }

    /// Creates or updates the passed sequence of `ErxChargeItem`s
    /// - Parameter chargeItems: Array of charge items that should be stored
    /// - Returns: `true` if save operation was successful
    public func save(chargeItems: [ErxSparseChargeItem], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        coreDataCrudable.save(mergePolicy: .error) { moc in
            _ = chargeItems.map { [weak self] chargeItem -> ErxChargeItemEntity? in
                let request: NSFetchRequest<ErxChargeItemEntity> = ErxChargeItemEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    argumentArray: [#keyPath(ErxChargeItemEntity.identifier), chargeItem.identifier]
                )

                if let chargeItemEntity = try? moc.fetch(request).first {
                    chargeItemEntity.update(with: chargeItem, profileEntity: self?.fetchProfile(profileId, in: moc))
                    return chargeItemEntity
                } else {
                    let chargeItemEntity = ErxChargeItemEntity.from(
                        chargeItem: chargeItem,
                        in: moc
                    )
                    chargeItemEntity?.profile = self?.fetchProfile(profileId, in: moc)
                    return chargeItemEntity
                }
            }
        }
    }

    /// Deletes a sequence of charge items from the store
    /// - Parameter profileId: The profile identifier to which the item belongs to or nil if all data should be
    /// considered
    /// - Parameter chargeItems: Array of charge items that should be deleted
    /// - Returns: `true` if delete operation was successful
    public func delete(
        of profileId: UUID?,
        chargeItems: [ErxSparseChargeItem]
    ) -> AnyPublisher<Bool, LocalStoreError> {
        let request: NSFetchRequest<ErxChargeItemEntity> = ErxChargeItemEntity.fetchRequest()
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxChargeItemEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        let ids = chargeItems.map(\.id)
        subPredicates.append(NSPredicate(format: "%K in %@", #keyPath(ErxChargeItemEntity.identifier), ids))
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)

        return coreDataCrudable.delete(resultsOf: request)
    }
}
