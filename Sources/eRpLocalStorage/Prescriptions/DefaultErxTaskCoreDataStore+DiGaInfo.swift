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

/// ErxDeviceRequest.DiGaInfo related local store interfaces
extension DefaultErxTaskCoreDataStore {
    /// Updates a already existing DiGaInfo into the store
    /// - Parameter diGaInfo: new `DiGaInfo` that should be saved
    /// - Returns: A publisher that finishes with `true` on completion or fails with an error.
    public func update(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, LocalStoreError> {
        coreDataCrudable.save(mergePolicy: .mergeByPropertyObjectTrump) { moc in
            let request: NSFetchRequest<DiGaInfoEntity> = DiGaInfoEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(DiGaInfoEntity.taskId),
                diGaInfo.taskId
            )

            if let existingDiGaInfo = try? moc.fetch(request).first {
                existingDiGaInfo.isRead = diGaInfo.isRead
                existingDiGaInfo.state = diGaInfo.diGaState.encoding()
                existingDiGaInfo.refreshDate = diGaInfo.refreshDate
            }
        }
    }
}
