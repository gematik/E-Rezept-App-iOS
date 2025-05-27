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

import CoreData
import eRpKit

extension DiGaInfoEntity {
    static func from(diGaInfo: DiGaInfo,
                     in context: NSManagedObjectContext) -> DiGaInfoEntity? {
        DiGaInfoEntity(info: diGaInfo,
                       in: context)
    }

    convenience init?(info: DiGaInfo?,
                      in context: NSManagedObjectContext) {
        guard let diGaInfo = info else { return nil }

        self.init(context: context)

        state = diGaInfo.diGaState.encoding()
        isRead = diGaInfo.isRead
        refreshDate = diGaInfo.refreshDate
        taskId = diGaInfo.taskId
    }
}

extension DiGaInfo {
    init?(entity: DiGaInfoEntity?,
          decoder: JSONDecoder = JSONDecoder()) {
        guard let entity = entity else { return nil }

        let diGaState = try? decoder.decode(DiGaInfo.DiGaState.self, from: entity.state ?? Data())

        var state: DiGaInfo.DiGaState = diGaState ?? .request
        var erxTaskStatus: ErxTask.Status = .ready
        if let status = entity.deviceRequest?.task?.status {
            erxTaskStatus = ErxTask.Status(rawValue: status) ?? .ready
        }

        // .activate state is set locally and .downloaded is the default state when the task is .inProgress
        switch (erxTaskStatus, state) {
        case (.ready, .insurance):
            state = .insurance
        case (.ready, _):
            state = .request
        case (.inProgress, _):
            state = .insurance
        case (.completed, .request),
             (.completed, .insurance):
            state = .download
        default:
            // maybe error state later
            break
        }

        let medicationDispenses: [ErxMedicationDispense] = entity.deviceRequest?.task?.medicationDispenses?
            .compactMap { medicationDispense in
                if let entity = medicationDispense as? ErxTaskMedicationDispenseEntity {
                    return ErxMedicationDispense(entity: entity)
                } else {
                    return nil
                }
            } ?? []

        if let diGaDispense = medicationDispenses.first?.diGaDispense, diGaDispense.isMissingData, !state.isArchive {
            state = .noInformation
        }

        self.init(diGaState: state,
                  isRead: entity.isRead,
                  refreshDate: entity.refreshDate,
                  taskId: entity.taskId)
    }
}
