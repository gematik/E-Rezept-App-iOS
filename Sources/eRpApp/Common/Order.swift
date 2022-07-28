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

import AVS
import eRpKit
import Foundation
import OpenSSL
import Pharmacy

protocol eRpRemoteStorageOrder {
    var version: String { get }
    var redeemType: RedeemOption { get }
    var name: String? { get }
    var address: Address? { get }
    var hint: String? { get }
    var phone: String? { get }
    var mail: String? { get }
    var taskID: String { get }
    var accessCode: String { get }
    var telematikId: String? { get }
}

protocol AVSOrder {
    var version: String { get }
    var redeemType: RedeemOption { get }
    var name: String? { get }
    var address: Address? { get }
    var hint: String? { get }
    var text: String? { get }
    var phone: String? { get }
    var mail: String? { get }
    var transactionID: UUID { get }
    var taskID: String { get }
    var accessCode: String { get }
    var endpoint: PharmacyLocation.AVSEndpoints.Endpoint? { get }
    var recipients: [X509] { get }
}

struct Address: Equatable {
    let street: String?
    let zip: String?
    let city: String?

    func asArray() -> [String] {
        var address = [String]()
        if let street = street {
            address.append(street)
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

struct Order: eRpRemoteStorageOrder, AVSOrder, Equatable {
    let redeemType: RedeemOption
    let version: String
    let name: String?
    let address: Address?
    let hint: String?
    let text: String?
    let phone: String?
    let mail: String?
    let transactionID: UUID
    let taskID: String
    let accessCode: String
    let endpoint: PharmacyLocation.AVSEndpoints.Endpoint?
    let recipients: [X509]
    let telematikId: String?

    init(
        version: String = "1",
        redeemType: RedeemOption,
        name: String? = nil,
        address: Address? = nil,
        hint: String? = nil,
        text: String? = nil,
        phone: String? = nil,
        mail: String? = nil,
        transactionID: UUID = UUID(),
        taskID: String,
        accessCode: String,
        endpoint: PharmacyLocation.AVSEndpoints.Endpoint? = nil,
        recipients: [X509] = [],
        telematikId: String? = nil
    ) {
        self.version = version
        self.redeemType = redeemType
        self.name = name
        self.address = address
        self.hint = hint
        self.text = text
        self.phone = phone
        self.mail = mail
        self.transactionID = transactionID
        self.taskID = taskID
        self.accessCode = accessCode
        self.endpoint = endpoint
        self.recipients = recipients
        self.telematikId = telematikId
    }
}

extension AVSMessage.SupplyOptionsType {
    var asRedeemOption: RedeemOption {
        switch self {
        case .onPremise: return .onPremise
        case .delivery: return .delivery
        case .shipment: return .shipment
        }
    }
}

extension RedeemOption {
    var asSupplyOptionType: AVSMessage.SupplyOptionsType {
        switch self {
        case .onPremise: return .onPremise
        case .delivery: return .delivery
        case .shipment: return .shipment
        }
    }
}

extension ErxTaskOrder {
    init(_ order: Order) throws {
        guard let telematikId = order.telematikId else {
            throw RedeemServiceError.internalError(.missingTelematikId)
        }
        let version = 1
        if case let .invalid(error) = Validator().isValidErxTaskOrderInput(
            version: version,
            redeemOption: order.redeemType,
            name: order.name,
            address: order.address,
            hint: order.hint,
            phone: order.phone,
            mail: order.mail
        ) {
            throw ErxTaskOrder.Error.invalidErxTaskOrderInput(error)
        }

        let payload = ErxTaskOrder.Payload(
            version: String(version),
            supplyOptionsType: order.redeemType,
            name: order.name ?? "",
            address: order.address?.asArray() ?? [],
            hint: order.hint ?? "",
            phone: order.phone ?? ""
        )
        self.init(
            erxTaskId: order.taskID,
            accessCode: order.accessCode,
            pharmacyTelematikId: telematikId,
            payload: payload
        )
    }
}

extension AVSMessage {
    init(_ order: Order) throws {
        guard let version = Int(order.version) else {
            throw RedeemServiceError.InternalError.conversionVersionNumber
        }
        guard Validator().isValidAVSMessageInput(
            version: version,
            supplyOptionsType: order.redeemType.asSupplyOptionType,
            name: order.name,
            address: order.address,
            hint: order.hint,
            text: order.text,
            phone: order.phone,
            mail: order.mail
        ) == .valid
        else {
            throw AVSError.invalidAVSMessageInput
        }

        self.init(
            version: version,
            supplyOptionsType: order.redeemType.asSupplyOptionType,
            name: order.name,
            address: order.address?.asArray(),
            hint: order.hint,
            text: order.text,
            phone: order.phone,
            mail: order.mail,
            transactionID: order.transactionID,
            taskID: order.taskID,
            accessCode: order.accessCode
        )
    }
}
