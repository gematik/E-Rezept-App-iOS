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

// swiftlint:enable opening_brace type_name
