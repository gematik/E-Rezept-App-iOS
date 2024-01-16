//
//  Copyright (c) 2024 gematik GmbH
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

/// MedicationDispense related local store interfaces
extension DefaultErxTaskCoreDataStore {
    /// List all medication dispenses contained in the store
    public func listAllMedicationDispenses() -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        let request: NSFetchRequest<ErxTaskMedicationDispenseEntity> = ErxTaskMedicationDispenseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            key: #keyPath(ErxTaskMedicationDispenseEntity.whenHandedOver),
            ascending: false
        )]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskMedicationDispenseEntity.task.profile.identifier), identifier]
            )
        }
        return coreDataCrudable.fetch(request)
            .map { list in list.compactMap(ErxMedicationDispense.init) }
            .eraseToAnyPublisher()
    }

    /// Creates or updates the passed sequence of `ErxTask.MedicationDispense`s
    /// - Parameter medicationDispenses: Array of medication dispenses that should be stored
    /// - Returns: `true` if save operation was successful
    public func save(medicationDispenses: [ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError> {
        coreDataCrudable.save(mergePolicy: .mergeByPropertyObjectTrump) { moc in
            _ = medicationDispenses.map { medicationDispense -> ErxTaskMedicationDispenseEntity in
                let medicationDispenseEntity = ErxTaskMedicationDispenseEntity.from(
                    medicationDispense: medicationDispense,
                    in: moc
                )
                return medicationDispenseEntity
            }
        }
    }
}
