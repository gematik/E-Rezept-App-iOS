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

extension ErxTask {
    /// Acts as the intermediate data model from a communication resource response and the local store representation
    public struct Communication: Equatable, Identifiable {
        /// Identifier for this communication resource (e.g.:  "16d2cfc8-2023-11b2-81e1-783a425d8e87")
        public let identifier: String
        /// Profile of the communication resource (e.g.: "ErxCommunicationReply")
        public let profile: Profile
        /// Id for the task this communication is related to (e.g.: "39c67d5b-1df3-11b2-80b4-783a425d8e87"
        public let taskId: String
        /// KVNR of the user (e.g.: "X110461389")
        public let insuranceId: String
        /// Telematik id of the sender (e.g. "3-09.2.S.10.743")
        public let telematikId: String
        /// Id for every order of prescriptions
        public let orderId: String?
        /// Date time string representing the time of sending the communication
        public let timestamp: String
        /// `true` if user has interacted with this communication, otherwise false if loaded from server
        public var isRead: Bool
        /// JSON string containing informations the actual message (to-do: parse into object)
        public let payloadJSON: String
        /// Parsed `payloadJSON` into `Payload` or nil if format is wrong
        public let payload: Payload?

        public var id: String {
            identifier
        }

        /// Default initializer for a ErxTaskCommunication which represent a ModulesR4.Communication
        /// - Parameters:
        ///   - identifier: Identifier for this communication resource
        ///   - profile:communication profile
        ///   - taskId: Id for the task this communication is related to
        ///   - userId: KVNR of the use
        ///   - telematikId: Telematik id of the sender
        ///   - orderId: Id for every order of prescriptions
        ///   - timestamp: Date time string representing the time of sending the communication
        ///   - payloadJSON: Payload contains informations about the actual message
        ///   - isRead: Indicates if the user has interacted (true) with this communication resource
        public init(
            identifier: String,
            profile: Profile,
            taskId: String,
            userId: String,
            telematikId: String,
            orderId: String? = nil,
            timestamp: String,
            payloadJSON: String,
            isRead: Bool = false
        ) {
            self.identifier = identifier
            self.taskId = taskId
            insuranceId = userId
            self.telematikId = telematikId
            self.orderId = orderId
            self.timestamp = timestamp
            self.payloadJSON = payloadJSON
            self.isRead = isRead
            self.profile = profile
            payload = try? Payload.from(string: payloadJSON)
        }

        public struct Payload: Codable, Equatable {
            /// The selected shipment option by the user
            public let supplyOptionsType: RedeemOption
            /// Free description text by the pharmacy
            public let infoText: String?
            /// Only available with supplyOptionsType `onPremise` (e.g.: "12341234")
            public let pickUpCodeHR: String?
            /// Only available with supplyOptionsType `onPremise`.
            /// Contains content that can be converted into a data matrix code
            public let pickUpCodeDMC: String?
            /// Only available with supplyOptionsType `shipment`.
            /// Contains an url with informations about the shipment
            public let url: String?
            /// Version of the JSON
            let version: String

            public static func from(string: String, decoder: JSONDecoder = defaultDecoder) throws -> Self {
                try from(data: Data(string.utf8), decoder: decoder)
            }

            static func from(data: Data, decoder: JSONDecoder = defaultDecoder) throws -> Self {
                try decoder.decode(Payload.self, from: data)
            }

            public static var defaultDecoder: JSONDecoder {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }

            public var isPickupCodeEmptyOrNil: Bool {
                pickUpCodeHR?.isEmpty ?? true && pickUpCodeDMC?.isEmpty ?? true
            }
        }

        public enum Profile: String, Codable {
            case reply
            case dispReq
            case infoReq
            case representative
            case all
            case none

            public var isReply: Bool {
                self == .reply
            }

            public var isAll: Bool {
                self == .all
            }
        }
    }
}
