//
//  Copyright (c) 2023 gematik GmbH
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

@testable import eRpApp
import Nimble
import XCTest

final class DateExtensionTests: XCTestCase {
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    func testDaysUntilWithDateInFuture() {
        // given
        let startDate = dateFormatter.date(from: "2017-01-01")!
        let endDate = dateFormatter.date(from: "2018-01-01")!

        // when
        let sut = startDate.days(until: endDate)

        // then
        expect(sut) == 365
    }

    func testDaysUntilWithDateInPast() {
        // given
        let startDate = dateFormatter.date(from: "2018-01-01")!
        let endDate = dateFormatter.date(from: "2017-01-01")!

        // when
        let sut = startDate.days(until: endDate)

        // then
        expect(sut) == -365
    }

    func testDaysUntilWithEqualDates() {
        // given
        let startDate = dateFormatter.date(from: "2018-01-01")!
        let endDate = dateFormatter.date(from: "2018-01-01")!

        // when
        let sut = startDate.days(until: endDate)

        // then
        expect(sut) == 0
    }

    func testDaysUntilIncludingDateWithEqualDates() {
        // given
        let startDate = dateFormatter.date(from: "2018-01-01")!
        let endDate = dateFormatter.date(from: "2018-01-01")!

        // when
        let sut = startDate.daysUntil(including: endDate)

        // then
        expect(sut) == 1
    }
}
