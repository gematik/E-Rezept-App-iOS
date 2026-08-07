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

import Foundation

extension ErxTask {
    /// Acts as the intermediate data model from a communication resource response and the local store representation
    public struct Communication: Equatable, Identifiable, Codable, Sendable {
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
        public let payloadJSON: String?
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
            payloadJSON: String?,
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

        public struct Payload: Codable, Equatable, Sendable {
            /// Version of the JSON (1 for v1, 3 for v3)
            public let version: Int
            /// The selected shipment option by the user (v1 only)
            public let supplyOptionsType: RedeemOption?
            /// Free description text by the pharmacy (v1: `info_text`, v3: `text`)
            public let infoText: String?
            /// Pickup code human-readable (v1: `pickUpCodeHR`, v3 `pickupCodeHR`)
            public let pickUpCodeHR: String?
            /// Data matrix code content (v1: `pickUpCodeDMC`, v3: `pickupCodeDMC`)
            public let pickUpCodeDMC: String?
            /// URL with shipment info (v1 + v3 link type)
            public let url: String?
            /// Communication type discriminator (v3 only)
            public let communicationType: CommunicationType?
            /// Transaction identifier (v3 only)
            public let transactionID: String?
            /// Reservation readiness status (v3 `reservationStatus` type)
            public let readyForCollection: ReadyForCollection?
            /// Delivery tracking status (v3 `deliveryStatus` type)
            public let deliveryStatus: DeliveryStatusType?
            /// Current position during transport (v3 `deliveryStatus` type)
            public let inTransportPosition: Position?
            /// Estimated time of arrival window (v3 `deliveryStatus` type)
            public let inTransportETA: ETA?
            /// Total amount in smallest currency unit (v3 `paymentInfo` type)
            public let totalAmount: Int?
            /// Available payment methods (v3 `paymentInfo` type)
            public let paymentMethods: [PaymentMethod]

            /// Detected payload version
            public var payloadVersion: PayloadVersion {
                PayloadVersion(rawValue: version) ?? .v1_0
            }

            /// Payload v1 initializer — backward compatible
            public init(
                supplyOptionsType: RedeemOption,
                infoText: String? = nil,
                pickUpCodeHR: String? = nil,
                pickUpCodeDMC: String? = nil,
                url: String? = nil,
                version: Int
            ) {
                self.supplyOptionsType = supplyOptionsType
                self.infoText = infoText
                self.pickUpCodeHR = pickUpCodeHR
                self.pickUpCodeDMC = pickUpCodeDMC
                self.url = url
                self.version = version
                communicationType = nil
                transactionID = nil
                readyForCollection = nil
                deliveryStatus = nil
                inTransportPosition = nil
                inTransportETA = nil
                totalAmount = nil
                paymentMethods = []
            }

            /// Payload v3 initializer
            public init(
                version: Int = 3,
                communicationType: CommunicationType,
                transactionID: String,
                infoText: String? = nil,
                url: String? = nil,
                pickUpCodeHR: String? = nil,
                pickUpCodeDMC: String? = nil,
                readyForCollection: ReadyForCollection? = nil,
                deliveryStatus: DeliveryStatusType? = nil,
                inTransportPosition: Position? = nil,
                inTransportETA: ETA? = nil,
                totalAmount: Int? = nil,
                paymentMethods: [PaymentMethod] = []
            ) {
                self.version = version
                self.communicationType = communicationType
                self.transactionID = transactionID
                supplyOptionsType = nil
                self.infoText = infoText
                self.url = url
                self.pickUpCodeHR = pickUpCodeHR
                self.pickUpCodeDMC = pickUpCodeDMC
                self.readyForCollection = readyForCollection
                self.deliveryStatus = deliveryStatus
                self.inTransportPosition = inTransportPosition
                self.inTransportETA = inTransportETA
                self.totalAmount = totalAmount
                self.paymentMethods = paymentMethods
            }

            private enum CodingKeysV1: String, CodingKey {
                case supplyOptionsType
                case infoText = "info_text"
                case pickUpCodeHR
                case pickUpCodeDMC
                case url
                case version
            }

            private enum CodingKeysV3: String, CodingKey {
                case communicationType
                case transactionID
                case text
                case pickupCodeHR
                case pickupCodeDMC
                case url
                case version
                case readyForCollection
                case deliveryStatus
                case inTransportPosition
                case inTransportETA
                case totalAmount
                case paymentMethods
            }

            // MARK: - Decoding

            public static func from(string: String?, decoder: JSONDecoder = defaultDecoder) throws -> Self? {
                guard let string else { return nil }
                return try from(data: Data(string.utf8), decoder: decoder)
            }

            static func from(data: Data, decoder: JSONDecoder = defaultDecoder) throws -> Self {
                try decoder.decode(Payload.self, from: data)
            }

            public init(from decoder: Decoder) throws {
                let containerV3 = try decoder.container(keyedBy: CodingKeysV3.self)
                let containerV1 = try decoder.container(keyedBy: CodingKeysV1.self)

                // Version (supports both Int and String)
                if let intVersion = try? containerV3.decode(Int.self, forKey: .version) {
                    version = intVersion
                } else if let stringVersion = try? containerV3.decode(String.self, forKey: .version),
                          let intVersion = Int(stringVersion) {
                    version = intVersion
                } else {
                    version = try containerV1.decode(Int.self, forKey: .version)
                }

                switch PayloadVersion(rawValue: version) ?? .v1_0 {
                case .v3_0:
                    communicationType = try containerV3.decodeIfPresent(
                        CommunicationType.self,
                        forKey: .communicationType
                    )
                    transactionID = try containerV3.decodeIfPresent(String.self, forKey: .transactionID)
                    infoText = try containerV3.decodeIfPresent(String.self, forKey: .text)
                    pickUpCodeHR = try containerV3.decodeIfPresent(String.self, forKey: .pickupCodeHR)
                    pickUpCodeDMC = try containerV3.decodeIfPresent(String.self, forKey: .pickupCodeDMC)
                    url = try containerV3.decodeIfPresent(String.self, forKey: .url)
                    readyForCollection = try containerV3.decodeIfPresent(
                        ReadyForCollection.self,
                        forKey: .readyForCollection
                    )
                    deliveryStatus = try containerV3.decodeIfPresent(DeliveryStatusType.self, forKey: .deliveryStatus)
                    inTransportPosition = try containerV3.decodeIfPresent(Position.self, forKey: .inTransportPosition)
                    inTransportETA = try containerV3.decodeIfPresent(ETA.self, forKey: .inTransportETA)
                    totalAmount = try containerV3.decodeIfPresent(Int.self, forKey: .totalAmount)
                    paymentMethods = try containerV3
                        .decodeIfPresent([PaymentMethod].self, forKey: .paymentMethods) ?? []

                    supplyOptionsType = nil
                case .v1_0:
                    supplyOptionsType = try containerV1.decodeIfPresent(RedeemOption.self, forKey: .supplyOptionsType)
                    infoText = try containerV1.decodeIfPresent(String.self, forKey: .infoText)
                    pickUpCodeHR = try containerV1.decodeIfPresent(String.self, forKey: .pickUpCodeHR)
                    pickUpCodeDMC = try containerV1.decodeIfPresent(String.self, forKey: .pickUpCodeDMC)
                    url = try containerV1.decodeIfPresent(String.self, forKey: .url)

                    communicationType = nil
                    transactionID = nil
                    readyForCollection = nil
                    deliveryStatus = nil
                    inTransportPosition = nil
                    inTransportETA = nil
                    totalAmount = nil
                    paymentMethods = []
                }
            }

            // MARK: - Encoding

            public func encode(to encoder: Encoder) throws {
                var containerV1 = encoder.container(keyedBy: CodingKeysV1.self)
                var containerV3 = encoder.container(keyedBy: CodingKeysV3.self)

                try containerV1.encode(version, forKey: .version)
                try containerV3.encode(version, forKey: .version)

                switch payloadVersion {
                case .v3_0:
                    try containerV3.encodeIfPresent(communicationType, forKey: .communicationType)
                    try containerV3.encodeIfPresent(transactionID, forKey: .transactionID)
                    try containerV3.encodeIfPresent(infoText, forKey: .text)
                    try containerV3.encodeIfPresent(url, forKey: .url)
                    try containerV3.encodeIfPresent(pickUpCodeHR, forKey: .pickupCodeHR)
                    try containerV3.encodeIfPresent(pickUpCodeDMC, forKey: .pickupCodeDMC)
                    try containerV3.encodeIfPresent(readyForCollection, forKey: .readyForCollection)
                    try containerV3.encodeIfPresent(deliveryStatus, forKey: .deliveryStatus)
                    try containerV3.encodeIfPresent(inTransportPosition, forKey: .inTransportPosition)
                    try containerV3.encodeIfPresent(inTransportETA, forKey: .inTransportETA)
                    try containerV3.encodeIfPresent(totalAmount, forKey: .totalAmount)
                    try containerV3.encodeIfPresent(paymentMethods, forKey: .paymentMethods)
                case .v1_0:
                    try containerV1.encodeIfPresent(supplyOptionsType, forKey: .supplyOptionsType)
                    try containerV1.encodeIfPresent(infoText, forKey: .infoText)
                    try containerV1.encodeIfPresent(pickUpCodeHR, forKey: .pickUpCodeHR)
                    try containerV1.encodeIfPresent(pickUpCodeDMC, forKey: .pickUpCodeDMC)
                    try containerV1.encodeIfPresent(url, forKey: .url)
                }
            }

            public static var defaultDecoder: JSONDecoder {
                JSONDecoder()
            }

            public var isPickupCodeEmptyOrNil: Bool {
                pickUpCodeHR?.isEmpty ?? true && pickUpCodeDMC?.isEmpty ?? true
            }
        }

        // swiftlint:disable identifier_name
        /// Payload version discriminator for communication payloads
        public enum PayloadVersion: Int, Codable, Equatable, Sendable {
            case v1_0 = 1
            case v3_0 = 3
        }

        // swiftlint:enable identifier_name

        public enum Profile: String, Codable, Sendable {
            case reply
            case dispReq
            // infoReq is deprecated with workflow version v1_5_2
            @available(*, deprecated)
            case infoReq
            case diga
            case representative
            case all
            case none

            public var isAll: Bool {
                self == .all
            }
        }
    }
}

extension ErxTask.Communication.Payload {
    public enum CommunicationType: String, Codable, Equatable, Sendable {
        case text
        case link
        case reservationStatus
        case pickupCodeHR
        case pickupCodeDMC
        case deliveryStatus
        case paymentInfo
    }

    public enum ReadyForCollection: String, Codable, Equatable, Sendable {
        case immediately
        case sameDay
        case nextDay
        case nextDayAM
        case nextDayPM
        case unknown
        case notAvailable
    }

    public enum DeliveryStatusType: String, Codable, Equatable, Sendable {
        case preparedWaiting
        case inTransport
        case delivered
        case incident
    }

    public struct Position: Codable, Equatable, Sendable {
        public let long: Double
        public let lat: Double

        public init(long: Double, lat: Double) {
            self.long = long
            self.lat = lat
        }
    }

    // swiftlint:disable identifier_name
    public struct ETA: Codable, Equatable, Sendable {
        public let from: Int
        public let to: Int

        public init(from: Int, to: Int) {
            self.from = from
            self.to = to
        }
    }

    // swiftlint:enable identifier_name

    public struct PaymentMethod: Codable, Equatable, Sendable {
        public let method: PaymentMethodType
        public let url: String?

        public init(method: PaymentMethodType, url: String? = nil) {
            self.method = method
            self.url = url
        }

        public enum PaymentMethodType: String, Codable, Equatable, Sendable {
            case cash
            case bankaccount
            case creditcard
            case paypal
        }
    }
}

extension ErxTask.Communication: Comparable, Hashable {
    public struct Unique: Equatable, Identifiable, Codable, Sendable {
        public let identifier: String
        public let profile: Profile
        public let taskIds: [String]
        public let insuranceId: String
        public let telematikId: String
        public let orderId: String?
        public let timestamp: String
        public let isRead: Bool
        public let payloadJSON: String?
        public let payload: Payload?
        public var id: String {
            identifier
        }

        public init(
            identifier: String,
            profile: Profile,
            taskIds: [String],
            insuranceId: String,
            telematikId: String,
            orderId: String? = nil,
            timestamp: String,
            payloadJSON: String? = nil,
            isRead: Bool = false
        ) {
            self.identifier = identifier
            self.taskIds = taskIds
            self.insuranceId = insuranceId
            self.telematikId = telematikId
            self.orderId = orderId
            self.timestamp = timestamp
            self.payloadJSON = payloadJSON
            self.isRead = isRead
            self.profile = profile
            payload = try? Payload.from(string: payloadJSON)
        }

        public init(from communication: ErxTask.Communication) {
            identifier = communication.identifier
            taskIds = [communication.taskId]
            insuranceId = communication.insuranceId
            telematikId = communication.telematikId
            orderId = communication.orderId
            timestamp = communication.timestamp
            payloadJSON = communication.payloadJSON
            isRead = communication.isRead
            profile = communication.profile
            payload = try? Payload.from(string: communication.payloadJSON)
        }
    }

    /// Acts as the key for an Unique Communication
    struct UniqueKey: Equatable, Hashable {
        let profile: Profile
        let payload: String?
        let insuranceId: String
        let telematikId: String
        let orderId: String
    }

    public static func <(lhs: ErxTask.Communication, rhs: ErxTask.Communication) -> Bool {
        lhs.timestamp > rhs.timestamp
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Collection<ErxTask.Communication> {
    /// Returns a result of `[ErxTask.Communication.Unique]` that are unique for there properties:
    /// `profile`, `payload`, `insuranceId`, `telematikId`and `orderId`
    ///  The element is also unique if the `orderId` is `nil`. Duplicated `taskId` from `ErxTask.Communication` with
    ///  the same `ErxTask.Communication.UniqueKey` are stored within `ErxTask.Communication.Unique.taskIds`
    ///
    /// - Returns: `[ErxTask.Communication.Unique]` that are unique in there filtered properties
    public func filterUnique()
        -> [ErxTask.Communication.Unique] {
        var groupDict = [ErxTask.Communication.UniqueKey: [ErxTask.Communication]]()
        // sort by timestamp to filter newer elements
        let sortedElements = sorted { $0.timestamp < $1.timestamp }

        for element in sortedElements {
            let key = ErxTask.Communication.UniqueKey(profile: element.profile,
                                                      payload: element.payloadJSON,
                                                      insuranceId: element.insuranceId,
                                                      telematikId: element.telematikId,
                                                      orderId: element.orderId ?? UUID().uuidString)
            groupDict[key, default: []].append(element)
        }

        return groupDict.map { key, elements -> ErxTask.Communication.Unique in
            // Array of all taskIds that have the same unique properties and remove all duplicated taskIds
            let taskIds = Array(Set(elements.map(\.taskId)))
            // isRead false if any communication isRead is false
            let isRead = !elements.contains { !$0.isRead }

            let latestTimestamp = elements.map(\.timestamp).max { $0 < $1 } ?? ""
            let firstId = elements.first?.id ?? UUID().uuidString

            return ErxTask.Communication.Unique(identifier: firstId,
                                                profile: key.profile,
                                                taskIds: taskIds.sorted(),
                                                insuranceId: key.insuranceId,
                                                telematikId: key.telematikId,
                                                orderId: key.orderId,
                                                timestamp: latestTimestamp,
                                                payloadJSON: key.payload,
                                                isRead: isRead)
        }
    }
}

// swiftlint:enable file_length
