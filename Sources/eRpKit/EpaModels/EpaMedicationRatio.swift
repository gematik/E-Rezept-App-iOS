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

public struct EpaMedicationRatio: Equatable, Hashable, Codable, CustomStringConvertible, Sendable {
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

    public struct Quantity: Equatable, Hashable, Codable, CustomStringConvertible, Sendable {
        public init(value: String, unit: String? = nil, system: String? = nil, code: String? = nil) {
            self.value = value
            self.unit = unit
            self.system = system
            self.code = code
        }

        public let value: String
        public let unit: String?
        public let system: String?
        public let code: String?

        public var description: String {
            if let code = code {
                return "\(value) \(code)"
            } else if let unit = unit {
                return "\(value) \(unit)"
            } else {
                return value
            }
        }
    }
}
