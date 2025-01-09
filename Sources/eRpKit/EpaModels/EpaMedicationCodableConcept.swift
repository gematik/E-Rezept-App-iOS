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

/// Represents `code.coding`'s field tye of `EpaMedication` resource
public typealias EpaMedicationCodeCodableConcept = EpaMedicationCodableConcept<CodeCodingSystem>

/// Represents `ingredient.item.itemCodableConcept.code.coding`'s field tye of `EpaMedication` resource
public typealias EpaMedicationIngredientItemCodableConcept = EpaMedicationCodableConcept<IngredientItemCodingSystem>
// swiftlint:disable:previous type_name

/// Represents `ingredient.item.itemCodableConcept.code.coding`'s field tye of `EpaMedication` resource
public typealias EpaMedicationFormCodableConcept = EpaMedicationCodableConcept<FormCodingSystem>

public enum CodeCodingSystem: String, EpaMedicationCodingSystem {
    case pzn = "http://fhir.de/CodeSystem/ifa/pzn"
    case ask = "http://fhir.de/CodeSystem/ask"
    case atcDe = "http://fhir.de/CodeSystem/bfarm/atc"
    case snomed = "http://snomed.info/sct"
    case productKey =
        "https://terminologieserver.bfarm.de/fhir/CodeSystem/arzneimittel-referenzdaten-pharmazeutisches-produkt"
}

public enum IngredientItemCodingSystem: String, EpaMedicationCodingSystem {
    case ask = "http://fhir.de/CodeSystem/ask"
    case atcDe = "http://fhir.de/CodeSystem/bfarm/atc"
    case snomed = "http://snomed.info/sct"
}

public enum FormCodingSystem: String, EpaMedicationCodingSystem {
    case edqm = "http://standardterms.edqm.eu"
    case snomed = "http://snomed.info/sct"
    case kbvDarreichungsform = "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DARREICHUNGSFORM"
}

public protocol EpaMedicationCodingSystem: Equatable, Hashable, Codable, Sendable {}

public struct EpaMedicationCoding<CodingSystem: EpaMedicationCodingSystem>: Equatable, Hashable, Codable, Sendable {
    public let system: CodingSystem
    public let version: String?
    public let code: String
    public let display: String?
    let userSelected: Bool?

    public init(
        system: CodingSystem,
        version: String? = nil,
        code: String,
        display: String? = nil,
        userSelected: Bool? = nil
    ) {
        self.system = system
        self.version = version
        self.code = code
        self.display = display
        self.userSelected = userSelected
    }
}

public struct EpaMedicationCodableConcept<System: EpaMedicationCodingSystem>: Equatable, Hashable, Codable, Sendable {
    /// A reference to a code defined by a terminology system.
    public let codings: [EpaMedicationCoding<System>]
    /// A human language representation of the concept as seen/selected/uttered by the user
    /// who entered the data and/or which represents the intended meaning of the user.
    public let text: String?

    public init(codings: [EpaMedicationCoding<System>], text: String? = nil) {
        self.codings = codings
        self.text = text
    }
}
