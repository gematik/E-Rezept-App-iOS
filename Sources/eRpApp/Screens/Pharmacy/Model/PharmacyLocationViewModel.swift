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

import ComposableCoreLocation
import Foundation
import Pharmacy

/// Adds additional properties to the PharmacyLocation entity that are used in the view.
struct PharmacyLocationViewModel: Equatable, Hashable {
    init(pharmacy: PharmacyLocation,
         referenceLocation: Location? = nil,
         referenceDate: Date? = Date()) {
        let openHoursCalculator = PharmacyOpenHoursCalculator()
        let hoursOfOperationNonNil = pharmacy.hoursOfOperation.compactMap(\.daysOfWeek.first)
        pharmacyLocation = pharmacy
        openHoursReferenceDate = referenceDate
        openingState = PharmacyOpenHoursCalculator.TodaysOpeningState.unknown
        days = initHoursOfOperation(
            pharmacy: pharmacy,
            referenceDate: referenceDate ?? Date(),
            hoursOfOperation: hoursOfOperationNonNil,
            openHoursCalculator: openHoursCalculator
        )
        if let pharmacyPosition = pharmacy.position {
            distanceInKm = initDistance(pharmacyPosition: pharmacyPosition, referenceLocation: referenceLocation)
        }
    }

    var pharmacyLocation: PharmacyLocation
    var openHoursReferenceDate: Date?
    var openingState: PharmacyOpenHoursCalculator.TodaysOpeningState
    var days: [DailyOpenHours] = []
    var distanceInKm: Double?

    var todayOpeningState: PharmacyOpenHoursCalculator.TodaysOpeningState {
        days.first { day -> Bool in
            if case .open = day.openingState {
                return true
            }
            return false
        }?.openingState ?? PharmacyOpenHoursCalculator.TodaysOpeningState.unknown
    }

    struct DailyOpenHours: Equatable, Hashable {
        let daysOfWeek: String
        let entries: [OpenCloseTimes]
        var openingState: PharmacyOpenHoursCalculator.TodaysOpeningState {
            entries.compactMap { entry in
                switch entry.openingState {
                case .unknown, .closed:
                    return nil
                case .open, .willOpen:
                    return entry.openingState
                }
            }.first ?? .closed
        }

        struct OpenCloseTimes: Equatable, Hashable {
            let openingState: PharmacyOpenHoursCalculator.TodaysOpeningState
            let openingTime: String?
            let closingTime: String?
        }
    }

    mutating func initHoursOfOperation(
        pharmacy: PharmacyLocation,
        referenceDate: Date,
        hoursOfOperation: [String],
        openHoursCalculator: PharmacyOpenHoursCalculator
    ) -> [DailyOpenHours] {
        days = Dictionary(grouping: pharmacy.hoursOfOperation) {
            $0.daysOfWeek.first
        }
        .map { day, hours -> DailyOpenHours in
            let hop = hours.map { hour in
                DailyOpenHours.OpenCloseTimes(
                    openingState: openHoursCalculator.determineOpeningState(
                        for: referenceDate,
                        hoursOfOperation: [hour]
                    ),
                    openingTime: hour.openTimeWithoutSeconds,
                    closingTime: hour.closeTimeWithoutSeconds
                )
            }
            return DailyOpenHours(daysOfWeek: day ?? "", entries: hop)
        }
        .sorted {
            hoursOfOperation.firstIndex(of: $0.daysOfWeek) ?? -1
                < hoursOfOperation.firstIndex(of: $1.daysOfWeek) ?? -1
        }
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
    .map { PharmacyLocationViewModel(pharmacy: $0) }
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
