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
import ModelsR4
// swiftlint:disable file_length
// sourcery: CodedError = "580"
public enum RemoteStorageBundleParsingError: Swift.Error {
    // sourcery: errorCode = "01"
    case parseError(String)
}

extension ModelsR4.Bundle {
    func parseErxTasksContainer() throws -> PagedContent<[ErxTask]> {
        PagedContent(content: try parseErxTasksFromContainer(), next: parseNext())
    }

    /// Parse and extract all found ErxTasks from `Self`
    ///
    /// - Returns: Array with all found task's
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxTasksFromContainer() throws -> [ErxTask] {
        try entry?.compactMap {
            guard let task = $0.resource?.get(if: ModelsR4.Task.self) else {
                return nil
            }
            guard let identifier = task.id?.value?.string else {
                throw RemoteStorageBundleParsingError.parseError("Could not parse id from task.")
            }

            let flowType = task.flowTypeCode.map { ErxTask.FlowType(rawValue: $0) } ?? ErxTask
                .FlowType(taskId: identifier)

            guard let status = task.status.value?.rawValue,
                  let erxTaskStatus = ErxTask.Status(rawValue: status)
            else {
                return ErxTask(identifier: identifier, status: .error(.missingStatus), flowType: flowType)
            }

            return ErxTask(
                identifier: identifier,
                status: erxTaskStatus,
                flowType: flowType,
                accessCode: task.accessCode,
                fullUrl: $0.fullUrl?.value?.url.absoluteString,
                authoredOn: task.authoredOn?.value?.description,
                lastModified: task.lastModified?.value?.description,
                expiresOn: task.expiryDate,
                acceptedUntil: task.acceptDate,
                lastMedicationDispense: task.lastMedicationDispense,
                prescriptionId: task.prescriptionId
            )
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
        var flowType: ErxTask.FlowType = task.flowTypeCode.map {
            ErxTask.FlowType(rawValue: $0)
        } ?? ErxTask.FlowType(taskId: taskId)

        guard let status = task.status.value?.rawValue,
              let erxTaskStatus = ErxTask.Status(rawValue: status)
        else {
            return ErxTask(
                identifier: taskId,
                status: .error(.missingStatus),
                flowType: flowType,
                accessCode: taskAccessCode
            )
        }

        // Find the patientReceipt document reference
        guard let patientReceiptReference = task.input?.firstPatientReceipt else {
            return ErxTask(
                identifier: taskId,
                status: .error(.missingPatientReceiptReference),
                flowType: flowType,
                accessCode: taskAccessCode,
                fullUrl: fullUrl?.value?.url.absoluteString,
                authoredOn: task.authoredOn?.value?.description,
                lastModified: task.lastModified?.value?.description,
                expiresOn: task.expiryDate,
                acceptedUntil: task.acceptDate,
                lastMedicationDispense: task.lastMedicationDispense,
                prescriptionId: task.prescriptionId
            )
        }
        guard let patientReceiptIdentifier = patientReceiptReference.value.identifierValue else {
            return ErxTask(
                identifier: taskId,
                status: .error(.missingPatientReceiptIdentifier),
                flowType: flowType,
                accessCode: taskAccessCode,
                fullUrl: fullUrl?.value?.url.absoluteString,
                authoredOn: task.authoredOn?.value?.description,
                lastModified: task.lastModified?.value?.description,
                expiresOn: task.expiryDate,
                acceptedUntil: task.acceptDate,
                lastMedicationDispense: task.lastMedicationDispense,
                prescriptionId: task.prescriptionId
            )
        }
        // Find the Document Bundle (KBV-Bundle)
        guard let patientReceiptBundle = bundle
            .findResource(with: patientReceiptIdentifier, type: ModelsR4.Bundle.self) else {
            return ErxTask(
                identifier: taskId,
                status: .error(.missingPatientReceiptBundle),
                flowType: flowType,
                accessCode: taskAccessCode,
                fullUrl: fullUrl?.value?.url.absoluteString,
                authoredOn: task.authoredOn?.value?.description,
                lastModified: task.lastModified?.value?.description,
                expiresOn: task.expiryDate,
                acceptedUntil: task.acceptDate,
                lastMedicationDispense: task.lastMedicationDispense,
                prescriptionId: task.prescriptionId
            )
        }

        let patient = patientReceiptBundle.patient
        let practitioner = patientReceiptBundle.practitioner
        let organization = patientReceiptBundle.organization
        let deviceRequest = patientReceiptBundle.deviceRequest

        return ErxTask(
            identifier: taskId,
            status: erxTaskStatus,
            flowType: flowType,
            accessCode: taskAccessCode,
            fullUrl: fullUrl?.value?.url.absoluteString,
            authoredOn: task.authoredOn?.value?.description,
            lastModified: task.lastModified?.value?.description,
            expiresOn: task.expiryDate,
            acceptedUntil: task.acceptDate,
            lastMedicationDispense: task.lastMedicationDispense,
            author: patientReceiptBundle.organization?.author,
            prescriptionId: task.prescriptionId,
            source: .server,
            medication: patientReceiptBundle.parseErxMedication(),
            medicationRequest: patientReceiptBundle.parseErxMedicationRequest(),
            patient: ErxPatient(
                title: patient?.title,
                name: patient?.fullName,
                address: patient?.completeAddress,
                birthDate: patient?.birthDate?.value?.description,
                phone: patient?.phone,
                status: patientReceiptBundle.coverageStatus,
                insurance: patientReceiptBundle.coverage?.payor.first?.display?.value?.string,
                insuranceId: patient?.insuranceId,
                coverageType: ErxPatient.CoverageType(rawValue: patientReceiptBundle.coverageType)
            ),
            practitioner: ErxPractitioner(
                title: practitioner?.title,
                lanr: practitioner?.lanr,
                zanr: practitioner?.zanr,
                name: practitioner?.fullName,
                qualification: practitioner?.qualificationText,
                email: practitioner?.email,
                address: practitioner?.completeAddress
            ),
            organization: ErxOrganization(
                identifier: organization?.erxOrganizationIdentifier,
                name: organization?.name?.value?.string,
                phone: organization?.phone,
                email: organization?.email,
                address: organization?.completeAddress
            ),
            deviceRequest: ErxDeviceRequest(
                status: deviceRequest?.deviceRequestStatus,
                intent: deviceRequest?.deviceRequestIntent,
                pzn: deviceRequest?.pzn,
                appName: deviceRequest?.appName,
                isSER: deviceRequest?.isSer,
                accidentInfo: deviceRequest?.accidentInfo,
                authoredOn: deviceRequest?.authoredOn?.value?.description
            )
        )
    }

    func findResource<Resource: ModelsR4.Resource>(with identifier: FHIRPrimitive<FHIRString>,
                                                   type _: Resource.Type) -> Resource? {
        let newIdentifier = identifier.dropHashSymbol

        // try finding the resource by fullUrl
        if let kbvBundle = entry?.first(where: { bundleEntry in
            guard let urlString = bundleEntry.fullUrl?.value?.url.absoluteString else { return false }
            return urlString == newIdentifier.value?.string
        })?
            .resource?
            .get(if: Resource.self) {
            return kbvBundle
        }

        // select the second entry
        if entry?.count == 2 {
            return entry?.last?.resource?.get(if: Resource.self)
        }

        // try finding it by identifier
        if let bundle = entry?.compactMap({ $0.resource?.get(if: Resource.self) }),
           let kbvBundle = bundle.first(where: { bundleEntry in newIdentifier == bundleEntry.id }) {
            return kbvBundle
        }

        return nil
    }

    func findResource<Resource: ModelsR4.Resource>(for metaProfile: String?,
                                                   type _: Resource.Type) -> Resource? {
        guard let metaProfile = metaProfile else { return nil }
        // try finding it by identifier
        if let bundle = entry?.compactMap({ $0.resource?.get(if: Resource.self) }),
           let resource = bundle.first(where: { bundleEntry in
               bundleEntry.meta?.profile?.compactMap { $0.value?.url.absoluteString }.contains(metaProfile) ?? false
           }) {
            return resource
        }

        return nil
    }

    /// Creates an `ErxTask.Medication` from the ModelsR4.Medication
    func parseErxMedication() -> ErxMedication {
        .init(
            name: medication?.medicationText,
            profile: medication?.profileType,
            drugCategory: medication?.drugCategory,
            pzn: medication?.pzn,
            isVaccine: medication?.isVaccine ?? false,
            amount: medication?.medicationAmount,
            dosageForm: medication?.dosageForm,
            normSizeCode: medication?.normSizeCode,
            batch: medication?.erxTaskBatch,
            packaging: medication?.packaging,
            manufacturingInstructions: medication?.compoundingInstruction,
            ingredients: medication?.erxTaskIngredients ?? []
        )
    }

    /// Creates an `eRpKit.MedicationRequest` from the ModelsR4.MedicationRequest
    func parseErxMedicationRequest() -> ErxMedicationRequest {
        .init(
            authoredOn: medicationRequest?.authoredOn?.value?.description,
            dosageInstructions: medicationRequest?.kbvDosageInstruction,
            substitutionAllowed: medicationRequest?.substitutionAllowed,
            hasEmergencyServiceFee: medicationRequest?.noctuFeeWaiver,
            dispenseValidityEnd: dispenseValidityEnd,
            accidentInfo: medicationRequest?.accidentInfo,
            bvg: medicationRequest?.bvg,
            coPaymentStatus: medicationRequest?.coPaymentStatus,
            multiplePrescription: medicationRequest?.multiplePrescription,
            quantity: medicationRequest?.erxTaskQuantity
        )
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

extension ModelsR4.Identifier {
    func value(for systemKeys: [Workflow.Version: String]) -> String? {
        guard let systemValue = system?.value?.url.absoluteString,
              systemKeys.contains(where: { $0.value == systemValue }) else {
            return nil
        }

        return value?.value?.string
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

    var lastMedicationDispense: String? {
        `extension`?.first { anExtension in
            Workflow.Key.lastMedicationDispense.contains { $0.value == anExtension.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.instant(instantValue) = valueX,
               let dateString = instantValue.value?.description {
                return dateString
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
    var invoice: ModelsR4.Invoice? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.Invoice.self)
        }.first
    }

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
            $0.url.value?.url.absoluteString == ErpPrescription.Key.coverageStatusKey
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

    var coverageType: String? {
        coverage?.type?.coding?.first {
            $0.system?.value?.url.absoluteString == ErpPrescription.Key.coverageTypeKey
        }?.code?.value?.string
    }

    var joinedDosageInstructions: String? {
        medicationRequest?.dosageInstruction?.compactMap {
            $0.text?.value?.string
        }
        .joined(separator: ",")
    }

    // DiGa
    var deviceRequest: ModelsR4.DeviceRequest? {
        entry?.lazy.compactMap {
            $0.resource?.get(if: ModelsR4.DeviceRequest.self)
        }.first
    }
}

extension ModelsR4.Organization {
    var author: String? {
        name?.value?.string
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

// swiftlint:enable file_length
