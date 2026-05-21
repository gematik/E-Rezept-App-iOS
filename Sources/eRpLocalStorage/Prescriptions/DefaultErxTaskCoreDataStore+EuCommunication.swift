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

/// ErxDeviceRequest.EuAccessCode related local store interfaces
extension DefaultErxTaskCoreDataStore {
    /// Creates or updates the passes sequence of `EuCommunication`s
    /// - Parameter euCommunications: Array of `EuCommunication`s  that should be stored
    /// - Parameter profileId: The profile identifier to which the item belongs to or nil if all data should be
    /// considered
    /// - Returns: `true` if save operation was successful
    public func save(euCommunications: [EuCommunication],
                     profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        coreDataCrudable.save(mergePolicy: .error) { moc in
            _ = euCommunications.map { [weak self] euCommunication -> EuCommunicationEntity? in
                let request: NSFetchRequest<EuCommunicationEntity> = EuCommunicationEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    argumentArray: [#keyPath(EuCommunicationEntity.identifier), euCommunication.id]
                )

                if let euCommunicationEntity = try? moc.fetch(request).first {
                    euCommunicationEntity.update(
                        with: euCommunication,
                        euAccessCodeEntity: EuAccessCodeEntity(
                            euAccessCode: euCommunication.euAccessCode,
                            in: moc
                        ),
                        profileEntity: euCommunicationEntity.profile,
                        in: moc
                    )
                    return euCommunicationEntity
                } else {
                    let newEuCommunicationEntity = EuCommunicationEntity(
                        euCommunication: euCommunication,
                        in: moc
                    )
                    newEuCommunicationEntity.profile = self?.fetchProfile(profileId, in: moc)
                    return newEuCommunicationEntity
                }
            }
        }
    }

    /// List all `EuCommunication`s contained in the store
    /// - Parameter countryCode: String of countryCode that should be filtered
    /// - Parameter profileId: The profile identifier to which the item belongs to or nil if all data should be
    /// considered
    /// - Returns: sequence of `EuCommunication`s
    public func listAllEuCommunication(countryCode: String?,
                                       profileId: UUID?) -> AnyPublisher<[EuCommunication], LocalStoreError> {
        let request: NSFetchRequest<EuCommunicationEntity> = EuCommunicationEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(EuCommunicationEntity.timestamp),
                                                    ascending: false)]
        var subPredicates = [NSPredicate]()

        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(EuCommunicationEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        if let countryCode {
            let countryPredicate = NSPredicate(
                format: "(%K == %@) OR (%K == %@)",
                argumentArray: [
                    #keyPath(EuCommunicationEntity.euAccessCode.countryCode),
                    countryCode,
                    #keyPath(EuCommunicationEntity.countryCode),
                    countryCode,
                ]
            )
            subPredicates.append(countryPredicate)
        }
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)

        return coreDataCrudable.fetch(request)
            .map { list in list.compactMap { EuCommunication(entity: $0) } }
            .eraseToAnyPublisher()
    }

    /// Returns latest `EuCommunication`  with an accessCode contained in the store
    /// - Parameter profileId: The profile identifier to which the item belongs to or nil if all data should be
    /// considered
    /// - Returns: `EuCommunication` if save operation was successful
    public func loadLatestActiveEuCommunication(profileId: UUID?)
        -> AnyPublisher<EuCommunication?, LocalStoreError> {
        let request: NSFetchRequest<EuCommunicationEntity> = EuCommunicationEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(EuCommunicationEntity.timestamp),
                                                    ascending: false)]
        var subPredicates = [NSPredicate]()

        subPredicates.append(NSPredicate(
            format: "%K != nil",
            argumentArray: [#keyPath(EuCommunicationEntity.euAccessCode.accessCode)]
        ))

        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(EuCommunicationEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)

        return coreDataCrudable.fetch(request)
            .map { EuCommunication(entity: $0.first) }
            .eraseToAnyPublisher()
    }

    /// Deletes sequence of `EuCommunication`s from parameter
    /// - Parameter euCommunications: Array of `EuCommunication`s  that should be deleted
    /// - Parameter profileId: The profile identifier to which the item belongs to or nil if all data should be
    /// considered
    /// - Returns: `true` if save operation was successful
    public func delete(euCommunications: [EuCommunication], profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        let request: NSFetchRequest<EuCommunicationEntity> = EuCommunicationEntity.fetchRequest()
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(EuCommunicationEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        let ids = euCommunications.map(\.id)
        subPredicates.append(NSPredicate(format: "%K in %@", #keyPath(EuCommunicationEntity.identifier), ids))
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)

        return coreDataCrudable.delete(resultsOf: request)
    }
}
