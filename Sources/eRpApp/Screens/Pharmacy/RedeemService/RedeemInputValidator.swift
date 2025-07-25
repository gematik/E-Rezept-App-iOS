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

// swiftlint:disable file_length

import AVS
import Dependencies
import DependenciesMacros
import eRpKit
import Foundation

public enum Validity: Equatable {
    case valid
    case invalid(String)
}

@DependencyClient
struct RedeemOrderInputValidator {
    var type: @Sendable (RedeemServiceOption?) -> RedeemInputValidator?
}

extension RedeemOrderInputValidator: DependencyKey {
    static let liveValue: Self = {
        @Dependency(\.avsMessageValidator) var avsMessageValidator
        @Dependency(\.erxTaskOrderValidator) var erxTaskOrderValidator

        return Self { option in
            switch option {
            case .avs:
                return avsMessageValidator
            case .erxTaskRepository, .erxTaskRepositoryAvailable:
                return erxTaskOrderValidator
            case .noService, .none:
                return nil
            }
        }
    }()
}

extension DependencyValues {
    var redeemOrderInputValidator: RedeemOrderInputValidator {
        get { self[RedeemOrderInputValidator.self] }
        set { self[RedeemOrderInputValidator.self] = newValue }
    }
}

extension RedeemOrderInputValidator: TestDependencyKey {
    static let previewValue = Self()
    static let testValue = Self()
}

protocol RedeemInputValidator {
    var service: RedeemServiceOption { get }

    func isValid(version: Int) -> Validity
    func isValid(name: String?) -> Validity
    func isValid(street: String?) -> Validity
    func isValid(zip: String?) -> Validity
    func isValid(city: String?) -> Validity
    func isValid(hint: String?) -> Validity
    func isValid(text: String?) -> Validity
    func isValid(phone: String?) -> Validity
    func isValid(mail: String?) -> Validity

    func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
        optionType: RedeemOption,
        phone: String?,
        mail: String?
    ) -> Validity

    func onPremiseOrElseIsNonEmptyContactData( // swiftlint:disable:this function_parameter_count
        optionType: RedeemOption,
        name: String?,
        street: String?,
        zip: String?,
        city: String?,
        phone: String?
    ) -> Bool
}

struct RedeemInputValidatorDependency: DependencyKey {
    // Is initially unimplemented because there is no reasonable default
    // Use the dependency values from `AVSMessage.Validator` or `ErxTaskOrder.Validator` to override
    static let liveValue: RedeemInputValidator = UnimplementedRedeemInputValidator()
    static let previewValue: RedeemInputValidator = DemoRedeemInputValidator()
}

extension DependencyValues {
    var redeemInputValidator: RedeemInputValidator {
        get { self[RedeemInputValidatorDependency.self] }
        set { self[RedeemInputValidatorDependency.self] = newValue }
    }
}

extension RedeemInputValidator {
    func isValid(address: Address?) -> Validity {
        if isValid(street: address?.street) != .valid {
            return isValid(street: address?.street)
        }
        if isValid(zip: address?.zip) != .valid {
            return isValid(zip: address?.zip)
        }
        if isValid(city: address?.city) != .valid {
            return isValid(city: address?.city)
        }
        return .valid
    }
}

extension AVSMessage {
    /// Collection of input validation functions for redeem via AVS. Constraints defined in
    /// [gemF_eRp_altern_Zuweisung:A_22784]
    struct Validator: RedeemInputValidator, Equatable {
        static var maxHintLength = 500
        static var maxTextLength = 500
        static var maxAddressFieldLength = 50
        static var maxNameLength = 50
        init() {}

        func isValidAVSMessageInput( // swiftlint:disable:this function_parameter_count
            version: Int,
            supplyOptionsType: SupplyOptionsType,
            name: String?,
            address: Address?,
            hint: String?,
            text: String?,
            phone: String?,
            mail: String?
        ) -> Validity {
            if isValid(version: version) != .valid {
                return isValid(version: version)
            }
            if isValid(name: name) != .valid {
                return isValid(name: name)
            }
            if isValid(address: address) != .valid {
                return isValid(address: address)
            }
            if isValid(hint: hint) != .valid {
                return isValid(hint: hint)
            }
            if isValid(text: text) != .valid {
                return isValid(text: text)
            }
            if isValid(phone: phone) != .valid {
                return isValid(phone: phone)
            }
            if isValid(mail: mail) != .valid {
                return isValid(mail: mail)
            }
            if ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
                supplyOptionsType: supplyOptionsType,
                phone: phone,
                mail: mail
            ) != .valid {
                return ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
                    supplyOptionsType: supplyOptionsType,
                    phone: phone,
                    mail: mail
                )
            }

            return .valid
        }

        func isValid(version: Int) -> Validity {
            (version > 0 && version < 1_000_000) ? .valid : .invalid(L10n.rivAvsWrongVersion.text)
        }

        func isValid(name: String?) -> Validity {
            (name?.countIsLessOrEqual(Validator.maxNameLength) ?? true) ? .valid :
                .invalid(L10n.rivAvsInvalidName(String(Validator.maxNameLength)).text)
        }

        func isValid(address: Address?) -> Validity {
            if isValid(street: address?.street) != .valid {
                return isValid(street: address?.street)
            }
            if isValid(zip: address?.zip) != .valid {
                return isValid(zip: address?.zip)
            }
            if isValid(city: address?.city) != .valid {
                return isValid(city: address?.city)
            }
            return .valid
        }

        func isValid(street: String?) -> Validity {
            (street?.countIsLessOrEqual(Validator.maxAddressFieldLength) ?? true) ? .valid :
                .invalid(L10n.rivAvsInvalidStreet(String(Validator.maxAddressFieldLength)).text)
        }

        func isValid(zip: String?) -> Validity {
            (zip?.countIsLessOrEqual(Validator.maxAddressFieldLength) ?? true) ? .valid :
                .invalid(L10n.rivAvsInvalidZip(String(Validator.maxAddressFieldLength)).text)
        }

        func isValid(city: String?) -> Validity {
            (city?.countIsLessOrEqual(Validator.maxAddressFieldLength) ?? true) ? .valid :
                .invalid(L10n.rivAvsInvalidCity(String(Validator.maxAddressFieldLength)).text)
        }

        func isValid(hint: String?) -> Validity {
            (hint?.countIsLessOrEqual(Validator.maxHintLength) ?? true) ? .valid :
                .invalid(L10n.rivAvsInvalidHint(String(Validator.maxHintLength)).text)
        }

        func isValid(text: String?) -> Validity {
            (text?.countIsLessOrEqual(Validator.maxTextLength) ?? true) ? .valid :
                .invalid(L10n.rivAvsInvalidHint(String(Validator.maxTextLength)).text)
        }

        func isValid(phone: String?) -> Validity {
            guard let phone = phone, !phone.isEmpty else {
                return .valid
            }
            let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
            guard let detector = try? NSDataDetector(types: types.rawValue) else { return .valid }

            let range = NSRange(phone.startIndex ..< phone.endIndex, in: phone)
            let matches = detector.matches(in: phone, options: [], range: range)

            guard matches.count == 1,
                  let match = matches.first,
                  match.resultType == .phoneNumber,
                  match.phoneNumber != nil else {
                return .invalid(L10n.rivAvsInvalidPhone.text)
            }

            return .valid
        }

        func isValid(mail: String?) -> Validity {
            guard let mail = mail, !mail.isEmpty else {
                return .valid
            }
            return mail.isValidEmail ? .valid : .invalid(L10n.rivAvsInvalidMail.text)
        }

        func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            supplyOptionsType: SupplyOptionsType,
            phone: String?,
            mail: String?
        ) -> Validity {
            switch supplyOptionsType {
            case .onPremise:
                return .valid
            case .shipment, .delivery:
                return isNonEmptyPhoneOrNonEmptyMail(phone: phone, mail: mail) ? .valid :
                    .invalid(L10n.rivAvsInvalidMissingContact.text)
            }
        }

        func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: RedeemOption,
            phone: String?,
            mail: String?
        ) -> Validity {
            ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
                supplyOptionsType: optionType.asSupplyOptionType,
                phone: phone,
                mail: mail
            )
        }

        func onPremiseOrElseIsNonEmptyContactData( // swiftlint:disable:this function_parameter_count
            optionType: RedeemOption,
            name: String?,
            street: String?,
            zip: String?,
            city: String?,
            phone: String?
        ) -> Bool {
            switch optionType {
            case .onPremise:
                return true
            case .shipment, .delivery:
                return isCompleteContactData(name: name, street: street, zip: zip, city: city, phone: phone)
            }
        }

        var service: RedeemServiceOption {
            .avs
        }

        func isNonEmptyPhoneOrNonEmptyMail(phone: String?, mail: String?) -> Bool {
            switch (phone, mail) {
            case (nil, nil): return false
            case let (phone?, mail?): return !phone.isEmpty || !mail.isEmpty
            case let (phone?, nil): return !phone.isEmpty
            case let (nil, mail?): return !mail.isEmpty
            }
        }

        func isCompleteContactData(name: String?, street: String?, zip: String?, city: String?,
                                   phone: String?) -> Bool {
            name != nil && street != nil && zip != nil && city != nil && phone != nil
        }
    }
}

// sourcery: skipUnimplemented
extension AVSMessage.Validator: DependencyKey {
    static let liveValue: RedeemInputValidator = AVSMessage.Validator()
    static let previewValue: RedeemInputValidator = AVSMessage.Validator()
    static let testValue: RedeemInputValidator = UnimplementedRedeemInputValidator()
}

extension DependencyValues {
    var avsMessageValidator: RedeemInputValidator {
        get { self[AVSMessage.Validator.self] }
        set { self[AVSMessage.Validator.self] = newValue }
    }
}

extension ErxTaskOrder {
    /// Collection of input validation functions for redeem via ErxTaskRepository. Constraints defined in
    /// [gemILF_PS_eRp]
    struct Validator: RedeemInputValidator, Equatable {
        static var maxHintLength = 500
        static var maxAddressFieldLength = 50
        static var maxPostcodeFieldLength = 50
        static var maxNameLength = 100
        init() {}

        func isValidErxTaskOrderInput( // swiftlint:disable:this function_parameter_count
            version: Int,
            redeemOption: RedeemOption,
            name: String?,
            address: Address?,
            hint: String?,
            phone: String?,
            mail: String?
        ) -> Validity {
            if isValid(version: version) != .valid {
                return isValid(version: version)
            }
            if isValid(name: name) != .valid {
                return isValid(name: name)
            }
            if isValid(address: address) != .valid {
                return isValid(address: address)
            }
            if isValid(hint: hint) != .valid {
                return isValid(hint: hint)
            }
            if isValid(phone: phone) != .valid {
                return isValid(phone: phone)
            }
            if isValid(mail: mail) != .valid {
                return isValid(mail: mail)
            }
            if ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
                optionType: redeemOption,
                phone: phone,
                mail: mail
            ) != .valid {
                return ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
                    optionType: redeemOption,
                    phone: phone,
                    mail: mail
                )
            }

            return .valid
        }

        func isValid(version: Int) -> Validity {
            version == 1 ? .valid : .invalid(L10n.rivTiWrongVersion.text)
        }

        func isValid(name: String?) -> Validity {
            (name?.countIsLessOrEqual(Validator.maxNameLength) ?? true) ? .valid :
                .invalid(L10n.rivTiInvalidName(String(Validator.maxNameLength)).text)
        }

        func isValid(street: String?) -> Validity {
            (street?.countIsLessOrEqual(Validator.maxAddressFieldLength) ?? true) ? .valid :
                .invalid(L10n.rivTiInvalidStreet(String(Validator.maxAddressFieldLength)).text)
        }

        func isValid(zip: String?) -> Validity {
            (zip?.countIsLessOrEqual(Validator.maxPostcodeFieldLength) ?? true) ? .valid :
                .invalid(L10n.rivTiInvalidZip(String(Validator.maxPostcodeFieldLength)).text)
        }

        func isValid(city: String?) -> Validity {
            (city?.countIsLessOrEqual(Validator.maxAddressFieldLength) ?? true) ? .valid :
                .invalid(L10n.rivTiInvalidCity(String(Validator.maxAddressFieldLength)).text)
        }

        func isValid(hint: String?) -> Validity {
            (hint?.countIsLessOrEqual(Validator.maxHintLength) ?? true) ? .valid :
                .invalid(L10n.rivTiInvalidHint(String(Validator.maxHintLength)).text)
        }

        // Not specified for ErxTaskOrder
        func isValid(text _: String?) -> Validity {
            .valid
        }

        func isValid(phone: String?) -> Validity {
            guard let phone = phone, !phone.isEmpty else {
                return .valid
            }
            let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
            guard let detector = try? NSDataDetector(types: types.rawValue) else { return .valid }

            let range = NSRange(phone.startIndex ..< phone.endIndex, in: phone)
            let matches = detector.matches(in: phone, options: [], range: range)

            guard matches.count == 1,
                  let match = matches.first,
                  match.resultType == .phoneNumber,
                  match.phoneNumber != nil else {
                return .invalid(L10n.rivTiInvalidPhone.text)
            }

            return .valid
        }

        func isValid(mail: String?) -> Validity {
            guard let mail = mail, !mail.isEmpty else {
                return .valid
            }
            return mail.isValidEmail ? .valid : .invalid(L10n.rivTiInvalidMail.text)
        }

        func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: RedeemOption,
            phone: String?,
            mail _: String?
        ) -> Validity {
            switch optionType {
            case .onPremise:
                return .valid
            case .delivery, .shipment:
                guard let phone = phone, !phone.isEmpty else {
                    return .invalid(L10n.rivTiInvalidMissingContact.text)
                }
                return .valid
            }
        }

        func onPremiseOrElseIsNonEmptyContactData( // swiftlint:disable:this function_parameter_count
            optionType: RedeemOption,
            name: String?,
            street: String?,
            zip: String?,
            city: String?,
            phone: String?
        ) -> Bool {
            switch optionType {
            case .onPremise:
                return true
            case .shipment, .delivery:
                return isCompleteContactData(name: name, street: street, zip: zip, city: city, phone: phone)
            }
        }

        var service: RedeemServiceOption {
            .erxTaskRepository
        }

        func isCompleteContactData(name: String?, street: String?, zip: String?, city: String?,
                                   phone: String?) -> Bool {
            name != nil && street != nil && zip != nil && city != nil && phone != nil
        }
    }
}

// sourcery: skipUnimplemented
extension ErxTaskOrder.Validator: DependencyKey {
    static let liveValue: RedeemInputValidator = ErxTaskOrder.Validator()
    static let previewValue: RedeemInputValidator = ErxTaskOrder.Validator()
    static let testValue: RedeemInputValidator = UnimplementedRedeemInputValidator()
}

extension DependencyValues {
    var erxTaskOrderValidator: RedeemInputValidator {
        get { self[ErxTaskOrder.Validator.self] }
        set { self[ErxTaskOrder.Validator.self] = newValue }
    }
}

struct DemoRedeemInputValidator: RedeemInputValidator {
    var service: RedeemServiceOption = .erxTaskRepository

    func isValid(version _: Int) -> Validity { .valid }

    func isValid(name _: String?) -> Validity { .valid }

    func isValid(street _: String?) -> Validity { .valid }

    func isValid(zip _: String?) -> Validity { .valid }

    func isValid(city _: String?) -> Validity { .valid }

    func isValid(hint _: String?) -> Validity { .valid }

    func isValid(text _: String?) -> Validity { .valid }

    func isValid(phone _: String?) -> Validity { .valid }

    func isValid(mail _: String?) -> Validity { .valid }

    func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
        optionType _: RedeemOption,
        phone _: String?,
        mail _: String?
    ) -> Validity {
        .valid
    }

    func onPremiseOrElseIsNonEmptyContactData( // swiftlint:disable:this function_parameter_count
        optionType _: RedeemOption,
        name _: String?,
        street _: String?,
        zip _: String?,
        city _: String?,
        phone _: String?
    ) -> Bool {
        true
    }
}

extension String {
    func countIsLessOrEqual(_ limit: Int) -> Bool {
        count <= limit
    }

    var isValidEmail: Bool {
        let emailRegex = "^[^@\\s]+@([^@\\s.]+\\.)+[^@\\s.]+$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}

// swiftlint:enable file_length
