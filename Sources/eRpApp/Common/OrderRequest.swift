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

import eRpKit
import Foundation
import OpenSSL
import Pharmacy

// swiftlint:disable:next type_name
protocol eRpRemoteStorageOrder {
    var version: String { get }
    var redeemType: RedeemOption { get }
    var flowType: String { get }
    var name: String? { get }
    var address: Address? { get }
    var hint: String? { get }
    var phone: String? { get }
    var mail: String? { get }
    var transactionID: UUID { get }
    var taskID: String { get }
    var accessCode: String { get }
    var telematikId: String? { get }
}

struct OrderRequest: eRpRemoteStorageOrder, Equatable, Codable {
    let orderID: UUID
    let redeemType: RedeemOption
    let version: String
    let name: String?
    let flowType: String
    let address: Address?
    let hint: String?
    let text: String?
    let phone: String?
    let mail: String?
    let transactionID: UUID
    let taskID: String
    let accessCode: String
    let recipients: [X509]
    let telematikId: String?

    init(
        orderID: UUID = UUID(),
        version: String = "2",
        redeemType: RedeemOption,
        name: String? = nil,
        flowType: String,
        address: Address? = nil,
        hint: String? = nil,
        text: String? = nil,
        phone: String? = nil,
        mail: String? = nil,
        transactionID: UUID = UUID(),
        taskID: String,
        accessCode: String,
        recipients: [X509] = [],
        telematikId: String? = nil
    ) {
        self.orderID = orderID
        self.version = version
        self.redeemType = redeemType
        self.name = name
        self.flowType = flowType
        self.address = address
        self.hint = hint
        self.text = text
        self.phone = phone
        self.mail = mail
        self.transactionID = transactionID
        self.taskID = taskID
        self.accessCode = accessCode
        self.recipients = recipients
        self.telematikId = telematikId
    }

    enum CodingKeys: String, CodingKey {
        case orderID
        case version
        case redeemType
        case name
        case flowType
        case address
        case hint
        case text
        case phone
        case mail
        case transactionID
        case taskID
        case accessCode
        case endpoint
        case recipients
        case telematikId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderID = try container.decode(UUID.self, forKey: .orderID)
        version = try container.decode(String.self, forKey: .version)
        redeemType = try container.decode(RedeemOption.self, forKey: .redeemType)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        flowType = try container.decode(String.self, forKey: .flowType)
        address = try container.decodeIfPresent(Address.self, forKey: .address)
        hint = try container.decodeIfPresent(String.self, forKey: .hint)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        mail = try container.decodeIfPresent(String.self, forKey: .mail)
        transactionID = try container.decode(UUID.self, forKey: .transactionID)
        taskID = try container.decode(String.self, forKey: .taskID)
        accessCode = try container.decode(String.self, forKey: .accessCode)
        recipients = try container.decode([Data].self, forKey: .recipients).map { try X509(der: $0) }
        telematikId = try container.decodeIfPresent(String.self, forKey: .telematikId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(orderID, forKey: .orderID)
        try container.encode(version, forKey: .version)
        try container.encode(redeemType, forKey: .redeemType)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(flowType, forKey: .flowType)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(hint, forKey: .hint)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(mail, forKey: .mail)
        try container.encode(transactionID, forKey: .transactionID)
        try container.encode(taskID, forKey: .taskID)
        try container.encode(accessCode, forKey: .accessCode)
        try container.encode(recipients.map(\.derBytes), forKey: .recipients)
        try container.encodeIfPresent(telematikId, forKey: .telematikId)
    }
}

extension ErxTaskOrder {
    init(_ order: OrderRequest) throws {
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
            version: version,
            supplyOptionsType: order.redeemType,
            name: order.name ?? "",
            address: order.address?.asArray() ?? [],
            hint: order.hint ?? "",
            phone: order.phone ?? ""
        )
        self.init(
            identifier: order.orderID.uuidString,
            erxTaskId: order.taskID,
            accessCode: order.accessCode,
            telematikId: telematikId,
            flowType: order.flowType,
            payload: payload
        )
    }
}

extension Sequence<ErxTask> {
    func asOrders(
        orderId: UUID,
        option redeemOption: RedeemOption,
        for pharmacy: PharmacyLocation,
        with shipmentInfo: ShipmentInfo?
    ) -> [OrderRequest] {
        map { $0.asOrder(orderId: orderId, option: redeemOption, for: pharmacy, with: shipmentInfo) }
    }
}

extension ErxTask {
    func asOrder(orderId: UUID, option redeemOption: RedeemOption, for pharmacy: PharmacyLocation,
                 with shipmentInfo: ShipmentInfo?) -> OrderRequest {
        let transactionId = UUID()
        return OrderRequest(
            orderID: orderId,
            redeemType: redeemOption,
            name: shipmentInfo?.name,
            flowType: flowType.rawValue,
            address: Address(
                street: shipmentInfo?.street,
                detail: shipmentInfo?.addressDetail,
                zip: shipmentInfo?.zip,
                city: shipmentInfo?.city
            ),
            hint: shipmentInfo?.deliveryInfo,
            text: nil, // TODO: other ticket //swiftlint:disable:this todo
            phone: shipmentInfo?.phone,
            mail: shipmentInfo?.mail,
            transactionID: transactionId,
            taskID: id,
            accessCode: accessCode ?? "",
            telematikId: pharmacy.telematikID
        )
    }
}
