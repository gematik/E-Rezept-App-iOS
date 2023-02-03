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

import Combine
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class MultiplePrescriptionExtensionTests: XCTestCase {
    func testMultiplePrescriptionStartDateTodayIsRedeemable() {
        // given
        let sut = multiplePrescription(startDate: DemoDate.createDemoDate(.today))

        // when then
        expect(sut.isRedeemable).to(beTrue())
    }

    func testMultiplePrescriptionStartDateInPastIsRedeemable() {
        // given
        let yesterday = multiplePrescription(startDate: DemoDate.createDemoDate(.yesterday))
        let nearPast = multiplePrescription(startDate: DemoDate.createDemoDate(.weekBefore))
        let past = multiplePrescription(startDate: DemoDate.createDemoDate(.ninetyTwoDaysBefore))

        // when then
        expect(yesterday.isRedeemable).to(beTrue())
        expect(nearPast.isRedeemable).to(beTrue())
        expect(past.isRedeemable).to(beTrue())
    }

    func testMultiplePrescriptionStartDateInFutureIsNotRedeemable() {
        // given
        let tomorrow = multiplePrescription(startDate: DemoDate.createDemoDate(.tomorrow))
        let nearFuture = multiplePrescription(startDate: DemoDate.createDemoDate(.twelveDaysAhead))
        let future = multiplePrescription(startDate: DemoDate.createDemoDate(.ninetyTwoDaysAhead))

        // when then
        expect(tomorrow.isRedeemable).to(beFalse())
        expect(nearFuture.isRedeemable).to(beFalse())
        expect(future.isRedeemable).to(beFalse())
    }

    private func multiplePrescription(startDate: String?) -> ErxTask.MultiplePrescription {
        guard let startDate = startDate else {
            XCTFail("No valid start date defined")
            return ErxTask.MultiplePrescription()
        }
        return ErxTask.MultiplePrescription(
            mark: true,
            numbering: 3,
            totalNumber: 7,
            startPeriod: startDate,
            endPeriod: "2323-01-26T15:23:21+00:00"
        )
    }
}
