//
//  Copyright (c) 2021 gematik GmbH
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
        accessCode: String? = nil,
        fullUrl: String? = nil,
        authoredOn: String? = nil,
        expiresOn: String? = nil,
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
        communications: [Communication] = []
    ) {
        self.identifier = identifier
        self.prescriptionId = prescriptionId
        self.accessCode = accessCode
        self.fullUrl = fullUrl
        self.authoredOn = authoredOn
        self.expiresOn = expiresOn
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
    }

    // MARK: gematik profiled FHIR resources

    /// Id of the task
    public var id: String { identifier } // swiftlint:disable:this identifier_name

    /// Idenditifer of the task
    public let identifier: String
    /// Prescription Id of the task
    public let prescriptionId: String?
    /// Access code authorizing for the task
    public let accessCode: String?
    /// The full URL composed of id and access code
    public let fullUrl: String? // e.g. "https://prescriptionserver.telematik/Task/588780"

    // MARK: KBV profiled FHIR resources

    /// When the prescription was authored
    public let authoredOn: String?
    /// When the prescription will be expired
    public let expiresOn: String?
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
}

extension ErxTask {
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

    public static func ==(lhs: ErxTask, rhs: ErxTask) -> Bool {
        lhs.identifier == rhs.identifier
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
                    insuranceIdentifier: String? = nil) {
            self.name = name
            self.address = address
            self.birthDate = birthDate
            self.phone = phone
            self.status = status
            self.insurance = insurance
            self.insuranceIdentifier = insuranceIdentifier
        }

        public let name: String?
        public let address: String?
        public let birthDate: String?
        public let phone: String?
        public let status: String?
        public let insurance: String?
        public let insuranceIdentifier: String?
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
                    dosageInstructions: String? = nil) {
            self.name = name
            self.pzn = pzn
            self.amount = amount
            self.dosageForm = dosageForm
            self.dose = dose
            self.dosageInstructions = dosageInstructions
        }

        public let name: String?
        public let pzn: String?
        public let amount: Decimal?
        public let dosageForm: String?
        public let dose: String?
        public let dosageInstructions: String?
    }
}
