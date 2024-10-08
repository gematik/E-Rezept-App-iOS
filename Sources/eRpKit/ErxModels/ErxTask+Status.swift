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

import Foundation

extension ErxTask {
    /// All defined states of a task (see `gemSysL_eRp` chapter 2.4.6 "Konzept Status E-Rezept")
    public enum Status: Equatable, RawRepresentable, Codable {
        /// The task has been initialized but  is not yet ready to be acted upon.
        case draft
        /// The task is ready (open) to be performed, but no action has yet been taken.
        case ready
        /// The task has been started by a pharmacy but is not yet complete.
        /// If the task is in this state it is blocked for any operation (e.g. redeem or delete)
        case inProgress
        /// The task was not completed and has been deleted.
        case cancelled
        /// The task has been completed which means it has been accepted by a pharmacy
        case completed
        /// The task state is not defined as subset of eRp status
        case undefined(status: String)
        /// This status is not part of the FHIR task status and is computed on device only.
        /// Status is computed in `ErxTaskEntity+ErxTask`
        case computed(status: ComputedStatus)
        /// Extra error status (not FHIR)
        case error(Error)

        public enum ComputedStatus: String {
            /// Status is `sent` when an ErxTask has been sent to an AVS service without using the fachdienst
            case sent
            /// Status is `waiting` for 10 minutes after redeeming an ErxTask via fachdienst
            case waiting
        }

        /// The associated `RawValue` type
        public typealias RawValue = String

        private static let errorPrefix = "error: "

        /// Creates a new instance with the specified raw value.
        public init?(rawValue: RawValue) { // swiftlint:disable:this cyclomatic_complexity
            switch rawValue {
            case "draft": self = .draft
            case "ready": self = .ready
            case "in-progress": self = .inProgress
            case "cancelled": self = .cancelled
            case "completed": self = .completed
            case "sent": self = .computed(status: .sent)
            case "waiting": self = .computed(status: .waiting)
            /// The task is ready to be acted upon and action is sought.
            case "requested", "undefined: requested": self = .undefined(status: "requested")
            /// A potential performer has claimed ownership of the task and is evaluating whether to perform it.
            case "received", "undefined: received": self = .undefined(status: "received")
            /// The potential performer has agreed to execute the task but has not yet started work.
            case "accepted", "undefined: accepted": self = .undefined(status: "accepted")
            /// The potential performer who claimed ownership of the task has decided
            /// not to execute it prior to performing any action.
            case "rejected", "undefined: rejected": self = .undefined(status: "rejected")
            /// The task has been started but work has been paused.
            case "on-hold", "undefined: on-hold": self = .undefined(status: "on-hold")
            /// The task was attempted but could not be completed due to some error.
            case "failed", "undefined: failed": self = .undefined(status: "failed")
            /// The task should never have existed and is retained only because of the possibility it may have used.
            case "entered-in-error", "undefined: entered-in-error": self = .undefined(status: "entered-in-error")
            default:
                if rawValue.hasPrefix(Self.errorPrefix) {
                    let errorRawValue = String(rawValue.dropFirst(Self.errorPrefix.count))
                    self = .error(.init(rawValue: errorRawValue))
                } else {
                    return nil
                }
            }
        }

        /// The corresponding value of the raw type.
        public var rawValue: RawValue {
            switch self {
            case .draft: return "draft"
            case .ready: return "ready"
            case .inProgress: return "in-progress"
            case .cancelled: return "cancelled"
            case .completed: return "completed"
            case let .computed(status: status): return status.rawValue
            case let .undefined(status: status): return "undefined: \(status)"
            case let .error(error): return Self.errorPrefix + error.rawValue
            }
        }
    }
}

extension ErxTask.Status {
    // sourcery: CodedError = "201"
    public enum Error: Swift.Error, RawRepresentable {
        // sourcery: errorCode = "01"
        case decoding(message: String)
        // sourcery: errorCode = "02"
        case unknown(message: String)
        // sourcery: errorCode = "03"
        case missingStatus
        // sourcery: errorCode = "04"
        case missingPatientReceiptReference
        // sourcery: errorCode = "05"
        case missingPatientReceiptIdentifier
        // sourcery: errorCode = "06"
        case missingPatientReceiptBundle

        public typealias RawValue = String

        private static let decodingPrefix = "decoding "
        private static let unknownPrefix = "unknown "

        public init(rawValue: RawValue) {
            switch rawValue {
            case "missingStatus": self = .missingStatus
            case "missingPatientReceiptReference": self = .missingPatientReceiptReference
            case "missingPatientReceiptIdentifier": self = .missingPatientReceiptIdentifier
            case "missingPatientReceiptBundle": self = .missingPatientReceiptBundle
            default:
                if rawValue.hasPrefix(Self.decodingPrefix) {
                    let message = String(rawValue.dropFirst(Self.decodingPrefix.count))
                    self = .decoding(message: message)
                } else if rawValue.hasPrefix(Self.unknownPrefix) {
                    let message = String(rawValue.dropFirst(Self.unknownPrefix.count))
                    self = .unknown(message: message)
                } else {
                    self = .unknown(message: "Unexpected raw value")
                }
            }
        }

        public var rawValue: RawValue {
            switch self {
            case let .decoding(message: message): return Self.decodingPrefix + message
            case let .unknown(message: message): return Self.unknownPrefix + message
            case .missingStatus: return "missingStatus"
            case .missingPatientReceiptReference: return "missingPatientReceiptReference"
            case .missingPatientReceiptIdentifier: return "missingPatientReceiptIdentifier"
            case .missingPatientReceiptBundle: return "missingPatientReceiptBundle"
            }
        }
    }
}
