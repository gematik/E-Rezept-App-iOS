// swiftlint:disable:this file_name
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

extension ErxTask.Communication {
    enum Dummies {
        static let communicationDispRequest = ErxTask.Communication(
            identifier: "1",
            profile: .dispReq,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}" // swiftlint:disable:this line_length
        )

        static let communicationOnPremise = ErxTask.Communication(
            identifier: "1",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}" // swiftlint:disable:this line_length
        )

        static let communicationOnPremiseWithUrl = ErxTask.Communication(
            identifier: "1",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\", \"url\": \"https://das-e-rezept-fuer-deutschland.de\"}" // swiftlint:disable:this line_length
        )

        static let communicationShipment = ErxTask.Communication(
            identifier: "2",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-28T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://das-e-rezept-fuer-deutschland.de\"}",
            // swiftlint:disable:previous line_length
            isRead: true
        )

        static let communicationDelivery = ErxTask.Communication(
            identifier: "3",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-29T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\", \"url\": \"https://das-e-rezept-fuer-deutschland.de\"}" // swiftlint:disable:this line_length
        )

        static let communicationWithOrderId = ErxTask.Communication(
            identifier: "4",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            orderId: "orderId",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            // swiftlint:disable:next line_length
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}",
            isRead: true
        )

        static let communicationWithoutPayload = ErxTask.Communication(
            identifier: "4",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            orderId: "orderId",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "",
            isRead: true
        )

        static let multipleCommunications1 = [
            communicationOnPremise,
            communicationShipment,
            communicationDelivery,
        ]

        static let multipleCommunications2 = [communicationWithOrderId]
    }
}
