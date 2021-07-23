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
import ComposableArchitecture
import ComposableCoreLocation
@testable import eRpApp
import eRpKit
import Nimble
import Pharmacy
import XCTest

class PharmacyOpenHoursCalculatorTests: XCTestCase {
    let openHoursCalculator = PharmacyOpenHoursCalculator()

    func testOpenNow() throws {
        // When current test-time is set to 9:00am on 17th June 2021...
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 6
        dateComponents.day = 17
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 9
        dateComponents.minute = 00
        let cal = Calendar(identifier: .gregorian)
        let currentTestDateTime = cal.date(from: dateComponents)!

        // And closing time of pharmacy is set to 10:00 am on 17th June 2021...
        dateComponents.hour = 10
        dateComponents.minute = 00
        let closingDateTime = cal.date(from: dateComponents)!
        // And test hours-of-operation are 8am to 10am for the same day...
        let hop = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "8:00:00",
                closingTime: "10:00:00"
            ),
        ]
        // then expect pharmacy be open (for another 60 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime, hoursOfOperation: hop
            )
        ).to(
            equal(
                PharmacyOpenHoursCalculator.TodaysOpeningState.open(
                    minutesTilClose: 60,
                    closingDateTime: closingDateTime
                )
            )
        )
    }

    func testClosedNow() throws {
        // When current test-time is set to 11:00am on 17th June 2021...
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 6
        dateComponents.day = 17
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 11
        dateComponents.minute = 00
        let cal = Calendar(identifier: .gregorian)
        let currentTestDateTime = cal.date(from: dateComponents)!

        // And test hours-of-operation are 8am to 10am for the same day...
        let hop = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "8:00:00",
                closingTime: "10:00:00"
            ),
        ]
        // then expect pharmacy be closed...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime, hoursOfOperation: hop
            )
        ).to(
            equal(
                PharmacyOpenHoursCalculator.TodaysOpeningState.closed
            )
        )
    }

    func testOpenAfternoon() throws {
        // When current test-time is set to 16:00 on 17th June 2021...
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 6
        dateComponents.day = 17
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 16
        dateComponents.minute = 00
        let cal = Calendar(identifier: .gregorian)
        let currentTestDateTime = cal.date(from: dateComponents)!

        // And closing time of pharmacy is set to 10:00 and again to 18:00 on 17th June 2021...
        dateComponents.hour = 18
        dateComponents.minute = 00
        let closingDateTime = cal.date(from: dateComponents)!
        // And test hours-of-operation are 8am to 10am and 15 to 18 for the same day...
        let hop = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "8:00:00",
                closingTime: "10:00:00"
            ),
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "15:00:00",
                closingTime: "18:00:00"
            ),
        ]
        // then expect pharmacy be open (for another 120 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime, hoursOfOperation: hop
            )
        ).to(
            equal(
                PharmacyOpenHoursCalculator.TodaysOpeningState.open(
                    minutesTilClose: 120,
                    closingDateTime: closingDateTime
                )
            )
        )
    }

    func testOpenSoon() throws {
        // When current test-time is set to 14:30 on 17th June 2021...
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 6
        dateComponents.day = 17
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 14
        dateComponents.minute = 30
        let cal = Calendar(identifier: .gregorian)
        let currentTestDateTime = cal.date(from: dateComponents)!

        // And pharmacy openingDateTime to 15:00 on 17th June 2021...
        dateComponents.hour = 15
        dateComponents.minute = 00
        let openingDateTime = cal.date(from: dateComponents)!
        // And test hours-of-operation are 8am to 10am and 15 to 18 for the same day...
        let hop = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "8:00:00",
                closingTime: "10:00:00"
            ),
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "15:00:00",
                closingTime: "18:00:00"
            ),
        ]
        // then expect pharmacy be open soon (in 30 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime, hoursOfOperation: hop
            )
        ).to(
            equal(
                PharmacyOpenHoursCalculator.TodaysOpeningState.willOpen(
                    minutesTilOpen: 30,
                    openingDateTime: openingDateTime
                )
            )
        )
    }

    func testOpenUnknownBecausOfEmptyHoursOfOperation() throws {
        // When current test-time is set to 14:30 on 17th June 2021...
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 6
        dateComponents.day = 17
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 14
        dateComponents.minute = 30
        let cal = Calendar(identifier: .gregorian)
        let currentTestDateTime = cal.date(from: dateComponents)!

        // And test hours-of-operation are empty
        let hop: [PharmacyLocation.HoursOfOperation] = []
        // then expect pharmacy be open soon (in 30 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime, hoursOfOperation: hop
            )
        ).to(
            equal(
                PharmacyOpenHoursCalculator.TodaysOpeningState.unknown
            )
        )
    }
}
