// swiftlint:disable:this file_name
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

import Foundation

/// Checkout the FHIR Version document for more informations about all types of versions and when they will be applied
/// https://github.com/gematik/api-erp/blob/master/docs/erp_fhirversion.adoc

/// Prescription profiles specified by the KBV which holds all informations
/// about the prescription (also called KBV-Bundle)
/// https://simplifier.net/eRezept/
enum Prescription {
    // swiftlint:disable identifier_name
    enum Version: String {
        case v1_0_2 = "1.0.2"
        case v1_1_0 = "1.1.0"
    }

    /// Collection of defined keys within the KBV profiles (begins with `fhir.kbv.de/`)
    /// Also contains some standard FHIR keys since they were used by the KBV profiles
    /// Note: If there is no version array the key is equal over all versions
    enum Key {
        enum Medication {
            static let medicationTypePZNKey = "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_PZN"
            static let medicationTypeFreeTextKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_FreeText"
            static let medicationTypeIngredientKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_Ingredient"
            static let medicationTypeCompoundingKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_Compounding"
            static let vaccineKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Vaccine"
            static let categoryKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Category"
            static let ingredientFormKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Ingredient_Form"
            static let wirkstoffNumberKey = "http://fhir.de/CodeSystem/ask"
            static let ingredientAmountKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Ingredient_Amount"
            static let packagingKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Packaging"
            static let compoundingInstructionKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_CompoundingInstruction"
            static let packagingSizeKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_PackagingSize"

            static let baseMedicationTypeKey: [Version: String] = [
                .v1_1_0: "https://fhir.kbv.de/StructureDefinition/KBV_EX_Base_Medication_Type",
            ]
        }

        enum MedicationRequest {
            static let statusCoPaymentKey: [Version: String] = [
                .v1_0_2: "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_StatusCoPayment",
                .v1_1_0: "https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_StatusCoPayment",
            ]
            static let noctuFeeWaiverKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_EmergencyServicesFee"
            static let bvg = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_BVG"
            static let accidentInfoKey: [Version: String] = [
                .v1_0_2: "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Accident",
                .v1_1_0: "https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_Accident",
            ]
            static let accidentTypeKey: [Version: String] = [
                .v1_0_2: "unfallkennzeichen",
                .v1_1_0: "Unfallkennzeichen",
            ]
            static let accidentPlaceKey: [Version: String] = [
                .v1_0_2: "unfallbetrieb",
                .v1_1_0: "Unfallbetrieb",
            ]
            static let accidentDateKey: [Version: String] = [
                .v1_0_2: "unfalltag",
                .v1_1_0: "Unfalltag",
            ]
            static let multiplePrescriptionKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Multiple_Prescription"
            static let multiplePrescriptionPeriod = "Zeitraum"
            static let multiplePrescriptionMark = "Kennzeichen"
            static let multiplePrescriptionNumber = "Nummerierung"
        }

        static let coverageStatusKey = "http://fhir.de/StructureDefinition/gkv/versichertenart"
        static let organisationIdentifierKey = "https://fhir.kbv.de/NamingSystem/KBV_NS_Base_BSNR"
        static let medicationDoesKey = "http://fhir.de/StructureDefinition/normgroesse"

        static let pznKey = "http://fhir.de/CodeSystem/ifa/pzn"
        static let dosageFlag = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_DosageFlag"
        static let gkvKvIDKeys: [Version: String] = [
            .v1_0_2: "http://fhir.de/NamingSystem/gkv/kvid-10",
            .v1_1_0: "http://fhir.de/sid/gkv/kvid-10",
        ]
        static let pkvKvIDKeys: [Version: String] = [
            .v1_0_2: "http://www.acme.com/identifiers/patient",
            .v1_1_0: "http://fhir.de/sid/pkv/kvid-10",
        ]
        static let dosageFormKey = "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DARREICHUNGSFORM"
    }
}

/// https://simplifier.net/erezept-patientenrechnung
enum ErpCharge {
    /// Profile version specified by gematik
    enum Version {
        case v1_0_0
    }

    enum Key {
        enum Consent {
            static let consent: [Version: String] = [
                .v1_0_0: "https://gematik.de/fhir/erpchrg/StructureDefinition/GEM_ERPCHRG_PR_Consent",
            ]
            static let consentType: [Version: String] = [
                .v1_0_0: "https://gematik.de/fhir/erpchrg/CodeSystem/GEM_ERPCHRG_CS_ConsentType",
            ]
        }

        enum ChargeItem {
            static let prescriptionBundle: [Version: String] = [
                .v1_0_0: "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Bundle",
            ]
            static let receiptBundle: [Version: String] = [
                .v1_0_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Bundle",
            ]
            static let dispenseBundle: [Version: String] = [
                .v1_0_0: "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenBundle",
            ]
        }
    }
}

/// https://simplifier.net/packages/de.abda.erezeptabgabedaten
enum Dispense {
    enum Version {
        case v1_3_0
    }

    enum Key {
        static let totalAdditionalFee: [Version: String] = [
            .v1_3_0: "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Gesamtzuzahlung",
        ]

        static let organisationIdentifier: [Version: String] = [
            .v1_3_0: "http://fhir.de/sid/arge-ik/iknr",
        ]

        enum ChargeItem {
            static let hmnr: [Version: String] = [
                .v1_3_0: "http://fhir.de/sid/gkv/hmnr",
            ]
            static let ta1: [Version: String] = [
                .v1_3_0: "http://TA1.abda.de",
            ]
            static let pzn: [Version: String] = [
                .v1_3_0: "http://fhir.de/CodeSystem/ifa/pzn",
            ]
        }
    }
}

// swiftlint:enable identifier_name
