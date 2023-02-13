//
//  Copyright (c) 2023 gematik GmbH
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
public struct ErxTask: Identifiable, Equatable, Hashable {
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
        redeemedOn: String? = nil,
        author: String? = nil,
        dispenseValidityEnd: String? = nil,
        noctuFeeWaiver: Bool = false,
        prescriptionId: String? = nil,
        substitutionAllowed: Bool = false,
        source: Source = .server,
        medication: Medication? = nil,
        multiplePrescription: MultiplePrescription? = nil,
        patient: Patient? = nil,
        practitioner: Practitioner? = nil,
        organization: Organization? = nil,
        workRelatedAccident: WorkRelatedAccident? = nil,
        coPaymentStatus: CoPaymentStatus? = nil,
        bvg: Bool = false,
        communications: [Communication] = [],
        medicationDispenses: [MedicationDispense] = []
    ) {
        self.identifier = identifier
        self.status = status
        self.flowType = flowType
        self.prescriptionId = prescriptionId
        self.accessCode = accessCode
        self.fullUrl = fullUrl
        self.authoredOn = authoredOn
        self.lastModified = lastModified
        self.expiresOn = expiresOn
        self.acceptedUntil = acceptedUntil
        self.redeemedOn = redeemedOn
        self.author = author
        hasEmergencyServiceFee = noctuFeeWaiver
        self.substitutionAllowed = substitutionAllowed
        self.source = source
        self.dispenseValidityEnd = dispenseValidityEnd
        self.medication = medication
        self.multiplePrescription = multiplePrescription
        self.patient = patient
        self.practitioner = practitioner
        self.organization = organization
        self.workRelatedAccident = workRelatedAccident
        self.communications = communications
        self.medicationDispenses = medicationDispenses
        self.bvg = bvg
        self.coPaymentStatus = coPaymentStatus
    }

    // MARK: Variables that only exist locally

    /// When the prescription was redeemed (only for scanned tasks)
    public var redeemedOn: String?
    /// Indicates if the task was fetched from the `FHIRClient` or scanned by the `ScannerDomain`
    public let source: Source

    // MARK: gematik profiled FHIR resources

    /// Id of the task
    public var id: String { identifier }
    /// Idenditifer of the task
    public let identifier: String
    /// Status of the current task
    public var status: Status
    /// FlowType describes type of task (e.G. Direktzuweisung).
    /// Usually the flowtype is identical to the beginning of the task id
    public var flowType: FlowType?
    /// When the prescription will be expired
    public let expiresOn: String?
    /// Date until which a prescription can be redeemed in the pharmacy without paying
    /// the entire prescription. Note that `acceptDate <= expireDate`
    public let acceptedUntil: String?
    /// Prescription Id of the task
    public let prescriptionId: String?
    /// Access code authorizing for the task
    public let accessCode: String?
    /// The full URL composed of id and access code
    public let fullUrl: String? // e.g. "https://prescriptionserver.telematik/Task/588780"

    // MARK: KBV profiled FHIR resources

    /// Timestamp of the last modification of the task
    public let lastModified: String?
    /// Practitioner who authored the prescription
    public let author: String?
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

    // DH.TODO: group MedicationRequest variables into own type //swiftlint:disable:this todo

    /// When the prescription was authored
    public let authoredOn: String?
    /// Whether substitution is allowed (Aut-Idem)
    public let substitutionAllowed: Bool
    /// Indicates emergency service fee (Notdienstgebühr)
    public let hasEmergencyServiceFee: Bool
    /// Work-related accident info
    public let workRelatedAccident: WorkRelatedAccident?
    /// Indicates if this prescription is related to the
    /// 'Bundesentschädigungsgesetz' or 'Bundesversorgungsgesetz'
    public let bvg: Bool
    /// Indicates if additional charges are applied
    public let coPaymentStatus: CoPaymentStatus?
    /// Information about multiple tasks (e.g. prescription)
    public let multiplePrescription: MultiplePrescription?

    // MARK: gematik profiled FHIR resources loaded from additional endpoints

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
    /// https://simplifier.net/packages/kbv.ita.for/1.1.0/files/720086
    public enum CoPaymentStatus: String, Equatable {
        /// Von Zuzahlungspflicht nicht befreit / gebührenpflichtig
        case subjectToCharge = "0"
        /// Von Zuzahlungspflicht befreit / gebührenfrei
        case noSubjectToCharge = "1"
        /// Künstliche Befruchtung (Regelung nach § 27a SGB V)
        case artificialInsemination = "2"
    }

    public enum FlowType: Equatable, RawRepresentable {
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

    public enum Source: String, Codable {
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
        public init(mark: String?,
                    workPlaceIdentifier: String? = nil,
                    date: String?) {
            self.workPlaceIdentifier = workPlaceIdentifier
            self.date = date
            self.mark = mark
        }

        /// Information, if the prescription has been prescribed in relation to an accident
        public let mark: String?
        /// Place of work
        public let workPlaceIdentifier: String?
        /// Date of accident
        public let date: String?
    }
}
