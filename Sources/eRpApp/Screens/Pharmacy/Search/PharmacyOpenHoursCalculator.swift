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

import Combine
import Foundation
import Pharmacy

struct PharmacyOpenHoursCalculator {
    enum TodaysOpeningState: Hashable, Equatable {
        case unknown
        case closed
        case open(minutesTilClose: Int?, closingDateTime: Date)
        case willOpen(minutesTilOpen: Int?, openingDateTime: Date)

        var isOpen: Bool {
            if case .open = self {
                return true
            }
            return false
        }
    }

    func determineOpeningState(for date: Date,
                               hoursOfOperation: [PharmacyLocation.HoursOfOperation])
    -> TodaysOpeningState {
        let timeFormatter = createTimeFormatter()

        let groupedByWeekday = Dictionary(grouping: hoursOfOperation) { $0.daysOfWeek.first }
        let todaysHoursOfOperation = groupedByWeekday[weekDayAs3CharString(from: date)]
        var result = TodaysOpeningState.unknown

        for hop in todaysHoursOfOperation ?? [] {
            if let openTimeString = hop.openingTime,
               let closeTimeString = hop.closingTime,
               let openingTime = timeFormatter.date(from: openTimeString),
               let closingTime = timeFormatter.date(from: closeTimeString),
               let openingDateTime = date.createSameDay(with: openingTime),
               let closingDateTime = date.createSameDay(with: closingTime) {
                // Is open right now?
                if date > openingDateTime, date < closingDateTime {
                    let minutesTilClose = Calendar.current.dateComponents([.minute], from: date, to: closingDateTime)
                    result = TodaysOpeningState.open(
                        minutesTilClose: minutesTilClose.minute,
                        closingDateTime: closingDateTime
                    )
                    break // when it's open do not compare any other times
                // if not open right now maybe opens later?
                } else if openingDateTime > date {
                    let minutesTilOpen = Calendar.current.dateComponents([.minute], from: date, to: openingDateTime)
                    result = TodaysOpeningState.willOpen(
                        minutesTilOpen: minutesTilOpen.minute,
                        openingDateTime: openingDateTime
                    )
                } else {
                    result = TodaysOpeningState.closed
                }
            }
        }
        return result
    }

    private func createTimeFormatter() -> DateFormatter {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        return timeFormatter
    }

    private func weekDayAs3CharString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        // weekdays from pharmacy server are always english!
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date).lowercased()
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
