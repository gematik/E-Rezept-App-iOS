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
