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

final class TimelineEntryUpdateChipsTests: XCTestCase {
    @MainActor
    func testUpdateChipText() {
        // given
        let timelineEntries: [TimelineEntry] = [
            .reply(OrderDetailDomainTests.communicationReply1Unique,
                   chipTexts: []),
            .reply(OrderDetailDomainTests.communicationReply2Unique,
                   chipTexts: []),
            .dispReq(OrderDetailDomainTests.communicationDispReq1Unique,
                     pharmacy: nil,
                     chipTexts: []),
            .dispReq(OrderDetailDomainTests.communicationDispReq2Unique,
                     pharmacy: nil,
                     chipTexts: []),
        ]

        let erxTask = [ErxTask.Fixtures.erxTask17, ErxTask.Fixtures.erxTask18]

        // when
        let result = timelineEntries.updateChipTexts(with: erxTask)

        // then
        expect(result.count).to(equal(4))
        expect(result).to(contain(
            .reply(OrderDetailDomainTests.communicationReply1Unique,
                   chipTexts: ["Vita-Tee"]),
            .reply(OrderDetailDomainTests.communicationReply2Unique,
                   chipTexts: [L10n.ordDetailTxtChipAll.text]),
            .dispReq(OrderDetailDomainTests.communicationDispReq1Unique,
                     pharmacy: nil,
                     chipTexts: [L10n.ordDetailTxtChipAll.text]),
            .dispReq(OrderDetailDomainTests.communicationDispReq2Unique,
                     pharmacy: nil,
                     chipTexts: [L10n.ordDetailTxtChipAll.text])
        ))
    }
}
