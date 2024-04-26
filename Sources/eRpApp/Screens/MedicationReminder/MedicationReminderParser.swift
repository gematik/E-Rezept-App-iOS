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

import Dependencies
import eRpKit
import Foundation
import IdentifiedCollections

struct MedicationReminderParser {
    var parse: @Sendable (ErxTask) -> MedicationSchedule
}

extension MedicationReminderParser: DependencyKey {
    static var liveValue: MedicationReminderParser = .live

    static var testValue: MedicationReminderParser = unimplemented()
}

extension MedicationReminderParser {
    static let live = MedicationReminderParser { erxTask in
        @Dependency(\.date) var date

        let title = erxTask.medication?.name
            ?? L10n.medReminderTxtParserMedicationSchedulePlaceholderTitle.text

        let dosageForm = erxTask.medication?.localizedDosageForm
            ?? erxTask.medication?.amount?.numerator.unit
            ?? L10n.medReminderTxtParserMedicationSchedulePlaceholderAmount.text

        let dosageInstructions: String = {
            erxTask.medicationRequest.dosageInstructions ?? L10n.prscFdTxtNa.text
        }()

        let medicationScheduleEntries: IdentifiedArrayOf<MedicationSchedule.Entry> = {
            if let dosageInstructions = erxTask.medicationRequest.dosageInstructions {
                let instructions = parseFromDosageInstructions(dosageInstructions)
                let entries = instructions.map { instruction in
                    MedicationSchedule.Entry(
                        title: title,
                        hourComponent: instruction.time.hourComponent,
                        minuteComponent: instruction.time.minuteComponent,
                        dosageForm: dosageForm,
                        amount: instruction.amount
                    )
                }
                return IdentifiedArray(uniqueElements: entries)
            }
            // else may can gain some insight from the medication.amount?
            return []
        }()

        let medicationSchedule = MedicationSchedule(
            start: date.now,
            end: Date.distantFuture,
            title: title,
            dosageInstructions: dosageInstructions,
            taskId: erxTask.identifier,
            isActive: false,
            entries: medicationScheduleEntries
        )
        return medicationSchedule
    }

    // Transform strings like "1-0-0" or "1-0-0-0" or "1 x morgens" into an Instruction
    static func parseFromDosageInstructions(_ dosageInstructions: String) -> [Instruction] {
        if #available(iOS 16.0, *) {
            // swiftlint:disable all
            // swiftformat:disable all
            let abcRegex  = /^[\s<>]*\(?(?<morning>\d*(\s*[\.,]?\s*½)?([.,]\d+)?)\s*-\s*(?<noon>\d*(\s*[\.,]?\s*½)?([.,]\d+)?)\s*-\s*(?<evening>\d*(\s*[\.,]?\s*½)?([.,]\d+)?)\)?[\s<>]*$/
            let abcdRegex = /^[\s<>]*\(?(?<morning>\d*(\s*[\.,]?\s*½)?([.,]\d+)?)\s*-\s*(?<noon>\d*(\s*[\.,]?\s*½)?([.,]\d+)?)\s*-\s*(?<evening>\d*(\s*[\.,]?\s*½)?([.,]\d+)?)\s*-\s*(?<night>\d*(\s*[\.,]?\s*½)?([.,]\d+)?)\)?[\s<>]*$/
            // swiftformat:enable all
            // swiftlint:enable all
            if let matchResult = try? abcRegex.wholeMatch(in: dosageInstructions) {
                let morning = Instruction(amount: String(matchResult.morning), time: .morning)
                let noon = Instruction(amount: String(matchResult.noon), time: .noon)
                let evening = Instruction(amount: String(matchResult.evening), time: .evening)

                return [morning, noon, evening].filter { $0.amount != "0" && !$0.amount.isEmpty }
            } else if
                let matchResult = try? abcdRegex.wholeMatch(in: dosageInstructions) {
                let morning = Instruction(amount: String(matchResult.morning), time: .morning)
                let noon = Instruction(amount: String(matchResult.noon), time: .noon)
                let evening = Instruction(amount: String(matchResult.evening), time: .evening)
                let night = Instruction(amount: String(matchResult.night), time: .night)

                return [morning, noon, evening, night].filter { $0.amount != "0" && !$0.amount.isEmpty }
            }
            return []
        } else {
            // Fallback for older iOS versions
            return []
        }
    }

    struct Instruction: Equatable, CustomStringConvertible {
        let amount: String
        let time: Time

        var description: String {
            "\(amount) x \(time.localizedText)"
        }

        enum Time {
            // 1-0-0, 1-0-0-0
            case morning
            // 0-1-0, 0-1-0-0
            case noon
            // 0-0-1, 0-0-1-0
            case evening
            // 0-0-0-1
            case night

            var hourComponent: Int {
                switch self {
                case .morning: return 8
                case .noon: return 12
                case .evening: return 18
                case .night: return 20
                }
            }

            var localizedText: String {
                switch self {
                case .morning:
                    L10n.prscDtlTxtDosageInstructionsMorning.text
                case .noon:
                    L10n.prscDtlTxtDosageInstructionsNoon.text
                case .evening:
                    L10n.prscDtlTxtDosageInstructionsEvening.text
                case .night:
                    L10n.prscDtlTxtDosageInstructionsNight.text
                }
            }

            var minuteComponent: Int {
                0
            }
        }
    }
}

extension MedicationReminderParser {
    enum Dummies {
        static let noonAndEvening = MedicationReminderParser { _ in
            medicationScheduleNoonOnly
        }

        static let medicationScheduleNoonOnly = MedicationSchedule(
            start: Date(),
            end: Date(timeIntervalSinceNow: 60 * 60 * 24 * 28),
            title: "GemaDolor",
            dosageInstructions: "1 pill at noon and in the evening",
            taskId: "",
            isActive: true,
            entries: [
                .init(
                    hourComponent: 12,
                    minuteComponent: 0,
                    dosageForm: "Pill",
                    amount: "1.0"
                ),
            ]
        )
    }
}

extension DependencyValues {
    var medicationReminderParser: MedicationReminderParser {
        get { self[MedicationReminderParser.self] }
        set { self[MedicationReminderParser.self] = newValue }
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
