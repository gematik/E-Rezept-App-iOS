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
        dispenseValidityEnd = task.medicationRequest.dispenseValidityEnd
        bvg = task.medicationRequest.bvg
        dosageInstructions = task.medicationRequest.dosageInstructions
        coPaymentStatus = task.medicationRequest.coPaymentStatus?.rawValue
        noctuFeeWaiver = task.medicationRequest.hasEmergencyServiceFee
        substitutionAllowed = task.medicationRequest.substitutionAllowed
        accidentInfo = ErxTaskAccidentInfoEntity(
            accident: task.medicationRequest.accidentInfo,
            in: context
        )
        multiplePrescription = ErxTaskMultiplePrescriptionEntity(
            multiplePrescription: task.medicationRequest.multiplePrescription,
            in: context
        )
        source = task.source.rawValue

        medication = ErxTaskMedicationEntity(medication: task.medication,
                                             in: context)
        patient = ErxTaskPatientEntity(patient: task.patient,
                                       in: context)
        practitioner = ErxTaskPractitionerEntity(practitioner: task.practitioner,
                                                 in: context)
        organization = ErxTaskOrganizationEntity(organization: task.organization,
                                                 in: context)
        // Note: communications, avsTransactions and medicationDispenses are not set here
        // since they are loaded asynchronous from remote
    }
}

extension ErxTask {
    private static func updatedStatusForRedeemedScannedTask(
        communications: [Communication],
        avsTransactions: [AVSTransaction],
        currentDate now: Date
    ) -> ErxTask.Status? {
        if !avsTransactions.isEmpty {
            let recentTransactions = avsTransactions.filter { transaction in
                let redeemedTimeInterval = now.timeIntervalSince(transaction.groupedRedeemTime)
                return redeemedTimeInterval < ErxTask.scannedTaskMinIntervalForCompletion &&
                    redeemedTimeInterval > 0
            }
            return recentTransactions.isEmpty ? .completed : .inProgress
        } else if !communications.isEmpty {
            let recentCommunications = communications.filter { communication in
                guard communication.profile == .dispReq,
                      let redeemTime = communication.timestamp.date else {
                    return false
                }
                let redeemedTimeInterval = now.timeIntervalSince(redeemTime)
                return redeemedTimeInterval < ErxTask.scannedTaskMinIntervalForCompletion &&
                    redeemedTimeInterval > 0
            }
            return recentCommunications.isEmpty ? .completed : .inProgress
        }
        return nil
    }

    private static func updatedStatusForServerTask(
        communications: [ErxTask.Communication],
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

    #if ENABLE_DEBUG_VIEW
    /// Time interval for the fake status of a scanned `ErxTask`
    public static var scannedTaskMinIntervalForCompletion: TimeInterval = 600
    #else
    static let scannedTaskMinIntervalForCompletion: TimeInterval = 600
    #endif

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
        let avsTransactions: [AVSTransaction] = entity.avsTransaction?
            .compactMap { avsTransaction in
                if let entity = avsTransaction as? AVSTransactionEntity {
                    return AVSTransaction(entity: entity)
                } else {
                    return nil
                }
            } ?? []

        if erxTaskStatus == .ready {
            if source == .scanner {
                erxTaskStatus = ErxTask.updatedStatusForRedeemedScannedTask(
                    communications: mappedCommunications,
                    avsTransactions: avsTransactions,
                    currentDate: now
                ) ?? erxTaskStatus
            } else if source == .server {
                erxTaskStatus = ErxTask
                    .updatedStatusForServerTask(
                        communications: mappedCommunications,
                        currentDate: now
                    ) ?? erxTaskStatus
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
            avsTransactions: avsTransactions.sorted { $0.groupedRedeemTime < $1.groupedRedeemTime },
            author: entity.author,
            prescriptionId: entity.prescriptionId,
            source: source,
            medication: ErxMedication(entity: entity.medication),
            medicationRequest: .init(
                dosageInstructions: entity.dosageInstructions,
                substitutionAllowed: entity.substitutionAllowed,
                hasEmergencyServiceFee: entity.noctuFeeWaiver,
                dispenseValidityEnd: entity.dispenseValidityEnd,
                accidentInfo: AccidentInfo(entity: entity.accidentInfo),
                bvg: entity.bvg,
                coPaymentStatus: CoPaymentStatus(rawValue: entity.coPaymentStatus ?? "nil"),
                multiplePrescription: MultiplePrescription(entity: entity.multiplePrescription)
            ),
            patient: ErxPatient(entity: entity.patient),
            practitioner: ErxPractitioner(entity: entity.practitioner),
            organization: ErxOrganization(entity: entity.organization),
            communications: mappedCommunications
                .sorted { $0.timestamp < $1.timestamp },
            medicationDispenses: entity.medicationDispenses?
                .compactMap { medicationDispense in
                    if let entity = medicationDispense as? ErxTaskMedicationDispenseEntity {
                        return ErxMedicationDispense(entity: entity)
                    } else {
                        return nil
                    }
                }
                .sorted { $0.identifier < $1.identifier } ?? []
        )
    }
}
