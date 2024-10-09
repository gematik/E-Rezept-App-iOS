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

/// Represents a health insurance number (Krankenversicherungs Nummer)
///
/// Format should be a Letter followed by 9 digits, e.g. A123456785, where last digit is a checksum.
public typealias KVNR = String

extension KVNR {
    /// Validates a KVNR and checks for format, length and checksum.
    public var isValid: Bool {
        let input = uppercased()

        guard input.count == 10 else { return false }
        guard let letter = input.first else { return false }
        guard let checksum = input.last else { return false }

        let rawNumber = String(input.dropFirst().dropLast())

        guard rawNumber.allSatisfy(Set("0123456789").contains) else { return false }

        guard let letterAsInt = letter.asciiValue,
              let aAsInt = "A".first?.asciiValue,
              letterAsInt >= aAsInt else {
            return false
        }
        let letterValue = letterAsInt - aAsInt + 1

        guard 1 ... 26 ~= letterValue else { return false }

        let letterAsDigitString = String(format: "%02d", letterValue)

        let numberStringToCheck = letterAsDigitString + rawNumber

        let numbersToCheck = numberStringToCheck
            .compactMap { character in
                Int(String(character))
            }
        let calculatedChecksum: Int = numbersToCheck.enumerated()
            .reduce(0) { result, item in
                let digit = item.element * (item.offset % 2 + 1)
                return result + ((digit > 9) ? digit - 9 : digit)
            }

        return calculatedChecksum % 10 == Int(String(checksum))
    }
}
