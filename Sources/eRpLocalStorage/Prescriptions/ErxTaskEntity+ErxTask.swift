//
//  Copyright (c) 2022 gematik GmbH
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

extension ErxTaskEntity {
    static func from(task: ErxTask,
                     in context: NSManagedObjectContext) -> ErxTaskEntity {
        ErxTaskEntity(task: task,
                      in: context)
    }

    convenience init(task: ErxTask, in context: NSManagedObjectContext) {
        self.init(context: context)
        identifier = task.identifier
        prescriptionId = task.prescriptionId
        accessCode = task.accessCode
        fullUrl = task.fullUrl
        status = task.status.rawValue
        authoredOn = task.authoredOn
        lastModified = task.lastModified
        expiresOn = task.expiresOn
        acceptedUntil = task.acceptedUntil
        redeemedOn = task.redeemedOn
        author = task.author
        dispenseValidityEnd = task.dispenseValidityEnd

        noctuFeeWaiver = task.noctuFeeWaiver
        substitutionAllowed = task.substitutionAllowed
        source = task.source.rawValue

        medication = ErxTaskMedicationEntity(medication: task.medication,
                                             in: context)
        patient = ErxTaskPatientEntity(patient: task.patient,
                                       in: context)
        practitioner = ErxTaskPractitionerEntity(practitioner: task.practitioner,
                                                 in: context)
        organization = ErxTaskOrganizationEntity(organization: task.organization,
                                                 in: context)
        workRelatedAccident = ErxTaskWorkRelatedAccidentEntity(accident: task.workRelatedAccident,
                                                               in: context)
        // Note: auditEvents, communications and medicationDispense is not set here
        // since it is loaded asynchronous from remote
    }
}

extension ErxTask {
    init?(entity: ErxTaskEntity) {
        guard let identifier = entity.identifier else {
            return nil
        }

        var erxTaskStatus: ErxTask.Status = .ready
        if let status = entity.status {
            erxTaskStatus = ErxTask.Status(rawValue: status) ?? .ready
        }
        self.init(
            identifier: identifier,
            status: erxTaskStatus,
            accessCode: entity.accessCode,
            fullUrl: entity.fullUrl,
            authoredOn: entity.authoredOn,
            lastModified: entity.lastModified,
            expiresOn: entity.expiresOn,
            acceptedUntil: entity.acceptedUntil,
            redeemedOn: entity.redeemedOn,
            author: entity.author,
            dispenseValidityEnd: entity.dispenseValidityEnd,
            noctuFeeWaiver: entity.noctuFeeWaiver,
            prescriptionId: entity.prescriptionId,
            substitutionAllowed: entity.substitutionAllowed,
            source: Source(rawValue: entity.source ?? "") ?? .server,
            medication: Medication(entity: entity.medication),
            patient: Patient(entity: entity.patient),
            practitioner: Practitioner(entity: entity.practitioner),
            organization: Organization(entity: entity.organization),
            workRelatedAccident: WorkRelatedAccident(entity: entity.workRelatedAccident),
            auditEvents: entity.auditEvents?
                .compactMap { auditEventEntity in
                    if let entity = auditEventEntity as? ErxAuditEventEntity {
                        return ErxAuditEvent(entity: entity)
                    }
                    return nil
                }
                .sorted { $0.timestamp ?? "" > $1.timestamp ?? "" } ?? [],
            communications: entity.communications?
                .compactMap { entity in
                    if let communicationEntity = entity as? ErxTaskCommunicationEntity {
                        return ErxTask.Communication(entity: communicationEntity)
                    } else {
                        return nil
                    }
                }
                .sorted { $0.timestamp < $1.timestamp } ?? [],
            medicationDispense: MedicationDispense(entity: entity.medicationDispense)
        )
    }
}
