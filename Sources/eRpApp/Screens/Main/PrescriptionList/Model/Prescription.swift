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

import eRpKit
import eRpStyleKit
import Foundation
import SwiftUI

/// `Prescription` acts as a view model for an `ErxTask` to better fit the presentation logic
@dynamicMemberLookup
struct Prescription: Equatable, Identifiable {
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
    // [REQ:gemSpec_FD_eRp:A_21267] direct assignment
    var type: PrescriptionType = .regular
    let viewStatus: Status
    let authoredOnDate: String?

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
        dateFormatter: UIDateFormatter
    ) {
        if erxTask.medicationRequest.multiplePrescription?.mark == true {
            type = .multiplePrescription
        }
        if erxTask.flowType == .directAssignment ||
            erxTask.flowType == .directAssignmentForPKV ||
            erxTask.id.starts(with: ErxTask.FlowType.Code.kDirectAssignment) ||
            erxTask.id.starts(with: ErxTask.FlowType.Code.kDirectAssignmentForPKV) {
            type = .directAssignment
        }
        if erxTask.source == .scanner {
            type = .scanned
        }

        authoredOnDate = dateFormatter.date(erxTask.authoredOn)
        self.erxTask = erxTask

        viewStatus = Self.evaluateViewStatus(
            for: erxTask,
            type: type,
            whenHandedOver: erxTask.medicationDispenses.first?.whenHandedOver ?? erxTask.redeemedOn,
            date: date,
            uiDateFormatter: dateFormatter
        )
    }

    subscript<A>(dynamicMember keyPath: KeyPath<ErxTask, A>) -> A {
        erxTask[keyPath: keyPath]
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    static func evaluateViewStatus(
        for erxTask: ErxTask,
        type: PrescriptionType,
        whenHandedOver: String?,
        date: Date = Date(),
        uiDateFormatter: UIDateFormatter
    ) -> Status {
        switch erxTask.status {
        case .inProgress:
            if let date = erxTask.lastModified?.date {
                let localizedString = uiDateFormatter.relativeTime(from: date, formattingContext: .middleOfSentence)
                return .open(until: L10n.erxTxtClaimedAt(localizedString).text)
            } else {
                return .open(until: L10n.erxTxtClaimedAt("").text)
            }
        case .computed(status: .waiting):
            // swiftlint:disable:next todo
            // TODO: `.computed(status: .sent)` is excluded because we do not store sent messages via AVS yet.

            if let recentCommunication = erxTask.communications.filter({ $0.profile == .dispReq })
                .compactMap(\.timestamp.date)
                .max() {
                let localizedString = uiDateFormatter.relativeTime(
                    from: recentCommunication,
                    formattingContext: .middleOfSentence
                )
                return .open(until: L10n.erxTxtSentAt(localizedString).text)
            } else {
                return .open(until: L10n.erxTxtSentAt("").text)
            }
        case .ready, .computed(status: .sent):
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
                // Use (remainingDays - 1) to obtain a 3rd cardinality distinction in the stringsdict
                // (remainingDays - 1) == "zero" ---> "valid only today"
                // (remainingDays - 1) == "one" ---> "valid only until tomorrow"
                // (remainingDays - 1) == "other" ---> "valid for \(other) more days"
                return .open(until: L10n.erxTxtAcceptedUntil(remainingDays - 1).text)
            }
            if let expiresDate = erxTask.expiresOn?.date,
               let remainingDays = date.days(until: expiresDate),
               remainingDays > 0 {
                // Use (remainingDays - 1) to obtain a 3rd cardinality distinction in the stringsdict
                // (remainingDays - 1) == "zero" ---> "valid only today"
                // (remainingDays - 1) == "one" ---> "valid only until tomorrow"
                // (remainingDays - 1) == "other" ---> "valid for \(other) more days"
                return .open(until: L10n.erxTxtExpiresIn(remainingDays - 1).text)
            }

            let formattedDate = ((erxTask.expiresOn as String?).map { uiDateFormatter.date($0) ?? "?" }) ?? "?"

            return .archived(message: L10n.erxTxtExpiredOn(formattedDate).text)

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
        if let name = erxTask.medication?.displayName {
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
        case .archived: return true
        case .open,
             .redeem,
             .undefined,
             .error:
            return false
        }
    }

    var isRedeemable: Bool {
        // [REQ:gemSpec_FD_eRp:A_21360] no redeem informations available for flowtype 169
        guard type != .directAssignment
        else { return false }

        if type == .multiplePrescription {
            if let mvo = erxTask.medicationRequest.multiplePrescription {
                if mvo.isRedeemable == false {
                    return false
                }
            }
        }

        switch (erxTask.status, viewStatus) {
        case (_, .archived),
             (_, .redeem): return false
        case (.ready, _): return true
        case (.draft, _),
             (.inProgress, _),
             (.cancelled, _),
             (.completed, _),
             (.computed(.sent), _),
             (.computed(.waiting), _),
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

    var isDeletable: Bool {
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

    var statusTitle: String {
        guard type != .directAssignment else {
            switch viewStatus {
            case .open, .redeem, .undefined, .error:
                return L10n.prscStatusDirectAssigned.text
            case .archived:
                return L10n.prscStatusCompleted.text
            }
        }

        switch (erxTask.status, viewStatus) {
        case (.ready, .redeem): return L10n.prscStatusMultiplePrsc.text
        case (.ready, .archived): return L10n.erxTxtInvalid.text
        case (.ready, _): return L10n.prscStatusReady.text
        case (.inProgress, .archived): return L10n.erxTxtInvalid.text
        case (.inProgress, _): return L10n.prscStatusInProgress.text
        case (.completed, _): return L10n.prscStatusCompleted.text
        case (.cancelled, _): return L10n.prscStatusCanceled.text
        case (.computed(.sent), _): return L10n.prscStatusSent.text
        case (.computed(.waiting), _): return L10n.prscStatusWaiting.text
        case (.draft, _),
             (.undefined, _): return L10n.prscStatusUndefined.text
        case (.error, _): return L10n.prscStatusError.text
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
        case (.inProgress, .archived): return Image(systemName: SFSymbolName.clockWarning)
        case (.inProgress, _): return nil
        case (.computed(.sent), _): return Image(asset: Asset.Prescriptions.checkmarkDouble)
        case (.computed(.waiting), _): return nil
        case (.completed, _): return Image(asset: Asset.Prescriptions.checkmarkDouble)
        case (.cancelled, _): return Image(systemName: SFSymbolName.cross)
        case (.draft, _),
             (.undefined, _): return Image(systemName: SFSymbolName.calendarWarning)
        case (.error, _): return Image(systemName: SFSymbolName.exclamationMark)
        }
    }

    var isLoading: Bool {
        switch (erxTask.status, viewStatus) {
        case (.computed(.waiting), _): return true
        default: return false
        }
    }

    var titleTint: Color {
        guard type != .directAssignment
        else { return Colors.systemGray }

        switch (erxTask.status, viewStatus) {
        case (.draft, _),
             (.undefined, _),
             (.completed, _),
             (.computed(.sent), _),
             (.computed(.waiting), _),
             (.inProgress, .archived),
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
             (.computed(.waiting), _),
             (.computed(.sent), _),
             (.inProgress, .archived),
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
             (.computed(.sent), _),
             (.computed(.waiting), _),
             (.inProgress, .archived),
             (.ready, .archived): return Colors.secondary
        case (.ready, .redeem),
             (.inProgress, _): return Colors.yellow200
        case (.ready, _): return Colors.primary100
        case (.cancelled, _): return Colors.red100
        case (.error, _): return Colors.red100
        }
    }
}

extension Prescription: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(erxTask.identifier)
    }
}

extension Prescription {
    enum Dummies {
        static let prescriptionReady = Prescription(erxTask: ErxTask.Demo.erxTaskReady,
                                                    dateFormatter: UIDateFormatter.previewValue)
        static let prescriptionRedeemed = Prescription(erxTask: ErxTask.Demo.erxTaskRedeemed,
                                                       dateFormatter: UIDateFormatter.previewValue)
        static let prescriptionDirectAssignment = Prescription(erxTask: ErxTask.Demo.erxTaskDirectAssignment,
                                                               dateFormatter: UIDateFormatter.previewValue)
        static let prescriptionError = Prescription(erxTask: ErxTask.Demo.erxTaskError,
                                                    dateFormatter: UIDateFormatter.previewValue)
        static let scanned = Prescription(erxTask: ErxTask.Demo.erxTaskScanned1,
                                          dateFormatter: UIDateFormatter.previewValue)
        static let prescriptions = ErxTask.Demo.erxTasks.map {
            Prescription(erxTask: $0, dateFormatter: UIDateFormatter.previewValue)
        }

        static let prescriptionsScanned = ErxTask.Demo.erxTasksScanned
            .map { Prescription(erxTask: $0, dateFormatter: UIDateFormatter.previewValue) }
        static let prescriptionMVO = Prescription(erxTask: ErxTask.Demo.erxTask14,
                                                  dateFormatter: UIDateFormatter.previewValue)
        static let prescriptionSelfPayer = Prescription(erxTask: ErxTask.Demo.erxTaskSelfPayer,
                                                        dateFormatter: UIDateFormatter.previewValue)
    }
}
