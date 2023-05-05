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

import eRpKit
import Foundation
import SwiftUI

/// `Prescription` acts as a view model for an `ErxTask` to better fit the presentation logic
@dynamicMemberLookup
struct Prescription: Equatable, Hashable, Identifiable {
    enum Status: Equatable {
        case open(until: String)
        case redeem(at: String) // swiftlint:disable:this identifier_name
        case archived(message: String)
        case undefined
        case error(message: String)

        var isError: Bool {
            if case .error = self {
                return true
            }
            return false
        }
    }

    let erxTask: ErxTask
    let prescribedMedication: Medication?
    let actualMedications: [Medication]
    // [REQ:gemSpec_FD_eRp:A_21267] direct assignment
    var type: PrescriptionType = .regular
    let viewStatus: Status

    enum PrescriptionType {
        case scanned
        case regular
        case directAssignment
        case multiplePrescription
    }

    var id: String {
        erxTask.id
    }

    init(
        erxTask: ErxTask,
        date: Date = Date(),
        dateFormatter: UIDateFormatter = UIDateFormatter.liveValue
    ) {
        if erxTask.medicationRequest.multiplePrescription?.mark == true {
            type = .multiplePrescription
        }
        if erxTask.flowType == .directAssignment ? true : erxTask.id
            .starts(with: ErxTask.FlowType.Code.kDirectAssignment) {
            type = .directAssignment
        }
        if erxTask.source == .scanner {
            type = .scanned
        }

        self.erxTask = erxTask
        actualMedications = erxTask.medicationDispenses.map(Medication.from(medicationDispense:))

        if let taskMedication = erxTask.medication {
            prescribedMedication = Medication.from(
                medication: taskMedication,
                dosageInstructions: erxTask.medicationRequest.dosageInstructions,
                redeemedOn: erxTask.redeemedOn
            )
        } else {
            prescribedMedication = nil
        }
        viewStatus = Self.evaluateViewStatus(for: erxTask,
                                             type: type,
                                             whenHandedOver: actualMedications.first?
                                                 .handedOver ?? prescribedMedication?.handedOver,
                                             date: date,
                                             uiDateFormatter: dateFormatter)
    }

    subscript<A>(dynamicMember keyPath: KeyPath<ErxTask, A>) -> A {
        erxTask[keyPath: keyPath]
    }

    static func evaluateViewStatus(
        for erxTask: ErxTask,
        type: PrescriptionType,
        whenHandedOver: String?,
        date: Date = Date(),
        uiDateFormatter: UIDateFormatter
    ) -> Status {
        switch erxTask.status {
        case .ready, .inProgress:
            if type == .scanned,
               let authoredOn = erxTask.authoredOn?.date {
                let localizedDateString = uiDateFormatter.relativeDate(from: authoredOn)
                return .open(until: L10n.erxTxtScannedAt(localizedDateString).text)
            }

            guard erxTask.expiresOn != nil || erxTask.acceptedUntil != nil else {
                return .open(until: L10n.prscFdTxtNa.text)
            }

            if type == .multiplePrescription,
               erxTask.medicationRequest.multiplePrescription?.isRedeemable == false,
               let startDate = erxTask.medicationRequest.multiplePrescription?.startDate {
                let localizedDateString = uiDateFormatter.relativeDate(from: startDate)
                return .redeem(at: L10n.erxTxtRedeemAt(localizedDateString).text)
            }

            if let acceptedUntilDate = erxTask.acceptedUntil?.date,
               let remainingDays = date.days(until: acceptedUntilDate),
               remainingDays > 0 {
                return .open(until: L10n.erxTxtAcceptedUntil(remainingDays).text)
            }

            if let expiresDate = erxTask.expiresOn?.date,
               let remainingDays = date.days(until: expiresDate),
               remainingDays > 0 {
                return .open(until: L10n.erxTxtExpiresIn(remainingDays).text)
            }

            return .archived(message: L10n.erxTxtInvalid.text)

        case .completed:
            let redeemedOnDate = uiDateFormatter.relativeDate(whenHandedOver) ?? L10n.prscFdTxtNa.text
            return .archived(message: L10n.dtlTxtMedRedeemedOn(redeemedOnDate).text)
        case .draft, .cancelled, .undefined:
            return .undefined
        case .error:
            let authoredOn = uiDateFormatter.relativeDate(erxTask.authoredOn) ?? L10n.prscFdTxtNa.text
            return .error(message: L10n.dtlTxtMedAuthoredOn(authoredOn).text)
        }
    }

    var title: String {
        if let name = prescribedMedication?.displayName {
            return name
        } else if case .error = viewStatus {
            return L10n.prscTxtFallbackName.text
        } else {
            return L10n.prscFdTxtNa.text
        }
    }

    var statusMessage: String {
        guard type != .directAssignment
        else {
            return L10n.prscRedeemNoteDirectAssignment.text
        }

        switch viewStatus {
        case let .open(until: localizedString): return localizedString
        case let .redeem(at: localizedString): return localizedString
        case let .archived(message: localizedString): return localizedString
        case .undefined: return L10n.prscFdTxtNa.text
        case let .error(message: localizedString): return localizedString
        }
    }

    var isArchived: Bool {
        switch viewStatus {
        case .archived(message: _): return true
        case .open(until: _),
             .redeem(at: _),
             .undefined,
             .error:
            return false
        }
    }

    var isRedeemable: Bool {
        // [REQ:gemSpec_FD_eRp:A_21360] no redeem informations available for flowtype 169
        guard type != .directAssignment
        else { return false }

        switch (erxTask.status, viewStatus) {
        case (_, .archived),
             (_, .redeem): return false
        case (.ready, _): return true
        case (.draft, _),
             (.inProgress, _),
             (.cancelled, _),
             (.completed, _),
             (.undefined, _),
             (.error, _): return false
        }
    }

    var isManualRedeemEnabled: Bool {
        guard erxTask.source == .scanner else {
            return false
        }

        return erxTask.communications.isEmpty && erxTask.avsTransactions.isEmpty
    }

    var isDeleteabel: Bool {
        // [REQ:gemSpec_FD_eRp:A_22102] prevent deletion of tasks with flowtype 169 while not completed
        guard type != .directAssignment
        else { return erxTask.status == .completed }

        if isArchived {
            return true
        }

        // [REQ:gemSpec_FD_eRp:A_19145] prevent deletion while task is in progress
        return erxTask.status != .inProgress
    }

    var errorString: String {
        if case let .error(.decoding(message)) = erxTask.status {
            return message
        } else if case let .error(.unknown(message)) = erxTask.status {
            return message
        }
        return "No error message available"
    }

    /// `true` if the medication has been dispensed and substituted by an alternative medication, `false` otherwise.
    var isMedicationSubstituted: Bool {
        guard let medicationPZN = erxTask.medication?.pzn,
              let medicationDispPZN = erxTask.medicationDispenses.first?.medication?.pzn
        else { // TODO: change for all medicationDispenses, // swiftlint:disable:this todo
            return false
        }
        return medicationPZN != medicationDispPZN
    }

    var multiplePrescriptionStatus: String? {
        guard let multiplePrescription = erxTask.medicationRequest.multiplePrescription,
              multiplePrescription.mark,
              let index = multiplePrescription.numbering,
              let count = multiplePrescription.totalNumber
        else { return nil }

        return "\(index)/\(count)"
    }
}

extension MultiplePrescription {
    var isRedeemable: Bool {
        guard let startDate = startDate,
              let daysUntilStartDate = Date().days(until: startDate)
        else { return false }

        return daysUntilStartDate <= 0
    }

    var startDate: Date? {
        guard let start = startPeriod,
              let startDate = FHIRDateFormatter.liveValue.date(from: start, format: .yearMonthDay)
        else { return nil }

        return startDate
    }
}

extension Prescription {
    var coPaymentStatusText: String {
        switch erxTask.medicationRequest.coPaymentStatus {
        case .noSubjectToCharge:
            return L10n.prscDtlTxtNo.text
        case .subjectToCharge:
            return L10n.prscDtlTxtYes.text
        case .artificialInsemination:
            return L10n.prscDtlTxtPartial.text
        case .none:
            return L10n.prscFdTxtNa.text
        }
    }

    var statusTitle: LocalizedStringKey {
        guard type != .directAssignment else {
            switch viewStatus {
            case .open, .redeem, .undefined, .error:
                return L10n.prscStatusDirectAssigned.key
            case .archived:
                return L10n.prscStatusCompleted.key
            }
        }

        switch (erxTask.status, viewStatus) {
        case (.ready, .redeem): return L10n.prscStatusMultiplePrsc.key
        case (.ready, .archived): return L10n.prscStatusExpired.key
        case (.ready, _): return L10n.prscStatusReady.key
        case (.inProgress, _): return L10n.prscStatusInProgress.key
        case (.completed, _): return L10n.prscStatusCompleted.key
        case (.cancelled, _): return L10n.prscStatusCanceled.key
        case (.draft, _),
             (.undefined, _): return L10n.prscStatusUndefined.key
        case (.error, _): return L10n.prscStatusError.key
        }
    }

    var image: Image? {
        guard type != .directAssignment else {
            switch viewStatus {
            case .open, .redeem, .undefined, .error:
                return nil
            case .archived:
                return Image(systemName: SFSymbolName.hourglass)
            }
        }

        switch (erxTask.status, viewStatus) {
        case (.ready, .redeem): return Image(systemName: SFSymbolName.calendarClock)
        case (.ready, .archived): return Image(systemName: SFSymbolName.clockWarning)
        case (.ready, _): return nil
        case (.inProgress, _): return nil
        case (.completed, _): return Image(Asset.Prescriptions.checkmarkDouble)
        case (.cancelled, _): return Image(systemName: SFSymbolName.cross)
        case (.draft, _),
             (.undefined, _): return Image(systemName: SFSymbolName.calendarWarning)
        case (.error, _): return Image(systemName: SFSymbolName.exclamationMark)
        }
    }

    var titleTint: Color {
        guard type != .directAssignment
        else { return Colors.systemGray }

        switch (erxTask.status, viewStatus) {
        case (.draft, _),
             (.undefined, _),
             (.completed, _),
             (.ready, .archived): return Colors.systemGray
        case (.ready, .redeem),
             (.inProgress, _): return Colors.yellow900
        case (.ready, _): return Colors.primary900
        case (.cancelled, _): return Colors.red900
        case (.error, _): return Colors.red900
        }
    }

    var imageTint: Color {
        guard type != .directAssignment
        else { return Colors.systemGray2 }

        switch (erxTask.status, viewStatus) {
        case (.draft, _),
             (.undefined, _),
             (.completed, _),
             (.ready, .archived): return Colors.systemGray2
        case (.ready, .redeem),
             (.inProgress, _): return Colors.yellow500
        case (.ready, _): return Colors.primary500
        case (.cancelled, _): return Colors.red500
        case (.error, _): return Colors.red500
        }
    }

    var backgroundTint: Color {
        guard type != .directAssignment
        else { return Colors.secondary }

        switch (erxTask.status, viewStatus) {
        case (.draft, _),
             (.undefined, _),
             (.completed, _),
             (.ready, .archived): return Colors.secondary
        case (.ready, .redeem),
             (.inProgress, _): return Colors.yellow200
        case (.ready, _): return Colors.primary100
        case (.cancelled, _): return Colors.red100
        case (.error, _): return Colors.red100
        }
    }
}

extension Prescription: Comparable {
    public static func <(lhs: Prescription, rhs: Prescription) -> Bool {
        compare(lhs: lhs.prescribedMedication, rhs: rhs.prescribedMedication) {
            compare(lhs: lhs.actualMedications.first, rhs: rhs.actualMedications.first) {
                compare(lhs: lhs.expiresOn, rhs: rhs.expiresOn) {
                    false
                }
            }
        }
    }

    public static func compare<T: Comparable>(lhs: T?, rhs: T?, onEqual: () -> Bool) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return onEqual()
        case (_, nil): return true
        case (nil, _): return false
        case let (.some(lhsValue), .some(rhsValue)):
            if lhsValue != rhsValue {
                return lhsValue < rhsValue
            }
            return onEqual()
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(erxTask.identifier)
    }
}

extension Prescription {
    enum Dummies {
        static let prescriptionReady = Prescription(erxTask: ErxTask.Demo.erxTaskReady)
        static let prescriptionDirectAssignment = Prescription(erxTask: ErxTask.Demo.erxTaskDirectAssignment)
        static let prescriptionError = Prescription(erxTask: ErxTask.Demo.erxTaskError)
        static let scanned = Prescription(erxTask: ErxTask.Demo.erxTaskScanned1)
        static let prescriptions = ErxTask.Demo.erxTasks.map { Prescription(erxTask: $0) }
        static let prescriptionsScanned = ErxTask.Demo.erxTasksScanned
            .map { Prescription(erxTask: $0) }
    }
}
