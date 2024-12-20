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

/// Represents all information needed by the Erx App to handle profiled Erx Tasks (e.g. Prescriptions).
public struct ErxTask: Identifiable, Equatable, Hashable, Codable, Sendable {
    /// ErxTask default initializer
    public init(
        identifier: String,
        status: Status,
        flowType: FlowType? = nil,
        accessCode: String? = nil,
        fullUrl: String? = nil,
        authoredOn: String? = nil,
        lastModified: String? = nil,
        expiresOn: String? = nil,
        acceptedUntil: String? = nil,
        lastMedicationDispense: String? = nil,
        redeemedOn: String? = nil,
        avsTransactions: [AVSTransaction] = [],
        author: String? = nil,
        prescriptionId: String? = nil,
        source: Source = .server,
        medication: ErxMedication? = nil,
        medicationRequest: ErxMedicationRequest = ErxMedicationRequest(quantity: nil),
        medicationSchedule: MedicationSchedule? = nil,
        patient: ErxPatient? = nil,
        practitioner: ErxPractitioner? = nil,
        organization: ErxOrganization? = nil,
        communications: [Communication] = [],
        medicationDispenses: [ErxMedicationDispense] = []
    ) {
        self.identifier = identifier
        self.status = status
        self.flowType = flowType
        self.accessCode = accessCode
        self.fullUrl = fullUrl
        self.authoredOn = authoredOn
        self.lastModified = lastModified
        self.prescriptionId = prescriptionId
        self.expiresOn = expiresOn
        self.acceptedUntil = acceptedUntil
        self.lastMedicationDispense = lastMedicationDispense
        self.redeemedOn = redeemedOn
        self.author = author
        self.source = source
        self.medication = medication
        self.medicationSchedule = medicationSchedule
        self.medicationRequest = medicationRequest
        self.patient = patient
        self.practitioner = practitioner
        self.organization = organization
        self.communications = communications
        self.medicationDispenses = medicationDispenses
        self.avsTransactions = avsTransactions
    }

    // MARK: Variables that only exist locally

    /// When the prescription was redeemed (only for scanned tasks)
    public var redeemedOn: String?
    /// Indicates if the task was fetched from the `FHIRClient` or scanned by the `ScannerDomain`
    public let source: Source
    /// When redeemed via AVSRedeemService a transaction will be produced
    public let avsTransactions: [AVSTransaction]

    // MARK: gematik profiled FHIR resources

    /// Id of the task
    public var id: String { identifier }
    /// Identifier of the task
    public let identifier: String
    /// Status of the current task
    public var status: Status
    /// FlowType describes type of task (e.G. Direktzuweisung).
    /// Usually the flowtype is identical to the beginning of the task id
    public var flowType: FlowType?
    /// When the prescription will be expired
    public let expiresOn: String?
    /// When the prescription was authored
    public let authoredOn: String?
    /// Date until which a prescription can be redeemed in the pharmacy without paying
    /// the entire prescription. Note that `acceptDate <= expireDate`
    public let acceptedUntil: String?

    public let lastMedicationDispense: String?
    /// Prescription Id of the task
    public let prescriptionId: String?
    /// Access code authorizing for the task
    public let accessCode: String?
    /// The full URL composed of id and access code
    /// e.g. "https://prescriptionserver.telematik/Task/588780"
    public let fullUrl: String?

    // MARK: KBV profiled FHIR resources

    /// Timestamp of the last modification of the task
    public let lastModified: String?
    /// Practitioner who authored the prescription
    public let author: String?
    /// The prescribed medication
    public let medication: ErxMedication?
    /// Everything contained in a MedicationRequest resource
    public let medicationRequest: ErxMedicationRequest
    /// Associated MedicationSchedule if setup, nil otherwise
    public let medicationSchedule: MedicationSchedule?
    /// Patient for whom the prescription is issued
    public let patient: ErxPatient?
    /// Practitioner who issued the prescription
    public let practitioner: ErxPractitioner?
    /// Organization that issued the prescription
    public let organization: ErxOrganization?

    // MARK: gematik profiled FHIR resources loaded from additional endpoints

    /// List of all  communications for  the task, sorted by timestamp
    /// Every time when redeemed via ErxTaskRepository a Communication will linked to the task
    public let communications: [Communication]
    /// List of actual medication dispenses
    public let medicationDispenses: [ErxMedicationDispense]

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

    public func cancelled(on date: String?) -> Self {
        ErxTask(
            identifier: identifier,
            status: .cancelled,
            flowType: flowType,
            accessCode: accessCode,
            fullUrl: fullUrl,
            authoredOn: authoredOn,
            lastModified: date,
            expiresOn: prescriptionId,
            acceptedUntil: expiresOn,
            redeemedOn: acceptedUntil,
            avsTransactions: avsTransactions,
            author: author,
            prescriptionId: prescriptionId,
            source: source,
            medication: medication,
            medicationRequest: medicationRequest,
            medicationSchedule: medicationSchedule,
            patient: patient,
            practitioner: practitioner,
            organization: organization,
            communications: communications,
            medicationDispenses: medicationDispenses
        )
    }
}

extension ErxTask {
    /// https://simplifier.net/packages/kbv.ita.for/1.1.0/files/720086
    public enum CoPaymentStatus: String, Equatable, Codable, Sendable {
        /// Von Zuzahlungspflicht nicht befreit / gebührenpflichtig
        case subjectToCharge = "0"
        /// Von Zuzahlungspflicht befreit / gebührenfrei
        case noSubjectToCharge = "1"
        /// Künstliche Befruchtung (Regelung nach § 27a SGB V)
        case artificialInsemination = "2"
    }

    public enum FlowType: Equatable, RawRepresentable, Codable, Sendable {
        public enum Code {
            public static var kPharmacyOnly = "160"
            public static var kNarcotic = "165"
            public static var kTPrescription = "166"
            public static var kDirectAssignment = "169"
            public static var kPharmacyOnlyForPKV = "200"
            public static var kNarcoticForPKV = "205"
            public static var kTPrescriptionForPKV = "206"
            public static var kDirectAssignmentForPKV = "209"
        }

        public typealias RawValue = String?
        /// Muster 16 (Apothekenpflichtige Arzneimittel)
        case pharmacyOnly
        /// Muster 16 (Betäubungsmittel)
        case narcotic
        /// Muster 16 (T-Rezepte)
        case tPrescription
        /// Muster 16 (Direkte Zuweisung)
        /// [REQ:gemSpec_FD_eRp: A_21267] FlowType 169, some operations are not allowed (e.g. deleting)
        /// Indicates if a prescription has been assigned directly after prescription (a.k.a Direktzuweisung)
        /// AccessCode will not be available for theses Tasks
        case directAssignment
        /// Privatkrankenversicherte (Apothekenpflichtige Arzneimittel)
        case pharmacyOnlyForPKV
        /// Privatkrankenversicherte  (Betäubungsmittel)
        case narcoticForPKV
        /// Privatkrankenversicherte  (T-Rezepte)
        case tPrescriptionForPKV
        /// Privatkrankenversicherte  (Direkte Zuweisung)
        case directAssignmentForPKV
        /// all other (unknown) cases
        case unknown(String)

        public init?(rawValue: RawValue) {
            guard let rawValue = rawValue else { return nil }
            switch rawValue {
            case Code.kPharmacyOnly: self = .pharmacyOnly
            case Code.kNarcotic: self = .narcotic
            case Code.kTPrescription: self = .tPrescription
            case Code.kDirectAssignment: self = .directAssignment
            case Code.kPharmacyOnlyForPKV: self = .pharmacyOnlyForPKV
            case Code.kNarcoticForPKV: self = .narcoticForPKV
            case Code.kTPrescriptionForPKV: self = .tPrescriptionForPKV
            case Code.kDirectAssignmentForPKV: self = .directAssignmentForPKV
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String? {
            switch self {
            case .pharmacyOnly: return Code.kPharmacyOnly
            case .narcotic: return Code.kNarcotic
            case .tPrescription: return Code.kTPrescription
            case .directAssignment: return Code.kDirectAssignment
            case .pharmacyOnlyForPKV: return Code.kPharmacyOnlyForPKV
            case .narcoticForPKV: return Code.kNarcoticForPKV
            case .tPrescriptionForPKV: return Code.kTPrescriptionForPKV
            case .directAssignmentForPKV: return Code.kDirectAssignmentForPKV
            case let .unknown(type): return type
            }
        }
    }

    public enum Source: String, Codable, Sendable {
        case scanner
        case server
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
