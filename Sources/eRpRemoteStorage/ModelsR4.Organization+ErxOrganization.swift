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

extension ModelsR4.Organization {
    var erxOrganizationIdentifier: String? {
        identifier?.first {
            $0.system?.value?.url.absoluteString == ErpPrescription.Key.organisationIdentifierKey
        }?.value?.value?.string
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
                postalCodeAndCity = "\n" + postalCode + ", " + city
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

    var twoLineAddress: String? {
        guard let address = address?.first else { return nil }

        let postalCodeAndCity = [
            address.postalCode?.value?.string,
            address.city?.value?.string,
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        return [
            address.line?.first?.value?.string,
            postalCodeAndCity,
        ]
        .compactMap { $0 }
        .joined(separator: "\n")
    }
}
