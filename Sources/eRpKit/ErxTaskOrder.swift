//
//  Copyright (c) 2022 gematik GmbH
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
public struct ErxTaskOrder: Equatable {
    /// Task Id for the prescription
    public let erxTaskId: String
    /// Access Code of the prescription
    public let accessCode: String
    /// Identifier of the pharmacy where order will be issued
    public let pharmacyTelematikId: String
    /// Contains informations about the user and the selected redeem option
    public let payload: Payload

    /// Default initializer to instantiate an ErxTask order.
    /// - Parameters:
    ///   - erxTaskId: Id of the ErxTask to order
    ///   - accessCode: AccessCode of the prescription that should be redeemed
    ///   - pharmacyTelematikId: Telematik-ID for the pharmacy in which the order will be placed
    ///   - payloadJSON: Informations about the users address and the selected redeem option
    public init(erxTaskId: String,
                accessCode: String,
                pharmacyTelematikId: String,
                payload: Payload) {
        self.payload = payload
        self.erxTaskId = erxTaskId
        self.accessCode = accessCode
        self.pharmacyTelematikId = pharmacyTelematikId
    }

    public struct Payload: Codable, Equatable {
        public let version: String
        public let supplyOptionsType: RedeemOption
        public let name: String
        public let address: [String]
        public var hint: String
        public var phone: String

        public init(
            version: String = "1",
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

public enum RedeemOption: String, Codable, Equatable {
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
