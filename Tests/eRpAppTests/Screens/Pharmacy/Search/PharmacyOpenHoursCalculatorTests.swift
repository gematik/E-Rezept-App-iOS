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

import ComposableArchitecture
import ComposableCoreLocation
@testable import eRpFeatures
import eRpKit
import Nimble
import Pharmacy
import XCTest

class PharmacyOpenHoursCalculatorTests: XCTestCase {
    let openHoursCalculator = PharmacyOpenHoursCalculator()

    override func setUp() {
        super.setUp()
    }

    func testOpenNow() throws {
        // When current test-time is set to 9:00am on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(9, 00)

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
                hoursOfOperation: hop
            )
        ).to(equal(.open(closingDateTime: "10:00 Uhr")))
    }

    func testClosedNow() throws {
        // When current test-time is set to 11:00am on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(11, 00)

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
                hoursOfOperation: hop
            )
        ).to(equal(.closed))
    }

    func testPharmacyIsMarkedClosedOnDifferentDays() throws {
        // When current test-time is set to 11:00am on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(11, 00)

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
                hoursOfOperation: hop
            )
        ).to(equal(.closed))
    }

    func testOpenAfternoon() throws {
        // When current test-time is set to 16:00 on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(16, 00)

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
                for: currentTestDateTime,
                hoursOfOperation: hop
            )
        ).to(equal(.open(closingDateTime: "18:00 Uhr")))
    }

    func testOpenAfternoonMultipleDays() throws {
        // When current test-time is set to 16:00 on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(16, 00)

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

        // then expect pharmacy be open (for another 120 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop
            )
        ).to(equal(.open(closingDateTime: "18:00 Uhr")))
    }

    func testOpenAfternoonUnequalHoursMultipleDays() throws {
        // When current test-time is set to 16:00 on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(16, 00)

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
        // then expect pharmacy be open (for another 120 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop
            )
        ).to(equal(.open(closingDateTime: "18:00 Uhr")))
    }

    func testOpenSoon() throws {
        // When current test-time is set to 14:30 on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(14, 30)

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
                for: currentTestDateTime,
                hoursOfOperation: hop
            )
        ).to(equal(.willOpen(minutesTilOpen: 30, openingDateTime: "15:00 Uhr")))
    }

    func testOpenUnknownBecausOfEmptyHoursOfOperation() throws {
        // When current test-time is set to 14:30 on 17th June 2021...
        let currentTestDateTime = Fixtures.testDate(14, 30)

        // And test hours-of-operation are empty
        let hop: [PharmacyLocation.HoursOfOperation] = []
        // then expect pharmacy be open soon (in 30 minutes)...
        expect(
            self.openHoursCalculator.determineOpeningState(
                for: currentTestDateTime,
                hoursOfOperation: hop
            )
        ).to(equal(.unknown))
    }

    // MARK: EmergencyServiceHours

    func testEmergencyEndsBeforeOpening() throws {
        // emergency started yesterday and ends before opening
        let testDate = Fixtures.testDate(07, 30)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(00, 00),
                    endDate: Fixtures.fhirStringDate(7, 00)
                ),
            ]

            // expect emergency to end and open regular opening hours
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.willOpen(minutesTilOpen: 30, openingDateTime: "08:00 Uhr")))
        }
    }

    func testEmergencyStartsBeforeOpeningEndsAtRegularOpening() throws {
        // emergency started already and ends before during regular opening
        let testDate = Fixtures.testDate(07, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(06, 00),
                    endDate: Fixtures.fhirStringDate(08, 00)
                ),
            ]

            // expect the opening to change not closing
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "19:00 Uhr")))
        }
    }

    func testEmergencyStartsBeforeOpening() throws {
        // emergency started before and ends after regular opening hours
        let testDate = Fixtures.testDate(06, 30)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(06, 00),
                    endDate: Fixtures.fhirStringDate(23, 00)
                ),
            ]

            // expect the closing hours to change to 24
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "23:00 Uhr")))
        }
    }

    func testEmergencyStartDuringOpeningAlsoEndsDuring() throws {
        // emergency started yesterday and ends before opening
        let testDate = Fixtures.testDate(10, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(10, 00),
                    endDate: Fixtures.fhirStringDate(18, 00)
                ),
            ]

            // expect closing and opening not to change
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "19:00 Uhr")))
        }
    }

    func testEmergencyStartsDuringOpening() throws {
        // emergency started during opening and ends after regular closing
        let testDate = Fixtures.testDate(20, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(10, 00),
                    endDate: Fixtures.fhirStringDate(23, 30)
                ),
            ]

            // expect the closing hours to change to 24
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "23:30 Uhr")))
        }
    }

    func testEmergencyStartsDuringOpeningEndDuring() throws {
        // emergency started during opening and ends after regular closing
        let testDate = Fixtures.testDate(17, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(10, 00),
                    endDate: Fixtures.fhirStringDate(19, 00)
                ),
            ]

            // expect the closing hours to change to 24
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "19:00 Uhr")))
        }
    }

    func testEmergencyStartsAfterClosing() throws {
        // emergency started yesterday and ends before opening
        let testDate = Fixtures.testDate(18, 30)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(20, 00),
                    endDate: Fixtures.fhirStringDate(23, 30)
                ),
            ]

            // expect nextOpening to be 20:00 and first closing hours to change to regular 19:00
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.closingButOpenLaterToday(closingDateTime: "19:00 Uhr", openingDateTime: "20:00 Uhr")))
        }
    }

    func testEmergencyStartsSameAsRegularClosing() throws {
        // emergency started when regular closing
        let testDate = Fixtures.testDate(17, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(19, 00),
                    endDate: Fixtures.fhirStringDate(23, 30)
                ),
            ]

            // expect nextOpening to be 20:00 and first closing hours to change to regular 19:00
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "23:30 Uhr")))
        }
    }

    func testEmergencySameAsRegular() throws {
        // emergency starts same times as regular opening
        let testDate = Fixtures.testDate(18, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(08, 30),
                    endDate: Fixtures.fhirStringDate(19, 00)
                ),
            ]

            // expect no changes normal opening times
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "19:00 Uhr")))
        }
    }

    func testMultipleEmergency() throws {
        // emergency starts before regular opening
        let testDate = Fixtures.testDate(07, 45)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(01, 00),
                    endDate: Fixtures.fhirStringDate(7, 30)
                ),
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(20, 00),
                    endDate: Fixtures.fhirStringDate(23, 00)
                ),
            ]

            // expect to be already open until regular closing
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.willOpen(minutesTilOpen: 15, openingDateTime: "08:00 Uhr")))
        }

        // same test with different time
        let testDate2 = Fixtures.testDate(19, 30)
        withDependencies {
            $0.date.now = testDate2
        } operation: {
            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(01, 00),
                    endDate: Fixtures.fhirStringDate(08, 00)
                ),
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(20, 00),
                    endDate: Fixtures.fhirStringDate(23, 00)
                ),
            ]

            // expect to be will open at 20 Uhr
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate2,
                    hoursOfOperation: Fixtures.baseHours,
                    emergencyServiceHours: eop
                )
            ).to(equal(.willOpen(minutesTilOpen: 30, openingDateTime: "20:00 Uhr")))
        }
    }

    // MARK: SpecialClosingHours

    func testClosingFullyCovered() throws {
        let testDate = Fixtures.testDate(10, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            // closing whole day
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(0, 00),
                    endDate: Fixtures.fhirStringDate(24, 00)
                ),
            ]
            // closing whole day tp expect to be closed
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.closed))
        }
    }

    func testClosingEndsBeforeOpening() throws {
        // closing started yesterday and ends before opening
        let testDate = Fixtures.testDate(08, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(00, 00),
                    endDate: Fixtures.fhirStringDate(08, 00)
                ),
            ]

            // expect the pharmacy to be open with regular opening
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.open(closingDateTime: "19:00 Uhr")))
        }
    }

    func testClosingStartDuringOpeningAlsoEndsDuring() throws {
        // closing started and end during regular opening
        let testDate = Fixtures.testDate(10, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(10, 30),
                    endDate: Fixtures.fhirStringDate(11)
                ),
            ]

            // expect to be closed soon but open later
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.closingButOpenLaterToday(closingDateTime: "10:30 Uhr", openingDateTime: "11:00 Uhr")))
        }
    }

    func testClosingStartsDuringOpening() throws {
        // closing started during and ends after regular closing
        let testDate = Fixtures.testDate(10, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(11, 00),
                    endDate: Fixtures.fhirStringDate(24, 00)
                ),
            ]
            // expect the pharmacy to be closed for the day at 11
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.open(closingDateTime: "11:00 Uhr")))
        }
    }

    func testClosingStartsAfterClosing() throws {
        // closing starts after regular closing
        let testDate = Fixtures.testDate(19, 15)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(19, 30),
                    endDate: Fixtures.fhirStringDate(24, 00)
                ),
            ]
            // expect the pharmacy to be closed
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.closed))
        }
    }

    func testClosingEndsOnClosing() throws {
        // closing ends same when normal opening ends
        let testDate = Fixtures.testDate(18, 45)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(00, 30),
                    endDate: Fixtures.fhirStringDate(19, 00)
                ),
            ]
            // expect the pharmacy to be closed
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.closed))
        }
    }

    func testClosingSameAsOpening() throws {
        // closing has same time as regular opening times
        let testDate = Fixtures.testDate(12, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(07, 30),
                    endDate: Fixtures.fhirStringDate(19, 00)
                ),
            ]
            // expect the pharmacy to be closed
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.closed))
        }
    }

    func testMultipleClosing() throws {
        // emergency starts before regular opening
        let testDate = Fixtures.testDate(11, 45)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(12, 00),
                    endDate: Fixtures.fhirStringDate(13, 00)
                ),
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(16, 00),
                    endDate: Fixtures.fhirStringDate(17, 00)
                ),
            ]

            // expect to closing soon but open later again
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.closingButOpenLaterToday(closingDateTime: "12:00 Uhr", openingDateTime: "13:00 Uhr")))
        }

        // same test with different time
        let testDate2 = Fixtures.testDate(15, 45)
        withDependencies {
            $0.date.now = testDate2
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(12, 00),
                    endDate: Fixtures.fhirStringDate(13, 00)
                ),
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(16, 00),
                    endDate: Fixtures.fhirStringDate(17, 00)
                ),
            ]

            // expect to closing soon but open later again
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate2,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop
                )
            ).to(equal(.closingButOpenLaterToday(closingDateTime: "16:00 Uhr", openingDateTime: "17:00 Uhr")))
        }
    }

    // MARK: Special Cases with both SpecialClosing and EmergencyOpeningHours

    func testClosingAndEmergencySameTime() throws {
        // closing has same time as regular opening times
        let testDate = Fixtures.testDate(19, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(17, 00),
                    endDate: Fixtures.fhirStringDate(20, 00)
                ),
            ]

            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(17, 00),
                    endDate: Fixtures.fhirStringDate(20, 00)
                ),
            ]
            // expect the pharmacy to be open
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "20:00 Uhr")))
        }
    }

    func testClosingFirstAndEmergencyAfter() throws {
        // specialClosing early and then EmergencyService After
        let testDate = Fixtures.testDate(19, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(13, 00),
                    endDate: Fixtures.fhirStringDate(16, 00)
                ),
            ]

            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(17, 00),
                    endDate: Fixtures.fhirStringDate(20, 00)
                ),
            ]
            // expect the pharmacy to be closed
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "20:00 Uhr")))
        }
    }

    func testEmergencyFirstAndClosingAfter() throws {
        // emergencyService early and then specialClosing After
        let testDate = Fixtures.testDate(07, 00)
        withDependencies {
            $0.date.now = testDate
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(16, 00),
                    endDate: Fixtures.fhirStringDate(19, 00)
                ),
            ]

            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(01, 00),
                    endDate: Fixtures.fhirStringDate(08, 00)
                ),
            ]
            // expect the pharmacy to be closed
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop,
                    emergencyServiceHours: eop
                )
            ).to(equal(.open(closingDateTime: "16:00 Uhr")))
        }

        // same test different time
        let testDate2 = Fixtures.testDate(15, 30)
        withDependencies {
            $0.date.now = testDate2
        } operation: {
            let sop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(16, 00),
                    endDate: Fixtures.fhirStringDate(19, 00)
                ),
            ]

            let eop = [
                PharmacyLocation.SpecialOperationHours(
                    startDate: Fixtures.fhirStringDate(01, 00),
                    endDate: Fixtures.fhirStringDate(08, 00)
                ),
            ]
            // expect the pharmacy to be closing soon
            expect(
                self.openHoursCalculator.determineOpeningState(
                    for: testDate2,
                    hoursOfOperation: Fixtures.baseHours,
                    specialClosings: sop,
                    emergencyServiceHours: eop
                )
            ).to(equal(.closingSoon(closingDateTime: "16:00 Uhr")))
        }
    }
}

extension PharmacyOpenHoursCalculatorTests {
    enum Fixtures {
        static func fhirStringDate(month: Int = 6, day: Int = 17, _ hour: Int, _ minutes: Int = 0) -> String {
            String(format: "2021-%02d-%02dT%02d:%02d:00+02:00", month, day, hour, minutes)
        }

        static func testDate(month: Int = 6, day: Int = 17, _ hour: Int, _ minutes: Int = 0) -> Date {
            let dateComponents = DateComponents(
                calendar: Calendar(identifier: .gregorian),
                timeZone: .current,
                year: 2021,
                month: month,
                day: day,
                hour: hour,
                minute: minutes
            )
            return dateComponents.date!
        }

        static let baseHours = [
            PharmacyLocation.HoursOfOperation(
                daysOfWeek: ["thu"],
                openingTime: "08:00:00",
                closingTime: "19:00:00"
            ),
        ]
    }
}
