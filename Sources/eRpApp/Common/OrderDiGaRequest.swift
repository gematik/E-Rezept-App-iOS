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

import eRpKit
import Foundation
import OpenSSL

// swiftlint:disable:next type_name
protocol eRpRemoteStorageDiGaOrder {
    var flowType: String { get }
    var transactionID: UUID { get }
    var taskID: String { get }
    var accessCode: String { get }
    var telematikId: String { get }
}

struct OrderDiGaRequest: eRpRemoteStorageDiGaOrder, Equatable, Codable {
    let orderID: UUID
    let flowType: String
    let transactionID: UUID
    let taskID: String
    let accessCode: String
    var telematikId: String

    init(
        orderID: UUID = UUID(),
        flowType: String,
        transactionID: UUID = UUID(),
        taskID: String,
        accessCode: String,
        telematikId: String
    ) {
        self.orderID = orderID
        self.flowType = flowType
        self.transactionID = transactionID
        self.taskID = taskID
        self.accessCode = accessCode
        self.telematikId = telematikId
    }

    enum CodingKeys: String, CodingKey {
        case orderID
        case flowType
        case transactionID
        case taskID
        case accessCode
        case telematikId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderID = try container.decode(UUID.self, forKey: .orderID)
        flowType = try container.decode(String.self, forKey: .flowType)
        transactionID = try container.decode(UUID.self, forKey: .transactionID)
        taskID = try container.decode(String.self, forKey: .taskID)
        accessCode = try container.decode(String.self, forKey: .accessCode)
        telematikId = try container.decode(String.self, forKey: .telematikId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(orderID, forKey: .orderID)
        try container.encode(flowType, forKey: .flowType)
        try container.encode(transactionID, forKey: .transactionID)
        try container.encode(taskID, forKey: .taskID)
        try container.encode(accessCode, forKey: .accessCode)
        try container.encodeIfPresent(telematikId, forKey: .telematikId)
    }
}

extension ErxTaskOrder {
    init(_ order: OrderDiGaRequest) throws {
        self.init(
            identifier: order.orderID.uuidString,
            erxTaskId: order.taskID,
            accessCode: order.accessCode,
            telematikId: order.telematikId,
            flowType: order.flowType,
            payload: nil
        )
    }
}

extension Sequence where Self.Element == ErxTask {
    func asDiGaOrders(
        orderId: UUID,
        for telematikId: String
    ) -> [OrderDiGaRequest] {
        map { $0.asDiGaOrder(orderId: orderId, for: telematikId) }
    }
}

extension ErxTask {
    func asDiGaOrder(orderId: UUID, for telematikId: String) -> OrderDiGaRequest {
        let transactionId = UUID()
        return OrderDiGaRequest(
            orderID: orderId,
            flowType: flowType.rawValue,
            transactionID: transactionId,
            taskID: id,
            accessCode: accessCode ?? "",
            telematikId: telematikId
        )
    }
}
