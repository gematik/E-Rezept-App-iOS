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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.Patient {
    var fullName: String? {
        let firstName = name?.first?.given?.first?.value?.string
        let lastName = name?.first?.family?.value?.string

        // Do we have a first name?
        if let firstName = firstName,
           !firstName.isEmpty {
            // Do we also have a last name?
            if let lastName = lastName,
               !lastName.isEmpty {
                // Return the combination of first and last name
                return firstName + " " + lastName
            }

            // No last name, so only return the first name
            return firstName
        }

        // No first name, so only return the last name
        return lastName
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

    var insuranceId: String? {
        let gkvKeys: [String] = ErpPrescription.Key.gkvKvIDKeys.map(\.value)
        let pkvKeys: [String] = ErpPrescription.Key.pkvKvIDKeys.map(\.value)

        let keys = gkvKeys + pkvKeys
        return identifier?.first { identifier in
            keys.contains { $0 == identifier.system?.value?.url.absoluteString }
        }?.value?.value?.string
    }
}
