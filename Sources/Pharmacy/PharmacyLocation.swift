//
//  Copyright (c) 2021 gematik GmbH
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

/// Represents all information needed for searching for pharmacies.
public struct PharmacyLocation: Identifiable, Hashable, Equatable {
    /// Pharmacy default initializer
    public init(
        id: String, // swiftlint:disable:this identifier_name
        telematikID: String,
        name: String?,
        type: [PharmacyType],
        position: Position? = nil,
        address: Address? = nil,
        telecom: Telecom? = nil,
        hoursOfOperation: [HoursOfOperation]
    ) {
        self.id = id
        self.telematikID = telematikID
        self.name = name
        self.type = type
        self.position = position
        self.address = address
        self.telecom = telecom
        self.hoursOfOperation = hoursOfOperation
    }

    // MARK: FHIR resources

    /// Id of the FHIR Location
    public var id: String // swiftlint:disable:this identifier_name
    /// Idenditifer of the pharmacy
    public let telematikID: String
    /// Name of pharmacy
    public let name: String?
    /// Type is: "Präsenzapotheke", "Versandapotheke", etc. A pharmacy can have multiple types
    /// In FHIR the code is "PHARM" and "OUTPHARM" and "MOBL"
    public let type: [PharmacyType]
    /// Position, i.e. Latitude and Longitude of pharmacys address
    public var position: Position?
    /// Address
    public let address: Address?
    /// Telecom
    public let telecom: Telecom?
    /// HoursOfOperation (opening hours)
    public let hoursOfOperation: [HoursOfOperation]

    public var canBeDisplayedInMap: Bool {
        position?.latitude != nil && position?.longitude != nil
    }

    public var hasDeliveryService: Bool {
        type.contains { $0.isDeliveryService }
    }

    public var hasMailService: Bool {
        type.contains { $0.isMail }
    }

    public var hasReservationService: Bool {
        type.contains { $0.isReservation }
    }

    public var hasEmergencyService: Bool {
        type.contains { $0.isEmergency }
    }
}

extension PharmacyLocation: Comparable {
    public static func <(lhs: PharmacyLocation, rhs: PharmacyLocation) -> Bool {
        switch (lhs.name, rhs.name) {
        case (nil, nil): return true
        case (_, nil): return true
        case (nil, _): return false
        case let (.some(lhsValue), .some(rhsValue)):
            return lhsValue < rhsValue
        }
    }

    public static func ==(lhs: PharmacyLocation, rhs: PharmacyLocation) -> Bool {
        lhs.telematikID == rhs.telematikID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(telematikID)
    }
}

extension PharmacyLocation {
    public enum PharmacyType: Hashable {
        case pharm
        case outpharm
        case mobl
        case emergency

        var isDeliveryService: Bool {
            self == .mobl
        }

        var isReservation: Bool {
            self == .pharm
        }

        var isMail: Bool {
            self == .outpharm
        }

        var isEmergency: Bool {
            self == .emergency
        }
    }

    public struct Position: Hashable {
        public init(latitude: Decimal? = nil,
                    longitude: Decimal? = nil) {
            self.latitude = latitude
            self.longitude = longitude
        }

        public let latitude: Decimal?
        public let longitude: Decimal?
    }

    public struct Address: Hashable {
        public init(street: String? = nil,
                    housenumber: String? = nil,
                    zip: String? = nil,
                    city: String? = nil) {
            self.street = street
            self.housenumber = housenumber
            self.zip = zip
            self.city = city
        }

        public let street: String?
        public let housenumber: String?
        public let zip: String?
        public let city: String?

        public var fullAddress: String {
            var address = ""
            if let street = street {
                address = street
            }
            if let number = housenumber {
                address += " \(number)"
            }

            if let city = city {
                if let zip = zip {
                    address += ", \(zip) \(city)"
                } else {
                    address += ", \(city)"
                }
            }
            return address
        }
    }

    public struct Telecom: Hashable {
        public init(phone: String? = nil,
                    fax: String? = nil,
                    email: String? = nil,
                    web: String? = nil) {
            self.phone = phone
            self.fax = fax
            self.email = email
            self.web = web
        }

        public let phone: String?
        public let fax: String?
        public let email: String?
        public let web: String?
    }

    public struct HoursOfOperation: Hashable {
        public init(daysOfWeek: [String] = [],
                    openingTime: String? = nil,
                    closingTime: String? = nil) {
            self.daysOfWeek = daysOfWeek
            self.openingTime = openingTime
            self.closingTime = closingTime
        }

        public let daysOfWeek: [String]
        public let openingTime: String?
        public let closingTime: String?
    }
}

extension Decimal {
    /// Returns a `Double`type for this decimal type
    public var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
