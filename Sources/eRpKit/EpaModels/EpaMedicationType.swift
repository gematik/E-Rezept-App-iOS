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

/// ValueSet of valid concepts for EpaMedication
/// https://simplifier.net/packages/de.gematik.epa.medication/1.0.3/files/2539788
public enum EpaMedicationType: String, Equatable, Codable, Sendable {
    /// Kombipackung
    case medicinalProductPackage = "781405001"
    /// Rezeptur
    case extemporaneousPreparation = "1208954007"
    /// Ingredient of a  extemporaneous preparation
    case pharmaceuticalBiologicProduct = "373873005"
}
