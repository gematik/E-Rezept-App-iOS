// swiftlint:disable:this file_name
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

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable file_length

/// Checkout the FHIR Version document for more informations about all types of versions and when they will be applied
/// https://github.com/gematik/api-erp/blob/master/docs/erp_fhirversion.adoc

/// These Code Systems and Value Sets are cited in HL7 Published artifacts
/// (International Standards and Implemenation Guides) in a convenient browsable form.
/// https://terminology.hl7.org/
public enum Terminology {
    /// Supported Versions of HL7 `Terminology` definitions
    public enum Version: String {
        /// https://terminology.hl7.org/5.0.0/
        case v5_0_0 = "5.0.0"
    }

    /// Supported Keys of HL7 `Terminology` definitions
    ///
    /// If there is no version array the key is equal over all supported versions
    public enum Key {
        /// http://terminology.hl7.org/CodeSystem
        public enum CodeSystem {
            /// Act Code
            public static let actCode = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
            /// Consent Scope
            public static let consentScope = "http://terminology.hl7.org/CodeSystem/consentscope"
            /// Service Type
            public static let serviceType = "http://terminology.hl7.org/CodeSystem/service-type"
        }

        /// http://terminology.hl7.org/ValueSet
        public enum ValueSet {
            /// serviceDeliveryLocationRoleType
            public static let serviceDeliveryLocationRoleType =
                "http://terminology.hl7.org/ValueSet/v3-ServiceDeliveryLocationRoleType"
        }
    }
}

/// https://simplifier.net/erezept-workflow
public enum Workflow {
    /// Supported Versions of GEM `Workflow` definitions
    public enum Version {
        /// https://simplifier.net/packages/de.gematik.erezept-workflow.r4/1.1.1
        case v1_1_1
        /// https://simplifier.net/packages/de.gematik.erezept-workflow.r4/1.2.0
        case v1_2_0
        /// https://simplifier.net/packages/de.gematik.erezept-workflow.r4/1.3.0
        case v1_3_0
        /// https://simplifier.net/packages/de.gematik.erezept-workflow.r4/1.4.3
        case v1_4_3
    }

    /// Supported Keys of GEM `Workflow` definitions
    public enum Key {
        /// indicates when that last medication dispense has been created
        public static let lastMedicationDispense: [Version: String] = [
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_LastMedicationDispense",
            .v1_4_3:
                "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_LastMedicationDispense",
        ]

        /// Prescription Type
        public static let prescriptionTypeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/PrescriptionType",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_PrescriptionType",
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_PrescriptionType",
            .v1_4_3: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_PrescriptionType",
        ]
        /// Flow Type
        public static let flowTypeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/CodeSystem/Flowtype",
            .v1_2_0: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_FlowType",
            .v1_3_0: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_FlowType",
            .v1_4_3: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_FlowType",
        ]
        /// Document Type
        public static let documentTypeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/CodeSystem/Documenttype",
            .v1_2_0: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_DocumentType",
            .v1_3_0: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_DocumentType",
            .v1_4_3: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_DocumentType",
        ]
        /// Prescription ID
        public static let prescriptionIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/PrescriptionID",
            .v1_2_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId",
            .v1_3_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId",
            .v1_4_3: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId",
        ]
        /// Access Code
        public static let accessCodeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/AccessCode",
            .v1_2_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_AccessCode",
            .v1_3_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_AccessCode",
            .v1_4_3: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_AccessCode",
        ]
        /// Accept Date
        public static let acceptDateKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/AcceptDate",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate",
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate",
            .v1_4_3: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate",
        ]
        /// Expiry Date
        public static let expiryDateKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ExpiryDate",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_ExpiryDate",
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_ExpiryDate",
            .v1_4_3: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_ExpiryDate",
        ]
        /// Telematik ID
        public static let telematikIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/TelematikID",
            .v1_2_0: "https://gematik.de/fhir/sid/telematik-id",
            .v1_3_0: "https://gematik.de/fhir/sid/telematik-id",
            .v1_4_3: "https://gematik.de/fhir/sid/telematik-id",
        ]
        /// Communication Reply
        public static let communicationReply: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationReply",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Reply",
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Reply",
            .v1_4_3: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Reply",
        ]
        /// Communication Dispense Request
        public static let communicationDispReq: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationDispReq",
            .v1_4_3: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_DispReq",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_DispReq",
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_DispReq",
        ]
        /// Communication Info Request
        public static let communicationInfoReq: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationInfoReq",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_InfoReq",
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_InfoReq",
            .v1_4_3: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_InfoReq",
        ]
        /// Communication Representative
        public static let communicationRepresentative: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationRepresentative",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Representative",
            .v1_3_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Representative",
            .v1_4_3: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Representative",
        ]
        /// Insured Person ID
        public static let kvIDKeys: [Version: String] = [
            .v1_1_1: "http://fhir.de/NamingSystem/gkv/kvid-10",
            .v1_2_0: "http://fhir.de/sid/gkv/kvid-10",
            .v1_3_0: "http://fhir.de/sid/gkv/kvid-10",
            .v1_4_3: Self.unifiedKvIDKeys[.v1_4_3]!, // swiftlint:disable:this force_unwrapping
        ]
        /// Insured Person ID
        /// // to-do: delete when FD is talking workflow >= 1.4.3 only
        public static let pkvIDKeys: [Version: String] = [
            .v1_2_0: "http://fhir.de/sid/pkv/kvid-10",
            .v1_3_0: "http://fhir.de/sid/pkv/kvid-10",
            .v1_4_3: Self.unifiedKvIDKeys[.v1_4_3]!, // swiftlint:disable:this force_unwrapping
        ]
        /// Insured Person ID
        /// "Der PKV- und GKV-Identifier wurde in den deutschen Basisprofilen mit folgendem .system vereinheitlicht"
        public static let unifiedKvIDKeys: [Version: String] = [
            .v1_4_3: "http://fhir.de/sid/gkv/kvid-10",
        ]
        /// Order ID
        public static let orderIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/OrderID",
            .v1_2_0: "https://gematik.de/fhir/NamingSystem/OrderID",
            .v1_3_0: "https://gematik.de/fhir/NamingSystem/OrderID",
            .v1_4_3: "https://gematik.de/fhir/NamingSystem/OrderID",
        ]
    }
}

/// Prescription profiles specified by the KBV which holds all informations
/// about the prescription (also called KBV-Bundle)
/// https://simplifier.net/eRezept/
public enum ErpPrescription {
    /// Supported Versions of KBV `Prescription` definitions
    public enum Version: String {
        /// https://simplifier.net/packages/kbv.ita.erp/1.0.2
        case v1_0_2 = "1.0.2"
        /// https://simplifier.net/packages/kbv.ita.erp/1.1.0
        case v1_1_0 = "1.1.0"
    }

    /// Collection of defined keys within the KBV profiles (begins with `fhir.kbv.de/`)
    /// Also contains some standard FHIR keys since they were used by the KBV profiles
    ///
    /// If there is no version array the key is equal over all supported versions
    public enum Key {
        /// Medication keys
        public enum Medication {
            /// Medication Type PZN
            public static let medicationTypePZNKey = "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_PZN"
            /// Medication Type free text
            public static let medicationTypeFreeTextKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_FreeText"
            /// Medication Type ingredient
            public static let medicationTypeIngredientKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_Ingredient"
            /// Medication Type compounding
            public static let medicationTypeCompoundingKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_Compounding"
            /// Medication type eML/ePa compatible (used in MedicationDispenses / Dispense Requests)
            public static let medicationTypeGemErpPrMedicationKey =
                "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Medication"
            /// Vaccine
            public static let vaccineKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Vaccine"
            /// Category
            public static let categoryKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Category"
            /// Ingredient Form
            public static let ingredientFormKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Ingredient_Form"
            /// Active Ingredient Number (ASK)
            public static let activeIngredientNumberKey = "http://fhir.de/CodeSystem/ask"
            /// Ingredient Amount
            public static let ingredientAmountKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Ingredient_Amount"
            /// Packaging
            public static let packagingKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Packaging"
            /// Compounding Instruction
            public static let compoundingInstructionKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_CompoundingInstruction"
            /// Packaging Size
            public static let packagingSizeKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_PackagingSize"
            /// Base Medication Type
            public static let baseMedicationTypeKey: [Version: String] = [
                .v1_1_0: "https://fhir.kbv.de/StructureDefinition/KBV_EX_Base_Medication_Type",
            ]
        }

        /// MedicationRequest keys
        public enum MedicationRequest {
            /// Status Copayment
            public static let statusCoPaymentKey: [Version: String] = [
                .v1_0_2: "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_StatusCoPayment",
                .v1_1_0: "https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_StatusCoPayment",
            ]
            /// Nocturne Fee Waiver
            public static let noctuFeeWaiverKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_EmergencyServicesFee"
            /// Federal Supply Act (BVG)
            public static let bvg = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_BVG"
            /// Accident Info
            public static let accidentInfoKey: [Version: String] = [
                .v1_0_2: "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Accident",
                .v1_1_0: "https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_Accident",
            ]
            /// Accident Type
            public static let accidentTypeKey: [Version: String] = [
                .v1_0_2: "unfallkennzeichen",
                .v1_1_0: "Unfallkennzeichen",
            ]
            /// Accident Place
            public static let accidentPlaceKey: [Version: String] = [
                .v1_0_2: "unfallbetrieb",
                .v1_1_0: "Unfallbetrieb",
            ]
            /// Accident Date
            public static let accidentDateKey: [Version: String] = [
                .v1_0_2: "unfalltag",
                .v1_1_0: "Unfalltag",
            ]
            /// Multiple Prescription
            public static let multiplePrescriptionKey =
                "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Multiple_Prescription"
            /// Multiple Prescription Period
            public static let multiplePrescriptionPeriod = "Zeitraum"
            /// Multiple Prescription Mark
            public static let multiplePrescriptionMark = "Kennzeichen"
            /// Multiple Prescription Number
            public static let multiplePrescriptionNumber = "Nummerierung"
            /// Key for the dosage informations toggle
            public static let dosageInstructionFlagKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_DosageFlag"
            /// This is used by PVS software to indicate, that a Medikationsplan or another form of
            /// dosage instruction has been provided
            /// source: KBV_ITA_SIEX_Infos_Dosierungsangabe
            public static let dosageInstructionDj = "Dj"
        }

        /// DeviceRequest keys
        public enum DeviceRequest {
            /// Accident Info
            public static let accidentInfoKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_Accident"
            /// Accident Type
            public static let accidentTypeKey = "Unfallkennzeichen"
            /// Accident Place
            public static let accidentPlaceKey = "Unfallbetrieb"
            /// Accident Date
            public static let accidentDateKey = "Unfalltag"
            /// SER Info
            public static let serInfoKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_EVDGA_SER"
            /// redeem code (used in MedicationDispenses)
            public static let redeemCode = "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_RedeemCode"
            ///
            public static let deepLink = "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_DeepLink"
        }

        /// CoverageType
        public static let coverageTypeKey = "http://fhir.de/CodeSystem/versicherungsart-de-basis"
        /// Coverage Status
        public static let coverageStatusKey = "http://fhir.de/StructureDefinition/gkv/versichertenart"
        /// Organisation ID
        public static let organisationIdentifierKey = "https://fhir.kbv.de/NamingSystem/KBV_NS_Base_BSNR"
        /// Medication Norm Size Code
        public static let medicationNormSizeCodeKey = "http://fhir.de/StructureDefinition/normgroesse"

        /// Pharmaceutical Number (PZN)
        public static let pznKey = "http://fhir.de/CodeSystem/ifa/pzn"
        /// Dosage Flag
        public static let dosageFlag = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_DosageFlag"
        /// Legal Insured Person ID
        public static let gkvKvIDKeys: [Version: String] = [
            .v1_0_2: "http://fhir.de/NamingSystem/gkv/kvid-10",
            .v1_1_0: "http://fhir.de/sid/gkv/kvid-10",
        ]
        /// Privately Insured Person ID
        public static let pkvKvIDKeys: [Version: String] = [
            .v1_0_2: "http://www.acme.com/identifiers/patient",
            .v1_1_0: "http://fhir.de/sid/pkv/kvid-10",
        ]
        /// Dosage Form
        public static let dosageFormKey = "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DARREICHUNGSFORM"
    }
}

/// Epa Medication profiles specified gematik
/// https://simplifier.net/packages/de.gematik.epa.medication/1.1.1/files/2532738
public enum EpaMedication {
    /// Supported Versions EPA medication definitions
    public enum Version: String {
        // https://simplifier.net/packages/de.gematik.epa.medication/1.1.1
        case v1_1_1 = "1.1.1"
    }

    /// Supported Keys of EPA medication definitions
    public enum Key {
        /// Extension for EPAMedication types
        public static let typeExtensionKey =
            "https://gematik.de/fhir/epa-medication/StructureDefinition/epa-medication-type-extension"

        /// Medication PZN Ingredient (in Rezepturen enthalten)
        public static let pznIngredientKey =
            "https://gematik.de/fhir/epa-medication/StructureDefinition/epa-medication-pzn-ingredient"

        /// Medication Pharmaceutical Product (in Kombipackungen enthalten)
        public static let pharmaceuticalProductKey =
            "https://gematik.de/fhir/epa-medication/StructureDefinition/epa-medication-pharmaceutical-product"

        /// Extension for indicating the medication category.
        public static let drugCategoryExtensionKey =
            "https://gematik.de/fhir/epa-medication/StructureDefinition/drug-category-extension"

        /// Dosage form of an ingredient in a formulation.
        public static let ingredientDarreichungsformExtensionKey =
            // swiftlint:disable:next line_length
            "https://gematik.de/fhir/epa-medication/StructureDefinition/medication-ingredient-darreichungsform-extension"

        /// Amount text in Ingredient's strength
        public static let ingredientAmountExtensionKey =
            "https://gematik.de/fhir/epa-medication/StructureDefinition/medication-ingredient-amount-extension"
    }
}

/// https://simplifier.net/erezept-patientenrechnung
public enum ErpCharge {
    /// Supported Versions of GEM `ErpCharge` definitions
    public enum Version {
        /// https://simplifier.net/packages/de.gematik.erezept-patientenrechnung.r4/1.0.0
        case v1_0_0
    }

    /// Supported Keys of GEM `ErpCharge` definitions
    public enum Key {
        /// Consent keys
        public enum Consent {
            /// Consent
            public static let consent: [Version: String] = [
                .v1_0_0: "https://gematik.de/fhir/erpchrg/StructureDefinition/GEM_ERPCHRG_PR_Consent",
            ]
            /// Consent Type
            public static let consentType: [Version: String] = [
                .v1_0_0: "https://gematik.de/fhir/erpchrg/CodeSystem/GEM_ERPCHRG_CS_ConsentType",
            ]
        }

        /// ChargeItem keys
        public enum ChargeItem {
            /// Prescription Bundle
            public static let prescriptionBundle: [Version: String] = [
                .v1_0_0: "https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Bundle",
            ]
            /// Receipt Bundle
            public static let receiptBundle: [Version: String] = [
                .v1_0_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Bundle",
            ]
            /// Dispense Bundle
            public static let dispenseBundle: [Version: String] = [
                .v1_0_0: "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenBundle",
            ]
        }
    }
}

/// https://simplifier.net/packages/de.abda.eRezeptAbgabedatenPKV
public struct ABDAERezeptAbgabedaten {
    /// Available Profile Versions
    public enum Version: String {
        /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.1.0
        case v1_1 = "1.1"
        /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.2.0
        case v1_2 = "1.2"
        /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.3.0
        case v1_3 = "1.3"
    }

    /// instanced DAV_PKV_PR_ERP_AbgabedatenComposition profile
    public let dAV_PKV_PR_ERP_AbgabedatenComposition: DAV_PKV_PR_ERP_AbgabedatenComposition
    /// instanced DAV_EX_ERP_Abrechnungszeilen profile
    public let dAV_EX_ERP_Abrechnungszeilen: DAV_EX_ERP_Abrechnungszeilen
    /// instanced DAV_EX_ERP_ZusatzdatenHerstellung profile
    public let dAV_EX_ERP_ZusatzdatenHerstellung: DAV_EX_ERP_ZusatzdatenHerstellung
    /// instanced DAV_EX_ERP_ZusatzdatenEinheit profile
    public let dAV_EX_ERP_ZusatzdatenEinheit: DAV_EX_ERP_ZusatzdatenEinheit

    /// Default initalizer
    public init?(from string: String) {
        guard let version = Version(rawValue: string) else { return nil }
        dAV_PKV_PR_ERP_AbgabedatenComposition =
            DAV_PKV_PR_ERP_AbgabedatenComposition(version: .init(abdaVersion: version))
        dAV_EX_ERP_Abrechnungszeilen = DAV_EX_ERP_Abrechnungszeilen(version: .init(abdaVersion: version))
        dAV_EX_ERP_ZusatzdatenHerstellung = DAV_EX_ERP_ZusatzdatenHerstellung(version: .init(abdaVersion: version))
        dAV_EX_ERP_ZusatzdatenEinheit = DAV_EX_ERP_ZusatzdatenEinheit(version: .init(abdaVersion: version))
    }

    /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.3.0/files/2527401
    public struct DAV_PKV_PR_ERP_AbgabedatenComposition {
        /// Available Profile Versions
        public enum Version: String {
            case v1_1 = "1.1"
            case v1_2 = "1.2"
            case v1_3 = "1.3"

            init(abdaVersion: ABDAERezeptAbgabedaten.Version) {
                switch abdaVersion {
                case .v1_1: self = .v1_1
                case .v1_2: self = .v1_2
                case .v1_3: self = .v1_3
                }
            }
        }

        /// Profile Version
        public let version: Version

        /// Profile name used within meta
        public var meta_profile: String {
            switch version {
            case .v1_1:
                // swiftlint:disable line_length
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenComposition"
            case .v1_2:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenComposition"
            case .v1_3:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenComposition"
                // swiftlint:enable line_length
            }
        }

        /// Key used for retrieving dispense information reference
        public var dispenseInformationKey = "Abgabeinformationen"
    }

    /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.2.0/files/1966865
    public struct DAV_EX_ERP_Abrechnungszeilen {
        /// Available Profile Versions
        public enum Version: String {
            case v1_1 = "1.1"
            case v1_2 = "1.2"
            case v1_3 = "1.3"

            init(abdaVersion: ABDAERezeptAbgabedaten.Version) {
                switch abdaVersion {
                case .v1_1: self = .v1_1
                case .v1_2: self = .v1_2
                case .v1_3: self = .v1_3
                }
            }
        }

        /// Profile Version
        public let version: Version

        /// Profile name used within meta
        public var meta_profile: String {
            switch version {
            case .v1_1: return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Abrechnungszeilen"
            case .v1_2: return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Abrechnungszeilen"
            case .v1_3: return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Abrechnungszeilen"
            }
        }
    }

    /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.3.0/files/2527406
    public struct DAV_EX_ERP_ZusatzdatenHerstellung {
        /// Available Profile Versions
        public enum Version: String {
            case v1_1 = "1.1"
            case v1_2 = "1.2"
            case v1_3 = "1.3"

            init(abdaVersion: ABDAERezeptAbgabedaten.Version) {
                switch abdaVersion {
                case .v1_1: self = .v1_1
                case .v1_2: self = .v1_2
                case .v1_3: self = .v1_3
                }
            }
        }

        /// Profile Version
        public let version: Version

        /// Profile name used within meta
        public var meta_profile: String {
            switch version {
            case .v1_1:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-ZusatzdatenHerstellung"
            case .v1_2:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-ZusatzdatenHerstellung"
            case .v1_3:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-ZusatzdatenHerstellung"
            }
        }
    }

    /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.3.0/files/2527405
    public struct DAV_EX_ERP_ZusatzdatenEinheit {
        /// Available Profile Versions
        public enum Version: String {
            case v1_1 = "1.1"
            case v1_2 = "1.2"
            case v1_3 = "1.3"

            init(abdaVersion: ABDAERezeptAbgabedaten.Version) {
                switch abdaVersion {
                case .v1_1: self = .v1_1
                case .v1_2: self = .v1_2
                case .v1_3: self = .v1_3
                }
            }
        }

        /// Profile Version
        public let version: Version

        /// Profile name used within meta
        public var meta_profile: String {
            switch version {
            case .v1_1:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-ZusatzdatenEinheit"
            case .v1_2:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-ZusatzdatenEinheit"
            case .v1_3:
                return "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-ZusatzdatenEinheit"
            }
        }

        /// Extension for some counter element
        public let extension_counter = "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Zaehler"
    }
}

// ChargeItem
//   - AbgabedatenBundle
//      - AbgabedatenComposition
//      - Organisation (pharmacy)
//      - Abgabeinformation/MedicationDispense
//      - invoice
//      - MedicationDispense
//      - invoice

/// https://simplifier.net/erezeptabgabedatenpkv
public enum Dispense {
    /// Supported Versions of DAV `Dispense` definitions
    public enum Version {
        /// https://simplifier.net/packages/de.abda.erezeptabgabedatenpkv/1.2.0
        case v1_2_0
    }

    /// Supported Keys of DAV `Dispense` definitions
    public enum Key {
        /// Total Additional Fee
        public static let totalAdditionalFee: [Version: String] = [
            .v1_2_0: "http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Gesamtzuzahlung",
        ]
        /// Organisation ID
        public static let organisationIdentifier: [Version: String] = [
            .v1_2_0: "http://fhir.de/sid/arge-ik/iknr",
        ]

        /// ChargeItem keys
        public enum ChargeItem {
            /// Aid Number (HMNR)
            public static let hmnr: [Version: String] = [
                .v1_2_0: "http://fhir.de/sid/gkv/hmnr",
            ]
            /// Medication Dispense Number (TA1)
            public static let ta1: [Version: String] = [
                .v1_2_0: "http://TA1.abda.de",
            ]
            /// Pharmaceutical Number (PZN)
            public static let pzn: [Version: String] = [
                .v1_2_0: "http://fhir.de/CodeSystem/ifa/pzn",
            ]
        }
    }
}

/// https://simplifier.net/vzd-fhir-directory
public enum FHIRDirectory {
    /// Supported Versions of GEM `Workflow` definitions
    public enum Version {
        /// https://simplifier.net/packages/de.gematik.fhir.directory/0.12.0
        case v0_12_0
    }

    /// Supported Keys of GEM `FHIRDirectory` definitions
    public enum Key {
        /// Specialty key for pharmacies
        public static let specialtyKey = "apo-vzd"

        /// The codes for Organizations based on Profession OID's
        /// https://gematik.de/fhir/directory/CodeSystem/OrganizationProfessionOID
        public enum OrganizationProfession: String, Equatable, Codable {
            /// public pharmacies (Öffentliche Apotheke)
            case publicPharmacy = "1.2.276.0.76.4.54"
            /// cost-carrier (Betriebsstätte Kostenträger)
            case insuranceCompany = "1.2.276.0.76.4.59"
        }

        /// http://terminology.hl7.org/CodeSystem
        public enum CodeSystem {
            /// code system for pharmacy services (e.g. pickup, shipment, delivery)
            public static let pharmacyHealthcareSpecialty =
                "https://gematik.de/fhir/directory/CodeSystem/PharmacyHealthcareSpecialtyCS"
        }
    }
}

// swiftlint:enable identifier_name
// swiftlint:enable file_length
