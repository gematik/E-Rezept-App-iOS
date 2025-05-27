//
//  Copyright (c) 2025 gematik GmbH
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
