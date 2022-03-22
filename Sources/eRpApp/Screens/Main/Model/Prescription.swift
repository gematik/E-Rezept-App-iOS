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
import SwiftUI

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
                    return .open(until: L10n.prscFdTxtNa.text)
                }

                if let acceptedUntilDate = erxTask.acceptedUntil?.date,
                   let remainingDays = date.days(until: acceptedUntilDate),
                   remainingDays > 0 {
                    let remainingDaysOfAcceptString = String.localizedStringWithFormat(
                        L10n.erxTxtAcceptedUntil.text,
                        remainingDays
                    )
                    return .open(until: remainingDaysOfAcceptString)
                }

                if let expiresDate = erxTask.expiresOn?.date,
                   let remainingDays = date.days(until: expiresDate),
                   remainingDays > 0 {
                    let remainingDaysOfExpireString = String.localizedStringWithFormat(
                        L10n.erxTxtExpiresIn.text,
                        remainingDays
                    )
                    return .open(until: remainingDaysOfExpireString)
                }

                return .archived(message: L10n.erxTxtInvalid.text)

            case .completed:
                if let redeemedOnDate = whenHandedOver?.date {
                    let localizedDateString = dateFormatter.string(from: redeemedOnDate)
                    return .archived(message: L10n.dtlTxtMedRedeemedOn(localizedDateString).text)
                } else {
                    return .archived(message: L10n.dtlTxtMedRedeemedOn(L10n.prscFdTxtNa.text).text)
                }
            case .draft, .inProgress, .cancelled, .undefined:
                return .undefined
            }
        }

        var statusMessage: String {
            switch viewStatus {
            case let .open(until: localizedString): return localizedString
            case let .archived(message: localizedString): return localizedString
            case .undefined: return L10n.prscFdTxtNa.text
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

extension GroupedPrescription.Prescription {
    var title: LocalizedStringKey {
        switch (erxTask.status, viewStatus) {
        case (.ready, .archived): return L10n.prscStatusExpired.key
        case (.ready, _): return L10n.prscStatusReady.key
        case (.inProgress, _): return L10n.prscStatusInProgress.key
        case (.completed, _): return L10n.prscStatusCompleted.key
        case (.cancelled, _): return L10n.prscStatusCanceled.key
        case (.draft, _),
             (.undefined, _): return L10n.prscStatusUndefined.key
        }
    }

    var image: Image {
        switch (erxTask.status, viewStatus) {
        case (.ready, .archived): return Image(systemName: SFSymbolName.clockWarning)
        case (.ready, _): return Image(systemName: SFSymbolName.checkmark)
        case (.inProgress, _): return Image(systemName: SFSymbolName.hourglass)
        case (.completed, _): return Image(Asset.Prescriptions.checkmarkDouble)
        case (.cancelled, _): return Image(systemName: SFSymbolName.cross)
        case (.draft, _),
             (.undefined, _): return Image(systemName: SFSymbolName.calendarWarning)
        }
    }

    var titleTint: Color {
        switch (erxTask.status, viewStatus) {
        case (.draft, _),
             (.undefined, _),
             (.completed, _),
             (.ready, .archived): return Colors.systemGray
        case (.ready, _): return Colors.secondary900
        case (.inProgress, _): return Colors.yellow900
        case (.cancelled, _): return Colors.red900
        }
    }

    var imageTint: Color {
        switch (erxTask.status, viewStatus) {
        case (.draft, _),
             (.undefined, _),
             (.completed, _),
             (.ready, .archived): return Colors.systemGray2
        case (.ready, _): return Colors.secondary500
        case (.inProgress, _): return Colors.yellow500
        case (.cancelled, _): return Colors.red500
        }
    }

    var backgroundTint: Color {
        switch (erxTask.status, viewStatus) {
        case (.draft, _),
             (.undefined, _),
             (.completed, _),
             (.ready, .archived): return Colors.secondary
        case (.ready, _): return Colors.secondary100
        case (.inProgress, _): return Colors.yellow100
        case (.cancelled, _): return Colors.red100
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
