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

/// For informations on medication and it's profiles go to:
/// https://wiki.gematik.de/display/DEV/eRp+App+-+Medikamententypen+der+KBV
public struct ErxMedication: Hashable, Codable {
    public init(name: String? = nil,
                profile: ProfileType? = nil,
                drugCategory: DrugCategory? = nil,
                pzn: String? = nil,
                isVaccine: Bool = false,
                amount: Ratio? = nil,
                dosageForm: String? = nil,
                dose: String? = nil,
                batch: Batch? = nil,
                packaging: String? = nil,
                manufacturingInstructions: String? = nil,
                ingredients: [Ingredient] = []) {
        self.name = name
        self.profile = profile
        self.drugCategory = drugCategory
        self.pzn = pzn
        self.amount = amount
        self.dosageForm = dosageForm
        self.dose = dose
        self.batch = batch
        self.isVaccine = isVaccine
        self.packaging = packaging
        self.manufacturingInstructions = manufacturingInstructions
        self.ingredients = ingredients
    }

    /// Category of the drug
    public let drugCategory: DrugCategory?
    /// Underlying profile used to define the medication
    public let profile: ProfileType?
    /// Name of the medication (only for `.pzn`  and  `.freeText` profile types)
    /// - Note: For `.ingredient and .compounding` name should be substituted from `ingredients.first.text`
    public let name: String?
    /// Number of the medication ( only for `.pzn` profile types)
    public let pzn: String?
    /// Specific amount of the drug in the packaged product.
    public let amount: Ratio?
    /// Describes the form of the item. E.g.: Powder, tablets, capsule. (Darreichungsform)
    public let dosageForm: String?
    /// Describes the therapeutic size for the package (e.g. N1)  /  a.k.a. "Normgroesse"
    public let dose: String?
    /// True if marked as vaccine, false if not
    public let isVaccine: Bool
    /// Informations about the packaging (only for .`compounding` profile types)
    public let packaging: String?
    /// Instructions from the manufacturing company  (only for compounding profile types)
    public let manufacturingInstructions: String?
    /// Details about packaged medications (only available with medication dispense)
    public let batch: Batch?
    /// Ingredients of the medication (only for profileType `.ingredient` and `.compounding`)
    public let ingredients: [Ingredient]

    /// Information that only applies to packages.
    public struct Batch: Equatable, Hashable, Codable {
        public init(lotNumber: String? = nil, expiresOn: String? = nil) {
            self.lotNumber = lotNumber
            self.expiresOn = expiresOn
        }

        /// Identifier assigned to batch (charge number of product, only dispensed medications)
        public let lotNumber: String?
        /// When this specific batch of product will expire (only available for dispensed medications)
        public let expiresOn: String?
    }

    /// Category of a drug
    public enum DrugCategory: String, Equatable, Codable {
        // Arznei- und Verbandmittel "00"
        case avm = "00"
        // Betaeubungsmittel "01"
        case btm = "01"
        // Arzneimittelverschreibungsverordnung "02"
        case amvv = "02"
        // Sonstiges
        case other = "03"
        // Unknown category when there was a different category
        case unknown
    }

    public enum ProfileType: String, Equatable, Codable {
        case freeText
        case pzn
        case ingredient
        case compounding
        case unknown
    }

    public struct Ingredient: Equatable, Hashable, Codable {
        public init(
            text: String? = nil,
            number: String? = nil,
            form: String? = nil,
            strength: Ratio? = nil,
            strengthFreeText: String? = nil
        ) {
            self.text = text
            self.number = number
            self.form = form
            self.strength = strength
            self.strengthFreeText = strengthFreeText
        }

        /// Can be name of item
        public let text: String?
        /// Number of the item
        public let number: String?
        /// Describes the form of the item. E.g.: Powder, tablets, capsule. (Darreichungsform)
        /// (only available for `.compounding` medications)
        public let form: String?
        /// Amount/ strength of the ingredient related to the entire medication
        public let strength: Ratio?
        /// Amount/ strength of the ingredient related to the entire medication in text
        /// (only available for `.compounding` medications)
        public let strengthFreeText: String?
    }

    public struct Ratio: Equatable, Hashable, Codable, CustomStringConvertible {
        public init(numerator: Quantity, denominator: Quantity? = nil) {
            self.numerator = numerator
            self.denominator = denominator
        }

        public let numerator: Quantity
        public let denominator: Quantity?

        public var description: String {
            guard let denominator = denominator, denominator.value != "1" else {
                return "\(numerator.description)"
            }
            return "\(numerator.description) / \(denominator.description)"
        }
    }

    public struct Quantity: Equatable, Hashable, Codable, CustomStringConvertible {
        public init(value: String, unit: String? = nil) {
            self.value = value
            self.unit = unit
        }

        // we use string (instead Decimal) as value because in the new KBV profiles strings are used
        public let value: String
        public let unit: String?

        public var description: String {
            guard let unit = unit else {
                return value
            }
            return "\(value) \(unit)"
        }
    }
}
