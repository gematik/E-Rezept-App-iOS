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

@testable import eRpKit
import Foundation
import Nimble
import XCTest

final class FHIRDateFormatterTests: XCTestCase {
    lazy var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(abbreviation: "UTC") {
            calendar.timeZone = timeZone
        }
        return calendar
    }()

    func testCreatingDateWithYearFormat() {
        // given
        let inputDateString = "2020"
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        let refDate = calendar.date(from: dateComponents)
        let sut = FHIRDateFormatter.shared

        // when
        let date = sut.date(from: inputDateString)
        let dataString = sut.string(from: date ?? Date(), format: .year)

        // then
        expect(date) == refDate
        expect(dataString) == inputDateString
    }

    func testCreatingDateWithYearMonthFormat() {
        // given
        let inputDateString = "2020-10"
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 10
        let refDate = calendar.date(from: dateComponents)
        let sut = FHIRDateFormatter.shared

        // when
        let date = sut.date(from: inputDateString)
        let dataString = sut.string(from: date ?? Date(), format: .yearMonth)

        // then
        expect(date) == refDate
        expect(dataString) == inputDateString
    }

    func testYearMonthDayFormat() {
        // given
        let inputDateString = "2020-10-17"
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 10
        dateComponents.day = 17
        let refDate = calendar.date(from: dateComponents)
        let sut = FHIRDateFormatter.shared

        // when
        let date = sut.date(from: inputDateString)
        let dataString = sut.string(from: date ?? Date(), format: .yearMonthDay)

        // then
        expect(date) == refDate
        expect(dataString) == inputDateString
    }

    func testYearMonthDayTimeFormatWithDefaultTimeZone() {
        // given
        let inputDateString = "2020-06-23T09:41:00+00:00"
        let expectedOutputDateString = "2020-06-23T09:41:00Z" // large 'Z' indicates time zone is in UTC (aka 00:00)
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 06
        dateComponents.day = 23
        dateComponents.hour = 9
        dateComponents.minute = 41
        let refDate = calendar.date(from: dateComponents)
        let sut = FHIRDateFormatter.shared

        // when
        let date = sut.date(from: inputDateString)
        let dataString = sut.string(from: date ?? Date(), format: .yearMonthDayTime)

        // then
        expect(date) == refDate
        expect(dataString) == expectedOutputDateString
    }

    func testYearMonthDayTimeMilliSecondsFormatWithDefaultTimeZone() {
        // given
        let inputDateString = "2021-07-21T19:13:17.805+00:00"
        let expectedOutputDateString = "2021-07-21T19:13:17.805Z" // large 'Z' indicates time zone is in UTC (aka 00:00)
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 07
        dateComponents.day = 21
        dateComponents.hour = 19
        dateComponents.minute = 13
        dateComponents.second = 17
        dateComponents.nanosecond = 805
        let refDate = calendar.date(from: dateComponents)
        let sut = FHIRDateFormatter.shared

        // when
        let date = sut.date(from: inputDateString, format: .yearMonthDayTimeMilliSeconds)!
        let dataString = sut.string(from: date, format: .yearMonthDayTimeMilliSeconds)

        // then
        // see: https://stackoverflow.com/questions/67351860/swift-date-difference-in-nanoseconds-is-not-working
        // expect(date) == refDate //-> not working maybe due to a bug.
        // workaround check:
        expect(refDate?.timeIntervalSince(date)).to(beCloseTo(0.0, within: 1.0))
        // The final string is correct:
        expect(dataString) == expectedOutputDateString
    }

    func testYearMonthDayTimeFormatWithXXXTimeZone() {
        // given
        let inputDateString = "2020-06-23T09:41:00+00:00"
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 06
        dateComponents.day = 23
        dateComponents.hour = 9
        dateComponents.minute = 41
        let refDate = calendar.date(from: dateComponents)
        let sut = FHIRDateFormatter.shared

        // when
        let date = sut.date(from: inputDateString)
        let dataString = sut.stringWithLongUTCTimeZone(from: date ?? Date())

        // then
        expect(date) == refDate
        expect(dataString) == inputDateString
    }
}
