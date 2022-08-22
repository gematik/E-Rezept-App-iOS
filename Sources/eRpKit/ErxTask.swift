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

/// Represents all information needed by the Erx App to handle profiled Erx Tasks (e.g. Prescriptions).
public struct ErxTask: Identifiable, Hashable {
    /// ErxTask default initializer
    public init(
        identifier: String,
        status: Status,
        accessCode: String? = nil,
        fullUrl: String? = nil,
        authoredOn: String? = nil,
        lastModified: String? = nil,
        expiresOn: String? = nil,
        acceptedUntil: String? = nil,
        redeemedOn: String? = nil,
        author: String? = nil,
        dispenseValidityEnd: String? = nil,
        noctuFeeWaiver: Bool = false,
        prescriptionId: String? = nil,
        substitutionAllowed: Bool = false,
        source: Source = .server,
        medication: Medication? = nil,
        patient: Patient? = nil,
        practitioner: Practitioner? = nil,
        organization: Organization? = nil,
        workRelatedAccident: WorkRelatedAccident? = nil,
        auditEvents: [ErxAuditEvent] = [],
        communications: [Communication] = [],
        medicationDispenses: [MedicationDispense] = []
    ) {
        self.identifier = identifier
        self.status = status
        self.prescriptionId = prescriptionId
        self.accessCode = accessCode
        self.fullUrl = fullUrl
        self.authoredOn = authoredOn
        self.lastModified = lastModified
        self.expiresOn = expiresOn
        self.acceptedUntil = acceptedUntil
        self.redeemedOn = redeemedOn
        self.author = author
        self.noctuFeeWaiver = noctuFeeWaiver
        self.substitutionAllowed = substitutionAllowed
        self.source = source
        self.dispenseValidityEnd = dispenseValidityEnd
        self.medication = medication
        self.patient = patient
        self.practitioner = practitioner
        self.organization = organization
        self.workRelatedAccident = workRelatedAccident
        self.auditEvents = auditEvents
        self.communications = communications
        self.medicationDispenses = medicationDispenses
    }

    // MARK: gematik profiled FHIR resources

    /// Id of the task
    public var id: String { identifier }

    /// Idenditifer of the task
    public let identifier: String
    /// Status of the current task
    public var status: Status
    /// Prescription Id of the task
    public let prescriptionId: String?
    /// Access code authorizing for the task
    public let accessCode: String?
    /// The full URL composed of id and access code
    public let fullUrl: String? // e.g. "https://prescriptionserver.telematik/Task/588780"

    // MARK: KBV profiled FHIR resources

    /// When the prescription was authored
    public let authoredOn: String?
    /// Timestamp of the last modification of the task
    public let lastModified: String?
    /// When the prescription will be expired
    public let expiresOn: String?
    /// Date until which a prescription can be redeemed in the pharmacy without paying
    /// the entire prescription. Note that `acceptDate <= expireDate`
    public let acceptedUntil: String?
    /// When the prescription was redeemed (only for scanned tasks)
    public var redeemedOn: String?
    /// Practitioner who authored the prescription
    public let author: String?
    /// Whether substitution is allowed
    public let substitutionAllowed: Bool
    /// Whether noctu fees are waived
    public let noctuFeeWaiver: Bool
    /// Indicates if the task was fetched from the `FHIRClient` or scanned by the `ScannerDomain`
    public let source: Source
    /// The end date of the medication's dispense validity
    public let dispenseValidityEnd: String?
    /// The prescribed medication
    public let medication: Medication?
    /// Patient for whom the prescription is issued
    public let patient: Patient?
    /// Practitioner who issued the prescription
    public let practitioner: Practitioner?
    /// Organization that issued the prescription
    public let organization: Organization?
    /// Work-related accident info
    public let workRelatedAccident: WorkRelatedAccident?
    /// The audit events
    public let auditEvents: [ErxAuditEvent]
    /// List of all  communications for  the task, sorted by timestamp
    public let communications: [Communication]
    /// List of actual medication dispenses
    public let medicationDispenses: [MedicationDispense]

    /// Changes status of `ErxTask` and updates the manual changed `redeemedOn` property
    /// Use this method only for scanned `ErxTask`s that have been manually redeemed by the user
    /// - Parameter redeemedOn: Date string when the `ErxTask` has been redeemed.
    ///                         Pass `nil` to reset the redeem status
    public mutating func update(with redeemedOn: String?) {
        if let redeemedOn = redeemedOn {
            self.redeemedOn = redeemedOn
            status = .completed
        } else {
            self.redeemedOn = nil
            status = .ready
        }
    }
}

extension ErxTask {
    /// All defined states of a task (see `gemSysL_eRp` chapter 2.4.6 "Konzept Status E-Rezept")
    public enum Status: Equatable {
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
        /// Extra error status (not FHIR)
        case error(Error)

        // sourcery: CodedError = "201"
        public enum Error: Swift.Error {
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
        }
    }

    public enum Source: String, Codable {
        case scanner
        case server
    }
}

extension ErxTask.Status: RawRepresentable {
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
        case let .undefined(status: status): return "undefined: \(status)"
        case let .error(error): return Self.errorPrefix + error.rawValue
        }
    }
}

extension ErxTask.Status.Error: RawRepresentable {
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

extension ErxTask: Comparable {
    public static func <(lhs: ErxTask, rhs: ErxTask) -> Bool {
        switch (lhs.medication?.name, rhs.medication?.name) {
        case (nil, nil): return true
        case (_, nil): return true
        case (nil, _): return false
        case let (.some(lhsValue), .some(rhsValue)):
            if lhsValue != rhsValue {
                return lhsValue < rhsValue
            }

            switch (lhs.expiresOn, rhs.expiresOn) {
            case (nil, nil): return true
            case (_, nil): return true
            case (nil, _): return false
            case let (.some(lhsValue), .some(rhsValue)): return lhsValue < rhsValue
            }
        }
    }

    public static func ==(lhs: ErxTask, rhs: ErxTask) -> Bool {
        lhs.identifier == rhs.identifier &&
            lhs.status == rhs.status &&
            lhs.prescriptionId == rhs.prescriptionId &&
            lhs.accessCode == rhs.accessCode &&
            lhs.fullUrl == rhs.fullUrl &&
            lhs.authoredOn == rhs.authoredOn &&
            lhs.lastModified == rhs.lastModified &&
            lhs.expiresOn == rhs.expiresOn &&
            lhs.acceptedUntil == rhs.acceptedUntil &&
            lhs.redeemedOn == rhs.redeemedOn &&
            lhs.author == rhs.author &&
            lhs.noctuFeeWaiver == rhs.noctuFeeWaiver &&
            lhs.substitutionAllowed == rhs.substitutionAllowed &&
            lhs.source == rhs.source &&
            lhs.dispenseValidityEnd == rhs.dispenseValidityEnd &&
            lhs.medication == rhs.medication &&
            lhs.patient == rhs.patient &&
            lhs.practitioner == rhs.practitioner &&
            lhs.organization == rhs.organization &&
            lhs.workRelatedAccident == rhs.workRelatedAccident &&
            lhs.auditEvents.elementsEqual(rhs.auditEvents) &&
            lhs.communications.elementsEqual(rhs.communications) &&
            lhs.medicationDispenses == rhs.medicationDispenses
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension ErxTask {
    public struct Practitioner: Hashable {
        public init(lanr: String? = nil,
                    name: String? = nil,
                    qualification: String? = nil,
                    email: String? = nil,
                    address: String? = nil) {
            self.lanr = lanr
            self.name = name
            self.qualification = qualification
            self.email = email
            self.address = address
        }

        public let lanr: String?
        public let name: String?
        public let qualification: String?
        public let email: String?
        public let address: String?
    }

    public struct Patient: Hashable {
        public init(name: String? = nil,
                    address: String? = nil,
                    birthDate: String? = nil,
                    phone: String? = nil,
                    status: String? = nil,
                    insurance: String? = nil,
                    insuranceId: String? = nil) {
            self.name = name
            self.address = address
            self.birthDate = birthDate
            self.phone = phone
            self.status = status
            self.insurance = insurance
            self.insuranceId = insuranceId
        }

        /// First and last name of the patient (e.g.: Anna Vetter)
        public let name: String?
        /// Full address incl. street, city, postcode
        public let address: String?
        /// Patient birthdate (e.g.: 2010-01-31)
        public let birthDate: String?
        /// Patient phone number
        public let phone: String?
        /// Contract status (e.g.: 3 == family)
        public let status: String?
        /// Name of the health insurance (e.g.:  IT Versicherung)
        public let insurance: String?
        /// Health card insurance identifier a.k.a. kvnr (e.g: X764228533)
        public let insuranceId: String?
    }

    public struct Organization: Hashable {
        public init(identifier: String? = nil,
                    name: String? = nil,
                    phone: String? = nil,
                    email: String? = nil,
                    address: String? = nil) {
            self.identifier = identifier
            self.name = name
            self.phone = phone
            self.email = email
            self.address = address
        }

        public let identifier: String?
        public let name: String?
        public let phone: String?
        public let email: String?
        public let address: String?
    }

    public struct WorkRelatedAccident: Hashable {
        public init(workPlaceIdentifier: String? = nil,
                    date: String?) {
            self.workPlaceIdentifier = workPlaceIdentifier
            self.date = date
        }

        public let workPlaceIdentifier: String?
        public let date: String?
    }

    public struct Medication: Hashable {
        public init(name: String? = nil,
                    pzn: String? = nil,
                    amount: Decimal? = nil,
                    dosageForm: String? = nil,
                    dose: String? = nil,
                    dosageInstructions: String? = nil,
                    lot: String? = nil,
                    expiresOn: String? = nil) {
            self.name = name
            self.pzn = pzn
            self.amount = amount
            self.dosageForm = dosageForm
            self.dose = dose
            self.dosageInstructions = dosageInstructions
            self.lot = lot
            self.expiresOn = expiresOn
        }

        public let name: String?
        public let pzn: String?
        public let amount: Decimal?
        public let dosageForm: String?
        public let dose: String?
        public let dosageInstructions: String?
        public let lot: String?
        public let expiresOn: String?
    }
}
