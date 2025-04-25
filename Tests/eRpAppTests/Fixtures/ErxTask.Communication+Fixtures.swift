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

@testable import eRpFeatures
import eRpKit
import Foundation

extension ErxTask.Communication {
    // swiftlint:disable:next type_body_length
    enum Fixtures {
        // Order id 1
        static let allOrderId1Communications = [
            ErxTask.Communication.Fixtures.communicationDispReq1,
            ErxTask.Communication.Fixtures.communicationReply1,
            ErxTask.Communication.Fixtures.communicationDispReq2,
            ErxTask.Communication.Fixtures.communicationDispReqWithChargeItem,
        ]

        static let communicationDispReq1: ErxTask.Communication = .init(
            identifier: "disp_req_id_1",
            profile: .dispReq,
            taskId: "task_id_1",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Hello\"}",
            isRead: true
        )

        static let communicationReply1: ErxTask.Communication = .init(
            identifier: "disp_reply_1",
            profile: .reply,
            taskId: "task_id_1",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-27T10:59:37.098245934+00:00",
            // swiftlint:disable:next line_length
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Get it\", \"pickUpCodeHR\":\"4711\"}",
            isRead: true
        )

        static let communicationDispReq2: ErxTask.Communication = .init(
            identifier: "disp_req_id_2",
            profile: .dispReq,
            taskId: "task_id_2",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-27T15:59:37.098245935+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Please\"}",
            isRead: true
        )

        // communication with a task that contains a charge_item
        static let communicationDispReqWithChargeItem: ErxTask.Communication = .init(
            identifier: "disp_req_id_3",
            profile: .dispReq,
            taskId: "chargeItem_id_12_taskID", // is related to a charge item
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-27T15:59:40.098245936+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Please\"}",
            isRead: true
        )

        // Order id 2
        static let allOrderId2Communications = [
            ErxTask.Communication.Fixtures.communicationDispReqOrder2,
        ]

        static let communicationDispReqOrder2: ErxTask.Communication = .init(
            identifier: "disp_req_id_3",
            profile: .dispReq,
            taskId: "task_id_3",
            userId: "user_id_1",
            telematikId: "12345.2",
            orderId: "order_id_2",
            timestamp: "2021-07-26T10:59:37.098245943+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Hello\"}",
            isRead: true
        )

        static let communicationDispReqComputedDate: ErxTask.Communication = .init(
            identifier: "disp_req_id_1",
            profile: .dispReq,
            taskId: "task_id_1",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: DemoDate.createDemoDate(.oneHourAgo)!,
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Hello\"}",
            isRead: true
        )

        static let communicationDispReq2ComputedDate: ErxTask.Communication = .init(
            identifier: "disp_req_1",
            profile: .dispReq,
            taskId: "53210f983-1e67-22c5-8955-63bf44e44fb8",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-28T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Hello\"}",
            isRead: true
        )

        static let communicationDispReqYesterDay: ErxTask.Communication = .init(
            identifier: "disp_req_2",
            profile: .dispReq,
            taskId: "34235f983-1e67-22c5-8955-63bf44e44fb8",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-27T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Hello\"}",
            isRead: true
        )

        static let communicationReply2ComputedDate: ErxTask.Communication = .init(
            identifier: "disp_reply_1",
            profile: .reply,
            taskId: "53210f983-1e67-22c5-8955-63bf44e44fb8",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-28T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Hello\"}",
            isRead: true
        )

        static let communicationReplyYesterDay: ErxTask.Communication = .init(
            identifier: "disp_reply_2",
            profile: .reply,
            taskId: "34235f983-1e67-22c5-8955-63bf44e44fb8",
            userId: "user_id_1",
            telematikId: "12345.1",
            orderId: "order_id_1",
            timestamp: "2021-05-27T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Hello\"}",
            isRead: true
        )
    }
}
