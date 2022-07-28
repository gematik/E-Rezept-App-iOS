// swiftlint:disable:this file_name
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

import Foundation

/// Checkout the FHIR Version document for more informations about all types of versions and when they will be applied
/// https://github.com/gematik/api-erp/blob/master/docs/erp_fhirversion.adoc

/// Prescription profiles specified by the KBV which holds all informations
/// about the prescription (also called KBV-Bundle)
/// https://simplifier.net/eRezept/
enum Prescription {
    // swiftlint:disable identifier_name
    enum Version {
        case v1_0_2
        case v1_1_0
    }

    /// Collection of defined keys within the KBV profiles (begins with `fhir.kbv.de/`)
    /// Also contains some standard FHIR keys since they were used by the KBV profiles
    enum Key {
        static let coverageStatusKey = "http://fhir.de/StructureDefinition/gkv/versichertenart"
        static let organisationIdentifierKey = "https://fhir.kbv.de/NamingSystem/KBV_NS_Base_BSNR"
        static let medicationDoesKey = "http://fhir.de/StructureDefinition/normgroesse"
        static let workRelatedAccidentKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Accident"
        static let pznKey = "http://fhir.de/CodeSystem/ifa/pzn"

        static let noctuFeeWaiverKey = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_EmergencyServicesFee"
        static let dosageFlag = "https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_DosageFlag"
        static let kvIDKeys: [Version: String] = [
            .v1_0_2: "http://fhir.de/NamingSystem/gkv/kvid-10",
            .v1_1_0: "http://fhir.de/sid/gkv/kvid-10",
        ]
        static let dosageFormKey = "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DARREICHUNGSFORM"
    }
}

/// https://simplifier.net/erezept-workflow
enum Workflow {
    /// Profile version specified by gematik medical team
    enum Version {
        case v1_1_1
        case v1_2_0
    }

    /// Collection of defined keys within the e-rezept-workflow profiles (begins with `gematik.de/fhir/`)
    enum Key {
        static let documentTypeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/CodeSystem/Documenttype",
            .v1_2_0: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_DocumentType",
        ]
        static let prescriptionIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/PrescriptionID",
            .v1_2_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId",
        ]
        static let accessCodeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/AccessCode",
            .v1_2_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_AccessCode",
        ]
        static let acceptDateKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/AcceptDate",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate",
        ]
        static let expiryDateKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ExpiryDate",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_ExpiryDate",
        ]
        static let telematikIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/TelematikID",
            .v1_2_0: "https://gematik.de/fhir/sid/telematik-id",
        ]
        static let communicationReply: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationReply",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Reply",
        ]
        static let communicationDispReq: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationDispReq",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_DispReq",
        ]
        static let communicationInfoReq: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationInfoReq",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_InfoReq",
        ]
        static let communicationRepresentative: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationRepresentative",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Representative",
        ]
        static let kvIDKeys: [Version: String] = [
            .v1_1_1: "http://fhir.de/NamingSystem/gkv/kvid-10",
            .v1_2_0: "http://fhir.de/sid/gkv/kvid-10",
        ]
    }
}

// swiftlint:enable identifier_name
