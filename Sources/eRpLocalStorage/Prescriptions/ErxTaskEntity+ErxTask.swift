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
        flowType = task.flowType.rawValue
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
        quantity = ErxTaskQuantityEntity(quantity: task.medicationRequest.quantity, in: context)
        lastMedicationDispense = task.lastMedicationDispense

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
        deviceRequest = ErxTaskDeviceRequestEntity(request: task.deviceRequest,
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
            return .computed(status: .sent)
        } else if !communications.isEmpty {
            let recentCommunications = communications.filter { communication in
                guard communication.profile == .dispReq,
                      let redeemDate = communication.timestamp.date else {
                    return false
                }
                let redeemedTimeInterval = now.timeIntervalSince(redeemDate)
                return redeemedTimeInterval < ErxTask.minTimeIntervalForCompletion &&
                    redeemedTimeInterval > 0
            }
            return recentCommunications.isEmpty ? .completed : .computed(status: .waiting)
        }
        return nil
    }

    private static func updatedStatusForServerTask(
        lastModified: Date?,
        communications: [ErxTask.Communication],
        currentDate now: Date,
        isDiGa: Bool = false
    ) -> ErxTask.Status? {
        let comms = communications.filter { communication in
            guard communication.profile == .dispReq,
                  let redeemDate = communication.timestamp.date else {
                return false
            }
            let redeemedTimeInterval = now.timeIntervalSince(redeemDate)
            if let lastModifiedDate = lastModified {
                let lastModifiedTimeInterval = now.timeIntervalSince(lastModifiedDate)
                // if lastModified is more recent than the latest dispReq, we can be sure that something
                // happened with the task (e.g. claimed -> rejected) and omit status manipulation
                if lastModifiedTimeInterval < redeemedTimeInterval {
                    return false
                }
            }
            // For DiGa we dont have a time limit and wait until we get a response from the organization
            guard !isDiGa else { return true }
            return redeemedTimeInterval < ErxTask.minTimeIntervalForCompletion &&
                redeemedTimeInterval > 0
        }
        if !comms.isEmpty {
            // DiGa is instantly inProgress state and has no waiting state
            return isDiGa ? .inProgress : .computed(status: .waiting)
        }
        return nil
    }

    #if ENABLE_DEBUG_VIEW
    /// Time interval for the fake status of a scanned `ErxTask`
    public static var minTimeIntervalForCompletion: TimeInterval = 600
    #else
    static let minTimeIntervalForCompletion: TimeInterval = 600
    #endif

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    init?(entity: ErxTaskEntity, dateProvider: () -> Date) {
        guard let identifier = entity.identifier else {
            return nil
        }

        var flowType: ErxTask.FlowType
        if let flowTypeCode = entity.flowType {
            flowType = ErxTask.FlowType(rawValue: flowTypeCode)
        } else {
            flowType = ErxTask.FlowType(taskId: identifier)
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

        let medicationDispenses: [ErxMedicationDispense] = entity.medicationDispenses?
            .compactMap { medicationDispense in
                if let entity = medicationDispense as? ErxTaskMedicationDispenseEntity {
                    return ErxMedicationDispense(entity: entity)
                } else {
                    return nil
                }
            } ?? []

        switch (erxTaskStatus, source) {
        case (.ready, .scanner):
            erxTaskStatus = ErxTask.updatedStatusForRedeemedScannedTask(
                communications: mappedCommunications,
                avsTransactions: avsTransactions,
                currentDate: now
            ) ?? erxTaskStatus
        case (.ready, .server):
            erxTaskStatus = ErxTask.updatedStatusForServerTask(
                lastModified: entity.lastModified?.date,
                communications: mappedCommunications,
                currentDate: now,
                isDiGa: entity.deviceRequest?.pzn != nil
            ) ?? erxTaskStatus
        case (.inProgress, _):
            guard entity.lastMedicationDispense == nil else {
                erxTaskStatus = .computed(status: .dispensed)
                break
            }
            erxTaskStatus = .inProgress
        default:
            break
        }

        var quantity: ErxMedication.Quantity?
        if let value = entity.quantity?.value {
            quantity = .init(value: value, unit: entity.quantity?.unit)
        }

        var medicationSchedule: MedicationSchedule?
        if let schedule = entity.medicationSchedule {
            medicationSchedule = MedicationSchedule(entity: schedule)
        }

        self.init(
            identifier: identifier,
            status: erxTaskStatus,
            flowType: flowType,
            accessCode: entity.accessCode,
            fullUrl: entity.fullUrl,
            authoredOn: entity.authoredOn,
            lastModified: entity.lastModified,
            expiresOn: entity.expiresOn,
            acceptedUntil: entity.acceptedUntil,
            lastMedicationDispense: entity.lastMedicationDispense,
            redeemedOn: entity.redeemedOn,
            avsTransactions: avsTransactions
                .sorted { $0.groupedRedeemTime < $1.groupedRedeemTime },
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
                multiplePrescription: MultiplePrescription(entity: entity.multiplePrescription),
                quantity: quantity
            ),
            medicationSchedule: medicationSchedule,
            patient: ErxPatient(entity: entity.patient),
            practitioner: ErxPractitioner(entity: entity.practitioner),
            organization: ErxOrganization(entity: entity.organization),
            communications: mappedCommunications
                .sorted { $0.timestamp < $1.timestamp },
            medicationDispenses: medicationDispenses
                .sorted { $0.identifier < $1.identifier },
            deviceRequest: ErxDeviceRequest(entity: entity.deviceRequest)
        )
    }
}
