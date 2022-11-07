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

import ComposableCoreLocation
import eRpKit
import Foundation

/// Adds additional properties to the PharmacyLocation entity that are used in the view.
struct PharmacyLocationViewModel: Equatable, Hashable {
    init(
        pharmacy: PharmacyLocation,
        referenceLocation: Location? = nil,
        referenceDate: Date? = nil,
        timeOnlyFormatter: ERPDateFormatter? = nil
    ) {
        let referenceDate = referenceDate ?? Date()
        pharmacyLocation = pharmacy
        let openingHours = Self.initHoursOfOperation(
            pharmacy: pharmacy,
            referenceDate: referenceDate,
            timeOnlyFormatter: timeOnlyFormatter
        )
        self.openingHours = openingHours

        todayOpeningState = {
            let currentDay: String = Self.dayNameParseFormatter.string(from: referenceDate).lowercased()

            guard !openingHours.isEmpty else {
                // No opening hours in general -> do not display anything
                return .unknown
            }
            guard let currentDayOpeningHours = openingHours.first(where: { $0.dayOfWeek == currentDay }) else {
                // Day does not exist in Data -> display closed
                return .closed
            }
            return currentDayOpeningHours.openingState
        }()
        if let pharmacyPosition = pharmacy.position {
            distanceInKm = initDistance(pharmacyPosition: pharmacyPosition, referenceLocation: referenceLocation)
        }
    }

    var pharmacyLocation: PharmacyLocation
    var openingHours: [OpeningHoursDay] = []
    var distanceInKm: Double?

    let todayOpeningState: PharmacyOpenHoursCalculator.TodaysOpeningState

    struct OpeningHoursDay: Equatable, Hashable {
        internal init(dayOfWeek: String, entries: [PharmacyLocationViewModel.OpeningHoursDay.Timespan]) {
            self.dayOfWeek = dayOfWeek
            self.entries = entries

            // At this point dayOfWeek is of format 'EEE' in "en_US" locale
            let dayNameParseFormatter: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "EEE"
                return dateFormatter
            }()
            let localizesDisplayNameFormatter: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = .current
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter
            }()
            if let date = dayNameParseFormatter.date(from: dayOfWeek) {
                dayOfWeekLocalizedDisplayName = localizesDisplayNameFormatter.string(from: date)
                // .weekday starts with 1 being sunday, +5 % 7 to let monday be 0 and the first day
                dayOfWeekNumber = (Calendar.current.component(.weekday, from: date) + 5) % 7
            } else {
                dayOfWeekLocalizedDisplayName = dayOfWeek.uppercased()
                dayOfWeekNumber = 0
            }
        }

        let dayOfWeekNumber: Int
        let dayOfWeek: String
        let entries: [Timespan]
        var openingState: PharmacyOpenHoursCalculator.TodaysOpeningState {
            entries.compactMap { entry in
                switch entry.openingState {
                case .unknown, .closed:
                    return nil
                case .open, .willOpen, .closingSoon:
                    return entry.openingState
                }
            }.first ?? .closed // Day exists, but is not about to open today
        }

        struct Timespan: Equatable, Hashable {
            let openingState: PharmacyOpenHoursCalculator.TodaysOpeningState
            let openingTime: String?
            let closingTime: String?
        }

        let dayOfWeekLocalizedDisplayName: String
    }

    private static let defaultTimeOnlyFormatter: ERPDateFormatter = {
        let dateFormatter = DateFormatter()
        if let preferredLang = Locale.preferredLanguages.first,
           preferredLang.starts(with: "de") {
            dateFormatter.dateFormat = "HH:mm 'Uhr'"
        } else {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        return dateFormatter
    }()

    private static let dayNameParseFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE"
        return dateFormatter
    }()

    static func initHoursOfOperation(
        pharmacy: PharmacyLocation,
        referenceDate: Date,
        timeOnlyFormatter: ERPDateFormatter?
    ) -> [OpeningHoursDay] {
        let openHoursCalculator = PharmacyOpenHoursCalculator()
        let timeOnlyFormatter = timeOnlyFormatter ?? Self.defaultTimeOnlyFormatter

        let expandedDays = pharmacy.hoursOfOperation.flatMap { timeSet in
            timeSet.daysOfWeek.map { day in
                PharmacyLocation.HoursOfOperation(daysOfWeek: [day],
                                                  openingTime: timeSet.openingTime,
                                                  closingTime: timeSet.closingTime)
            }
        }
        let days = Dictionary(grouping: expandedDays) {
            // as expandedDays is used, `daysOfWeek` is always a single element Array
            $0.daysOfWeek.first
        }
        .map { day, hours -> OpeningHoursDay in
            let timespans = hours.map { hour in
                OpeningHoursDay.Timespan(
                    openingState: openHoursCalculator.determineOpeningState(
                        for: referenceDate,
                        hoursOfOperation: [hour],
                        timeOnlyFormatter: timeOnlyFormatter
                    ),
                    openingTime: hour.openTimeWithoutSeconds,
                    closingTime: hour.closeTimeWithoutSeconds
                )
            }
            return OpeningHoursDay(dayOfWeek: day ?? "", entries: timespans)
        }
        .sorted { $0.dayOfWeekNumber < $1.dayOfWeekNumber }
        return days
    }

    func initDistance(pharmacyPosition: PharmacyLocation.Position, referenceLocation: Location? = nil) -> Double? {
        if let pharmacyLat = pharmacyPosition.latitude?.doubleValue,
           let pharmacyLon = pharmacyPosition.longitude?.doubleValue {
            let pharmacyCLLocation = CLLocation(latitude: pharmacyLat, longitude: pharmacyLon)
            if let distanceInMeter = referenceLocation?.rawValue.distance(from: pharmacyCLLocation) {
                return distanceInMeter / 1000.0
            }
        }
        return nil
    }

    /// Used to show a redacted state on the pharmacy search
    static let placeholderPharmacies = (0 ... 10).map { _ in
        PharmacyLocation(
            id: .init(),
            status: .inactive,
            telematikID: .init(),
            name: String(repeating: " ", count: .random(in: 25 ... 50)),
            types: [PharmacyLocation.PharmacyType.pharm],
            address: PharmacyLocation.Address(
                street: String(repeating: " ", count: .random(in: 25 ... 50)),
                houseNumber: "  ",
                zip: "     ",
                city: String(repeating: " ", count: .random(in: 25 ... 50))
            ),
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: [String(repeating: " ", count: .random(in: 4 ... 8))],
                    openingTime: String(repeating: " ", count: .random(in: 8 ... 10)),
                    closingTime: String(repeating: " ", count: .random(in: 8 ... 10))
                ),
            ]
        )
    }
    .map {
        PharmacyLocationViewModel(pharmacy: $0)
    }
}

extension PharmacyLocation.HoursOfOperation {
    // swiftlint:disable:next todo
    // TODO: This can be removed when the ApoVZD-Server does not send seconds or when a proper DateFormatter is used.
    var openTimeWithoutSeconds: String {
        if let openTimeString = openingTime {
            return openTimeString.replacingOccurrences(
                of: "(\\d{1,2}:\\d{1,2})[:\\d]*",
                with: "$1",
                options: .regularExpression
            )
        }
        return openingTime ?? ""
    }

    var closeTimeWithoutSeconds: String {
        if let closeTimeString = closingTime {
            return closeTimeString.replacingOccurrences(
                of: "(\\d{1,2}:\\d{1,2})[:\\d]*",
                with: "$1",
                options: .regularExpression
            )
        }
        return closingTime ?? ""
    }
}

extension PharmacyLocationViewModel {
    enum Dummies {
        static let pharmacy = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            referenceDate: PharmacyLocation.Dummies.referenceDate
        )

        static let pharmacyInactive = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation.Dummies.pharmacyInactive,
            referenceDate: PharmacyLocation.Dummies.referenceDate
        )

        static let pharmacies = {
            PharmacyLocation.Dummies.pharmacies.map { pharmacy in
                PharmacyLocationViewModel(
                    pharmacy: pharmacy,
                    referenceDate: PharmacyLocation.Dummies.referenceDate
                )
            }
        }()
    }
}
