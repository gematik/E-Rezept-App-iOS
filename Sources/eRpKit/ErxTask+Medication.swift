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

extension ErxTask {
    /// For informations on medication and it's profiles go to:
    /// https://wiki.gematik.de/display/DEV/eRp+App+-+Medikamententypen+der+KBV
    public struct Medication: Hashable {
        public init(name: String? = nil,
                    profile: ProfileType? = nil,
                    drugCategory: DrugCategory? = nil,
                    pzn: String? = nil,
                    isVaccine: Bool = false,
                    amount: Decimal? = nil,
                    dosageForm: String? = nil,
                    dose: String? = nil,
                    dosageInstructions: String? = nil,
                    lot: String? = nil,
                    expiresOn: String? = nil,
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
            self.dosageInstructions = dosageInstructions
            self.lot = lot
            self.expiresOn = expiresOn
            self.isVaccine = isVaccine
            self.packaging = packaging
            self.manufacturingInstructions = manufacturingInstructions
            self.ingredients = ingredients
        }

        /// Category of the drug
        public let drugCategory: DrugCategory?
        /// Underlying profile used to define the medication
        public let profile: ProfileType?
        /// Displayed name of the medication
        public let name: String?
        /// Number of the medication if it is of profile type .pzn
        public let pzn: String? // DH.TODO: only pzn type //swiftlint:disable:this todo
        /// Specific amount of the drug in the packaged product.
        public let amount: Decimal? // DH.TODO: must be of type ratio //swiftlint:disable:this todo
        /// Describes the form of the item. E.g.: Powder, tablets, capsule. (Darreichungsform)
        public let dosageForm: String?
        /// Describes the therapeutic size for the package (e.g. N1)  /  a.k.a. "Normgroesse"
        public let dose: String?
        public let dosageInstructions: String?
        /// True if marked as vaccine, false if not
        public let isVaccine: Bool
        /// Informations about the packaging
        public let packaging: String? // DH.TODO: only Compounding //swiftlint:disable:this todo
        /// Instructions from the manufacturing company
        public let manufacturingInstructions: String? // TODO: only Compounding //swiftlint:disable:this todo
        ///  (medication Dispense only)
        public let lot: String?
        ///  (medication Dispense only)
        public let expiresOn: String?
        /// Ingredients of the medication (only for profileType .ingredient and .compounding)
        public let ingredients: [Ingredient] // DH.TODO: only ingredient and Compounding //swiftlint:disable:this todo

        /// Category of a drug
        public enum DrugCategory: Equatable {
            // Arznei- und Verbandmittel "00"
            case avm
            // Betaeubungsmittel "01"
            case btm
            // Arzneimittelverschreibungsverordnung "02"
            case amvv
            // Unknown category
            case unknown
        }

        public enum ProfileType {
            case freeText
            case pzn
            case ingredient
            case compounding
            case unknown
        }

        public struct Ingredient: Equatable, Hashable {
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
            public let form: String? //  DH.TODO: nur compounding //swiftlint:disable:this todo
            /// Amount/ strength of the ingredient related to the entire medication
            public let strength: Ratio?
            /// Amount/ strength of the ingredient related to the entire medication in text
            public let strengthFreeText: String? //  DH.TODO: nur compounding //swiftlint:disable:this todo
        }
    }

    public struct Ratio: Equatable, Hashable {
        public init(numerator: ErxTask.Quantity, denominator: ErxTask.Quantity?) {
            self.numerator = numerator
            self.denominator = denominator
        }

        let numerator: Quantity
        let denominator: Quantity?
    }

    public struct Quantity: Equatable, Hashable {
        public init(value: String, unit: String? = nil) {
            self.value = value
            self.unit = unit
        }

        let value: String // DH.TODO: string because next version uses string //swiftlint:disable:this todo
        let unit: String?
    }
}
