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
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

final class MultiplePrescriptionExtensionTests: XCTestCase {
    override func invokeTest() {
        withDependencies { dependencies in
            dependencies.date.now = TestDate.defaultReferenceDate
        } operation: {
            super.invokeTest()
        }
    }

    func testMultiplePrescriptionStartDateTodayIsRedeemable() {
        // given
        let sut = multiplePrescription(startDate: Date.Fixtures.createFormattedDate(.today))

        // when then
        expect(sut.isRedeemable).to(beTrue())
    }

    func testMultiplePrescriptionStartDateInPastIsRedeemable() {
        // given
        let yesterday = multiplePrescription(startDate: TestDate.createFormattedDate(.yesterday))
        let nearPast = multiplePrescription(startDate: TestDate.createFormattedDate(.weekBefore))
        let past = multiplePrescription(startDate: TestDate.createFormattedDate(.ninetyTwoDaysBefore))

        // when then
        expect(yesterday.isRedeemable).to(beTrue())
        expect(nearPast.isRedeemable).to(beTrue())
        expect(past.isRedeemable).to(beTrue())
    }

    func testMultiplePrescriptionStartDateInFutureIsNotRedeemable() {
        // given
        let tomorrow = multiplePrescription(startDate: TestDate.createFormattedDate(.tomorrow))
        let nearFuture = multiplePrescription(startDate: TestDate
            .createFormattedDate(.twelveDaysAhead))
        let future = multiplePrescription(startDate: TestDate
            .createFormattedDate(.ninetyTwoDaysAhead))

        // when then
        expect(tomorrow.isRedeemable).to(beFalse())
        expect(nearFuture.isRedeemable).to(beFalse())
        expect(future.isRedeemable).to(beFalse())
    }

    private func multiplePrescription(startDate: String?) -> MultiplePrescription {
        guard let startDate = startDate else {
            XCTFail("No valid start date defined")
            return MultiplePrescription()
        }
        return MultiplePrescription(
            mark: true,
            numbering: 3,
            totalNumber: 7,
            startPeriod: startDate,
            endPeriod: "2323-01-26T15:23:21+00:00"
        )
    }
}
