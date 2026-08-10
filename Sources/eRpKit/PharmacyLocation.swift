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

import Foundation
import MapKit
import OpenSSL

/// Represents all information needed for searching for pharmacies.
public struct PharmacyLocation: Identifiable, Equatable {
    /// Pharmacy default initializer
    public init(
        id: String,
        status: Status? = nil,
        telematikID: String,
        created: Date = Date(),
        name: String? = nil,
        types: [PharmacyType],
        position: Position? = nil,
        address: Address? = nil,
        telecom: Telecom? = nil,
        lastUsed: Date? = nil,
        isFavorite: Bool = false,
        imagePath: String? = nil,
        countUsage: Int = 0,
        hoursOfOperation: [HoursOfOperation] = [],
        physicalFeatures: [PhysicalFeature] = [],
        specialities: [Speciality] = [],
        specialClosingHours: [SpecialOperationHours] = [],
        emergencyServiceHours: [SpecialOperationHours] = []
    ) {
        self.id = id
        self.status = status
        self.telematikID = telematikID
        self.created = created
        self.name = name
        self.types = types
        self.position = position
        self.address = address
        self.telecom = telecom
        self.lastUsed = lastUsed
        self.isFavorite = isFavorite
        self.imagePath = imagePath
        self.countUsage = countUsage
        self.hoursOfOperation = hoursOfOperation
        self.physicalFeatures = physicalFeatures
        self.specialities = specialities
        self.specialClosingHours = specialClosingHours
        self.emergencyServiceHours = emergencyServiceHours
    }

    // MARK: FHIR resources

    /// Id of the FHIR Location
    public var id: String
    /// LocationStatus
    /// NOTE: Is here used to indicate E-Rezept readiness
    public var status: Status?
    /// Identifier of the pharmacy
    public var telematikID: String
    /// date of local client creation
    public var created: Date
    /// Name of pharmacy
    public var name: String?
    /// A pharmacy can have multiple types. In FHIR the code are e.g. "PHARM" and "OUTPHARM" and "MOBL"
    public var types: [PharmacyType]
    /// Position, i.e. Latitude and Longitude of the pharmacy's address
    public var position: Position?
    /// Address
    public var address: Address?
    /// Telecom
    public var telecom: Telecom?
    /// Bate of latest use for redeeming
    public var lastUsed: Date?
    /// Bool indicating if user has marked this pharmacy as favorite
    public var isFavorite: Bool
    /// Path to an image of the pharmacy
    public var imagePath: String?
    /// Number of times this pharmacy has been used for redeeming
    public var countUsage: Int
    /// HoursOfOperation (opening hours)
    public var hoursOfOperation: [HoursOfOperation]
    /// Special closing hours
    public var specialClosingHours: [SpecialOperationHours]
    /// Emergency Service Hours
    public var emergencyServiceHours: [SpecialOperationHours]
    /// Physical features available at this pharmacy location
    public var physicalFeatures: [PhysicalFeature] = []
    /// Specialities offered at this pharmacy location
    public var specialities: [Speciality] = []

    public var canBeDisplayedInMap: Bool {
        position?.latitude != nil && position?.longitude != nil
    }

    /// Indicates if the delivery service via the `eRpRemoteStorage` module (Fachdienst) is present
    /// Note: Authentication via "Fachdienst" is required
    public var hasDeliveryService: Bool {
        types.contains { $0.isDeliveryService }
    }

    /// Indicates if the shipment service via the `eRpRemoteStorage` module (Fachdienst) is present
    /// Note: Authentication via "Fachdienst" is required
    public var hasShipmentService: Bool {
        types.contains { $0.isShipment }
    }

    /// Indicates if the reservation/onPremise service via the `eRpRemoteStorage` module (Fachdienst) is present
    /// Note: Authentication via "Fachdienst" is required
    public var hasReservationService: Bool {
        types.contains { $0.isReservation }
    }

    /// Indicates if the emergency service via the `eRpRemoteStorage` module (Fachdienst) is present
    /// Note: Authentication via "Fachdienst" is required
    public var hasEmergencyService: Bool {
        types.contains { $0.isEmergency }
    }

    public mutating func updateLocalStoredProperties(with pharmacy: PharmacyLocation) {
        created = pharmacy.created
        isFavorite = pharmacy.isFavorite
        lastUsed = pharmacy.lastUsed
        imagePath = pharmacy.imagePath
        countUsage = pharmacy.countUsage
    }
}

extension PharmacyLocation {
    /// Mode of operation / eRx-readiness status
    public enum Status: String, Codable {
        /// The location is operational.
        /// /// NOTE: Is here used to indicate eRx-readiness.
        case active
        /// The location is temporarily closed.
        case suspended
        /// The location is no longer used.
        /// NOTE: Is here used to indicate non eRx-readiness.
        case inactive
    }

    public enum PharmacyType: String, Codable, Hashable {
        /// Pharmacy
        case pharm

        /// Outpatient pharmacy
        /// NOTE: Is here used to indicate (publicly accessible) brick and mortar pharmacies that offer pickup service.
        case outpharm

        /// Mobile Unit
        /// NOTE: Is here used to indicate pharmacies offering mail order service
        case mobl

        /// NOTE: Is here used to indicate (publicly accessible) brick and mortar pharmacies that offer delivery
        /// (a.k.a. Botendienst)
        case delivery

        case emergency

        var isDeliveryService: Bool {
            self == .delivery
        }

        var isReservation: Bool {
            self == .outpharm
        }

        var isShipment: Bool {
            self == .mobl
        }

        var isEmergency: Bool {
            self == .emergency
        }
    }

    public struct Position: Codable, Equatable, Hashable {
        public init(latitude: Decimal? = nil,
                    longitude: Decimal? = nil) {
            self.latitude = latitude
            self.longitude = longitude
        }

        public let latitude: Decimal?
        public let longitude: Decimal?
        public var coordinate: CLLocationCoordinate2D? {
            if let longitude, let latitude {
                return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
            } else {
                return nil
            }
        }
    }

    public struct Address: Codable, Hashable {
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
            if let street {
                address = street
            }
            if let number = houseNumber {
                address += " \(number)"
            }

            if let city {
                if let zip {
                    address += ", \(zip) \(city)"
                } else {
                    address += ", \(city)"
                }
            }
            return address
        }

        public var fullAddressBreak: String {
            var address = ""
            if let street {
                address = street
            }
            if let number = houseNumber {
                address += " \(number)"
            }

            if let city {
                if let zip {
                    address += "\n\(zip) \(city)"
                } else {
                    address += "\n\(city)"
                }
            }
            return address
        }
    }

    public struct Telecom: Codable, Hashable {
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

    public struct HoursOfOperation: Codable, Hashable {
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

    public enum PhysicalFeature: String, Codable, Hashable {
        case parking = "parkmoeglichkeit"
        case publicTransport = "oepnv"
        case barrierFree = "barrierefrei"
        case pickupAutomat = "abholautomat"
    }

    public enum Speciality: String, Codable, Hashable {
        // PharmacyHealthcareSpecialtyCS (codes 10-40 are handled by PharmacyType)
        case sterileCompounding = "50"
        case hypertension = "60"
        case inhalationTechnique = "70"
        case polymedication = "80"
        case oralCancerTherapy = "90"
        case organTransplantation = "100"
        // HealthcareServiceSpecialtyCS
        case vaccination = "impfung"
        case bodyMeasurements = "koerperwerte"
        case allergyTest = "allergietest"
        case travelMedicineConsultation = "reisemedizin-beratung"
    }

    public struct SpecialOperationHours: Codable, Hashable {
        public init(reason: String? = nil,
                    startDate: String? = nil,
                    endDate: String? = nil) {
            self.reason = reason
            self.startDate = startDate
            self.endDate = endDate
        }

        public let reason: String?
        public let startDate: String?
        public let endDate: String?
    }
}

extension Decimal {
    /// Returns a `Double`type for this decimal type
    public var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

extension PharmacyLocation: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case telematikID
        case created
        case name
        case types
        case position
        case address
        case telecom
        case lastUsed
        case isFavorite
        case imagePath
        case countUsage
        case hoursOfOperation
        case physicalFeatures
        case specialities
        case specialClosingHours
        case emergencyServiceHours
    }
}
