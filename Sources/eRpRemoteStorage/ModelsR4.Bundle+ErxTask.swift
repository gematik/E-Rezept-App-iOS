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

import eRpKit
import Foundation
import ModelsR4

// sourcery: CodedError = "580"
public enum RemoteStorageBundleParsingError: Swift.Error {
    // sourcery: errorCode = "01"
    case parseError(String)
}

extension ModelsR4.Bundle {
    /// Parse and extract all found ErxTask IDs from `Self`
    ///
    /// - Returns: Array with all found task ID's
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxTaskIDs() throws -> [String] {
        // Collect and parse all ErxTask id's
        try entry?.compactMap {
            guard let task = $0.resource?.get(if: ModelsR4.Task.self) else {
                return nil
            }
            guard let identifier = task.id?.value?.string else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse id from task.")
            }
            return identifier
        } ?? []
    }

    /// Parse ModelsR4.Task and extract ErxTask from `Self`
    ///
    /// - Returns: Parsed ErxTask, if available/parsable else nil
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxTask(taskId: ErxTask.ID) -> ErxTask? {
        // swiftlint:disable:previous function_body_length
        // Collect and parse ErxTask
        guard let entry = entry?.first, // for now we assume that there is only one task
              let task = entry.resource?.get(if: ModelsR4.Task.self),
              let taskIdentifier = task.id?.value?.string,
              taskId == taskIdentifier
        else {
            return nil
        }

        let fullUrl = entry.fullUrl
        let bundle = self
        let taskAccessCode = task.accessCode

        guard let status = task.status.value?.rawValue,
              let erxTaskStatus = ErxTask.Status(rawValue: status) else {
            return ErxTask(identifier: taskId, status: .error(.missingStatus), accessCode: taskAccessCode)
        }

        // Find the patientReceipt document reference
        guard let patientReceiptReference = task.input?.firstPatientReceipt else {
            return ErxTask(
                identifier: taskId,
                status: .error(.missingPatientReceiptReference),
                flowType: ErxTask.FlowType(rawValue: task.flowTypeCode),
                accessCode: taskAccessCode,
                fullUrl: fullUrl?.value?.url.absoluteString,
                authoredOn: task.authoredOn?.value?.description,
                lastModified: task.lastModified?.value?.description,
                expiresOn: task.expiryDate,
                acceptedUntil: task.acceptDate,
                prescriptionId: task.prescriptionId
            )
        }
        guard let patientReceiptIdentifier = patientReceiptReference.value.identifierValue else {
            return ErxTask(
                identifier: taskId,
                status: .error(.missingPatientReceiptIdentifier),
                flowType: ErxTask.FlowType(rawValue: task.flowTypeCode),
                accessCode: taskAccessCode,
                fullUrl: fullUrl?.value?.url.absoluteString,
                authoredOn: task.authoredOn?.value?.description,
                lastModified: task.lastModified?.value?.description,
                expiresOn: task.expiryDate,
                acceptedUntil: task.acceptDate,
                prescriptionId: task.prescriptionId
            )
        }
        // Find the Document Bundle
        guard let patientReceiptBundle = bundle
            .findResource(with: patientReceiptIdentifier, type: ModelsR4.Bundle.self) else {
            return ErxTask(
                identifier: taskId,
                status: .error(.missingPatientReceiptBundle),
                flowType: ErxTask.FlowType(rawValue: task.flowTypeCode),
                accessCode: taskAccessCode,
                fullUrl: fullUrl?.value?.url.absoluteString,
                authoredOn: task.authoredOn?.value?.description,
                lastModified: task.lastModified?.value?.description,
                expiresOn: task.expiryDate,
                acceptedUntil: task.acceptDate,
                prescriptionId: task.prescriptionId
            )
        }

        let medication = patientReceiptBundle.medication
        let multiplePrescription = patientReceiptBundle.medicationRequest?.multiplePrescription
        let patient = patientReceiptBundle.patient
        let practitioner = patientReceiptBundle.practitioner
        let organization = patientReceiptBundle.organization

        return ErxTask(
            identifier: taskId,
            status: erxTaskStatus,
            flowType: ErxTask.FlowType(rawValue: task.flowTypeCode),
            accessCode: taskAccessCode,
            fullUrl: fullUrl?.value?.url.absoluteString,
            authoredOn: patientReceiptBundle.medicationRequest?.authoredOn?.value?.description,
            lastModified: task.lastModified?.value?.description,
            expiresOn: task.expiryDate,
            acceptedUntil: task.acceptDate,
            author: patientReceiptBundle.organization?.author,
            dispenseValidityEnd: patientReceiptBundle.dispenseValidityEnd,
            noctuFeeWaiver: patientReceiptBundle.medicationRequest?.noctuFeeWaiver ?? false,
            prescriptionId: task.prescriptionId,
            substitutionAllowed: patientReceiptBundle.medicationRequest?.substitutionAllowed ?? false,
            source: .server,
            medication: ErxTask.Medication(
                name: medication?.medicationText,
                pzn: medication?.pzn,
                amount: medication?.decimalAmount,
                dosageForm: medication?.dosageForm,
                dose: medication?.dose,
                dosageInstructions: patientReceiptBundle.dosageInstructions,
                lot: medication?.lot,
                expiresOn: medication?.expiresOn
            ),
            multiplePrescription: ErxTask.MultiplePrescription(
                mark: multiplePrescription?.mark ?? false,
                numbering: multiplePrescription?.numbering,
                totalNumber: multiplePrescription?.totalNumber,
                startPeriod: multiplePrescription?.startPeriod,
                endPeriod: multiplePrescription?.endPeriod
            ),
            patient: ErxTask.Patient(
                name: patient?.fullName,
                address: patient?.completeAddress,
                birthDate: patient?.birthDate?.value?.description,
                phone: patient?.phone,
                status: patientReceiptBundle.coverageStatus,
                insurance: patientReceiptBundle.coverage?.payor.first?.display?.value?.string,
                insuranceId: patient?.insuranceId
            ),
            practitioner: ErxTask.Practitioner(
                lanr: practitioner?.lanr,
                name: practitioner?.fullName,
                qualification: practitioner?.qualificationText,
                email: practitioner?.email,
                address: practitioner?.completeAddress
            ),
            organization: ErxTask.Organization(
                identifier: organization?.organizationIdentifier,
                name: organization?.name?.value?.string,
                phone: organization?.phone,
                email: organization?.email,
                address: organization?.completeAddress
            ),
            workRelatedAccident: patientReceiptBundle.medicationRequest?.workRelatedAccident
        )
    }

    func findResource<Resource: ModelsR4.Resource>(with identifier: FHIRPrimitive<FHIRString>,
                                                   type _: Resource.Type) -> Resource? {
        let newIdentifier = identifier.dropHashSymbol

        return entry?.lazy.compactMap {
            $0.resource?.get(if: Resource.self)
        }
        .first { bundleEntry in
            newIdentifier == bundleEntry.id
        }
    }
}

extension ModelsR4.FHIRPrimitive where PrimitiveType == ModelsR4.FHIRString {
    var dropHashSymbol: Self {
        guard let stringValue = value?.string, stringValue.starts(with: "#") else {
            return self
        }

        return FHIRPrimitive(FHIRString(String(stringValue.dropFirst())))
    }
}

extension ModelsR4.Task {
    var prescriptionId: String? {
        identifier?.first { identifier in
            Workflow.Key.prescriptionIdKeys.contains { $0.value == identifier.system?.value?.url.absoluteString }
        }?.value?.value?.string
    }

    var accessCode: String? {
        identifier?.first { identifier in
            Workflow.Key.accessCodeKeys.contains { $0.value == identifier.system?.value?.url.absoluteString }
        }?.value?.value?.string
    }

    /// Date until which a prescription can be redeemed in the pharmacy without paying
    /// the entire prescription. Note that `acceptDate <= expireDate`
    var acceptDate: String? {
        `extension`?.first { anExtension in
            Workflow.Key.acceptDateKeys.contains { $0.value == anExtension.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.date(date) = valueX,
               let acceptDateString = date.value?.description {
                return acceptDateString
            }
            return nil
        }
    }

    /// Date until which a prescription can be redeemed in the pharmacy.
    /// if the current date is > `acceptDate` the customer has to pay the entire prescription
    var expiryDate: String? {
        `extension`?.first { anExtension in
            Workflow.Key.expiryDateKeys.contains { $0.value == anExtension.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.date(date) = valueX,
               let expiryDateString = date.value?.description {
                return expiryDateString
            }
            return nil
        }
    }

    var flowTypeCode: String? {
        `extension`?.first { anExtension in
            Workflow.Key.prescriptionTypeKeys.contains { $0.value == anExtension.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.coding(codingValue) = valueX,
               Workflow.Key.flowTypeKeys.contains(where: { $0.value == codingValue.system?.value?.url.absoluteString }),
               let code = codingValue.code?.value?.description {
                return code
            }
            return nil
        }
    }
}

extension ModelsR4.Bundle {
    var medication: ModelsR4.Medication? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.Medication.self)
        }.first
    }

    var medicationRequest: ModelsR4.MedicationRequest? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.MedicationRequest.self)
        }.first
    }

    var organization: ModelsR4.Organization? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.Organization.self)
        }.first
    }

    var practitioner: ModelsR4.Practitioner? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.Practitioner.self)
        }.first
    }

    var patient: ModelsR4.Patient? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.Patient.self)
        }.first
    }

    var composition: ModelsR4.Composition? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.Composition.self)
        }.first
    }

    var dispenseValidityEnd: String? {
        medicationRequest?.dispenseRequest?.validityPeriod?.end?.value?.date.description
    }

    var coverage: ModelsR4.Coverage? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.Coverage.self)
        }.first
    }

    var coverageStatus: String? {
        coverage?.extension?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.coverageStatusKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.coding(coding) = valueX,
               let key = coding.code?.value?.string {
                return key
            }
            return nil
        }
    }

    var dosageInstructions: String? {
        medicationRequest?.dosageInstruction?.first {
            $0.extension?.first {
                $0.url.value?.url.absoluteString == Prescription.Key.dosageFlag
            }
            .map {
                if let valueX = $0.value,
                   case Extension.ValueX.boolean(true) = valueX {
                    return true
                }
                return false
            } ?? false
        }
        .flatMap {
            $0.text?.value?.string
        }
    }
}

extension ModelsR4.Organization {
    var author: String? {
        name?.value?.string
    }
}

extension ModelsR4.Medication {
    var medicationText: String? {
        code?.text?.value?.string
    }

    var dosageForm: String? {
        form?.coding?.first {
            $0.system?.value?.url.absoluteString == Prescription.Key.dosageFormKey
        }?.code?.value?.string
    }

    var decimalAmount: Decimal? {
        guard let numerator = amount?.numerator?.value?.value?.decimal,
              let denominator = amount?.denominator?.value?.value?.decimal else { return nil }
        return numerator / denominator
    }

    var dose: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.medicationDoesKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.code(code) = valueX,
               let key = code.value?.string {
                return key
            }
            return nil
        }
    }

    var pzn: String? {
        code?.coding?.first {
            $0.system?.value?.url.absoluteString == Prescription.Key.pznKey
        }?.code?.value?.string
    }

    var lot: String? {
        batch?.lotNumber?.value?.string
    }

    var expiresOn: String? {
        batch?.expirationDate?.value?.description
    }
}

extension ModelsR4.TaskInput.ValueX {
    var identifierValue: FHIRPrimitive<FHIRString>? {
        switch self {
        case let .string(value):
            return value
        case let .reference(reference):
            return reference.reference
        case let .id(value):
            return value
        case let .identifier(identifier):
            return identifier.value
        default:
            return nil
        }
    }
}

extension ModelsR4.TaskInput {
    var isPatientReceiptDocumentType: Bool {
        type.coding?.contains { coding in
            Workflow.Key.documentTypeKeys.contains { $0.value == coding.system?.value?.url.absoluteString } &&
                coding.code?.value == "2"
        } ?? false
    }
}

extension Sequence where Element == ModelsR4.TaskInput {
    var firstPatientReceipt: ModelsR4.TaskInput? {
        first { inputType in
            inputType.isPatientReceiptDocumentType
        }
    }
}

extension Sequence where Element == ModelsR4.PractitionerQualification {
    var qualificationText: String? {
        first { $0.code.text != nil }?.code.text?.value?.string
    }
}
