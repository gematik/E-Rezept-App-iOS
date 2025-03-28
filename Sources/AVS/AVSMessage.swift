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

/// Message format for interchanging redeem information
///
/// [gemF_eRp_altern_Zuweisung:A_22784]
public struct AVSMessage: Encodable, Equatable {
    public let version: Int
    public let supplyOptionsType: SupplyOptionsType
    public let name: String?
    public let address: [String]? // swiftlint:disable:this discouraged_optional_collection
    public let hint: String?
    public let text: String?
    public let phone: String?
    public let mail: String?
    public let transactionID: UUID
    public let taskID: String
    public let accessCode: String

    public enum SupplyOptionsType: String, Encodable {
        case onPremise
        case shipment
        case delivery
    }

    public init(
        version: Int,
        supplyOptionsType: SupplyOptionsType,
        name: String? = nil,
        address: [String]? = nil, // swiftlint:disable:this discouraged_optional_collection
        hint: String? = nil,
        text: String? = nil,
        phone: String? = nil,
        mail: String? = nil,
        transactionID: UUID,
        taskID: String,
        accessCode: String
    ) {
        self.version = version
        self.supplyOptionsType = supplyOptionsType
        self.name = name
        self.address = address
        self.hint = hint
        self.text = text
        self.phone = phone
        self.mail = mail
        self.transactionID = transactionID
        self.taskID = taskID
        self.accessCode = accessCode
    }
}

extension AVSMessage: Sendable {}
