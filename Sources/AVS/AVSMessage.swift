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

    public enum SupplyOptionsType: String, Encodable, Sendable {
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
