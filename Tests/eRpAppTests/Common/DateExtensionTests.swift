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

@testable import eRpFeatures
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
}
