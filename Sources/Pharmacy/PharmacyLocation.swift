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
        status: Status?,
        telematikID: String,
        name: String?,
        types: [PharmacyType],
        position: Position? = nil,
        address: Address? = nil,
        telecom: Telecom? = nil,
        hoursOfOperation: [HoursOfOperation]
    ) {
        self.id = id
        self.status = status
        self.telematikID = telematikID
        self.name = name
        self.types = types
        self.position = position
        self.address = address
        self.telecom = telecom
        self.hoursOfOperation = hoursOfOperation
    }

    // MARK: FHIR resources

    /// Id of the FHIR Location
    public var id: String // swiftlint:disable:this identifier_name
    /// LocationStatus
    /// NOTE: Is here used to indicate E-Rezept readiness
    public let status: Status?
    /// Identifier of the pharmacy
    public let telematikID: String
    /// Name of pharmacy
    public let name: String?
    /// A pharmacy can have multiple types. In FHIR the code are e.g. "PHARM" and "OUTPHARM" and "MOBL"
    public let types: [PharmacyType]
    /// Position, i.e. Latitude and Longitude of the pharmacy's address
    public let position: Position?
    /// Address
    public let address: Address?
    /// Telecom
    public let telecom: Telecom?
    /// HoursOfOperation (opening hours)
    public let hoursOfOperation: [HoursOfOperation]

    public var canBeDisplayedInMap: Bool {
        position?.latitude != nil && position?.longitude != nil
    }

    public var isErxReady: Bool {
        if let status = status {
           return status == .active
        } else {
            return false
        }
    }

    public var hasDeliveryService: Bool {
        types.contains { $0.isDeliveryService }
    }

    public var hasMailService: Bool {
        types.contains { $0.isMail }
    }

    public var hasReservationService: Bool {
        types.contains { $0.isReservation }
    }

    public var hasEmergencyService: Bool {
        types.contains { $0.isEmergency }
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
    /// Mode of operation / eRx-readiness status
    public enum Status {
        /// The location is operational.
        /// /// NOTE: Is here used to indicate eRx-readiness.
        case active
        /// The location is temporarily closed.
        case suspended
        /// The location is no longer used.
        /// NOTE: Is here used to indicate non eRx-readiness.
        case inactive
    }

    public enum PharmacyType: Hashable {
        /// Pharmacy
        case pharm
        /// Outpatient pharmacy
        /// NOTE: Is here used to indicate (publicly accessible) brick and mortar pharmacies
        case outpharm
        /// Mobile Unit
        /// NOTE: Is here used to indicate pharmacies offering mail order service
        case mobl
        case emergency

        var isDeliveryService: Bool {
            self == .mobl
        }

        var isReservation: Bool {
            self == .pharm
        }

        var isMail: Bool {
            self == .mobl
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
                    houseNumber: String? = nil,
                    zip: String? = nil,
                    city: String? = nil) {
            self.street = street
            self.houseNumber = houseNumber
            self.zip = zip
            self.city = city
        }

        public let street: String?
        public let houseNumber: String?
        public let zip: String?
        public let city: String?

        public var fullAddress: String {
            var address = ""
            if let street = street {
                address = street
            }
            if let number = houseNumber {
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
