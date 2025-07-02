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

import eRpKit
import Foundation
import ModelsR4

extension Extension.ValueX {
    var stringOrNil: String? {
        switch self {
        case let .string(value):
            return value.value?.string
        default:
            return nil
        }
    }

    var referenceOrNil: Reference? {
        switch self {
        case let .reference(value):
            return value
        default:
            return nil
        }
    }
}

extension ModelsR4.Patient {
    var fullName: String? {
        let firstName = name?.first?.given?.first?.value?.string
        let lastName = name?.first?.family?.value?.string

        let nameParts: [String] = [firstName, lastName].compactMap { namePart in
            if namePart?.isEmpty ?? true {
                return nil
            }
            return namePart
        }

        var allParts: [String] = []
        if let prefixes = name?.first?.prefix?.compactMap({ $0.value?.string }).filter({ !$0.isEmpty }) {
            allParts = prefixes + nameParts
        } else {
            allParts = nameParts
        }

        return allParts.joined(separator: " ")
    }

    var title: String? {
        name?.first?.prefix?.compactMap(\.value?.string).joined(separator: "")
    }

    var phone: String? {
        telecom?.first {
            if case $0.system?.value = ContactPointSystem.phone {
                return true
            }
            return false
        }?.value?.value?.string
    }

    var email: String? {
        telecom?.first {
            if case $0.system?.value = ContactPointSystem.email {
                return true
            }
            return false
        }?.value?.value?.string
    }

    var completeAddress: String? {
        guard let address = address?.first else { return nil }

        var postalCodeAndCity: String?

        if let postalCode = address.postalCode?.value?.string {
            if let city = address.city?.value?.string {
                postalCodeAndCity = "\n" + postalCode + " " + city
            } else {
                postalCodeAndCity = "\n" + postalCode
            }
        } else if let city = address.city?.value?.string {
            postalCodeAndCity = "\n" + city
        }

        if let line = address.line?.first?.value?.string {
            if let postalCodeAndCity = postalCodeAndCity {
                return line + postalCodeAndCity
            }
        }

        return postalCodeAndCity
    }

    var singleLineAddress: String? {
        guard let address = address?.first else { return nil }

        var addressLine: String?

        let streetNameExt = address.line?.first?
            .extensions(for: "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName")
        let houseNumberExt = address.line?.first?
            .extensions(for: "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber")

        // unwrap valueX of string and check if isEmpty
        if let valueX = streetNameExt?.first?.value, case let Extension.ValueX.string(string) = valueX,
           let streetName = string.value?.string, !streetName.isEmpty,
           let valueX = houseNumberExt?.first?.value, case let Extension.ValueX.string(string) = valueX,
           let houseNumber = string.value?.string, !houseNumber.isEmpty {
            addressLine = streetName + " " + houseNumber
        } else {
            // fallback line?.first value
            addressLine = address.line?.first?.value?.string
        }

        let postalCodeAndCity = [
            address.postalCode?.value?.string,
            address.city?.value?.string,
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        return [
            addressLine,
            postalCodeAndCity,
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    var insuranceId: String? {
        let gkvKeys: [String] = ErpPrescription.Key.gkvKvIDKeys.map(\.value)
        let pkvKeys: [String] = ErpPrescription.Key.pkvKvIDKeys.map(\.value)

        let keys = gkvKeys + pkvKeys
        return identifier?.first { identifier in
            keys.contains { $0 == identifier.system?.value?.url.absoluteString }
        }?.value?.value?.string
    }
}
