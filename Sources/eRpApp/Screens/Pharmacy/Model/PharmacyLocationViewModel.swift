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

import ComposableCoreLocation
import Dependencies
import eRpKit
import eRpStyleKit
import Foundation
import OpenSSL
import SwiftUI
// swiftlint:disable type_body_length
/// Adds additional properties to the PharmacyLocation entity that are used in the view.
@dynamicMemberLookup
struct PharmacyLocationViewModel: Equatable, Identifiable {
    init(
        pharmacy: PharmacyLocation,
        referenceLocation: Location? = nil,
        referenceDate: Date? = nil,
        timeOnlyFormatter _: ERPDateFormatter? = nil
    ) {
        let referenceDate = referenceDate ?? Date()
        // filter out specialClosing and specialOpening that are older then the refrenceDate
        let filteredPharmacy = Self.filterSpecialHours(pharmacy: pharmacy, today: referenceDate)
        self.pharmacyLocation = filteredPharmacy

        let openingHours = Self.initHoursOfOperation(
            pharmacy: pharmacyLocation,
            referenceDate: referenceDate
        )
        self.openingHours = openingHours

        self.specialClosingHours = filteredPharmacy.specialClosingHours.compactMap { specialPeriods in
            SpecialOperationHoursPeriod(today: referenceDate, specialPeriods: specialPeriods)
        }

        self.emergencyServiceHours = filteredPharmacy.emergencyServiceHours.compactMap { openingPeriods in
            SpecialOperationHoursPeriod(today: referenceDate, specialPeriods: openingPeriods)
        }

        todayOpeningState = {
            let currentDay: String = Self.dayNameParseFormatter.string(from: referenceDate).lowercased()

            // No opening hours in general -> do not display anything
            if openingHours.isEmpty {
                return .unknown
            }
            guard let currentDayOpeningHours = openingHours.first(where: { $0.dayOfWeek == currentDay }) else {
                // Day does not exist in Data -> display closed
                return .closed
            }

            return currentDayOpeningHours.openingState
        }()
        if let pharmacyPosition = filteredPharmacy.position {
            distanceInM = initDistance(pharmacyPosition: pharmacyPosition, referenceLocation: referenceLocation)
            let distanceFormatter = MeasurementFormatter()
            distanceFormatter.locale = Locale.current
            distanceFormatter.unitStyle = .short
            distanceFormatter.unitOptions = .providedUnit
            distanceFormatter.numberFormatter.maximumFractionDigits = 1
            distanceFormatter.numberFormatter.minimumFractionDigits = 0

            if let distanceInM = distanceInM {
                if distanceInM > 100 {
                    let distanceInKM = distanceInM / 1000.0
                    if distanceInKM > 20 {
                        distanceFormatter.numberFormatter.maximumFractionDigits = 0
                    }
                    formattedDistance = distanceFormatter
                        .string(from: .init(value: distanceInM / 1000.0, unit: UnitLength.kilometers))
                } else {
                    formattedDistance = distanceFormatter
                        .string(from: .init(value: distanceInM, unit: UnitLength.meters))
                }
            }
        }
    }

    subscript<A>(dynamicMember keyPath: KeyPath<PharmacyLocation, A>) -> A {
        pharmacyLocation[keyPath: keyPath]
    }

    var id: String {
        pharmacyLocation.id
    }

    var pharmacyLocation: PharmacyLocation
    var openingHours: [OpeningHoursDay] = []
    var specialClosingHours: [SpecialOperationHoursPeriod] = []
    var emergencyServiceHours: [SpecialOperationHoursPeriod] = []
    var distanceInM: Double?
    var formattedDistance: String?

    let todayOpeningState: PharmacyOpenHoursCalculator.TodaysOpeningState

    struct SpecialOperationHoursPeriod: Equatable, Hashable {
        let imageName: EmergencyServiceImage
        let reason: String
        let displayPeriod: String
        let isActive: Bool
        let accessiblilityLabel: String

        internal init?(
            today: Date,
            specialPeriods: PharmacyLocation.SpecialOperationHours,
            calendar: Calendar = Calendar.current
        ) {
            @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter

            guard let start = specialPeriods.startDate,
                  let startString = start.dateStringWithOrWithoutHours(),
                  let startDate = fhirDateFormatter.date(from: start),
                  let end = specialPeriods.endDate,
                  let endString = end.dateStringWithOrWithoutHours(),
                  let endDate = fhirDateFormatter.date(from: end) else {
                return nil
            }

            imageName = {
                guard
                    let startThreshold = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: startDate),
                    let nextDay = calendar.date(
                        byAdding: .day,
                        value: 1,
                        to: calendar.startOfDay(for: startDate)
                    ),
                    let endThreshold = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: nextDay)
                else {
                    return .bell
                }

                return (startDate >= startThreshold && endDate <= endThreshold) ? .moon : .bell
            }()

            reason = specialPeriods.reason ?? ""

            isActive = {
                today >= startDate && today <= endDate
            }()

            let sameDay = calendar.isDate(startDate, inSameDayAs: endDate)

            accessiblilityLabel = {
                if !sameDay {
                    return """
                    \(startString),
                    \(L10n.phaDetailOpeningUntil.text)
                    \(endString)
                    """
                } else {
                    return """
                    \(startString)
                    """
                }
            }()

            displayPeriod = "\(startString)\(!sameDay ? " – " : "")\(!sameDay ? endString : "")"
        }
    }

    struct OpeningHoursDay: Equatable, Hashable {
        static let localizesDisplayNameFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter
        }()

        static var dateForDayOfWeek: [String: Date] = [:]
        static func date(from dayOfWeek: String) -> Date? {
            if let date = dateForDayOfWeek[dayOfWeek] {
                return date
            }
            let date = PharmacyLocationViewModel.dayNameParseFormatter.date(from: dayOfWeek)
            dateForDayOfWeek[dayOfWeek] = date
            return date
        }

        static var localizedDisplayNameFormatted: [Date: String] = [:]
        static func localizesDisplayNameFormatter(from date: Date) -> String {
            if let formatted = localizedDisplayNameFormatted[date] {
                return formatted
            }
            let formatted = Self.localizesDisplayNameFormatter.string(from: date)
            localizedDisplayNameFormatted[date] = formatted
            return formatted
        }

        internal init(dayOfWeek: String, entries: [PharmacyLocationViewModel.OpeningHoursDay.Timespan]) {
            self.dayOfWeek = dayOfWeek
            self.entries = entries

            if let date = Self.date(from: dayOfWeek) {
                dayOfWeekLocalizedDisplayName = Self.localizesDisplayNameFormatter(from: date)
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
                case .open, .willOpen, .closingSoon, .closingButOpenLaterToday:
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

    private static let dayNameParseFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE"
        return dateFormatter
    }()

    static func initHoursOfOperation(
        pharmacy: PharmacyLocation,
        referenceDate: Date
    ) -> [OpeningHoursDay] {
        let openHoursCalculator = PharmacyOpenHoursCalculator()

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
                        specialClosings: pharmacy.specialClosingHours,
                        emergencyServiceHours: pharmacy.emergencyServiceHours
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
                return round(distanceInMeter)
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

    /// FHIR return old entries of specialClosingHours and emergencyServiceHours and we need to filter them
    static func filterSpecialHours(pharmacy: PharmacyLocation, today: Date) -> PharmacyLocation {
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
        var copy = pharmacy

        copy.specialClosingHours = copy.specialClosingHours
            .filter {
                guard let end = $0.endDate,
                      let endDate = fhirDateFormatter.date(from: end) else { return false }
                return endDate >= today
            }

        copy.emergencyServiceHours = copy.emergencyServiceHours
            .filter {
                guard let end = $0.endDate,
                      let endDate = fhirDateFormatter.date(from: end) else { return false }
                return endDate >= today
            }

        return copy
    }
}

// swiftlint:enable type_body_length
enum EmergencyServiceImage {
    case bell
    case moon

    var symbolName: String {
        switch self {
        case .bell: return SFSymbolName.bell
        case .moon: return SFSymbolName.moon
        }
    }

    var color: Color {
        switch self {
        case .bell: return Colors.yellow700
        case .moon: return Colors.primary600
        }
    }
}

extension String {
    func dateStringWithOrWithoutHours() -> String? {
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter
        @Dependency(\.uiDateFormatter) var uiDateFormatter
        // string with time component will have an ":"
        if !contains(":") {
            return uiDateFormatter.date(self)
        } else if let date = fhirDateFormatter.date(from: self) {
            return uiDateFormatter.compactDateAndTimeFormatter
                .string(from: date)
                .replacingOccurrences(of: " ", with: "\u{00A0}")
        }
        return nil
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

extension Array where Element == PharmacyLocationViewModel {
    func filter(by filterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption]) -> [PharmacyLocationViewModel] {
        // Filter Pharmacies that are closed
        if filterOptions.contains(.open) {
            return filter { location in
                location.todayOpeningState.isOpen
            }
        }
        return self
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
                    referenceLocation: .init(
                        altitude: 5,
                        coordinate: .init(latitude: 49.247034, longitude: 8.8668786),
                        course: 0,
                        horizontalAccuracy: 0.0,
                        speed: 0.0,
                        timestamp: Date(),
                        verticalAccuracy: 0
                    ),
                    referenceDate: PharmacyLocation.Dummies.referenceDate
                )
            }
        }()
    }
}
