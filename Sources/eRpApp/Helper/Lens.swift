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

import eRpKit
import Foundation
import IdentifiedCollections

struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part) -> (Whole) -> Whole
}

// swiftlint:disable opening_brace type_name
extension Prescription {
    init(
        erxTask: ErxTask,
        type: PrescriptionType = .regular,
        viewStatus: Status,
        authoredOnDate: String?
    ) {
        self.erxTask = erxTask
        self.type = type
        self.viewStatus = viewStatus
        self.authoredOnDate = authoredOnDate
    }

    enum lens {
        static let erxTask = Lens<Prescription, ErxTask>(
            get: { $0.erxTask },
            set: { newErxTask in
                { oldPrescription in
                    Prescription(
                        erxTask: newErxTask,
                        type: oldPrescription.type,
                        viewStatus: oldPrescription.viewStatus,
                        authoredOnDate: oldPrescription.authoredOnDate
                    )
                }
            }
        )
    }
}

extension ErxTask {
    enum lens {
        static let medication = Lens<ErxTask, ErxMedication?>(
            get: { $0.medication },
            set: { newMedication in
                { oldErxTask in
                    ErxTask(
                        identifier: oldErxTask.identifier,
                        status: oldErxTask.status,
                        flowType: oldErxTask.flowType,
                        accessCode: oldErxTask.accessCode,
                        fullUrl: oldErxTask.fullUrl,
                        authoredOn: oldErxTask.authoredOn,
                        lastModified: oldErxTask.lastModified,
                        expiresOn: oldErxTask.expiresOn,
                        acceptedUntil: oldErxTask.acceptedUntil,
                        redeemedOn: oldErxTask.redeemedOn,
                        avsTransactions: oldErxTask.avsTransactions,
                        author: oldErxTask.author,
                        prescriptionId: oldErxTask.prescriptionId,
                        source: oldErxTask.source,
                        medication: newMedication,
                        medicationRequest: oldErxTask.medicationRequest,
                        medicationSchedule: oldErxTask.medicationSchedule,
                        patient: oldErxTask.patient,
                        practitioner: oldErxTask.practitioner,
                        organization: oldErxTask.organization,
                        communications: oldErxTask.communications,
                        medicationDispenses: oldErxTask.medicationDispenses
                    )
                }
            }
        )

        static let medicationSchedule = Lens<ErxTask, MedicationSchedule?>(
            get: { $0.medicationSchedule },
            set: { newMedicationSchedule in
                { oldErxTask in
                    ErxTask(
                        identifier: oldErxTask.identifier,
                        status: oldErxTask.status,
                        flowType: oldErxTask.flowType,
                        accessCode: oldErxTask.accessCode,
                        fullUrl: oldErxTask.fullUrl,
                        authoredOn: oldErxTask.authoredOn,
                        lastModified: oldErxTask.lastModified,
                        expiresOn: oldErxTask.expiresOn,
                        acceptedUntil: oldErxTask.acceptedUntil,
                        redeemedOn: oldErxTask.redeemedOn,
                        avsTransactions: oldErxTask.avsTransactions,
                        author: oldErxTask.author,
                        prescriptionId: oldErxTask.prescriptionId,
                        source: oldErxTask.source,
                        medication: oldErxTask.medication,
                        medicationRequest: oldErxTask.medicationRequest,
                        medicationSchedule: newMedicationSchedule,
                        patient: oldErxTask.patient,
                        practitioner: oldErxTask.practitioner,
                        organization: oldErxTask.organization,
                        communications: oldErxTask.communications,
                        medicationDispenses: oldErxTask.medicationDispenses
                    )
                }
            }
        )

        static let deviceRequest = Lens<ErxTask, ErxDeviceRequest?>(
            get: { $0.deviceRequest },
            set: { newdeviceRequest in
                { oldErxTask in
                    ErxTask(
                        identifier: oldErxTask.identifier,
                        status: oldErxTask.status,
                        flowType: oldErxTask.flowType,
                        accessCode: oldErxTask.accessCode,
                        fullUrl: oldErxTask.fullUrl,
                        authoredOn: oldErxTask.authoredOn,
                        lastModified: oldErxTask.lastModified,
                        expiresOn: oldErxTask.expiresOn,
                        acceptedUntil: oldErxTask.acceptedUntil,
                        redeemedOn: oldErxTask.redeemedOn,
                        avsTransactions: oldErxTask.avsTransactions,
                        author: oldErxTask.author,
                        prescriptionId: oldErxTask.prescriptionId,
                        source: oldErxTask.source,
                        medication: oldErxTask.medication,
                        medicationRequest: oldErxTask.medicationRequest,
                        medicationSchedule: oldErxTask.medicationSchedule,
                        patient: oldErxTask.patient,
                        practitioner: oldErxTask.practitioner,
                        organization: oldErxTask.organization,
                        communications: oldErxTask.communications,
                        medicationDispenses: oldErxTask.medicationDispenses,
                        deviceRequest: newdeviceRequest
                    )
                }
            }
        )
    }
}

extension ErxMedication {
    enum lens {
        static let name = Lens<ErxMedication, String?>(
            get: { $0.name },
            set: { newName in
                { oldErxMedication in
                    ErxMedication(
                        name: newName,
                        profile: oldErxMedication.profile,
                        drugCategory: oldErxMedication.drugCategory,
                        pzn: oldErxMedication.pzn,
                        isVaccine: oldErxMedication.isVaccine,
                        amount: oldErxMedication.amount,
                        dosageForm: oldErxMedication.dosageForm,
                        normSizeCode: oldErxMedication.normSizeCode,
                        batch: oldErxMedication.batch,
                        packaging: oldErxMedication.packaging,
                        manufacturingInstructions: oldErxMedication.manufacturingInstructions,
                        ingredients: oldErxMedication.ingredients
                    )
                }
            }
        )
    }
}

extension MedicationSchedule {
    enum lens {
        static let entries = Lens<MedicationSchedule, IdentifiedArrayOf<MedicationSchedule.Entry>>(
            get: { $0.entries },
            set: { newEntries in
                { oldValue in
                    MedicationSchedule(
                        id: oldValue.id,
                        start: oldValue.start,
                        end: oldValue.end,
                        title: oldValue.title,
                        dosageInstructions: oldValue.dosageInstructions,
                        taskId: oldValue.taskId,
                        isActive: oldValue.isActive,
                        entries: newEntries
                    )
                }
            }
        )
    }
}

extension Order {
    enum lens {
        static let pharmacy = Lens<Order, PharmacyLocation?>(
            get: { $0.pharmacy },
            set: { newPharmacy in
                { oldOrder in
                    Order(
                        orderId: oldOrder.orderId,
                        communications: oldOrder.communications,
                        chargeItems: oldOrder.chargeItems,
                        pharmacy: newPharmacy
                    )
                }
            }
        )
    }
}

extension ErxDeviceRequest {
    enum lens {
        static let diGaInfo = Lens<ErxDeviceRequest, DiGaInfo?>(
            get: { $0.diGaInfo },
            set: { newDiGaInfo in
                { oldDeviceRequest in
                    ErxDeviceRequest(status: oldDeviceRequest.status,
                                     intent: oldDeviceRequest.intent,
                                     pzn: oldDeviceRequest.pzn,
                                     appName: oldDeviceRequest.appName,
                                     isSER: oldDeviceRequest.isSER,
                                     accidentInfo: oldDeviceRequest.accidentInfo,
                                     authoredOn: oldDeviceRequest.authoredOn,
                                     diGaInfo: newDiGaInfo)
                }
            }
        )
    }
}

// swiftlint:enable opening_brace type_name
