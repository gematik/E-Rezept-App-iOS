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
import IdentifiedCollections

public struct MedicationSchedule: Codable, Equatable, Identifiable, Sendable {
    public init(
        id: UUID = UUID(),
        start: Date,
        end: Date,
        title: String,
        dosageInstructions: String,
        taskId: String,
        isActive: Bool,
        weekdays: Set<Weekday> = Set(Weekday.allCases), // Default to all days
        entries: IdentifiedArrayOf<MedicationSchedule.Entry>
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.title = title
        self.dosageInstructions = dosageInstructions
        self.taskId = taskId
        self.isActive = isActive
        self.weekdays = weekdays
        self.entries = entries
    }

    public var id: UUID
    public var start: Date
    public var end: Date
    public var title: String
    public var dosageInstructions: String
    public var taskId: String
    public var isActive: Bool
    public var weekdays: Set<Weekday>
    public var entries: IdentifiedArrayOf<MedicationSchedule.Entry>

    public struct Entry: Codable, Equatable, Identifiable, Sendable {
        public init(
            id: UUID = UUID(),
            title: String = "",
            hourComponent: Int,
            minuteComponent: Int,
            dosageForm: String,
            amount: String
        ) {
            self.id = id
            self.title = title
            self.hourComponent = hourComponent
            self.minuteComponent = minuteComponent
            self.dosageForm = dosageForm
            self.amount = amount
        }

        public var id = UUID()
        public var title: String = ""
        public var hourComponent: Int
        public var minuteComponent: Int
        public var dosageForm: String
        public var amount: String
    }
}

extension MedicationSchedule.Entry: CustomStringConvertible {
    public var description: String {
        "\(hourComponent) : \(minuteComponent)"
    }
}

extension MedicationSchedule: CustomStringConvertible {
    public var description: String {
        "Medication (\(id)) \(title) \(dosageInstructions) \(entries)"
    }
}

extension MedicationSchedule {
    public enum Weekday: Int, Codable, Equatable, CaseIterable, Identifiable, Sendable {
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6
        case sunday = 7

        public var id: Int { rawValue }
    }
}

// TODOmedicationReminder: migration strategy old reminders -> new reminders
// put all weekdays to selected?
// not necessary if default is all weekdays
