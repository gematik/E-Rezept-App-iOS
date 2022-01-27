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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.Bundle {
    public enum Error: Swift.Error {
        case parseError(String)
    }

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
                throw Error.parseError("Could not parse id from task.")
            }
            return identifier
        } ?? []
    }

    /// Parse and extract all found ErxTasks from `Self`
    ///
    /// - Returns: Array with all found and parsed tasks
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxTasks() throws -> [ErxTask] {
        // Collect and parse all ErxTasks
        try entry?.compactMap {
            guard let task = $0.resource?.get(if: ModelsR4.Task.self) else {
                return nil
            }
            return try Self.parse(task: task, fullUrl: $0.fullUrl, from: self)
        } ?? []
    }

    // swiftlint:disable function_body_length
    static func parse(task: ModelsR4.Task,
                      fullUrl: FHIRPrimitive<FHIRURI>?,
                      from bundle: ModelsR4.Bundle) throws -> ErxTask {
        let taskAccessCode = task.accessCode

        guard let id = task.id?.value?.string else { // swiftlint:disable:this identifier_name
            throw Error.parseError("Could not parse id from task.")
        }

        guard let status = task.status.value?.rawValue,
              let erxTaskStatus = ErxTask.Status(rawValue: status) else {
            throw Error.parseError("Could not parse status from task.")
        }

        // Find the patientReceipt document reference
        guard let patientReceiptReference = task.input?.firstPatientReceipt else {
            throw Error.parseError("No patientReceipt Document reference found")
        }
        guard let patientReceiptIdentifier = patientReceiptReference.value.identifierValue else {
            throw Error.parseError("The patientReceipt Identifier could not be extracted")
        }
        // Find the Document Bundle
        guard let patientReceiptBundle = bundle
            .findResource(with: patientReceiptIdentifier, type: ModelsR4.Bundle.self) else {
            throw Error.parseError("The patientReceipt Document could not be found")
        }

        let medication = patientReceiptBundle.medication
        let patient = patientReceiptBundle.patient
        let practitioner = patientReceiptBundle.practitioner
        let organization = patientReceiptBundle.organization

        return ErxTask(
            identifier: id,
            status: erxTaskStatus,
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
            medication: ErxTask.Medication(name: medication?.medicationText,
                                           pzn: medication?.pzn,
                                           amount: medication?.decimalAmount,
                                           dosageForm: medication?.dosageForm,
                                           dose: medication?.dose,
                                           dosageInstructions: patientReceiptBundle.dosageInstructions),
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
        identifier?.first {
            $0.system?.value?.url.absoluteString == FHIRResponseKeys.prescriptionIdKey
        }?.value?.value?.string
    }

    var accessCode: String? {
        identifier?.first {
            $0.system?.value?.url.absoluteString == FHIRResponseKeys.accessCodeKey
        }?.value?.value?.string
    }

    /// Date until which a prescription can be redeemed in the pharmacy without paying
    /// the entire prescription. Note that `acceptDate <= expireDate`
    var acceptDate: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == FHIRResponseKeys.acceptDateKey
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
        `extension`?.first {
            $0.url.value?.url.absoluteString == FHIRResponseKeys.expiryDateKey
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
            $0.url.value?.url.absoluteString == FHIRResponseKeys.coverageStatusKey
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
                $0.url.value == FHIRResponseKeys.dosageFlag
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

extension ModelsR4.MedicationRequest {
    var noctuFeeWaiver: Bool {
        `extension`?.first {
            $0.url.value == FHIRResponseKeys.noctuFeeWaiverKey
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        } ?? false
    }

    var workRelatedAccident: ErxTask.WorkRelatedAccident? {
        guard let accident = `extension`?.first(where: {
            $0.url.value == FHIRResponseKeys.workRelatedAccidentKey
        }) else {
            return nil
        }

        let identifier: String? = accident.extension?.first {
            $0.url.value?.url.absoluteString == "unfallbetrieb"
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(str) = valueX {
                return str.value?.string
            }
            return nil
        }

        let date: String? = accident.extension?.first {
            $0.url.value?.url.absoluteString == "unfalltag"
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.date(date) = valueX,
               let dateString = date.value?.description {
                return dateString
            }
            return nil
        }

        return ErxTask.WorkRelatedAccident(workPlaceIdentifier: identifier,
                                           date: date)
    }

    var substitutionAllowed: Bool {
        if case .boolean(booleanLiteral: true) = substitution?.allowed {
            return true
        }
        return false
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
            $0.system?.value?.url.absoluteString == FHIRResponseKeys.dosageFormKey
        }?.code?.value?.string
    }

    var decimalAmount: Decimal? {
        guard let numerator = amount?.numerator?.value?.value?.decimal,
              let denominator = amount?.denominator?.value?.value?.decimal else { return nil }
        return numerator / denominator
    }

    var dose: String? {
        `extension`?.first {
            $0.url.value == FHIRResponseKeys.medicationDoesKey
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
            $0.system?.value == FHIRResponseKeys.pznKey
        }?.code?.value?.string
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
        type.coding?.contains {
            $0.system?.value == FHIRResponseKeys.documentTypeKey && $0.code?.value == "2"
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

internal enum FHIRResponseKeys {
    static let organisationIdentifierKey: FHIRURI = "https://fhir.kbv.de/NamingSystem/KBV_NS_Base_BSNR"
    static let medicationDoesKey: FHIRURI = "http://fhir.de/StructureDefinition/normgroesse"
    static let workRelatedAccidentKey: FHIRURI = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Accident"
    static let pznKey: FHIRURI = "http://fhir.de/CodeSystem/ifa/pzn"
    static let documentTypeKey: FHIRURI = "https://gematik.de/fhir/CodeSystem/Documenttype"
    static let coverageStatusKey = "http://fhir.de/StructureDefinition/gkv/versichertenart"
    static let prescriptionIdKey = "https://gematik.de/fhir/NamingSystem/PrescriptionID"
    static let accessCodeKey = "https://gematik.de/fhir/NamingSystem/AccessCode"
    static let acceptDateKey = "https://gematik.de/fhir/StructureDefinition/AcceptDate"
    static let expiryDateKey = "https://gematik.de/fhir/StructureDefinition/ExpiryDate"
    static let noctuFeeWaiverKey: FHIRURI = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_EmergencyServicesFee"
    static let dosageFlag: FHIRURI = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_DosageFlag"
    static let kvIDKey = "http://fhir.de/NamingSystem/gkv/kvid-10"
    static let dosageFormKey = "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DARREICHUNGSFORM"
    static let telematikIdKey = "https://gematik.de/fhir/NamingSystem/TelematikID"
}
