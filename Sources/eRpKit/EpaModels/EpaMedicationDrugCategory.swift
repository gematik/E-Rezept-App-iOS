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

/// Category of a drug
/// https://gematik.de/fhir/terminology/CodeSystem/epa-drug-category-cs
public enum EpaMedicationDrugCategory: String, Equatable, Codable, Sendable {
    // "00" Arzneimittel oder in die Arzneimittelversorgung nach § 31 SGB V einbezogenes Produkt
    case avm = "00"
    // "01" BtM Betäubungsmittel
    case btm = "01"
    // "02" AMVV § 3a Abs. 1 (Thalidomid o. ä.) (Arzneimittelverschreibungsverordnung)
    case amvv = "02"
    // Sonstiges
    case other = "03"
}
