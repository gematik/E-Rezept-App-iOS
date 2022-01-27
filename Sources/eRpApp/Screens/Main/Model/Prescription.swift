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

import eRpKit
import Foundation

extension GroupedPrescription {
    /// `Prescription ` acts as an view model for an `ErxTask` to better fit the presentation logic
    @dynamicMemberLookup
    struct Prescription: Equatable, Hashable {
        enum Status {
            case open(until: String)
            case archived(message: String)
            case undefined
        }

        let erxTask: ErxTask
        let actualMedication: GroupedPrescription.Medication?
        let viewStatus: Status

        init(
            erxTask: ErxTask,
            date: Date = Date(),
            dateFormatter: DateFormatter = globals.uiDateFormatter
        ) {
            self.erxTask = erxTask
            if let medicationDispense = erxTask.medicationDispense {
                actualMedication = Medication.from(medicationDispense: medicationDispense)
            } else if let taskMedication = erxTask.medication {
                actualMedication = Medication.from(medication: taskMedication, redeemedOn: erxTask.redeemedOn)
            } else {
                actualMedication = nil
            }
            viewStatus = Self.evaluateViewStatus(for: erxTask,
                                                 whenHandedOver: actualMedication?.handedOver,
                                                 date: date,
                                                 dateFormatter: dateFormatter)
        }

        subscript<A>(dynamicMember keyPath: KeyPath<ErxTask, A>) -> A {
            erxTask[keyPath: keyPath]
        }

        static func evaluateViewStatus(
            for erxTask: ErxTask,
            whenHandedOver: String?,
            date: Date = Date(),
            dateFormatter: DateFormatter = globals.uiDateFormatter
        ) -> Status {
            switch erxTask.status {
            case .ready:
                guard erxTask.expiresOn != nil || erxTask.acceptedUntil != nil else {
                    return .open(until: NSLocalizedString("prsc_fd_txt_na", comment: ""))
                }

                if let expiresDate = erxTask.expiresOn?.date,
                   let remainingDays = date.days(until: expiresDate),
                   remainingDays > 0 {
                    let expiresInFormat: String = NSLocalizedString(
                        "erx_txt_expires_in",
                        comment: "erx_txt_expires_in string format to be found in Localized.stringsdict"
                    )
                    let remainingDaysOfExpireString = String.localizedStringWithFormat(expiresInFormat, remainingDays)
                    return .open(until: remainingDaysOfExpireString)
                }

                if let acceptedUntilDate = erxTask.acceptedUntil?.date,
                   let remainingDays = date.days(until: acceptedUntilDate),
                   remainingDays > 0 {
                    let acceptedUntilFormat: String = NSLocalizedString(
                        "erx_txt_accepted_until",
                        comment: "erx_txt_accepted_until string format to be found in Localized.stringsdict"
                    )
                    let remainingDaysOfAcceptString = String.localizedStringWithFormat(
                        acceptedUntilFormat,
                        remainingDays
                    )
                    return .open(until: remainingDaysOfAcceptString)
                }

                return .archived(message: NSLocalizedString("erx_txt_invalid", comment: ""))

            case .completed:
                let redeemedOnFormat = NSLocalizedString("dtl_txt_med_redeemed_on_%@", comment: "")
                if let redeemedOnDate = whenHandedOver?.date {
                    let localizedDateString = dateFormatter.string(from: redeemedOnDate)
                    return .archived(message: String.localizedStringWithFormat(redeemedOnFormat, localizedDateString))
                } else {
                    let redeemedWithoutDate = String.localizedStringWithFormat(
                        redeemedOnFormat,
                        NSLocalizedString("prsc_fd_txt_na", comment: "")
                    )
                    return .archived(message: redeemedWithoutDate)
                }
            case .draft, .inProgress, .cancelled:
                return .undefined
            }
        }

        var statusMessage: String {
            switch viewStatus {
            case let .open(until: localizedString): return localizedString
            case let .archived(message: localizedString): return localizedString
            case .undefined: return NSLocalizedString("prsc_fd_txt_na", comment: "")
            }
        }

        var isArchived: Bool {
            switch viewStatus {
            case .archived(message: _): return true
            case .open(until: _), .undefined: return false
            }
        }

        /// `true` if the medication has been dispensed and substituted by an alternative medication, `false` otherwise.
        var isMedicationSubstituted: Bool {
            guard let medicationPZN = erxTask.medication?.pzn,
                  let medicationDispPZN = erxTask.medicationDispense?.pzn else {
                return false
            }
            return medicationPZN != medicationDispPZN
        }
    }

    struct Medication: Equatable, Hashable {
        let pzn: String?
        let dose: String?
        let amount: Decimal?
        let name: String?
        let dosageInstruction: String?
        let dosageForm: String?
        let handedOver: String?

        static func from(medicationDispense: ErxTask.MedicationDispense) -> Medication {
            self.init(
                pzn: medicationDispense.pzn,
                dose: medicationDispense.dose,
                amount: medicationDispense.amount,
                name: medicationDispense.name,
                dosageInstruction: medicationDispense.dosageInstruction,
                dosageForm: medicationDispense.dosageForm,
                handedOver: medicationDispense.whenHandedOver
            )
        }

        static func from(medication: ErxTask.Medication, redeemedOn: String?) -> Medication {
            self.init(
                pzn: medication.pzn,
                dose: medication.dose,
                amount: medication.amount,
                name: medication.name,
                dosageInstruction: medication.dosageInstructions,
                dosageForm: medication.dosageForm,
                handedOver: redeemedOn
            )
        }
    }
}

extension GroupedPrescription.Prescription: Comparable {
    public static func <(lhs: GroupedPrescription.Prescription, rhs: GroupedPrescription.Prescription) -> Bool {
        switch (lhs.actualMedication?.name, rhs.actualMedication?.name) {
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

    public static func ==(lhs: GroupedPrescription.Prescription, rhs: GroupedPrescription.Prescription) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(erxTask.identifier)
    }
}
