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

import CodedError
import Foundation

/// Data Model that holds all relevant informations for placing an order in a pharmacy
public struct ErxTaskOrder: Equatable, Codable {
    /// `ErxTaskOrder` identifier
    public let identifier: String
    /// Task Id for the prescription
    public let erxTaskId: String
    /// Access Code of the prescription
    public let accessCode: String
    /// Identifier of the organization where order will be issued
    public let telematikId: String
    /// FlowType describes type of task (e.G. Direktzuweisung).
    public var flowType: String
    /// Contains informations about the user and the selected redeem option (optional for flowtype 162)
    public let payload: Payload?

    /// Default initializer to instantiate an ErxTask order.
    /// - Parameters:
    ///   - identifier: `ErxTaskOrder` identifier
    ///   - erxTaskId: Id of the ErxTask to order
    ///   - accessCode: AccessCode of the prescription that should be redeemed
    ///   - telematikId: Telematik-ID for the organization in which the order will be placed
    ///   - payloadJSON: Informations about the users address and the selected redeem option
    public init(identifier: String,
                erxTaskId: String,
                accessCode: String,
                telematikId: String,
                flowType: String,
                payload: Payload? = nil) {
        self.identifier = identifier
        self.payload = payload
        self.erxTaskId = erxTaskId
        self.accessCode = accessCode
        self.telematikId = telematikId
        self.flowType = flowType
    }

    public struct Payload: Codable, Equatable {
        public let version: Int
        public let supplyOptionsType: RedeemOption?
        // V1 fields
        public let name: String?
        public let address: [String]
        public var hint: String?
        public var phone: String?
        // V3 fields
        public let communicationType: DispReqCommunicationType?
        public let firstname: String?
        public let lastname: String?
        public let addressLine: String?
        public let postcode: String?
        public let city: String?
        public let country: String?
        public var text: String?
        public let email: String?
        public let transactionID: String?

        /// V1 initializer — backward compatible
        public init(
            version: Int = 1,
            supplyOptionsType: RedeemOption,
            name: String,
            address: [String] = [],
            hint: String,
            phone: String
        ) {
            self.version = version
            self.supplyOptionsType = supplyOptionsType
            self.name = name
            self.address = address
            self.hint = hint
            self.phone = phone
            communicationType = nil
            firstname = nil
            lastname = nil
            addressLine = nil
            postcode = nil
            city = nil
            country = nil
            text = nil
            email = nil
            transactionID = nil
        }

        /// V3 initializer
        public init(
            version: Int = 3,
            communicationType: DispReqCommunicationType,
            supplyOptionsType: RedeemOption? = nil,
            firstname: String? = nil,
            lastname: String? = nil,
            addressLine: String? = nil,
            postcode: String? = nil,
            city: String? = nil,
            country: String? = nil,
            phone: String? = nil,
            hint: String? = nil,
            text: String? = nil,
            email: String? = nil,
            transactionID: String? = nil
        ) {
            self.version = version
            self.communicationType = communicationType
            self.supplyOptionsType = supplyOptionsType
            self.firstname = firstname
            self.lastname = lastname
            self.addressLine = addressLine
            self.postcode = postcode
            self.city = city
            self.country = country
            self.phone = phone
            self.hint = hint
            self.text = text
            self.email = email
            self.transactionID = transactionID
            name = nil
            address = []
        }

        public enum DispReqCommunicationType: String, Codable, Equatable {
            case order
            case text
        }

        // MARK: - Custom Coding

        private enum CodingKeys: String, CodingKey {
            case version, supplyOptionsType, name, address, hint, phone
            case communicationType, firstname, lastname, postcode, city, country
            case text, email, transactionID
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let intVersion = try? container.decode(Int.self, forKey: .version) {
                version = intVersion
            } else if let stringVersion = try? container.decode(String.self, forKey: .version),
                      let intVersion = Int(stringVersion) {
                version = intVersion
            } else {
                version = try container.decode(Int.self, forKey: .version)
            }

            supplyOptionsType = try container.decodeIfPresent(RedeemOption.self, forKey: .supplyOptionsType)
            communicationType = try container.decodeIfPresent(DispReqCommunicationType.self,
                                                              forKey: .communicationType)
            hint = try container.decodeIfPresent(String.self, forKey: .hint)
            phone = try container.decodeIfPresent(String.self, forKey: .phone)
            text = try container.decodeIfPresent(String.self, forKey: .text)
            email = try container.decodeIfPresent(String.self, forKey: .email)
            transactionID = try container.decodeIfPresent(String.self, forKey: .transactionID)

            if version >= 3 {
                // V3: address is a single string, name is split into firstname/lastname
                firstname = try container.decodeIfPresent(String.self, forKey: .firstname)
                lastname = try container.decodeIfPresent(String.self, forKey: .lastname)
                addressLine = try container.decodeIfPresent(String.self, forKey: .address)
                postcode = try container.decodeIfPresent(String.self, forKey: .postcode)
                city = try container.decodeIfPresent(String.self, forKey: .city)
                country = try container.decodeIfPresent(String.self, forKey: .country)
                name = nil
                address = []
            } else {
                // V1: address is an array, name is a single string
                name = try container.decodeIfPresent(String.self, forKey: .name)
                address = try container.decodeIfPresent([String].self, forKey: .address) ?? []
                firstname = nil
                lastname = nil
                addressLine = nil
                postcode = nil
                city = nil
                country = nil
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(version, forKey: .version)
            try container.encodeIfPresent(supplyOptionsType, forKey: .supplyOptionsType)
            try container.encodeIfPresent(hint, forKey: .hint)
            try container.encodeIfPresent(phone, forKey: .phone)

            if version >= 3 {
                // V3: encode v3-specific fields
                try container.encodeIfPresent(communicationType, forKey: .communicationType)
                try container.encodeIfPresent(firstname, forKey: .firstname)
                try container.encodeIfPresent(lastname, forKey: .lastname)
                try container.encodeIfPresent(addressLine, forKey: .address)
                try container.encodeIfPresent(postcode, forKey: .postcode)
                try container.encodeIfPresent(city, forKey: .city)
                try container.encodeIfPresent(country, forKey: .country)
                try container.encodeIfPresent(text, forKey: .text)
                try container.encodeIfPresent(email, forKey: .email)
                try container.encodeIfPresent(transactionID, forKey: .transactionID)
            } else {
                // V1: encode v1-specific fields
                try container.encodeIfPresent(name, forKey: .name)
                try container.encodeIfPresent(address, forKey: .address)
            }
        }
    }
}

public struct Address: Codable, Equatable {
    public let street: String?
    public let detail: String?
    public let zip: String?
    public let city: String?

    public init(
        street: String? = nil,
        detail: String? = nil,
        zip: String? = nil,
        city: String? = nil
    ) {
        self.street = street
        self.detail = detail
        self.zip = zip
        self.city = city
    }

    public func asArray() -> [String] {
        var address = [String]()
        if let street {
            address.append(street)
        }
        if let detail {
            address.append(detail)
        }
        if let zip {
            address.append(zip)
        }
        if let city {
            address.append(city)
        }
        return address
    }
}

extension ErxTaskOrder {
    @CodedError("208")
    public enum Error: Swift.Error {
        /// Unable to construct communication request
        @ErrorCode("01")
        case unableToConstructCommunicationRequest
        /// Invalid ErxTaskOrder though previous validation checks have been passed
        @ErrorCode("02")
        case invalidErxTaskOrderInput(String)
    }
}

public enum RedeemOption: String, Codable, Hashable, CaseIterable, Sendable {
    case onPremise
    case delivery
    case shipment

    public var isShipment: Bool {
        self == .shipment
    }

    public var isDelivery: Bool {
        self == .delivery
    }

    public var isOnPremise: Bool {
        self == .onPremise
    }
}

extension String {
    func countIsLessOrEqual(_ limit: Int) -> Bool {
        count < limit
    }

    var isValidEmail: Bool {
        let emailRegex = "^[^@\\s]+@[^@\\s.]+.[^@\\s.]+$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
