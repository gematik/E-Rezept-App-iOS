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
        public let supplyOptionsType: RedeemOption
        public let name: String
        public let address: [String]
        public var hint: String
        public var phone: String

        public init(
            version: Int = 1,
            supplyOptionsType: RedeemOption,
            name: String,
            address: [String],
            hint: String,
            phone: String
        ) {
            self.version = version
            self.supplyOptionsType = supplyOptionsType
            self.name = name
            self.address = address
            self.hint = hint
            self.phone = phone
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
        if let street = street {
            address.append(street)
        }
        if let detail = detail {
            address.append(detail)
        }
        if let zip = zip {
            address.append(zip)
        }
        if let city = city {
            address.append(city)
        }
        return address
    }
}

extension ErxTaskOrder {
    // sourcery: CodedError = "208"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        /// Unable to construct communication request
        case unableToConstructCommunicationRequest
        // sourcery: errorCode = "02"
        /// Invalid ErxTaskOrder though previous validation checks have been passed
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
