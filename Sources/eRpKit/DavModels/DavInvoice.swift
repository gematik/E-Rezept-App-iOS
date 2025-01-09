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

/// Acts as the intermediate data model from a `ModelsR4.Invoice` resource response
/// and the local store representation
public struct DavInvoice: Hashable, Codable {
    public init(
        totalAdditionalFee: Decimal,
        totalGross: Decimal,
        currency: String,
        chargeableItems: [ChargeableItem] = [],
        productionSteps: [Production] = []
    ) {
        self.totalAdditionalFee = totalAdditionalFee
        self.totalGross = totalGross
        self.currency = currency
        self.chargeableItems = chargeableItems
        self.productionSteps = productionSteps
    }

    /// Specification of the total additional costs of the insured person
    public let totalAdditionalFee: Decimal
    /// An amount of economic utility in some recognized currency (taxes included).
    public let totalGross: Decimal
    /// ISO 4217 currency code
    public let currency: String
    /// Reference to ChargeItem containing details of this line item or an inline billing code
    public let chargeableItems: [ChargeableItem]

    public let productionSteps: [Production]
}

extension DavInvoice {
    public struct ChargeableItem: Hashable, Codable {
        public init(
            factor: Decimal,
            price: Decimal?,
            description: String? = nil,
            pzn: String? = nil,
            ta1: String? = nil,
            hmrn: String? = nil,
            zusatzattribut: Zusatzattribut? = nil
        ) {
            self.factor = factor
            self.price = price
            self.description = description
            self.pzn = pzn
            self.ta1 = ta1
            self.hmrn = hmrn
            self.zusatzattribut = zusatzattribut
        }

        /// The factor that has been applied on the base price for calculating this component
        public let factor: Decimal
        /// An amount of economic utility in some recognized currency.
        public let price: Decimal?
        /// Handelsname und Packungsgröße
        public let description: String?
        /// Pharmazentralnummer (PZN)
        public let pzn: String?
        /// Sonderkennzeichen aus der Technischen Anlage 1 zur Arzneimittelabrechnungsvereinbarung
        public let ta1: String?
        /// Hilfsmittelpositionsnummer bei Applikationshilfen ohne PZN
        public let hmrn: String?
        /// Zusätzliche Angaben aufgrund AMPreisV, etc.
        public let zusatzattribut: Zusatzattribut?

        public enum Zusatzattribut: Hashable, Codable {
            // Datum und Uhrzeit der Abgabe
            case notdienst(String)
            // Freitextfeld
            case zusätzlicheAbgabeangaben(String)
            // Spender-PZN
            case teilmengenabgabe(String)
            // 1= Patientenwunsch, 2= Nicht-Verfügbarkeit, 3= dringender Fall, 4= sonstige Bedenken + ggf. Freitext
            case autidem(String)
        }
    }

    public struct Production: Hashable, Codable {
        public init(title: String, createdOn: String, sequence: String, ingredients: [Ingredient]) {
            self.title = title
            self.createdOn = createdOn
            self.sequence = sequence
            self.ingredients = ingredients
        }

        public let title: String
        public let createdOn: String
        public let sequence: String
        public let ingredients: [Ingredient]

        public struct Ingredient: Hashable, Codable {
            public init(pzn: String, factorMark: String?, factor: Decimal?, price: Decimal) {
                self.pzn = pzn
                self.factorMark = factorMark
                self.factor = factor
                self.price = price
            }

            public let pzn: String
            public let factorMark: String?
            public let factor: Decimal?
            public let price: Decimal
        }
    }
}
