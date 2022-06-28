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
    ) throws {
        guard Validator.isValidAVSMessageInput(
            version: version,
            supplyOptionsType: supplyOptionsType,
            name: name,
            address: address,
            hint: hint,
            text: text,
            phone: phone,
            mail: mail
        )
        else {
            throw AVSError.invalidAVSMessageInput
        }

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

extension AVSMessage {
    /// Collection of input validation functions
    /// [gemF_eRp_altern_Zuweisung:A_22784]
    public enum Validator {
        // swiftlint:disable missing_docs
        // Constraints defined in [gemF_eRp_altern_Zuweisung:A_22784]
        static func isValidAVSMessageInput( // swiftlint:disable:this function_parameter_count
            version: Int,
            supplyOptionsType: SupplyOptionsType,
            name: String?,
            // swiftlint:disable:next discouraged_optional_collection
            address: [String]?,
            hint: String?,
            text: String?,
            phone: String?,
            mail: String?
        ) -> Bool {
            [
                isValid(version: version),
                isValid(name: name),
                isValid(address: address),
                isValid(hint: hint),
                isValid(text: text),
                isValid(phone: phone),
                isValid(mail: mail),
                ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
                    supplyOptionsType: supplyOptionsType,
                    phone: phone,
                    mail: mail
                ),
            ]
            .allSatisfy { $0 == true }
        }

        public static func isValid(version: Int) -> Bool {
            version > 0 && version < 1_000_000
        }

        public static func isValid(name: String?) -> Bool {
            name?.countIsLessOrEqual(50) ?? true
        }

        // swiftlint:disable:next discouraged_optional_collection
        public static func isValid(address: [String]?) -> Bool {
            address?.allSatisfy { $0.countIsLessOrEqual(50) } ?? true
        }

        public static func isValid(hint: String?) -> Bool {
            hint?.countIsLessOrEqual(500) ?? true
        }

        public static func isValid(text: String?) -> Bool {
            text?.countIsLessOrEqual(500) ?? true
        }

        public static func isValid(phone: String?) -> Bool {
            phone?.countIsLessOrEqual(25) ?? true
        }

        public static func isValid(mail: String?) -> Bool {
            if let mail = mail {
                return mail.isValidEmail || mail.isEmpty
            }
            return true
        }

        public static func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            supplyOptionsType: SupplyOptionsType,
            phone: String?,
            mail: String?
        ) -> Bool {
            [SupplyOptionsType.delivery, SupplyOptionsType.shipment].contains(supplyOptionsType) ?
                isNonEmptyPhoneOrNonEmptyMail(phone: phone, mail: mail) : true
        }

        static func isNonEmptyPhoneOrNonEmptyMail(phone: String?, mail: String?) -> Bool {
            switch (phone, mail) {
            case (nil, nil): return false
            case let (phone?, mail?): return !phone.isEmpty || !mail.isEmpty
            case let (phone?, nil): return !phone.isEmpty
            case let (nil, mail?): return !mail.isEmpty
            }
        }
        // swiftlint:enable missing_docs
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
