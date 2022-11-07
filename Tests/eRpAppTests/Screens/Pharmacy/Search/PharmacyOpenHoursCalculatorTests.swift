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

import ComposableArchitecture
import ComposableCoreLocation
@testable import eRpApp
import eRpKit
import Nimble
import Pharmacy
import XCTest

class PharmacyOpenHoursCalculatorTests: XCTestCase {
    let openHoursCalculator = PharmacyOpenHoursCalculator()

    override func setUp() {
        super.setUp()

        mockDateFormatter = MockERPDateFormatter()
    }

    var mockDateFormatter: MockERPDateFormatter!

    func testOpenNow() throws {
        // When current test-time is set to 9:00am on 17th June 2021...
        let currentTestDateTime = testDate(9, 00)

        // And closing time of pharmacy is set to 10:00 am on 17th June 2021...
        let closingDateTime = testDate(10, 00)

        mockDateFormatter.stringFromReturnValue = "10:00 Uhr"

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
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.open(closingDateTime: "10:00 Uhr")))
        expect(self.mockDateFormatter.stringFromReceivedInvocations).to(equal([closingDateTime]))
    }

    func testClosedNow() throws {
        // When current test-time is set to 11:00am on 17th June 2021...
        let currentTestDateTime = testDate(11, 00)

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
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.closed))
    }

    func testPharmacyIsMarkedClosedOnDifferentDays() throws {
        // When current test-time is set to 11:00am on 17th June 2021...
        let currentTestDateTime = testDate(11, 00)

        // And test hours-of-operation are 8am to 10am for the same day...
        let hop = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["fri"],
                openingTime: "8:00:00",
                closingTime: "10:00:00"
            ),
        ]
        // then expect pharmacy be closed...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.closed))
    }

    func testOpenAfternoon() throws {
        // When current test-time is set to 16:00 on 17th June 2021...
        let currentTestDateTime = testDate(16, 00)

        // And closing time of pharmacy is set to 10:00 and again to 18:00 on 17th June 2021...
        let closingDateTime = testDate(18, 00)
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
        mockDateFormatter.stringFromReturnValue = "18:00 Uhr"
        // then expect pharmacy be open (for another 120 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.open(closingDateTime: "18:00 Uhr")))
        expect(self.mockDateFormatter.stringFromReceivedInvocations).to(equal([closingDateTime]))
    }

    private func testDate(_ hour: Int, _ minutes: Int = 0) -> Date {
        let dateComponents = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: .current,
            year: 2021,
            month: 6,
            day: 17,
            hour: hour,
            minute: minutes
        )

        return dateComponents.date!
    }

    func testOpenAfternoonMultipleDays() throws {
        // When current test-time is set to 16:00 on 17th June 2021...
        let currentTestDateTime = testDate(16, 00)

        // And closing time of pharmacy is set to 10:00 and again to 18:00 on 17th June 2021...
        let closingDateTime = testDate(18, 00)
        // And test hours-of-operation are 8am to 10am and 15 to 18 for the same day...
        let hop = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["mon", "thu"],
                openingTime: "8:00:00",
                closingTime: "10:00:00"
            ),
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["mon", "thu"],
                openingTime: "15:00:00",
                closingTime: "18:00:00"
            ),
        ]
        mockDateFormatter.stringFromReturnValue = "18:00 Uhr"
        // then expect pharmacy be open (for another 120 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.open(closingDateTime: "18:00 Uhr")))
        expect(self.mockDateFormatter.stringFromReceivedInvocations).to(equal([closingDateTime]))
    }

    func testOpenAfternoonUnequalHoursMultipleDays() throws {
        // When current test-time is set to 16:00 on 17th June 2021...
        let currentTestDateTime = testDate(16, 00)

        // And closing time of pharmacy is set to 10:00 and again to 18:00 on 17th June 2021...
        let closingDateTime = testDate(18, 00)
        // And test hours-of-operation are 8am to 10am and 15 to 18 for the same day...
        let hop = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "8:00:00",
                closingTime: "10:00:00"
            ),
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["mon", "thu"],
                openingTime: "15:00:00",
                closingTime: "18:00:00"
            ),
        ]
        mockDateFormatter.stringFromReturnValue = "18:00 Uhr"
        // then expect pharmacy be open (for another 120 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.open(closingDateTime: "18:00 Uhr")))
        expect(self.mockDateFormatter.stringFromReceivedInvocations).to(equal([closingDateTime]))
    }

    func testOpenSoon() throws {
        // When current test-time is set to 14:30 on 17th June 2021...
        let currentTestDateTime = testDate(14, 30)

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
        mockDateFormatter.stringFromReturnValue = "15:00 Uhr"
        // then expect pharmacy be open soon (in 30 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.willOpen(minutesTilOpen: 30, openingDateTime: "15:00 Uhr")))
    }

    func testOpenUnknownBecausOfEmptyHoursOfOperation() throws {
        // When current test-time is set to 14:30 on 17th June 2021...
        let currentTestDateTime = testDate(14, 30)

        // And test hours-of-operation are empty
        let hop: [PharmacyLocation.HoursOfOperation] = []
        // then expect pharmacy be open soon (in 30 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop,
                timeOnlyFormatter: self.mockDateFormatter
            )
        ).to(equal(.unknown))
    }
}
