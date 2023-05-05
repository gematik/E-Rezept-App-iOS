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

public struct ErxPatient: Hashable, Codable {
    public init(name: String? = nil,
                address: String? = nil,
                birthDate: String? = nil,
                phone: String? = nil,
                status: String? = nil,
                insurance: String? = nil,
                insuranceId: String? = nil) {
        self.name = name
        self.address = address
        self.birthDate = birthDate
        self.phone = phone
        self.status = status
        self.insurance = insurance
        self.insuranceId = insuranceId
    }

    /// First and last name of the patient (e.g.: Anna Vetter)
    public let name: String?
    /// Full address incl. street, city, postcode
    public let address: String?
    /// Patient birthdate (e.g.: 2010-01-31)
    public let birthDate: String?
    /// Patient phone number
    public let phone: String?
    /// Contract status (e.g.: 3 == family)
    public let status: String?
    /// Name of the health insurance (e.g.:  IT Versicherung)
    public let insurance: String?
    /// Health card insurance identifier a.k.a. kvnr (e.g: X764228533)
    public let insuranceId: String?
}
