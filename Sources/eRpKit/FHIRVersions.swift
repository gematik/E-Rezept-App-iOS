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

// swiftlint:disable missing_docs

/// Checkout the FHIR Version document for more informations about all types of versions and when they will be applied
/// https://github.com/gematik/api-erp/blob/master/docs/erp_fhirversion.adoc

/// These Code Systems and Value Sets are cited in HL7 Published artifacts
/// (International Standards and Implemenation Guides) in a convenient browsable form.
/// https://terminology.hl7.org/
public enum Terminology {
    // swiftlint:disable identifier_name
    public enum Version: String {
        case v5_0_0 = "5.0.0"
    }

    public enum Key {
        public enum CodeSystem {
            public static let actCode = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
            public static let consentScope = "http://terminology.hl7.org/CodeSystem/consentscope"
            public static let serviceType = "http://terminology.hl7.org/CodeSystem/service-type"
        }

        public enum ValueSet {
            public static let serviceDeliveryLocationRoleType =
                "http://terminology.hl7.org/ValueSet/v3-ServiceDeliveryLocationRoleType"
        }
    }
}

/// https://simplifier.net/erezept-workflow
public enum Workflow {
    /// Profile version specified by gematik medical team
    public enum Version {
        case v1_1_1
        case v1_2_0
    }

    /// Collection of defined keys within the e-rezept-workflow profiles (begins with `gematik.de/fhir/`)
    public enum Key {
        public static let prescriptionTypeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/PrescriptionType",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_PrescriptionType",
        ]
        public static let flowTypeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/CodeSystem/Flowtype",
            .v1_2_0: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_FlowType",
        ]
        public static let documentTypeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/CodeSystem/Documenttype",
            .v1_2_0: "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_DocumentType",
        ]
        public static let prescriptionIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/PrescriptionID",
            .v1_2_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId",
        ]
        public static let accessCodeKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/AccessCode",
            .v1_2_0: "https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_AccessCode",
        ]
        public static let acceptDateKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/AcceptDate",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_AcceptDate",
        ]
        public static let expiryDateKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ExpiryDate",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_ExpiryDate",
        ]
        public static let telematikIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/TelematikID",
            .v1_2_0: "https://gematik.de/fhir/sid/telematik-id",
        ]
        public static let communicationReply: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationReply",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Reply",
        ]
        public static let communicationDispReq: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationDispReq",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_DispReq",
        ]
        public static let communicationInfoReq: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationInfoReq",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_InfoReq",
        ]
        public static let communicationRepresentative: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/StructureDefinition/ErxCommunicationRepresentative",
            .v1_2_0: "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_Representative",
        ]
        public static let kvIDKeys: [Version: String] = [
            .v1_1_1: "http://fhir.de/NamingSystem/gkv/kvid-10",
            .v1_2_0: "http://fhir.de/sid/gkv/kvid-10",
        ]
        public static let orderIdKeys: [Version: String] = [
            .v1_1_1: "https://gematik.de/fhir/NamingSystem/OrderID",
        ]
    }
}

// swiftlint:enable identifier_name
