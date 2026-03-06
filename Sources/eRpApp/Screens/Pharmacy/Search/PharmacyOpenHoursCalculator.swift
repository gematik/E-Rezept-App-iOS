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
import Dependencies
import eRpKit
import eRpStyleKit
import Foundation
import SwiftUI

struct PharmacyOpenHoursCalculator {
    enum TodaysOpeningState: Hashable, Equatable {
        case unknown
        case closed
        case open(closingDateTime: String)
        case closingSoon(closingDateTime: String)
        case willOpen(minutesTilOpen: Int?, openingDateTime: String)
        case closingButOpenLaterToday(closingDateTime: String, openingDateTime: String)

        var isOpen: Bool {
            switch self {
            case .open, .closingButOpenLaterToday, .closingSoon:
                true
            case .willOpen, .unknown, .closed:
                false
            }
        }

        var foregroundColor: Color {
            switch self {
            case .open:
                Colors.secondary700
            case .closingButOpenLaterToday, .closingSoon, .willOpen:
                Colors.yellow800
            case .unknown, .closed:
                Colors.systemLabelSecondary
            }
        }
    }

    static let minimumOpenMinutesLeftBeforeWarn = 30

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func determineOpeningState(for date: Date,
                               hoursOfOperation: [PharmacyLocation.HoursOfOperation],
                               specialClosings: [PharmacyLocation.SpecialOperationHours] = [],
                               emergencyServiceHours: [PharmacyLocation.SpecialOperationHours] = [])
        -> TodaysOpeningState {
        @Dependency(\.uiDateFormatter) var uiDateFormatter

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

        let emergencyClosedRange = parseClosedRange(emergencyServiceHours)

        let closingClosedRange = parseClosedRange(specialClosings)

        for hop in todaysHoursOfOperation ?? [] {
            if let openTimeString = hop.openingTime,
               let closeTimeString = hop.closingTime,
               let openingTime = timeFormatter.date(from: openTimeString),
               let closingTime = timeFormatter.date(from: closeTimeString),
               let openingDateTime = date.createSameDay(with: openingTime),
               let closingDateTime = date.createSameDay(with: closingTime) {
                var nextReopenTime: Date?

                var openInterval: ClosedRange<Date>

                if openingDateTime <= closingDateTime {
                    openInterval = openingDateTime ... closingDateTime
                } else {
                    openInterval = closingDateTime ... openingDateTime
                }

                let todayStart = Calendar.current.startOfDay(for: date)
                let endOfToday = Calendar.current
                    .date(byAdding: .init(day: 1, second: -1), to: todayStart) ?? todayStart

                // filter and min for the next or active emergencies, we only care for the first one
                let nextEmergencies: ClosedRange<Date>? = emergencyClosedRange
                    .filter { $0.lowerBound <= endOfToday && $0.upperBound > date }
                    .min { $0.lowerBound < $1.lowerBound }

                // filter and min for the next or active, we only care for the first one
                let nextClosing: ClosedRange<Date>? = closingClosedRange
                    .filter { $0.lowerBound <= endOfToday && $0.upperBound > date }
                    .min { $0.lowerBound < $1.lowerBound }

                if let nextClosing {
                    if nextClosing.lowerBound <= openInterval.lowerBound,
                       nextClosing.upperBound >= openInterval.upperBound {
                        // fully closed but could have emergencyOpening
                        if nextEmergencies == nil {
                            return .closed
                        }
                    }

                    if nextClosing.lowerBound <= openInterval.lowerBound,
                       nextClosing.upperBound < openInterval.upperBound {
                        // specialClosing starts before regular opening and ends during regular opening
                        openInterval = nextClosing.upperBound ... openInterval.upperBound
                    }

                    if nextClosing.lowerBound >= openInterval.lowerBound,
                       nextClosing.lowerBound < openInterval.upperBound {
                        // specialClosing during regular opening
                        openInterval = openInterval.lowerBound ... nextClosing.lowerBound

                        if nextClosing.upperBound < closingDateTime {
                            // specialClosing ends before regular closing
                            nextReopenTime = nextReopenTime.map { min($0, nextClosing.upperBound) } ?? nextClosing
                                .upperBound
                        }
                    }
                    // ignore cases when it starts/ends before or after regular opening
                }

                if let nextEmergencies {
                    // Emergency ends before regular opening
                    if nextEmergencies.upperBound < openInterval.lowerBound {
                        nextReopenTime = nextReopenTime.map { min($0, openInterval.lowerBound) } ?? openInterval
                            .lowerBound
                    }

                    // Emergency after current interval
                    if nextEmergencies.lowerBound > openInterval.upperBound {
                        if date >= openInterval.upperBound {
                            // is already closed and opening is now emergency opening
                            openInterval = nextEmergencies.lowerBound ... nextEmergencies.upperBound
                        } else {
                            nextReopenTime = nextReopenTime
                                .map { min($0, nextEmergencies.lowerBound) } ?? nextEmergencies
                                .lowerBound
                        }
                    }

                    // Emergency starts before
                    if nextEmergencies.lowerBound < openInterval.lowerBound {
                        openInterval = nextEmergencies.lowerBound ... openInterval.upperBound
                    }

                    // Emergency ends after current interval and nextEmergencies is not set
                    if nextEmergencies.upperBound > openInterval.upperBound, nextReopenTime == nil {
                        openInterval = openInterval.lowerBound ... nextEmergencies.upperBound
                    }
                }

                // Is open right now?
                if openInterval.contains(date) {
                    let timeSpanTillClose = Calendar.current.dateComponents(
                        [.minute],
                        from: date,
                        to: openInterval.upperBound
                    )

                    let closingString = uiDateFormatter.timeOnlyFormatter.string(from: openInterval.upperBound)

                    if let openLater = nextReopenTime,
                       let minutesTillClose = timeSpanTillClose.minute,
                       minutesTillClose <= Self.minimumOpenMinutesLeftBeforeWarn {
                        let openingString = uiDateFormatter.timeOnlyFormatter.string(from: openLater)
                        return .closingButOpenLaterToday(
                            closingDateTime: closingString,
                            openingDateTime: openingString
                        )
                    } else if let minutesTillClose = timeSpanTillClose.minute,
                              minutesTillClose <= Self.minimumOpenMinutesLeftBeforeWarn {
                        return .closingSoon(closingDateTime: closingString)
                    } else {
                        return .open(closingDateTime: closingString)
                    }

                    // if not open right now maybe opens later?
                } else if openInterval.lowerBound > date {
                    let minutesTilOpen = Calendar.current.dateComponents(
                        [.minute],
                        from: date,
                        to: openInterval.lowerBound
                    )
                    result = .willOpen(
                        minutesTilOpen: minutesTilOpen.minute,
                        openingDateTime: uiDateFormatter.timeOnlyFormatter.string(from: openInterval.lowerBound)
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

    func parseClosedRange(_ specialHours: [PharmacyLocation.SpecialOperationHours]) -> [ClosedRange<Date>] {
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter

        return specialHours.compactMap { specialHour in
            guard
                let start = specialHour.startDate,
                let end = specialHour.endDate,
                let startDate = fhirDateFormatter.date(from: start),
                let endDate = fhirDateFormatter.date(from: end)
            else { return nil }

            return startDate ... endDate
        }
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
