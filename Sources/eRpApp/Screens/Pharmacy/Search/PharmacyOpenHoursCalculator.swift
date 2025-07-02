//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import eRpKit
import Foundation

struct PharmacyOpenHoursCalculator {
    enum TodaysOpeningState: Hashable, Equatable {
        case unknown
        case closed
        case open(closingDateTime: String)
        case closingSoon(closingDateTime: String)
        case willOpen(minutesTilOpen: Int?, openingDateTime: String)

        var isOpen: Bool {
            if case .open = self {
                return true
            }
            return false
        }
    }

    static let minimumOpenMinutesLeftBeforeWarn = 30

    func determineOpeningState(for date: Date,
                               hoursOfOperation: [PharmacyLocation.HoursOfOperation],
                               timeOnlyFormatter: ERPDateFormatter)
        -> TodaysOpeningState {
        let timeFormatter = createTimeFormatter()

        // Map sets of days into single elements to reliably group entries for each day
        // [(["mon", "tue"], 15:00 - 16:00)]
        // ->
        // [
        //   (["mon"], 15:00 - 16:00),
        //   (["tue"], 15:00 - 16:00)
        // ]
        let hoursOfOperation = hoursOfOperation.flatMap { hours in
            hours.daysOfWeek.map { day in
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: [day],
                    openingTime: hours.openingTime,
                    closingTime: hours.closingTime
                )
            }
        }

        let groupedByWeekday = Dictionary(grouping: hoursOfOperation) { $0.daysOfWeek.first }
        let todaysHoursOfOperation = groupedByWeekday[weekDayAs3CharString(from: date)]

        guard !hoursOfOperation.isEmpty else {
            return TodaysOpeningState.unknown
        }
        var result = TodaysOpeningState.closed

        for hop in todaysHoursOfOperation ?? [] {
            if let openTimeString = hop.openingTime,
               let closeTimeString = hop.closingTime,
               let openingTime = timeFormatter.date(from: openTimeString),
               let closingTime = timeFormatter.date(from: closeTimeString),
               let openingDateTime = date.createSameDay(with: openingTime),
               let closingDateTime = date.createSameDay(with: closingTime) {
                // Is open right now?
                if date > openingDateTime, date < closingDateTime {
                    let timeSpanTillClose = Calendar.current.dateComponents([.minute], from: date, to: closingDateTime)

                    if let minutesTillClose = timeSpanTillClose.minute,
                       minutesTillClose < Self.minimumOpenMinutesLeftBeforeWarn {
                        return TodaysOpeningState.closingSoon(
                            closingDateTime: timeOnlyFormatter.string(from: closingDateTime)
                        )
                    } else {
                        return TodaysOpeningState.open(
                            closingDateTime: timeOnlyFormatter.string(from: closingDateTime)
                        )
                    }

                    // if not open right now maybe opens later?
                } else if openingDateTime > date {
                    let minutesTilOpen = Calendar.current.dateComponents([.minute], from: date, to: openingDateTime)
                    result = TodaysOpeningState.willOpen(
                        minutesTilOpen: minutesTilOpen.minute,
                        openingDateTime: timeOnlyFormatter.string(from: openingDateTime)
                    )
                }
            }
        }
        return result
    }

    static let timeFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        return timeFormatter
    }()

    private func createTimeFormatter() -> DateFormatter {
        Self.timeFormatter
    }

    static let dateFormatter = {
        let dateFormatter = DateFormatter()
        // weekdays from pharmacy server are always english!
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE"
        return dateFormatter
    }()

    private func weekDayAs3CharString(from date: Date) -> String {
        Self.dateFormatter.string(from: date).lowercased()
    }
}

extension Date {
    /// Takes hours and minutes of the provided
    func createSameDay(with time: Date) -> Date? {
        let hours = Calendar.current.component(.hour, from: time)
        let minutes = Calendar.current.component(.minute, from: time)
        return Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: self)
    }
}
