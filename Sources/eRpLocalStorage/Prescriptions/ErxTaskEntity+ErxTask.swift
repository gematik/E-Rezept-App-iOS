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
        flowType = task.flowType?.rawValue
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

        noctuFeeWaiver = task.hasEmergencyServiceFee
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
        multiplePrescription = ErxTaskMultiplePrescriptionEntity(multiplePrescription: task.multiplePrescription,
                                                                 in: context)

        // Note: communications and medicationDispenses are not set here
        // since they are loaded asynchronous from remote
    }
}

extension ErxTask {
    private static func updatedStatusForAVSRedeemedTask(_ entity: ErxTaskEntity, currentDate now: Date) -> ErxTask
        .Status? {
        if let avsTransactions = entity.avsTransaction {
            let transactions = avsTransactions.filter { transaction in
                guard let transaction = transaction as? AVSTransactionEntity,
                      let redeemTime = transaction.groupedRedeemTime else {
                    return false
                }
                return now.timeIntervalSince(redeemTime) > ErxTask.scannedTaskMinIntervalForCompletion
            }
            if !transactions.isEmpty {
                return .completed
            } else if !Array(avsTransactions).isEmpty {
                return .inProgress
            }
        }
        return nil
    }

    private static func updatedStatusForTask(
        _: ErxTaskEntity,
        with communications: [ErxTask.Communication],
        currentDate now: Date
    ) -> ErxTask.Status? {
        let comms = communications.filter { communication in
            guard communication.profile == .dispReq,
                  let redeemTime = communication.timestamp.date else {
                return false
            }
            let redeemedTimeInterval = now.timeIntervalSince(redeemTime)
            return redeemedTimeInterval < ErxTask.scannedTaskMinIntervalForCompletion &&
                redeemedTimeInterval > 0
        }
        if !comms.isEmpty {
            return .inProgress
        }
        return nil
    }

    static let scannedTaskMinIntervalForCompletion: TimeInterval = 600
    // swiftlint:disable:next function_body_length
    init?(entity: ErxTaskEntity, dateProvider: () -> Date) {
        guard let identifier = entity.identifier else {
            return nil
        }

        let now = dateProvider()
        let source = Source(rawValue: entity.source ?? "") ?? .server
        var erxTaskStatus: ErxTask.Status = .ready
        if let status = entity.status {
            erxTaskStatus = ErxTask.Status(rawValue: status) ?? .ready
        }
        let mappedCommunications: [ErxTask.Communication] = entity.communications?
            .compactMap { entity in
                if let communicationEntity = entity as? ErxTaskCommunicationEntity {
                    return ErxTask.Communication(entity: communicationEntity)
                } else {
                    return nil
                }
            } ?? []
        if erxTaskStatus == .ready {
            if source == .scanner {
                erxTaskStatus = ErxTask.updatedStatusForAVSRedeemedTask(entity, currentDate: now) ?? erxTaskStatus
            } else if source == .server {
                erxTaskStatus = ErxTask
                    .updatedStatusForTask(entity, with: mappedCommunications, currentDate: now) ?? erxTaskStatus
            }
        }
        self.init(
            identifier: identifier,
            status: erxTaskStatus,
            flowType: ErxTask.FlowType(rawValue: entity.flowType),
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
            source: source,
            medication: Medication(entity: entity.medication),
            multiplePrescription: MultiplePrescription(entity: entity.multiplePrescription),
            patient: Patient(entity: entity.patient),
            practitioner: Practitioner(entity: entity.practitioner),
            organization: Organization(entity: entity.organization),
            workRelatedAccident: WorkRelatedAccident(entity: entity.workRelatedAccident),
            communications: mappedCommunications
                .sorted { $0.timestamp < $1.timestamp },
            medicationDispenses: entity.medicationDispenses?
                .compactMap { medicationDispense in
                    if let entity = medicationDispense as? ErxTaskMedicationDispenseEntity {
                        return ErxTask.MedicationDispense(entity: entity)
                    } else {
                        return nil
                    }
                }
                .sorted { $0.identifier < $1.identifier } ?? []
        )
    }
}
