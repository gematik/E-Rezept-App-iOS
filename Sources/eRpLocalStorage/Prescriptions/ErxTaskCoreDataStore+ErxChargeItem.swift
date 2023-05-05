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
import CoreData
import eRpKit

/// ChargeItems related local store interfaces
extension ErxTaskCoreDataStore {
    /// Fetch the ErxChargeItem by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxChargeItem ID
    ///   - fullDetail: if set to true, fetches all available information
    ///   otherwise only a minimal version
    /// - Returns: Publisher for the fetch request
    public func fetchChargeItem(
        by chargeItemID: ErxChargeItem.ID,
        fullDetail: Bool
    ) -> AnyPublisher<ErxChargeItem?, LocalStoreError> {
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
        return fetch(request)
            .tryMap { results in
                guard let chargeItem = results.first else {
                    return nil
                }
                let item = ErxChargeItem(entity: chargeItem)
                if fullDetail {
                    return try item?.parseFullItemDetails()
                } else {
                    return item
                }
            }
            .mapError(LocalStoreError.read(error:))
            .eraseToAnyPublisher()
    }

    /// Fetch the most recent `enteredDate` of all `ChargeItem`s
    public func fetchLatestTimestampForChargeItems() -> AnyPublisher<String?, LocalStoreError> {
        let request: NSFetchRequest<ErxChargeItemEntity> = ErxChargeItemEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxChargeItemEntity.enteredDate), ascending: false)]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxChargeItemEntity.profile.identifier), identifier]
            )
        }
        return fetch(request)
            .map { $0.first?.enteredDate }
            .eraseToAnyPublisher()
    }

    /// List all charge items with the given local contained in the store
    /// - Returns: Array of the fetched charge items or error
    public func listAllChargeItems(
    ) -> AnyPublisher<[ErxChargeItem], LocalStoreError> {
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
        return fetch(request)
            .map { list in list.compactMap { ErxChargeItem(entity: $0) }}
            .eraseToAnyPublisher()
    }

    /// Creates or updates the passed sequence of `ErxChargeItem`s
    /// - Parameter chargeItems: Array of charge items that should be stored
    /// - Returns: `true` if save operation was successful
    public func save(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        save(mergePolicy: .mergeByPropertyObjectTrump) { moc in
            _ = chargeItems.map { [weak self] chargeItem -> ErxChargeItemEntity? in
                let chargeItemsEntity = ErxChargeItemEntity.from(
                    chargeItem: chargeItem,
                    in: moc
                )
                chargeItemsEntity?.profile = self?.fetchProfile(in: moc)
                return chargeItemsEntity
            }
        }
    }
}
