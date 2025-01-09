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

public struct EpaMedicationIngredient: Equatable, Hashable, Codable, Sendable {
    public enum Item: Equatable, Hashable, Codable, Sendable {
        case codableConcept(EpaMedicationCodeCodableConcept)
        /// When the ingredients is itself an EpaMedication. It may be a
        ///  *MedicationPznIngredient* when the "main" medication is an *extemporaneous preparation* (Rezeptur) or
        ///  *MedicationPharmaceuticalProduct* when the "main" medication is a *medicinalProductPackage* (Kombipackung)
        case epaMedication(ErxEpaMedication)
    }

    public struct Strength: Equatable, Hashable, Codable, Sendable {
        public let ratio: EpaMedicationRatio
        public let amountText: String?

        public init(ratio: EpaMedicationRatio, amountText: String?) {
            self.ratio = ratio
            self.amountText = amountText
        }
    }

    public let item: Item
    /// Indication of whether this ingredient affects the therapeutic action of the drug.
    public let isActive: Bool?
    /// Amount/ strength of the ingredient related to the entire medication
    public let strength: Strength?
    /// Dosage form of an ingredient in a formulation.
    /// The dosage form as free text can be used if the ingredient in the formulation
    ///  is not a finished medicinal product.
    public let darreichungsForm: String?

    public init(
        item: Item,
        isActive: Bool? = nil,
        strength: Strength? = nil,
        darreichungsForm: String? = nil
    ) {
        self.item = item
        self.isActive = isActive
        self.strength = strength
        self.darreichungsForm = darreichungsForm
    }
}
